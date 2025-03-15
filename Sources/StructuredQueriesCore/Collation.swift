public struct Collation: RawRepresentable, Sendable {
  public static let binary = Self(rawValue: "BINARY")
  public static let nocase = Self(rawValue: "NOCASE")
  public static let rtrim = Self(rawValue: "RTRIM")

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}
