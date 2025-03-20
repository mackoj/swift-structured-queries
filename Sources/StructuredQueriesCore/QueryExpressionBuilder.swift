@resultBuilder
public enum QueryFragmentBuilder {
  public static func buildExpression<each C: QueryExpression>(
    _ expression: (repeat each C)
  ) -> [QueryFragment] {
    Array(repeat each expression)
  }

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
