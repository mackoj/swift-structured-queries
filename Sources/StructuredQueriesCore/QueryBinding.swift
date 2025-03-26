public enum QueryBinding: Hashable, Sendable {
  case blob([UInt8])
  case double(Double)
  case int(Int64)
  case null
  case text(String)
  case _invalid(QueryBindingError)

  static func invalid(_ error: any Error) -> Self {
    ._invalid(QueryBindingError(underlyingError: error))
  }
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
    case let ._invalid(error):
      return "<\(error.underlyingError.localizedDescription)>"
    }
  }
}
