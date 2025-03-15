import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public enum TableMacro {}

extension TableMacro: ExtensionMacro {
  public static func expansion<D: DeclGroupSyntax, T: TypeSyntaxProtocol, C: MacroExpansionContext>(
    of node: AttributeSyntax,
    attachedTo declaration: D,
    providingExtensionsOf type: T,
    conformingTo protocols: [TypeSyntax],
    in context: C
  ) throws -> [ExtensionDeclSyntax] {
    guard
      let declaration = declaration.as(StructDeclSyntax.self)
    else {
      context.diagnose(
        Diagnostic(
          node: declaration.introducer,
          message: MacroExpansionErrorMessage("'@Table' can only be applied to struct types")
        )
      )
      return []
    }
    var allColumns: [TokenSyntax] = []
    var columnsProperties: [DeclSyntax] = []
    var decodings: [ExprSyntax] = []
    var diagnostics: [Diagnostic] = []

    // NB: A compiler bug prevents us from applying the '@_Draft' macro directly
    var draftBindings: [PatternBindingSyntax] = []
    // NB: End of workaround

    var draftProperties: [DeclSyntax] = []
    var draftTableType: TypeSyntax?
    var primaryKey: (identifier: TokenSyntax, type: TypeSyntax?, label: TokenSyntax?)?
    let selfRewriter = SelfRewriter(
      selfEquivalent: type.as(IdentifierTypeSyntax.self)?.name ?? "QueryValue"
    )
    let tableName: ExprSyntax
    if case let .argumentList(arguments) = node.arguments,
      let expression = arguments.first?.expression
    {
      if node.attributeName.identifier == "_Draft" {
        let memberAccess = expression.cast(MemberAccessExprSyntax.self)
        let base = memberAccess.base!
        draftTableType = TypeSyntax("\(base)")
        tableName = "\(base).tableName"
      } else {
        if !expression.isNonEmptyStringLiteral {
          diagnostics.append(
            Diagnostic(
              node: expression,
              message: MacroExpansionErrorMessage("Argument must be a non-empty string literal")
            )
          )
        }
        tableName = expression.trimmed
      }
    } else {
      tableName = ExprSyntax(
        StringLiteralExprSyntax(
          content: declaration.name.trimmed.text.lowerCamelCased().pluralized()
        )
      )
    }
    for member in declaration.memberBlock.members {
      guard
        let property = member.decl.as(VariableDeclSyntax.self),
        !property.isStatic,
        !property.isComputed,
        property.bindings.count == 1,
        let binding = property.bindings.first,
        let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed
      else { continue }

      var columnName = ExprSyntax(
        StringLiteralExprSyntax(content: identifier.text.trimmingBackticks())
      )
      var columnQueryValueType =
        (binding.typeAnnotation?.type.trimmed
        ?? binding.initializer?.value.literalType)
        .map { selfRewriter.rewrite($0).cast(TypeSyntax.self) }
      let columnQueryOutputType = columnQueryValueType
      var isPrimaryKey = primaryKey == nil && identifier.text == "id"

      for attribute in property.attributes {
        guard
          let attribute = attribute.as(AttributeSyntax.self),
          let attributeName = attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text,
          attributeName == "Column",
          case let .argumentList(arguments) = attribute.arguments
        else { continue }

        for argumentIndex in arguments.indices {
          let argument = arguments[argumentIndex]

          switch argument.label {
          case nil:
            if !argument.expression.isNonEmptyStringLiteral {
              diagnostics.append(
                Diagnostic(
                  node: argument.expression,
                  message: MacroExpansionErrorMessage("Argument must be a non-empty string literal")
                )
              )
            }
            columnName = argument.expression

          case let .some(label) where label.text == "as":
            guard
              let memberAccess = argument.expression.as(MemberAccessExprSyntax.self),
              memberAccess.declName.baseName.tokenKind == .keyword(.self),
              let base = memberAccess.base
            else {
              diagnostics.append(
                Diagnostic(
                  node: argument.expression,
                  message: MacroExpansionErrorMessage("Argument 'as' must be a type literal")
                )
              )
              continue
            }

            columnQueryValueType = "\(raw: base.trimmedDescription)"

          case let .some(label) where label.text == "primaryKey":
            guard
              argument.expression.as(BooleanLiteralExprSyntax.self)?.literal.tokenKind
                == .keyword(.true)
            else {
              isPrimaryKey = false
              break
            }
            if let primaryKey, let originalLabel = primaryKey.label {
              var newArguments = arguments
              newArguments.remove(at: argumentIndex)
              diagnostics.append(
                Diagnostic(
                  node: label,
                  message: MacroExpansionErrorMessage(
                    "'@Table' only supports a single primary key"
                  ),
                  notes: [
                    Note(
                      node: Syntax(originalLabel),
                      position: originalLabel.position,
                      message: MacroExpansionNoteMessage(
                        "Primary key already applied to '\(primaryKey.identifier)'"
                      )
                    )
                  ],
                  fixIt: .replace(
                    message: MacroExpansionFixItMessage("Remove 'primaryKey: true'"),
                    oldNode: Syntax(attribute),
                    newNode: Syntax(attribute.with(\.arguments, .argumentList(newArguments)))
                  )
                )
              )
            }
            primaryKey = (
              identifier: identifier,
              type: columnQueryValueType,
              label: label
            )

          case let argument?:
            fatalError("Unexpected argument: \(argument)")
          }
        }
      }

      if isPrimaryKey {
        primaryKey = (
          identifier: identifier,
          type: columnQueryValueType,
          label: nil
        )
      }

      // NB: A compiled bug prevents us from applying the '@_Draft' macro directly
      if identifier == primaryKey?.identifier {
        draftBindings.append(binding.optionalized())
      } else {
        draftBindings.append(binding)
      }
      // NB: End of workaround

      var assignedType: String? {
        binding
          .initializer?
          .value
          .as(FunctionCallExprSyntax.self)?
          .calledExpression
          .as(DeclReferenceExprSyntax.self)?
          .baseName
          .text
      }
      if columnQueryValueType == columnQueryOutputType,
        let typeIdentifier = columnQueryValueType?.identifier ?? assignedType,
        ["Date", "UUID"].contains(typeIdentifier)
      {
        var fixIts: [FixIt] = []
        let optional = columnQueryValueType?.isOptionalType == true ? "?" : ""
        if typeIdentifier.hasPrefix("Date") {
          for representation in ["ISO8601", "UnixTime", "JulianDay"] {
            var newProperty = property.with(\.leadingTrivia, "")
            let attribute = "@Column(as: Date.\(representation)Representation\(optional).self)"
            newProperty.attributes.insert(
              AttributeListSyntax.Element("\(raw: attribute)")
                .with(
                  \.trailingTrivia,
                  .newline.merging(property.leadingTrivia.indentation(isOnNewline: true))
                ),
              at: newProperty.attributes.startIndex
            )
            fixIts.append(
              FixIt(
                message: MacroExpansionFixItMessage("Insert '\(attribute)'"),
                changes: [
                  .replace(
                    oldNode: Syntax(property),
                    newNode: Syntax(newProperty.with(\.leadingTrivia, property.leadingTrivia))
                  )
                ]
              )
            )
          }
        } else if typeIdentifier.hasPrefix("UUID") {
          for representation in ["Lowercased", "Uppercased", "Bytes"] {
            var newProperty = property.with(\.leadingTrivia, "")
            let attribute = "@Column(as: UUID.\(representation)Representation\(optional).self)"
            newProperty.attributes.insert(
              AttributeListSyntax.Element("\(raw: attribute)"),
              at: newProperty.attributes.startIndex
            )
            fixIts.append(
              FixIt(
                message: MacroExpansionFixItMessage("Insert '\(attribute)'"),
                changes: [
                  .replace(
                    oldNode: Syntax(property),
                    newNode: Syntax(newProperty.with(\.leadingTrivia, property.leadingTrivia))
                  )
                ]
              )
            )
          }
        }
        diagnostics.append(
          Diagnostic(
            node: property,
            message: MacroExpansionErrorMessage(
              "'\(typeIdentifier)' column requires a query representation"
            ),
            fixIts: fixIts
          )
        )
      }

      let defaultValue = (binding.initializer?.value).map {
        ", default: \(selfRewriter.rewrite($0).trimmedDescription)"
      }
      columnsProperties.append(
        """
        public let \(identifier) = \(moduleName).Column<\
        QueryValue, \
        \(columnQueryValueType ?? "_")\
        >(\
        \(columnName), \
        keyPath: \\QueryValue.\(identifier)\(raw: defaultValue ?? "")\
        )
        """
      )
      allColumns.append(identifier)
      decodings.append(
        """
        self.\(identifier) = try decoder.decode(\(columnQueryValueType.map { "\($0).self" } ?? ""))
        """
      )
      if let primaryKey, primaryKey.identifier == identifier {
        draftProperties.append(
          """
          @Column(primaryKey: false)
          public var \(identifier): \(primaryKey.type?.asOptionalType())
          """
        )
      } else {
        draftProperties.append(
          DeclSyntax(
            property.trimmed
              .with(\.bindingSpecifier.leadingTrivia, "")
          )
        )
      }
    }

    var draft: DeclSyntax?
    var initFromOther: DeclSyntax?
    if let draftTableType {
      initFromOther = """

        public init(_ other: \(draftTableType)) {
        \(allColumns.map { "self.\($0) = other.\($0)" as ExprSyntax }, separator: "\n")
        }
        """
    } else if let primaryKey {
      columnsProperties.append(
        """
        public var primaryKey: \(moduleName).Column<QueryValue, \(primaryKey.type)> {\
        self.\(primaryKey.identifier)
        }
        """
      )
      draft = """

        @_Draft(\(type).self)
        public struct Draft {
        \(draftProperties, separator: "\n")
        }
        """

      // NB: A compiler bug prevents us from applying the '@_Draft' macro directly
      let memberBlocks = try expansion(
        of: "@_Draft(\(type).self)",
        attachedTo: StructDeclSyntax("\(draft)"),
        providingExtensionsOf: TypeSyntax("\(type).Draft"),
        conformingTo: [],
        in: context
      )
      .compactMap(\.memberBlock.members.trimmed)
      let memberwiseArguments = draftBindings.map { $0.annotated() }
      let memberwiseAssignments =
        memberwiseArguments
        .map { $0.trimmed.pattern.cast(IdentifierPatternSyntax.self).identifier }
      let memberwiseInit: DeclSyntax = """
        public init(
        \(memberwiseArguments, separator: ",\n")
        ) {
        \(memberwiseAssignments.map { "self.\($0) = \($0)" as ExprSyntax }, separator: "\n")
        }
        """
      draft = """

        public struct Draft: \(moduleName).Table {
        \(draftProperties, separator: "\n")
        \(memberBlocks, separator: "\n")
        \(memberwiseInit)
        }
        """
      // NB: End of workaround

      var otherColumns: [ExprSyntax] = []
      for column in allColumns {
        if column == primaryKey.identifier {
          otherColumns.append("\(column)")
        } else {
          otherColumns.append("other.\(column)")
        }
      }
      let initFromOtherAssignments = zip(allColumns, otherColumns)
      initFromOther = """

        public init?(_ other: Draft) {
        guard let \(primaryKey.identifier) = other.\(primaryKey.identifier) else { return nil }
        \(initFromOtherAssignments.map { "self.\($0) = \($1)" as ExprSyntax }, separator: "\n")
        }
        """
    }

    var conformances: [TypeSyntax] = []
    let protocolNames: [TokenSyntax] =
      primaryKey != nil
      ? ["Table", "PrimaryKeyedTable"]
      : ["Table"]
    let schemaConformances: [ExprSyntax] =
      primaryKey != nil
      ? ["\(moduleName).Schema", "\(moduleName).PrimaryKeyedSchema"]
      : ["\(moduleName).Schema"]
    if let inheritanceClause = declaration.inheritanceClause {
      for type in protocolNames {
        if !inheritanceClause.inheritedTypes.contains(where: {
          [type.text, "\(moduleName).\(type)"].contains($0.type.trimmedDescription)
        }) {
          conformances.append("\(moduleName).\(type)")
        }
      }
    } else {
      conformances = protocolNames.map { "\(moduleName).\($0)" }
    }

    guard diagnostics.isEmpty else {
      diagnostics.forEach(context.diagnose)
      return []
    }

    return [
      DeclSyntax(
        """
        \(declaration.attributes.availability)extension \(type)\
        \(conformances.isEmpty ? "" : ": \(conformances, separator: ", ")") {
        public struct Columns: \(schemaConformances, separator: ", ") {
        public typealias QueryValue = \(type.trimmed)
        \(columnsProperties, separator: "\n")
        public var allColumns: [any \(moduleName).ColumnExpression] { \
        [\(allColumns.map { "self.\($0)" as ExprSyntax }, separator: ", ")]
        }
        }\(draft)
        public static let columns = Columns()
        public static let tableName = \(tableName)
        public init(decoder: some \(moduleName).QueryDecoder) throws {
        \(decodings, separator: "\n")
        }\(initFromOther)
        }
        """
      )
      .cast(ExtensionDeclSyntax.self)
    ]
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
