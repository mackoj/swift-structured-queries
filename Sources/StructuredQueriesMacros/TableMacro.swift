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
          node: declaration,
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
          let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
          let type = binding.typeAnnotation?.type ?? binding.initializer?.value.literalType
        else { continue }
        let name = identifier.trimmedDescription
        var columnNameArgument: String?
        for attribute in property.attributes {
          guard
            let attribute = attribute.as(AttributeSyntax.self),
            let attributeName = attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text,
            attributeName == "Column",
            case let .argumentList(arguments) = attribute.arguments,
            let expression = arguments.first?.expression
          else { continue }
          columnNameArgument = expression.trimmedDescription
          break
        }
        let columnName =
          columnNameArgument ?? """
            "\(name)"
            """
        let typeName = type.trimmedDescription
        columnsProperties.append(
          """
          public let \(name) = \(moduleName).Column<Value, \(typeName)>(\(columnName))
          """
        )
        allColumns.append(name)
        decodings.append("\(name) = try decoder.decode(\(typeName).self)")
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
    return [
      DeclSyntax(
        """
        \(declaration.attributes.availability)extension \(type.trimmed)\
        \(conformances.isEmpty ? "" : ": \(raw: conformances.joined(separator: ", "))") {
        public struct Columns: \(moduleName).TableExpression {
        public typealias Value = \(declaration.name.trimmed)
        \(raw: columnsProperties.joined(separator: "\n"))
        public var allColumns: [any \(moduleName).ColumnExpression] {\
        [\(raw: allColumns.joined(separator: ", "))] \
        }
        }
        public static var columns: Columns { Columns() }
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

private let moduleName: TokenSyntax = "StructuredQueries"

extension String {
  fileprivate func qualified() -> String {
    "\(moduleName).\(self)"
  }

  fileprivate func tableName() -> String {
    lowerCamelCased().pluralized()
  }

  fileprivate func lowerCamelCased() -> String {
    var prefix = prefix(while: \.isUppercase)
    if prefix.count > 1 { prefix = prefix.dropLast() }
    return prefix.lowercased() + dropFirst(prefix.count)
  }

  fileprivate func pluralized() -> String {
    let suffix = hasSuffix("s") ? "es" : "s"
    return self + suffix
  }
}
