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

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
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
