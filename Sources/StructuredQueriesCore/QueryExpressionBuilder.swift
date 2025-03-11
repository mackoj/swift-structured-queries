@resultBuilder
public enum AnyQueryExpressionBuilder {
  public static func buildExpression<each C: QueryExpression>(
    _ expression: (repeat each C)
  ) -> [any QueryExpression] {
    Array(repeat each expression)
  }

  public static func buildBlock(_ component: [any QueryExpression]) -> [any QueryExpression] {
    component
  }

  public static func buildEither(first component: [any QueryExpression]) -> [any QueryExpression] {
    component
  }

  public static func buildEither(second component: [any QueryExpression]) -> [any QueryExpression] {
    component
  }

  public static func buildOptional(_ component: [any QueryExpression]?) -> [any QueryExpression] {
    component ?? []
  }
}
