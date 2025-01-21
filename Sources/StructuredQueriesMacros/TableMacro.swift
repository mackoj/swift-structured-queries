import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct TableMacro {
  static let protocolName = "Table"
}

extension TableMacro: MemberAttributeMacro {
  public static func expansion<D: DeclGroupSyntax, T: DeclSyntaxProtocol, C: MacroExpansionContext>(
    of node: AttributeSyntax,
    attachedTo declaration: D,
    providingAttributesFor member: T,
    in context: C
  ) throws -> [AttributeSyntax] {
    guard
      declaration.is(StructDeclSyntax.self),
      let property = member.as(VariableDeclSyntax.self),
      !property.isStatic,
      !property.isComputed,
      !property.hasMacroApplication("Column")
    else { return [] }
    return ["@Column"]
  }
}

extension TableMacro: ExtensionMacro {
  public static func expansion<D: DeclGroupSyntax, T: TypeSyntaxProtocol, C: MacroExpansionContext>(
    of node: AttributeSyntax,
    attachedTo declaration: D,
    providingExtensionsOf type: T,
    conformingTo protocols: [TypeSyntax],
    in context: C
  ) throws -> [ExtensionDeclSyntax] {
    guard let declaration = declaration.as(StructDeclSyntax.self)
    else {
      context.diagnose(
        Diagnostic(
          node: declaration.introducer,
          message: MacroExpansionErrorMessage(
            "'@Table' can only be applied to struct types"
          )
        )
      )
      return []
    }
    var conformances: [String] = []
    if let inheritanceClause = declaration.inheritanceClause {
      for type in [protocolName] {
        if !inheritanceClause.inheritedTypes
          .contains(where: { [type, type.qualified()].contains($0.type.trimmedDescription) })
        {
          conformances.append("\(moduleName).\(type)")
        }
      }
    } else {
      conformances = [protocolName.qualified()]
    }
    var columnsProperties: [String] = []
    var allColumns: [String] = []
    var decodings: [String] = []
    let selfRewriter = SelfRewriter(selfEquivalent: declaration.name.trimmed)
    let memberBlock = selfRewriter.rewrite(declaration.memberBlock).cast(MemberBlockSyntax.self)
    for member in memberBlock.members {
      guard
        let property = member.decl.as(VariableDeclSyntax.self),
        !property.isStatic,
        !property.isComputed
      else { continue }
      for binding in property.bindings {
        guard
          let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
          continue
        }
        let name = identifier.trimmedDescription
        var columnNameArgument: String?
        var columnStrategyArgument: String?
        for attribute in property.attributes {
          guard
            let attribute = attribute.as(AttributeSyntax.self),
            let attributeName = attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text,
            attributeName == "Column",
            case let .argumentList(arguments) = attribute.arguments
          else { continue }
          for argument in arguments {
            switch argument.label?.text {
            case nil:
              // TODO: Require string literal
              columnNameArgument = argument.trimmedDescription
            case "as":
              columnStrategyArgument = argument.expression.trimmedDescription
            case let argument?:
              fatalError("Unexpected argument: \(argument)")
            }
          }
          break
        }
        let typeGeneric: String
        let columnName =
          columnNameArgument ?? """
            "\(name)"
            """
        var arguments = ""
        if let columnStrategyArgument {
          typeGeneric = "_"
          arguments.append(", as: \(columnStrategyArgument)")
        } else {
          typeGeneric = (binding.typeAnnotation?.type ?? binding.initializer?.value.literalType)?
            .trimmedDescription
            ?? "_"
        }
        if let value = binding.initializer?.value {
          arguments.append(", default: \(value.trimmedDescription)")
        }
        columnsProperties.append(
          """
          public let \(name) = \(moduleName).Column<Value, \(typeGeneric)>(\
          \(columnName), keyPath: \\.\(name)\(arguments)\
          )
          """
        )
        allColumns.append(name)
        decodings.append("self.\(name) = try Self.columns.\(name).decode(decoder: decoder)")
      }
    }
    let tableName: String
    if case let .argumentList(arguments) = node.arguments,
      let expression = arguments.first?.expression
    {
      tableName = expression.trimmedDescription
    } else {
      tableName = """
        "\(declaration.name.trimmed.text.tableName())"
        """
    }
    let typeName = type.trimmed
    return [
      DeclSyntax(
        """
        \(declaration.attributes.availability)extension \(typeName)\
        \(conformances.isEmpty ? "" : ": \(raw: conformances.joined(separator: ", "))") {
        public struct Columns: \(moduleName).Schema {
        public typealias Value = \(typeName)
        \(raw: columnsProperties.joined(separator: "\n"))
        public var allColumns: [any \(moduleName).ColumnExpression<Value>] {\
        [\(raw: allColumns.joined(separator: ", "))] \
        }
        }
        public static let columns = Columns()
        public static let name = \(raw: tableName)
        public init(decoder: any \(moduleName).QueryDecoder) throws {
        \(raw: decodings.joined(separator: "\n"))
        }
        }
        """
      )
      .cast(ExtensionDeclSyntax.self)
    ]
  }
}
