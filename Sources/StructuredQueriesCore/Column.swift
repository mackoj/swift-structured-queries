public struct Column<Root: Table, Value: QueryBindable> {
  public let keyPath: PartialKeyPath<Root> & Sendable
  public let name: String

  public init(_ name: String, keyPath: PartialKeyPath<Root> & Sendable) {
    self.keyPath = keyPath
    self.name = name
  }
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
