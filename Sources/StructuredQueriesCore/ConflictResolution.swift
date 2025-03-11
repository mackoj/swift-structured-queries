public struct ConflictResolution: RawRepresentable, Sendable {
  public static let abort = Self(rawValue: "ABORT")
  public static let fail = Self(rawValue: "FAIL")
  public static let ignore = Self(rawValue: "IGNORE")
  public static let replace = Self(rawValue: "REPLACE")
  public static let rollback = Self(rawValue: "ROLLBACK")

  public var rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}
