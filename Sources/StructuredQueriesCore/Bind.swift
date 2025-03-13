public struct BindQueryExpression<QueryValue: QueryBindable>: QueryExpression {
  public let base: QueryValue

  public init(_ queryValue: QueryValue) {
    self.base = queryValue
  }

  public var queryFragment: QueryFragment {
    base.queryFragment
  }
}
