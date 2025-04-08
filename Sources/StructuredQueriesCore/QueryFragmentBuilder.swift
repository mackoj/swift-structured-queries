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

extension QueryFragmentBuilder<_OrderClause> {
  public static func buildExpression<each C: QueryExpression>(
    _ expression: (repeat each C)
  ) -> [QueryFragment] {
    Array(repeat each expression)
  }
}

extension QueryFragmentBuilder<_WhereClause> {
  public static func buildExpression(
    _ expression: some QueryExpression<Bool>
  ) -> [QueryFragment] {
    [expression.queryFragment]
  }
}

// TODO: Rename to something else?
public enum _WhereClause {}
public enum _OrderClause {}
