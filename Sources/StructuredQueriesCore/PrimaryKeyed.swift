/// A type representing a database table with a primary key.
public protocol PrimaryKeyedTable: Table where TableColumns: PrimaryKeyedTableDefinition {
  /// A type that represents this type, but with an optional primary key.
  ///
  /// This type can be used to stage an inserted row.
  associatedtype Draft: Table
}

/// A type representing a database table's columns.
///
/// Don't conform to this protocol directly. Instead, use the `@Table` and `@Column` macros to
/// generate a conformance.
public protocol PrimaryKeyedTableDefinition<PrimaryKey>: TableDefinition
where QueryValue: PrimaryKeyedTable {
  /// A type representing this table's primary key.
  ///
  /// For auto-incrementing tables, this is typically `Int`.
  associatedtype PrimaryKey: QueryBindable where PrimaryKey.QueryValue == PrimaryKey

  /// The column representing this table's primary key.
  var primaryKey: TableColumn<QueryValue, PrimaryKey> { get }
}

extension PrimaryKeyedTableDefinition {
  /// A query expression representing the number of rows in this table.
  ///
  /// - Parameter filter: A `FILTER` clause to apply to the aggregation.
  /// - Returns: An expression representing the number of rows in this table.
  public func count(
    filter: (some QueryExpression<Bool>)? = Bool?.none
  ) -> some QueryExpression<Int> {
    primaryKey.count(filter: filter)
  }
}
