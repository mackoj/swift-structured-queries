public enum QueryBinding: Codable, Hashable, Sendable {
  case blob(ContiguousArray<UInt8>)
  case double(Double)
  case int(Int64)
  case null
  case text(String)
}

extension QueryBinding: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case let .blob(data):
      return String(decoding: data, as: UTF8.self).quoted("'")
    case let .double(value):
      return "\(value)"
    case let .int(value):
      return "\(value)"
    case .null:
      return "NULL"
    case let .text(string):
      return string.quoted("'")
    }
  }
}
