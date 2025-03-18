public protocol TableColumnExpression<Root, Value>: QueryExpression where Value == QueryValue {
  associatedtype Root: Table
  associatedtype Value: QueryRepresentable & QueryBindable

  var name: String { get }
  var keyPath: KeyPath<Root, Value.QueryOutput> { get }
}

public struct TableColumn<Root: Table, Value: QueryRepresentable & QueryBindable>:
  TableColumnExpression,
  Sendable
{
  public typealias QueryValue = Value

  public let name: String
  let _keyPath: KeyPath<Root, Value.QueryOutput> & Sendable

  public var keyPath: KeyPath<Root, Value.QueryOutput> {
    _keyPath
  }

  public init(
    _ name: String,
    keyPath: KeyPath<Root, Value.QueryOutput> & Sendable,
    default: Value.QueryOutput? = nil
  ) {
    self.name = name
    self._keyPath = keyPath
  }

  public init(
    _ name: String,
    keyPath: KeyPath<Root, Value.QueryOutput> & Sendable,
    default: Value? = nil
  ) where Value == Value.QueryOutput {
    self.name = name
    self._keyPath = keyPath
  }

  public func decode(_ decoder: some QueryDecoder) throws -> Value.QueryOutput {
    try decoder.decode(Value.self)
  }

  public var queryFragment: QueryFragment {
    "\(raw: Root.tableName.quoted()).\(raw: name.quoted())"
  }
}
