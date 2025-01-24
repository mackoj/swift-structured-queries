// TODO: Can we get rid of this?

public protocol Statement<QueryOutput>: QueryExpression, Hashable {}

extension Statement {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.queryFragment == rhs.queryFragment
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(queryFragment)
  }
}
