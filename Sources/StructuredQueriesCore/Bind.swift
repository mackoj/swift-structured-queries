public struct Bind<Strategy: QueryBindingStrategy>: QueryBindable {
  let representable: Strategy.Representable

  public init(_ value: Strategy.Representable, as strategy: Strategy) {
    self.representable = value
  }

  public var queryBinding: QueryBinding {
    Strategy.toQueryBindable(representable).queryBinding
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
  public init(decoder: some QueryDecoder) throws {
    try self.init(
      Strategy.fromQueryBindable(decoder.decode(Strategy.RawValue.self)),
      as: Strategy()
    )
  }
}
