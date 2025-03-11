import SwiftSyntax

extension PatternBindingSyntax {
  func annotated() -> PatternBindingSyntax {
    var annotated = with(\.pattern.trailingTrivia, "")
      .with(
        \.typeAnnotation,
        typeAnnotation
          ?? initializer?.value.literalType.map {
            TypeAnnotationSyntax(
              type: $0.with(\.trailingTrivia, .space)
            )
          }
      )
    guard annotated.typeAnnotation?.type.isOptionalType == true
    else { return annotated }

    annotated.initializer =
      annotated.initializer
      ?? InitializerClauseSyntax.init(
        equal: .equalToken(leadingTrivia: " ", trailingTrivia: " "),
        value: NilLiteralExprSyntax()
      )
    return annotated
  }

  func optionalized() -> PatternBindingSyntax {
    var optionalized = annotated()
    guard let optionalType = optionalized.typeAnnotation?.type.asOptionalType()
    else { return self }
    optionalized.typeAnnotation?.type = optionalType
    return optionalized
  }
}
