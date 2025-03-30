// TODO: Should this not be raw-representable and instead be initialized with a string to be quoted?

/// A conflict resolution algorithm.
public struct ConflictResolution: RawRepresentable, Sendable {
  /// The `ABORT` conflict resolution algorithm.
  public static let abort = Self(rawValue: "ABORT")

  /// The `FAIL` conflict resolution algorithm.
  public static let fail = Self(rawValue: "FAIL")

  /// The `IGNORE` conflict resolution algorithm.
  public static let ignore = Self(rawValue: "IGNORE")

  /// The `REPLACE` conflict resolution algorithm.
  public static let replace = Self(rawValue: "REPLACE")

  /// The `ROLLBACK` conflict resolution algorithm.
  public static let rollback = Self(rawValue: "ROLLBACK")

  public let rawValue: QueryFragment

  public init(rawValue: QueryFragment) {
    self.rawValue = rawValue
  }
}
