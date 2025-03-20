public struct Collation: RawRepresentable, Sendable {
  public static let binary = Self(rawValue: "BINARY")
  public static let nocase = Self(rawValue: "NOCASE")
  public static let rtrim = Self(rawValue: "RTRIM")

  public let rawValue: QueryFragment

  public init(rawValue: QueryFragment) {
    self.rawValue = rawValue
  }
}
