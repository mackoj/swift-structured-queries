// TODO: Can we get rid of this?

public protocol Statement<QueryOutput>: QueryExpression, Hashable {}

extension Statement {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.queryString == rhs.queryString && lhs.queryBindings == rhs.queryBindings
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(queryString)
    hasher.combine(queryBindings)
  }
}
