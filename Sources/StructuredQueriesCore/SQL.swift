/// A query expression of a raw SQL fragment.
///
/// It is not common to interact with this type directly. A value of this type is returned from the
/// `#sql` macro.
public struct SQLQueryExpression<QueryValue>: Statement {
  public typealias From = Never

  public let queryFragment: QueryFragment

  public var query: QueryFragment { queryFragment }

  public init(_ queryFragment: QueryFragment, as output: QueryValue.Type = QueryValue.self) {
    self.queryFragment = queryFragment
  }

  public init(_ queryFragment: QueryFragment) where QueryValue == () {
    self.queryFragment = queryFragment
  }

  @_disfavoredOverload
  public init(_ expression: some QueryExpression<QueryValue>) {
    self.queryFragment = expression.queryFragment
  }
}
