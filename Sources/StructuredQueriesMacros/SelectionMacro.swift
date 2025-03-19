import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public enum SelectionMacro {}

extension SelectionMacro: ExtensionMacro {
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
          message: MacroExpansionErrorMessage("'@Selection' can only be applied to struct types")
        )
      )
      return []
    }
    var allColumns: [(name: TokenSyntax, type: TypeSyntax?)] = []
    var decodings: [ExprSyntax] = []
    var diagnostics: [Diagnostic] = []

    let selfRewriter = SelfRewriter(
      selfEquivalent: type.as(IdentifierTypeSyntax.self)?.name ?? "QueryValue"
    )
    for member in declaration.memberBlock.members {
      guard
        let property = member.decl.as(VariableDeclSyntax.self),
        !property.isStatic,
        !property.isComputed,
        property.bindings.count == 1,
        let binding = property.bindings.first,
        let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed
      else { continue }

      var columnQueryValueType =
        (binding.typeAnnotation?.type.trimmed
        ?? binding.initializer?.value.literalType)
        .map { selfRewriter.rewrite($0).cast(TypeSyntax.self) }
      let columnQueryOutputType = columnQueryValueType

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
            var newArguments = arguments
            newArguments.remove(at: argumentIndex)
            diagnostics.append(
              Diagnostic(
                node: argument,
                message: MacroExpansionErrorMessage(
                  "'@Selection' column names are not supported"
                ),
                fixIt: .replace(
                  message: MacroExpansionFixItMessage(
                    "Remove '\(argument.trimmed)'"
                  ),
                  oldNode: Syntax(attribute),
                  newNode: Syntax(attribute.with(\.arguments, .argumentList(newArguments)))
                )
              )
            )

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
            var newArguments = arguments
            newArguments.remove(at: argumentIndex)
            diagnostics.append(
              Diagnostic(
                node: label,
                message: MacroExpansionErrorMessage(
                  "'@Selection' primary keys are not supported"
                ),
                fixIt: .replace(
                  message: MacroExpansionFixItMessage(
                    "Remove '\(argument.trimmed)'"
                  ),
                  oldNode: Syntax(attribute),
                  newNode: Syntax(attribute.with(\.arguments, .argumentList(newArguments)))
                )
              )
            )

          case let argument?:
            fatalError("Unexpected argument: \(argument)")
          }
        }
      }

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

      allColumns.append((identifier, columnQueryValueType))
      decodings.append(
        """
        self.\(identifier) = try decoder.decode(\(columnQueryValueType.map { "\($0).self" } ?? ""))
        """
      )
    }

    var conformances: [TypeSyntax] = []
    let protocolNames: [TokenSyntax] = ["QueryRepresentable"]
    let schemaConformances: [ExprSyntax] = ["\(moduleName).QueryExpression"]
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

    let initArguments =
      allColumns
      .map { "\($0): some \(moduleName).QueryExpression\($1.map { "<\($0)>" } ?? "")" }
      .joined(separator: ",\n")
    let initAssignment: [String] =
      allColumns
      .map { #"\(\#($0.name).queryFragment) AS \#($0.name.text.quoted())"# }

    let initDecoder: DeclSyntax? =
      declaration.hasMacroApplication("Table")
      ? nil
      : """

      public init(decoder: some \(moduleName).QueryDecoder) throws {
      \(decodings, separator: "\n")
      }
      """
    return [
      DeclSyntax(
        """
        \(declaration.attributes.availability)extension \(type)\
        \(conformances.isEmpty ? "" : ": \(conformances, separator: ", ")") {
        public struct Columns: \(schemaConformances, separator: ", ") {
        public typealias QueryValue = \(type.trimmed)
        public let queryFragment: \(moduleName).QueryFragment
        public init(
        \(raw: initArguments)
        ) {
        self.queryFragment = \"\"\"
        \(raw: initAssignment.joined(separator: ", "))
        \"\"\"
        }
        }\(initDecoder)
        }
        """
      )
      .cast(ExtensionDeclSyntax.self)
    ]
  }
}

extension SelectionMacro: MemberAttributeMacro {
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
      property.bindings.count == 1
    else { return [] }
    return [
      """
      @Column
      """
    ]
  }
}

extension String {
  fileprivate func quoted(_ delimiter: String = "\"") -> String {
    delimiter + replacingOccurrences(of: delimiter, with: delimiter + delimiter) + delimiter
  }
}
