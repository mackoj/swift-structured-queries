import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct TableMacro {}

extension TableMacro: ExtensionMacro {
  static let protocolName = "Table"

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
    for member in declaration.memberBlock.members {
      guard
        let property = member.decl.as(VariableDeclSyntax.self),
        !property.isStatic
      else { continue }
      for binding in property.bindings {
        guard
          let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
          let type = binding.typeAnnotation?.type ?? binding.initializer?.value.literalType
        else { continue}
        let name = identifier.trimmedDescription
        let typeName = type.trimmedDescription
        columnsProperties.append(
          """
          public let \(name) = \(moduleName).Column<Value, \(typeName)>("\(name)")
          """
        )
        allColumns.append(name)
        decodings.append("\(name) = try decoder.decode(\(typeName).self)")
      }
    }
    return [
      DeclSyntax(
        """
        \(declaration.attributes.availability)extension \(type.trimmed)\
        \(conformances.isEmpty ? "" : ": \(raw: conformances.joined(separator: ", "))") {
        public struct Columns: \(moduleName).TableExpression {
        public typealias Value = \(declaration.name.trimmed)
        \(raw: columnsProperties.joined(separator: "\n"))
        public var allColumns: [any \(moduleName).ColumnExpression<Value>] {\
        [\(raw: allColumns.joined(separator: ", "))] \
        }
        }
        public static var columns: Columns { Columns() }
        public static let name = "\(raw: declaration.name.trimmed.text.tableName())"
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

private extension String {
  func qualified() -> String {
    "\(moduleName).\(self)"
  }

  func tableName() -> String {
    lowerCamelCased().pluralized()
  }

  func lowerCamelCased() -> String {
    var prefix = prefix(while: \.isUppercase)
    if prefix.count > 1 { prefix = prefix.dropLast() }
    return prefix.lowercased() + dropFirst(prefix.count)
  }

  func pluralized() -> String {
    let suffix = hasSuffix("s") ? "es" : "s"
    return self + suffix
  }
}

extension VariableDeclSyntax {
  fileprivate var isStatic: Bool {
    self.modifiers.contains { modifier in
      modifier.name.tokenKind == .keyword(.static)
    }
  }
}

extension ExprSyntax {
  fileprivate var literalType: TypeSyntax? {
    if self.is(BooleanLiteralExprSyntax.self) {
      return "Swift.Bool"
    } else if self.is(FloatLiteralExprSyntax.self) {
      return "Swift.Double"
    } else if self.is(IntegerLiteralExprSyntax.self) {
      return "Swift.Int"
    } else if self.is(StringLiteralExprSyntax.self) {
      return "Swift.String"
    } else {
      return nil
    }
  }
}
