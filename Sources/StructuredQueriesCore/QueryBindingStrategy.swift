public protocol QueryBindingStrategy<Representable>: Sendable {
  associatedtype Representable: Sendable
  associatedtype RawValue: QueryBindable
  init()
  func fromQueryBindable(_ rawValue: RawValue) throws -> Representable
  func toQueryBindable(_ representable: Representable) -> RawValue
}

extension Column {
  public init<Strategy: QueryBindingStrategy>(
    _ name: String,
    keyPath: PartialKeyPath<Root> & Sendable,
    as strategy: Strategy
  )
  where Value == Bind<Strategy> {
    self.keyPath = keyPath
    self.name = name
  }

  public func decode<Strategy: QueryBindingStrategy>(
    decoder: any QueryDecoder
  ) throws -> Strategy.Representable
  where Value == Bind<Strategy> {
    try decoder.decode(Value.self).representable
  }
}
