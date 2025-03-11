public struct AnyQueryExpression<QueryValue>: QueryExpression {
  public let base: any QueryExpression<QueryValue>
  public var queryFragment: QueryFragment { base.queryFragment }

  public init(_ base: any QueryExpression<QueryValue>) {
    self.base = base
  }
}
