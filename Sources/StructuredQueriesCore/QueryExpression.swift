public protocol QueryExpression<Value>: Sendable, Hashable {
  associatedtype Value

  var sql: String { get }

  var bindings: [QueryBinding] { get }
}

extension QueryExpression {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.sql == rhs.sql && lhs.bindings == rhs.bindings
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(sql)
    hasher.combine(bindings)
  }
}
