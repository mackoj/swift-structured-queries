import SwiftSyntax

final class SelfRewriter: SyntaxRewriter {
  let selfEquivalent: TokenSyntax

  init(selfEquivalent: TokenSyntax) {
    self.selfEquivalent = selfEquivalent
  }

  override func visit(_ token: TokenSyntax) -> TokenSyntax {
    guard token.tokenKind == .keyword(.Self)
    else { return super.visit(token) }
    return super.visit(selfEquivalent)
  }
}
