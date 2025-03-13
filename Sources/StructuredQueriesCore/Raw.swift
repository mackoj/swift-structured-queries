public struct SQLQueryExpression<QueryValue>: QueryExpression {
  public let queryFragment: QueryFragment
  public init(_ queryFragment: QueryFragment, as output: QueryValue.Type = QueryValue.self) {
    self.queryFragment = queryFragment
  }
}
