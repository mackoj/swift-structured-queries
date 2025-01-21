public protocol QueryExpression<QueryOutput>: Sendable {
  associatedtype QueryOutput

  var queryString: String { get }

  var queryBindings: [QueryBinding] { get }
}

extension Optional: QueryExpression where Wrapped: QueryExpression {
  public typealias QueryOutput = Self
  public var queryString: String { self?.queryString ?? "?" }
  public var queryBindings: [QueryBinding] {
    switch self {
    case let wrapped?:
      return wrapped.queryBindings
    case nil:
      return [.null]
    }
  }
}

extension Array: QueryExpression where Element: QueryExpression {
  public typealias QueryOutput = Self
  public var queryString: String { "(\(map(\.queryString).joined(separator: ", ")))" }
  public var queryBindings: [QueryBinding] { flatMap(\.queryBindings) }
}

extension ClosedRange: QueryExpression where Bound: QueryExpression {
  public typealias QueryOutput = Self
  public var queryString: String { "\(lowerBound.queryString) AND \(upperBound.queryString)" }
  public var queryBindings: [QueryBinding] { lowerBound.queryBindings + upperBound.queryBindings }
}
