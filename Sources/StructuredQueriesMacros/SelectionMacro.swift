import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum SelectionMacro {
}

extension SelectionMacro: ExtensionMacro {
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    guard let declaration = declaration.as(StructDeclSyntax.self)
    else {
      context.diagnose(
        Diagnostic(
          node: declaration.introducer,
          message: MacroExpansionErrorMessage(
            "'@Selection' can only be applied to struct types"
          )
        )
      )
      return []
    }

    var conformances: [String] = []
    if let inheritanceClause = declaration.inheritanceClause {
      for type in ["QueryDecodable"] {
        if !inheritanceClause.inheritedTypes
          .contains(where: { [type, type.qualified()].contains($0.type.trimmedDescription) })
        {
          conformances.append("\(moduleName).\(type)")
        }
      }
    } else {
      conformances = ["QueryDecodable".qualified()]
    }

    var namesAndTypes: [(String, String)] = []
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
        let typeGeneric =
          (binding.typeAnnotation?.type ?? binding.initializer?.value.literalType)?
          .trimmedDescription
          ?? "_"
        namesAndTypes.append((name, typeGeneric))
        decodings.append("self.\(name) = try decoder.decode(\(typeGeneric).self)")
      }
    }
    let initializer = """
      public init(
      \(namesAndTypes.map { "\($0): some \(moduleName).QueryExpression<\($1)>" }.joined(separator: ",\n"))
      ) {
      self.queryString = "\(namesAndTypes.map { name, _ in "\\(\(name).queryString)" }.joined(separator: ", "))"
      self.queryBindings = \(namesAndTypes.map { name, _ in "\(name).queryBindings" }.joined(separator: " + "))
      }
      """
    let typeName = type.trimmed
    return [
      DeclSyntax(
        """
        \(declaration.attributes.availability)extension \(typeName)\
        \(conformances.isEmpty ? "" : ": \(raw: conformances.joined(separator: ", "))") {
        public struct Columns: \(moduleName).QueryExpression {
        public typealias Value = \(typeName)
        public let queryString: String 
        public let queryBindings: [\(moduleName).QueryBinding]
        \(raw: initializer)
        }
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
