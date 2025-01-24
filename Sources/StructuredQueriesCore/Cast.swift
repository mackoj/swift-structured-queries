extension QueryExpression {
  public func `as`<S: QueryBindingStrategy>(_ strategy: S) -> some QueryExpression<Bind<S>>
  where S.RawValue == QueryOutput {
    Cast(base: self, strategy: strategy)
  }
}

private struct Cast<
  Base: QueryExpression<Strategy.RawValue>, Strategy: QueryBindingStrategy
>: QueryExpression {
  let base: Base
  let strategy: Strategy

  typealias QueryOutput = Bind<Strategy>
  var queryFragment: QueryFragment { base.queryFragment }
}
