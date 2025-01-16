public enum QueryBinding: Codable, Hashable, Sendable {
  case blob([UInt8])
  case double(Double)
  case int(Int64)
  case null
  case text(String)
}

// TODO: Should we do something like this instead of conforming stdlib types to QueryBindable?
extension QueryExpression where Self == SQLString {
  public static func text(_ string: String) -> SQLString {
    SQLString(value: string)
  }
}
public struct SQLString: QueryExpression {
  public typealias Value = String
  var value: String
  public var queryString: String { "?" }
  public var queryBindings: [QueryBinding] { [.text(value)] }
}
