extension QueryExpression where QueryValue: QueryDecodable {
  public func asc(nulls nullOrdering: NullOrdering? = nil) -> some QueryExpression {
    OrderingTerm(base: self, direction: .asc, nullOrdering: nullOrdering)
  }

  public func desc(nulls nullOrdering: NullOrdering? = nil) -> some QueryExpression {
    OrderingTerm(base: self, direction: .desc, nullOrdering: nullOrdering)
  }
}

public struct NullOrdering: RawRepresentable, Sendable {
  public static let first = Self(rawValue: "FIRST")
  public static let last = Self(rawValue: "LAST")

  public let rawValue: QueryFragment

  public init(rawValue: QueryFragment) {
    self.rawValue = rawValue
  }
}

private struct OrderingTerm: QueryExpression {
  typealias QueryValue = Void

  struct Direction {
    static let asc = Self(queryFragment: "ASC")
    static let desc = Self(queryFragment: "DESC")
    let queryFragment: QueryFragment
  }

  let base: QueryFragment
  let direction: Direction
  let nullOrdering: NullOrdering?

  init(base: some QueryExpression, direction: Direction, nullOrdering: NullOrdering?) {
    self.base = base.queryFragment
    self.direction = direction
    self.nullOrdering = nullOrdering
  }

  var queryFragment: QueryFragment {
    var query: QueryFragment = "\(base) \(direction.queryFragment)"
    if let nullOrdering {
      query.append(" NULLS \(nullOrdering.rawValue)")
    }
    return query
  }
}
