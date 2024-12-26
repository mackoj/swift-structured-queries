public struct Column<Root: Table, Value: QueryBindable> {
  public let _keyPath: PartialKeyPath<Root> & Sendable
  public let name: String
  public let `default`: Value?

  public init(_ name: String, keyPath: PartialKeyPath<Root> & Sendable, default: Value? = nil) {
    self._keyPath = keyPath
    self.default = `default`
    self.name = name
  }

  public var keyPath: PartialKeyPath<Root> { _keyPath }
}

extension Column: ColumnExpression {
  public var queryString: String { "\(Root.name.quoted()).\(name.quoted())" }
  public var queryBindings: [QueryBinding] { [] }
}

extension Column {
  public func decode(decoder: any QueryDecoder) throws -> Value {
    try decoder.decode(Value.self)
  }
}
