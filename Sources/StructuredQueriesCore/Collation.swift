// TODO: Should this not be raw-representable and instead be initialized with a string to be quoted?

/// A collating sequence name.
///
/// Values of this type are supplied to ``QueryExpression/collate(_:)`` to describe how a string
/// should be compared in a query.
public struct Collation: RawRepresentable, Sendable {
  /// A query fragment representing the collating sequence name.
  public let rawValue: QueryFragment

  /// Initializes a collating sequence name from a query fragment.
  ///
  /// ```swift
  /// extension Collation {
  ///   static let fr_FR = Self(rawValue: "\(quote: fr_FR)")
  /// }
  ///
  /// Reminder.order { $0.title.collate(.fr_FR)  }
  /// // SELECT … FROM "reminders"
  /// // ORDER BY "reminders"."title" COLLATE "fr_FR"
  /// ```
  ///
  /// - Parameter rawValue: A query fragment of the sequence name.
  public init(rawValue: QueryFragment) {
    self.rawValue = rawValue
  }
}
