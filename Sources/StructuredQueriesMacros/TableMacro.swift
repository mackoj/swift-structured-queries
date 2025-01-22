import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct TableMacro {
  static func protocolName(primaryKey: Bool) -> String {
    primaryKey ? "PrimaryKeyedTable" : "Table"
  }
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
      !property.hasMacroApplication("Column"),
      property.bindings.count == 1,
      let binding = property.bindings.first,
      let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        .trimmingBackticks()
    else { return [] }
    if identifier == "id" {
      for member in declaration.memberBlock.members {
        guard
          let property = member.decl.as(VariableDeclSyntax.self),
          !property.isStatic,
          !property.isComputed
        else { continue }
        for attribute in property.attributes {
          guard
            let attribute = attribute.as(AttributeSyntax.self),
            let attributeName = attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text,
            attributeName == "Column",
            case let .argumentList(arguments) = attribute.arguments,
            arguments.contains(
              where: {
                $0.label?.text.trimmingBackticks() == "primaryKey"
                  && $0.expression.as(BooleanLiteralExprSyntax.self)?.literal.tokenKind
                    == .keyword(.true)
              }
            )
          else { continue }
          return [
            """
            @Column("\(raw: identifier)")
            """
          ]
        }
      }
    }
    return [
      """
      @Column("\(raw: identifier)"\(raw: identifier == "id" ? ", primaryKey: true" : ""))
      """
    ]
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
    var columnsProperties: [String] = []
    var allColumns: [String] = []
    var primaryKey: (identifier: String, type: String, isImplicit: Bool)?
    var decodings: [String] = []
    let selfRewriter = SelfRewriter(selfEquivalent: declaration.name.trimmed)
    let memberBlock = selfRewriter.rewrite(declaration.memberBlock).cast(MemberBlockSyntax.self)
    for member in memberBlock.members {
      guard
        let property = member.decl.as(VariableDeclSyntax.self),
        !property.isStatic,
        !property.isComputed,
        property.bindings.count == 1,
        let binding = property.bindings.first,
        let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
      else { continue }

      let name = identifier.text.trimmingBackticks()
      let type = binding.typeAnnotation?.type ?? binding.initializer?.value.literalType
      var columnNameArgument: String?
      var columnStrategyArgument: String?
      var isPrimaryKey = name == "id"
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
            columnNameArgument = argument.expression.trimmedDescription
          case "as":
            columnStrategyArgument = argument.expression.trimmedDescription
          case "primaryKey":
            let boolean = argument.expression.as(BooleanLiteralExprSyntax.self)?.literal.tokenKind
            guard boolean == .keyword(.true) else {
              isPrimaryKey = false
              break
            }
            guard primaryKey == nil else {
              throw DiagnosticsError(
                diagnostics: [
                  Diagnostic(
                    node: argument.expression,
                    message: MacroExpansionErrorMessage(
                      """
                      '@Table' only supports a single primary key
                      """
                    )
                  )
                ]
              )
            }
            primaryKey = (
              identifier: identifier.text,
              type: type?.trimmedDescription ?? "_",
              isImplicit: false
            )
          case let argument?:
            fatalError("Unexpected argument: \(argument)")
          }
        }
        break
      }
      if isPrimaryKey {
        primaryKey = (
          identifier: identifier.text,
          type: type?.trimmedDescription ?? "_",
          isImplicit: true
        )
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
        typeGeneric = type?.trimmedDescription ?? "_"
      }
      if let value = binding.initializer?.value {
        arguments.append(", default: \(value.trimmedDescription)")
      }
      columnsProperties.append(
        """
        public let \(identifier.trimmed) = \(moduleName).Column<QueryOutput, \(typeGeneric)>(\
        \(columnName), keyPath: \\.\(name)\(arguments)\
        )
        """
      )
      allColumns.append(name)
      decodings.append("self.\(name) = try Self.columns.\(name).decode(decoder: decoder)")
    }
    let schemaConformance: String
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
    if let primaryKey {
      schemaConformance = "PrimaryKeyedSchema"
      columnsProperties.append(
        """
        public var primaryKey: some \(moduleName).ColumnExpression<QueryOutput> & \(moduleName).QueryExpression<\(primaryKey.type)> {
        self.\(primaryKey.identifier)
        }
        """
      )
    } else {
      schemaConformance = "Schema"
    }
    var conformances: [String] = []
    let protocolNames =
      primaryKey == nil
      ? [protocolName(primaryKey: false)]
      : [protocolName(primaryKey: false), protocolName(primaryKey: true)]
    if let inheritanceClause = declaration.inheritanceClause {
      for type in protocolNames {
        if !inheritanceClause.inheritedTypes
          .contains(where: { [type, type.qualified()].contains($0.type.trimmedDescription) })
        {
          conformances.append("\(moduleName).\(type)")
        }
      }
    } else {
      conformances = protocolNames.map { $0.qualified() }
    }
    return [
      DeclSyntax(
        """
        \(declaration.attributes.availability)extension \(typeName)\
        \(conformances.isEmpty ? "" : ": \(raw: conformances.joined(separator: ", "))") {
        public struct Columns: \(moduleName).\(raw: schemaConformance) {
        public typealias QueryOutput = \(typeName)
        \(raw: columnsProperties.joined(separator: "\n"))
        public var allColumns: [any \(moduleName).ColumnExpression<QueryOutput>] {\
        [\(raw: allColumns.joined(separator: ", "))] \
        }
        }
        public struct Draft {
        // TODO
        }
        public static let columns = Columns()
        public static let name = \(raw: tableName)
        public init(decoder: some \(moduleName).QueryDecoder) throws {
        \(raw: decodings.joined(separator: "\n"))
        }
        }
        """
      )
      .cast(ExtensionDeclSyntax.self)
    ]
  }
}
