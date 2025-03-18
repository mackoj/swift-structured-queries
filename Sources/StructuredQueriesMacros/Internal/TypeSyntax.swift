import SwiftSyntax

extension TypeSyntax {
  var isOptionalType: Bool {
    self.is(OptionalTypeSyntax.self)
      || self.as(IdentifierTypeSyntax.self).map {
        ["Optional", "Swift.Optional"].contains($0.name.text)
      }
        ?? false
  }

  func asOptionalType() -> Self {
    guard !isOptionalType
    else { return self }
    return TypeSyntax(
      OptionalTypeSyntax(wrappedType: with(\.trailingTrivia, ""))
        .with(\.trailingTrivia, trailingTrivia)
    )
  }
}
