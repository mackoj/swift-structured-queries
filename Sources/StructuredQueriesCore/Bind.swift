public struct Bind<Strategy: QueryBindingStrategy>: QueryBindable {
  let representable: Strategy.Representable
  let strategy: Strategy

  public init(_ value: Strategy.Representable, as strategy: Strategy) {
    self.representable = value
    self.strategy = strategy
  }

  public var queryBinding: QueryBinding {
    strategy.toQueryBindable(representable).queryBinding
  }
}

extension QueryExpression {
  public static func bind<Strategy: QueryBindingStrategy>(
    _ value: Strategy.Representable, as strategy: Strategy
  ) -> Self
  where Self == Bind<Strategy> {
    Bind(value, as: strategy)
  }
}

extension Bind: QueryDecodable {
  public init(decoder: any QueryDecoder) throws {
    let strategy = Strategy()
    try self.init(
      strategy.fromQueryBindable(decoder.decode(Strategy.RawValue.self)),
      as: strategy
    )
  }
}
