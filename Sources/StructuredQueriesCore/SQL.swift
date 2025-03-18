/// A query expression of a raw SQL fragment.
///
/// It is not common to interact with this type directly. A value of this type is returned from the
/// `#sql` macro.
public struct SQLQueryExpression<QueryValue>: QueryExpression {
  public let queryFragment: QueryFragment

  public init(_ queryFragment: QueryFragment, as output: QueryValue.Type = QueryValue.self) {
    self.queryFragment = queryFragment
  }
}
