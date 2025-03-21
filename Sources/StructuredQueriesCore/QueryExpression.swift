public protocol QueryExpression<QueryValue>: Sendable {
  associatedtype QueryValue

  var queryFragment: QueryFragment { get }
}
