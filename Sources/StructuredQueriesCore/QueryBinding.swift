public enum QueryBinding: Hashable, Sendable {
  case blob([UInt8])
  case double(Double)
  case int(Int64)
  case null
  case text(String)
  case failure(QueryBindingError)
}

public struct QueryBindingError: Error, Hashable {
  public let underlyingError: any Error
  public init(underlyingError: any Error) {
    self.underlyingError = underlyingError
  }
  public static func == (lhs: Self, rhs: Self) -> Bool { true }
  public func hash(into hasher: inout Hasher) {}
}

extension QueryBinding: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case let .blob(data):
      return String(decoding: data, as: UTF8.self)
        .debugDescription
        .dropLast()
        .dropFirst()
        .quoted("'")
    case let .double(value):
      return "\(value)"
    case let .int(value):
      return "\(value)"
    case .null:
      return "NULL"
    case let .text(string):
      return string.quoted("'")
    case .failure(let error):
      return "<\(error.underlyingError.localizedDescription)>"
    }
  }
}
