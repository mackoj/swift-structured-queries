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
    var draftProperties: [String] = []
    var draftColumnsProperties: [String] = []
    var allColumns: [String] = []
    var allDraftColumns: [String] = []
    var primaryKey: (identifier: String, type: String, label: TokenSyntax?)?
    var decodings: [String] = []
    let selfRewriter = SelfRewriter(selfEquivalent: "QueryOutput")
    let memberBlock = declaration.memberBlock
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
          switch argument.label {
          case nil:
            // TODO: Require string literal
            columnNameArgument = argument.expression.trimmedDescription
          case let .some(label) where label.text == "as":
            columnStrategyArgument = argument.expression.trimmedDescription
          case let .some(label) where label.text == "primaryKey":
            let boolean = argument.expression.as(BooleanLiteralExprSyntax.self)?.literal.tokenKind
            guard boolean == .keyword(.true) else {
              isPrimaryKey = false
              break
            }
            if let primaryKey, let originalLabel = primaryKey.label {
              throw DiagnosticsError(
                diagnostics: [
                  Diagnostic(
                    node: label,
                    message: MacroExpansionErrorMessage(
                      """
                      '@Table' only supports a single primary key
                      """
                    ),
                    notes: [
                      Note(
                        node: Syntax(originalLabel),
                        position: originalLabel.position,
                        message: MacroExpansionNoteMessage(
                          """
                          Primary key already applied to '\(primaryKey.identifier)'
                          """
                        )
                      )
                    ]
                  )
                ]
              )
            }
            primaryKey = (
              identifier: identifier.text,
              type: type?.trimmedDescription ?? "_",
              label: label
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
          type: type.map { selfRewriter.rewrite($0).trimmedDescription } ?? "_",
          label: nil
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
      } else if let type {
        typeGeneric = selfRewriter.rewrite(type).trimmedDescription
        if typeGeneric == "Date" {
          throw DiagnosticsError(
            diagnostics: [
              Diagnostic(
                node: type,
                message: MacroExpansionErrorMessage(
                  """
                  'Date' column requires a bind strategy
                  """
                )
              )
            ]
          )
        } else if typeGeneric == "UUID" {
          throw DiagnosticsError(
            diagnostics: [
              Diagnostic(
                node: type,
                message: MacroExpansionErrorMessage(
                  """
                  'UUID' column requires a bind strategy
                  """
                )
              )
            ]
          )
        }
      } else {
        typeGeneric = "_"
      }
      if let value = binding.initializer?.value {
        arguments.append(", default: \(selfRewriter.rewrite(value).trimmedDescription)")
      }
      columnsProperties.append(
        """
        public let \(identifier.trimmed) = \(moduleName).Column<QueryOutput, \(typeGeneric)>(\
        \(columnName), keyPath: \\.\(name)\(arguments)\
        )
        """
      )
      allColumns.append("self.\(name)")
      if !isPrimaryKey {
        draftProperties.append("\(property.with(\.attributes, []).trimmed)")
        draftColumnsProperties.append(
        """
        public let \(identifier.trimmed) = \(moduleName).DraftColumn<QueryOutput, \(typeGeneric)>(\
        \(columnName), keyPath: \\.\(name)\(arguments)\
        )
        """
        )
        allDraftColumns.append("self.\(name)")
      }
      decodings.append("self.\(name) = try Self.columns.\(name).decode(decoder: decoder)")
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
    let draft: String
    let protocolNames: [String]
    let schemaConformance: String
    if let primaryKey {
      columnsProperties.append(
        """
        public var primaryKey: some \(moduleName).ColumnExpression<QueryOutput> & \(moduleName).QueryExpression<\(primaryKey.type)> {
        self.\(primaryKey.identifier)
        }
        """
      )
      draft = """

        public struct Draft: \(moduleName).Draft {
        \(draftProperties.joined(separator: "\n"))
        public struct Columns: \(moduleName).DraftSchema {
        public typealias QueryOutput = Draft
        \(draftColumnsProperties.joined(separator: "\n"))
        public var allColumns: [any \(moduleName).ColumnExpression<QueryOutput>] {\
        [\(allDraftColumns.joined(separator: ", "))] \
        }
        }
        public static let columns = Columns()
        }
        """
      protocolNames = [protocolName(primaryKey: false), protocolName(primaryKey: true)]
      schemaConformance = "PrimaryKeyedSchema"
    } else {
      draft = ""
      protocolNames = [protocolName(primaryKey: false)]
      schemaConformance = "Schema"
    }
    let typeName = type.trimmed
    var conformances: [String] = []
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
        }\(raw: draft)
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
