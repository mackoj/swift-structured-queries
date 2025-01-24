
// TODO: conform to CustomDebugStringConvertible and pretty print?
public protocol QueryExpression<QueryOutput>: Sendable {
  associatedtype QueryOutput
  var queryFragment: QueryFragment { get }
}

extension Optional: QueryExpression where Wrapped: QueryExpression {
  public typealias QueryOutput = Self
  public var queryFragment: QueryFragment {
    switch self {
    case let .some(wrapped):
      return wrapped.queryFragment
    case nil:
      return "\(.null)"
    }
  }
}

extension Array: QueryExpression where Element: QueryExpression {
  public typealias QueryOutput = Self
  public var queryFragment: QueryFragment {
    map(\.queryFragment).joined(separator: ", ")
  }
}

extension ClosedRange: QueryExpression where Bound: QueryExpression {
  public typealias QueryOutput = Self
  public var queryFragment: QueryFragment { "\(bind: lowerBound) AND \(bind: upperBound)" }
}

