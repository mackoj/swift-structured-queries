public protocol Statement<Columns, From, Joins>: QueryExpression, Hashable
where QueryValue == [Columns] {
  associatedtype Columns
  associatedtype From: Table
  associatedtype Joins = ()
}

extension Statement {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.queryFragment == rhs.queryFragment
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(queryFragment)
  }
}
