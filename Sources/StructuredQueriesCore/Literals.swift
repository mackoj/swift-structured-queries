extension Bool: QueryExpression {
  public typealias Value = Self
  public var sql: String { "?" }
  public var bindings: [QueryBinding] { [.int(self ? 1 : 0)] }
}

extension Double: QueryExpression {
  public typealias Value = Self
  public var sql: String { "?" }
  public var bindings: [QueryBinding] { [.double(self)] }
}

extension Int: QueryExpression {
  public typealias Value = Self
  public var sql: String { "?" }
  public var bindings: [QueryBinding] { [.int(self)] }
}

extension String: QueryExpression {
  public typealias Value = Self
  public var sql: String { "?" }
  public var bindings: [QueryBinding] { [.text(self)] }
}

extension DefaultStringInterpolation {
  @_disfavoredOverload
  @available(
    *,
     deprecated,
     message: """
      String interpolation produces a debug description for a SQL expression. \
      Use '+' to concatenate SQL expressions, instead."
      """
  )
  public mutating func appendInterpolation(_ value: some QueryExpression) {
    self.appendInterpolation(value as Any)
  }

  @available(
    *,
     deprecated,
     message: """
      String interpolation produces a debug description for a SQL expression. \
      Use '+' to concatenate SQL expressions, instead."
      """
  )
  public mutating func appendInterpolation<T, V>(_ value: Column<T, V>) {
    self.appendInterpolation(value as Any)
  }
}

extension Optional: QueryExpression where Wrapped: QueryExpression {
  public typealias Value = Self
  public var sql: String { "?" }
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
