import SwiftSyntax

final class SelfRewriter: SyntaxRewriter {
  let selfEquivalent: TokenSyntax

  init(selfEquivalent: TokenSyntax) {
    self.selfEquivalent = selfEquivalent
  }

  override func visit(_ node: IdentifierTypeSyntax) -> TypeSyntax {
    guard node.name.text == "Self"
    else { return super.visit(node) }
    return super.visit(node.with(\.name, self.selfEquivalent))
  }
}
