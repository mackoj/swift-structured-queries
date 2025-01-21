public struct AnyQueryExpression<QueryOutput>: QueryExpression {
  public let base: any QueryExpression<QueryOutput>

  public init(_ base: any QueryExpression<QueryOutput>) {
    self.base = base
  }

  public var queryString: String { base.queryString }
  public var queryBindings: [QueryBinding] { base.queryBindings }
}
