public enum QueryBinding: Codable, Hashable, Sendable {
  case blob([UInt8])
  case double(Double)
  case int(Int64)
  case null
  case text(String)
}
