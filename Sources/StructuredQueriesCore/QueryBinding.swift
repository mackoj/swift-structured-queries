public enum QueryBinding: Codable, Hashable, Sendable {
  case blob([UInt8])
  case double(Double)
  case int(Int)
  case null
  case text(String)
}

public protocol QueryBindable {
  var binding: QueryBinding { get }
}
