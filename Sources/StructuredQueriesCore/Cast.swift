extension QueryExpression {
  public func `as`<S: QueryBindingStrategy>(_ strategy: S) -> some QueryExpression<Bind<S>>
  where S.RawValue == Value {
    Cast(base: self, strategy: strategy)
  }
}

private struct Cast<
  Base: QueryExpression<Strategy.RawValue>, Strategy: QueryBindingStrategy
>: QueryExpression {
  let base: Base
  let strategy: Strategy

  typealias Value = Bind<Strategy>
  var queryString: String { base.queryString }
  var queryBindings: [QueryBinding] { base.queryBindings }
}
