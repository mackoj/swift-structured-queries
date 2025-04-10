/// A `SELECT` statement that selects a set of values.
///
/// Equivalent to a `VALUES` statement in SQL.
///
/// ```swift
/// Values(true, 2.3, "Hello")
/// // SELECT 1, 2.3, 'Hello'
/// // => (Bool, Double, String)
/// ```
///
/// While not particularly useful on its own it can act as a helpful starting point for recursive
/// common table expressions and other subqueries. See <doc:CommonTableExpressions> for more.
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
