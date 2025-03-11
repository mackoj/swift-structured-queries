extension QueryExpression where QueryValue: QueryDecodable {
  public func asc(nulls nullOrdering: NullOrdering? = nil) -> some QueryExpression {
    OrderingTerm(base: self, direction: .asc, nullOrdering: nullOrdering)
  }

  public func desc(nulls nullOrdering: NullOrdering? = nil) -> some QueryExpression {
    OrderingTerm(base: self, direction: .desc, nullOrdering: nullOrdering)
  }
}

public enum NullOrdering: Sendable {
  case first
  case last

  fileprivate var rawValue: String {
    switch self {
    case .first: "FIRST"
    case .last: "LAST"
    }
  }
}

private struct OrderingTerm<Base: QueryExpression>: QueryExpression {
  typealias QueryValue = Void

  enum Direction: String {
    case asc = "ASC"
    case desc = "DESC"
  }

  let base: Base
  let direction: Direction
  let nullOrdering: NullOrdering?

  var queryFragment: QueryFragment {
    var query: QueryFragment = "\(base) \(raw: direction.rawValue)"
    if let nullOrdering {
      query.append(" NULLS \(raw: nullOrdering.rawValue)")
    }
    return query
  }
}
