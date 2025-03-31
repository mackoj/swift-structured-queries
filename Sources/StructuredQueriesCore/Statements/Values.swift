// TODO: Do we care about keeping this?

public struct Values<QueryValue>: _SelectStatement {
  public typealias From = Never

  let values: [QueryFragment]

  public init<each Value: QueryExpression>(
    _ values: repeat each Value
  ) where QueryValue == (repeat (each Value).QueryValue) {
    self.values = Array(repeat each values)
  }

  public var query: QueryFragment {
    "SELECT \(values.joined(separator: ", "))"
  }
}
