public struct Collation: RawRepresentable, Sendable {
  static let binary = Self(rawValue: "BINARY")
  static let nocase = Self(rawValue: "NOCASE")
  static let rtrim = Self(rawValue: "RTRIM")

  public var rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}
