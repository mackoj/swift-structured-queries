public struct AnyQueryExpression<Value>: QueryExpression {
  public let base: any QueryExpression<Value>

  public init(_ base: any QueryExpression<Value>) {
    self.base = base
  }

  public var sql: String { base.sql }
  public var bindings: [QueryBinding] { base.bindings }
}
