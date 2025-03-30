extension Table {
  /// A delete statement for a table.
  ///
  /// - Returns: A delete statement.
  public static func delete() -> Delete<Self, Void> {
    Delete()
  }
}

extension PrimaryKeyedTable {
  /// A delete statement for a table row.
  ///
  /// ```swift
  /// Reminder.delete(reminder)
  /// // DELETE FROM "reminders" WHERE "reminders"."id" = 1
  /// ```
  ///
  /// - Parameter row: A row to delete.
  /// - Returns: A delete statement.
  public static func delete(_ row: Self) -> Delete<Self, Void> {
    Delete()
      .where {
        $0.primaryKey.eq(TableColumns.PrimaryKey(queryOutput: row[keyPath: $0.primaryKey.keyPath]))
      }
  }
}

/// A `DELETE` statement.
///
/// This type of statement is constructed from ``Table/delete()`` and ``Where/delete()``.
public struct Delete<From: Table, Returning> {
  var `where`: [QueryFragment] = []
  var returning: [QueryFragment] = []

  /// Adds a condition to a delete statement.
  ///
  /// - Parameter predicate: A predicate to add.
  /// - Returns: A statement with the added predicate.
  public func `where`(_ predicate: (From.TableColumns) -> some QueryExpression<Bool>) -> Self {
    var update = self
    update.where.append(predicate(From.columns).queryFragment)
    return update
  }

  /// Adds a returning clause to a delete statement.
  ///
  /// - Parameter selection: Columns to return.
  /// - Returns: A statement with a returning clause.
  public func returning<each QueryValue: QueryRepresentable>(
    _ selection: (From.TableColumns) -> (repeat TableColumn<From, each QueryValue>)
  ) -> Delete<From, (repeat (each QueryValue).QueryOutput)> {
    var returning: [QueryFragment] = []
    for resultColumn in repeat each selection(From.columns) {
      returning.append("\(quote: resultColumn.name)")
    }
    return Delete<From, (repeat (each QueryValue).QueryOutput)>(
      where: `where`,
      returning: Array(repeat each selection(From.columns))
    )
  }

  public func returning(
    _ selection: (From.TableColumns) -> From.TableColumns
  ) -> Delete<From, From> {
    var returning: [QueryFragment] = []
    for resultColumn in From.TableColumns.allColumns {
      returning.append("\(quote: resultColumn.name)")
    }
    return Delete<From, From>(
      where: `where`,
      returning: returning
    )
  }
}

public typealias DeleteOf<From: Table> = Delete<From, ()>

extension Delete: Statement {
  public typealias QueryValue = Returning

  public var query: QueryFragment {
    var query: QueryFragment = "DELETE FROM \(quote: From.tableName)"
    if let tableAlias = From.tableAlias {
      query.append(" AS \(quote: tableAlias)")
    }
    if !`where`.isEmpty {
      query.append("\(.newlineOrSpace)WHERE \(`where`.joined(separator: " AND "))")
    }
    if !returning.isEmpty {
      query.append("\(.newlineOrSpace)RETURNING \(returning.joined(separator: ", "))")
    }
    return query
  }
}
