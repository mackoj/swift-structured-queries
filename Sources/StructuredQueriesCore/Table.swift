/// A type representing a database table
///
/// Don't conform to this protocol directly. Instead, use the `@Table` and `@Column` macros to
/// generate a conformance.
@dynamicMemberLookup
public protocol Table: QueryRepresentable where TableColumns.QueryValue == Self {
  /// A type that describes this table's columns.
  associatedtype TableColumns: TableDefinition

  /// A value that describes this table's columns.
  static var columns: TableColumns { get }

  /// The table's name.
  static var tableName: String { get }

  /// A table alias.
  ///
  /// This property should always return `nil` unless called on a ``TableAlias``.
  static var tableAlias: String? { get }
}

extension Table {
  public static var tableAlias: String? {
    nil
  }

  /// Returns a table column to the resulting value of a given key path.
  ///
  /// Allows, _e.g._ `Reminder.columns.id` to be abbreviated `Reminder.id`, which is useful when
  /// constructing statements using the `#sql` macro:
  ///
  /// ```swift
  /// #sql("SELECT \(Reminder.id) FROM \(Reminder.self)", as: Int.self)
  /// // SELECT "reminders"."id" FROM "reminders
  /// ```
  public static subscript<Member>(
    dynamicMember keyPath: KeyPath<TableColumns, TableColumn<Self, Member>>
  ) -> TableColumn<Self, Member> {
    columns[keyPath: keyPath]
  }
}
