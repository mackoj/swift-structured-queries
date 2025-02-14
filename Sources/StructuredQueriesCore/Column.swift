// TODO: Rename `Root` to `Base`?
public struct Column<Root: Table, QueryOutput: QueryBindable> {
  public let _keyPath: PartialKeyPath<Root> & Sendable
  public let name: String
  public let `default`: QueryOutput?

  public init(
    _ name: String,
    keyPath: KeyPath<Root, QueryOutput> & Sendable,
    default: QueryOutput? = nil
  ) {
    self._keyPath = keyPath
    self.default = `default`
    self.name = name
  }

  public var keyPath: PartialKeyPath<Root> { _keyPath }
}

extension Column: ColumnExpression {
  public var queryFragment: QueryFragment {
    "\(raw: Root.name.quoted()).\(raw: name.quoted())"
  }

  public func encode(_ output: QueryOutput) -> QueryFragment {
    output.queryFragment
  }
}

// TODO: Move to `QueryBindable.swift`
extension QueryExpression where QueryOutput: QueryBindable {
  public func decode(decoder: some QueryDecoder) throws -> QueryOutput {
    try decoder.decode(QueryOutput.self)
  }
}
