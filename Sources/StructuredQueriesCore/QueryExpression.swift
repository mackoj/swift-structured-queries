public protocol QueryExpression<QueryValue>: Sendable {
  associatedtype QueryValue

  var queryFragment: QueryFragment { get }
}

extension Array: QueryExpression where Element: QueryExpression {
  public typealias QueryValue = Self
  public var queryFragment: QueryFragment {
    "(\(map(\.queryFragment).joined(separator: ", "))"
  }
}

extension ClosedRange: QueryExpression where Bound: QueryExpression {
  public typealias QueryValue = Self
  public var queryFragment: QueryFragment {
    "(\(lowerBound.queryFragment) AND \(upperBound.queryFragment))"
  }
}
