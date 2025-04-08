@resultBuilder
public enum QueryFragmentBuilder<Clause> {
  public static func buildBlock(_ component: [QueryFragment]) -> [QueryFragment] {
    component
  }

  public static func buildEither(first component: [QueryFragment]) -> [QueryFragment] {
    component
  }

  public static func buildEither(second component: [QueryFragment]) -> [QueryFragment] {
    component
  }

  public static func buildOptional(_ component: [QueryFragment]?) -> [QueryFragment] {
    component ?? []
  }
}

extension QueryFragmentBuilder<Bool> {
  public static func buildExpression(
    _ expression: some QueryExpression<Bool>
  ) -> [QueryFragment] {
    [expression.queryFragment]
  }
}

extension QueryFragmentBuilder<()> {
  public static func buildExpression<each C: QueryExpression>(
    _ expression: (repeat each C)
  ) -> [QueryFragment] {
    Array(repeat each expression)
  }
}
