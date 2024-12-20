public struct AnyQueryExpression<Value>: QueryExpression {
  public let base: any QueryExpression<Value>

  public init(_ base: any QueryExpression<Value>) {
    self.base = base
  }

  public var queryString: String { base.queryString }
  public var queryBindings: [QueryBinding] { base.queryBindings }
}
