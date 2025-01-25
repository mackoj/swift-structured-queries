public protocol QueryBindingStrategy<Representable>: Sendable {
  associatedtype Representable: Sendable
  associatedtype RawValue: QueryBindable
  init()
  static func fromQueryBindable(_ rawValue: RawValue) throws -> Representable
  static func toQueryBindable(_ representable: Representable) -> RawValue
}

extension Column {
  public init<Strategy: QueryBindingStrategy>(
    _ name: String,
    keyPath: KeyPath<Root, Strategy.Representable> & Sendable,
    as strategy: Strategy,
    default: QueryOutput? = nil
  )
  where QueryOutput == Bind<Strategy> {
    self._keyPath = keyPath
    self.default = `default`
    self.name = name
  }

  public init<Strategy: QueryBindingStrategy>(
    _ name: String,
    keyPath: KeyPath<Root, Strategy.Representable?> & Sendable,
    as strategy: Strategy,
    default: QueryOutput? = nil
  )
  where QueryOutput == Bind<Strategy>? {
    self._keyPath = keyPath
    self.default = `default`
    self.name = name
  }

  public func decode<Strategy: QueryBindingStrategy>(
    decoder: any QueryDecoder
  ) throws -> Strategy.Representable
  where QueryOutput == Bind<Strategy> {
    try decoder.decode(QueryOutput.self).representable
  }

  public func decode<Strategy: QueryBindingStrategy>(
    decoder: any QueryDecoder
  ) throws -> Strategy.Representable?
  where QueryOutput == Bind<Strategy>? {
    try decoder.decode(QueryOutput.self)?.representable
  }

  public func encode<Strategy: QueryBindingStrategy>(
    _ output: Strategy.Representable
  ) -> QueryFragment
  where QueryOutput == Bind<Strategy> {
    Strategy.toQueryBindable(output).queryFragment
  }

  public func encode<Strategy: QueryBindingStrategy>(
    _ output: Strategy.Representable?
  ) -> QueryFragment
  where QueryOutput == Bind<Strategy>? {
    output.map(Strategy.toQueryBindable).queryFragment
  }
}

extension DraftColumn {
  public init<Strategy: QueryBindingStrategy>(
    _ name: String,
    keyPath: KeyPath<Root, Strategy.Representable> & Sendable,
    as strategy: Strategy,
    default: QueryOutput? = nil
  )
  where QueryOutput == Bind<Strategy> {
    self._keyPath = keyPath
    self.default = `default`
    self.name = name
  }

  public init<Strategy: QueryBindingStrategy>(
    _ name: String,
    keyPath: KeyPath<Root, Strategy.Representable?> & Sendable,
    as strategy: Strategy,
    default: QueryOutput? = nil
  )
  where QueryOutput == Bind<Strategy>? {
    self._keyPath = keyPath
    self.default = `default`
    self.name = name
  }

  public func decode<Strategy: QueryBindingStrategy>(
    decoder: any QueryDecoder
  ) throws -> Strategy.Representable
  where QueryOutput == Bind<Strategy> {
    try decoder.decode(QueryOutput.self).representable
  }

  public func decode<Strategy: QueryBindingStrategy>(
    decoder: any QueryDecoder
  ) throws -> Strategy.Representable?
  where QueryOutput == Bind<Strategy>? {
    try decoder.decode(QueryOutput.self)?.representable
  }

  public func encode<Strategy: QueryBindingStrategy>(
    _ output: Strategy.Representable
  ) -> QueryFragment
  where QueryOutput == Bind<Strategy> {
    Strategy.toQueryBindable(output).queryFragment
  }

  public func encode<Strategy: QueryBindingStrategy>(
    _ output: Strategy.Representable?
  ) -> QueryFragment
  where QueryOutput == Bind<Strategy>? {
    output.map(Strategy.toQueryBindable).queryFragment
  }
}
