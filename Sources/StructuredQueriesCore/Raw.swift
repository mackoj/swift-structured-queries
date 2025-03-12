extension QueryExpression {
  public static func raw<QueryValue>(
    _ queryFragment: QueryFragment,
    as output: QueryValue.Type = QueryValue.self
  ) -> Self
  where Self == RawQueryExpression<QueryValue> {
    Self(queryFragment)
  }
}

public struct RawQueryExpression<QueryValue>: QueryExpression {
  public let queryFragment: QueryFragment
  public init(_ queryFragment: QueryFragment, as output: QueryValue.Type = QueryValue.self) {
    self.queryFragment = queryFragment
  }
}
