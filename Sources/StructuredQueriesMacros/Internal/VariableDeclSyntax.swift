import SwiftSyntax

extension VariableDeclSyntax {
  func accessorsMatching(_ predicate: (TokenKind) -> Bool) -> [AccessorDeclSyntax] {
    let accessors: [AccessorDeclListSyntax.Element] = bindings.compactMap { patternBinding in
      switch patternBinding.accessorBlock?.accessors {
      case .accessors(let accessors):
        return accessors
      default:
        return nil
      }
    }.flatMap { $0 }
    return accessors.compactMap { accessor in
      predicate(accessor.accessorSpecifier.tokenKind) ? accessor : nil
    }
  }

  func hasMacroApplication(_ name: String) -> Bool {
    for attribute in attributes {
      switch attribute {
      case .attribute(let attr):
        if attr.attributeName.tokens(viewMode: .all).map({ $0.tokenKind }) == [.identifier(name)] {
          return true
        }
      default:
        break
      }
    }
    return false
  }

  var isComputed: Bool {
    if accessorsMatching({ $0 == .keyword(.get) }).count > 0 {
      return true
    } else {
      return bindings.contains { binding in
        if case .getter = binding.accessorBlock?.accessors {
          return true
        } else {
          return false
        }
      }
    }
  }
}
