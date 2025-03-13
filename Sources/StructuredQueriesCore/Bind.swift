public struct BindQueryExpression<QueryValue: QueryBindable>: QueryExpression {
  public let base: QueryValue

  public init(_ queryOutput: QueryValue.QueryOutput) {
    self.base = QueryValue(queryOutput: queryOutput)
  }

  public var queryFragment: QueryFragment {
    base.queryFragment
  }
}
