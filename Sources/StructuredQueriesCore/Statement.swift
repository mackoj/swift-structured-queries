public protocol Statement<Value>: QueryExpression, Hashable {}

extension Statement {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.sql == rhs.sql && lhs.bindings == rhs.bindings
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(sql)
    hasher.combine(bindings)
  }
}
