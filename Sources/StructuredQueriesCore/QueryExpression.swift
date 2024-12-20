public protocol QueryExpression<Value>: Sendable {
  associatedtype Value

  var sql: String { get }

  var bindings: [QueryBinding] { get }
}

extension Optional: QueryExpression where Wrapped: QueryExpression {
  public typealias Value = Self
  public var sql: String { self?.sql ?? "?" }
  public var bindings: [QueryBinding] {
    switch self {
    case let wrapped?:
      return wrapped.bindings
    case nil:
      return [.null]
    }
  }
}

extension Array: QueryExpression where Element: QueryExpression {
  public typealias Value = Self
  public var sql: String { "(\(map(\.sql).joined(separator: ", ")))" }
  public var bindings: [QueryBinding] { flatMap(\.bindings) }
}

extension ClosedRange: QueryExpression where Bound: QueryExpression {
  public typealias Value = Self
  public var sql: String { "\(lowerBound.sql) AND \(upperBound.sql)" }
  public var bindings: [QueryBinding] { lowerBound.bindings + upperBound.bindings }
}
