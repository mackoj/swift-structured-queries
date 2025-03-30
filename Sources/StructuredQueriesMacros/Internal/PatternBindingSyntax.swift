import SwiftSyntax

extension PatternBindingSyntax {
  func annotated() -> PatternBindingSyntax {
    var annotated = with(
      \.typeAnnotation,
      typeAnnotation
        ?? initializer?.value.literalType.map {
          TypeAnnotationSyntax(
            type: $0.with(\.trailingTrivia, .space)
          )
        }
    )
    if annotated.typeAnnotation != nil {
      annotated.pattern.trailingTrivia = ""
    }
    annotated.accessorBlock = nil
    guard annotated.typeAnnotation?.type.isOptionalType == true
    else {
      return annotated.trimmed
    }

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
