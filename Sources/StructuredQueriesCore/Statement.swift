public protocol Statement<QueryValue>: QueryExpression, Hashable {
  associatedtype From: Table
  associatedtype Joins = ()

  var query: QueryFragment { get }
}

extension Statement {
  public var queryFragment: QueryFragment {
    "(\(query))"
  }
}

extension Statement {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.query == rhs.query
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(query)
  }
}
