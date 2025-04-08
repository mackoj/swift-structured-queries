extension Table {
  /// An update statement.
  ///
  /// ```swift
  /// Reminder.update {
  ///   $0.title = "Get haircut"
  /// }
  /// // UPDATE "reminders" SET "title" = 'Get haircut'
  /// ```
  ///
  /// - Parameters:
  ///   - conflictResolution: A conflict resolution algorithm.
  ///   - updates: A closure describing column-wise updates to perform.
  /// - Returns: An update statement.
  public static func update(
    or conflictResolution: ConflictResolution? = nil,
    set updates: (inout Updates<Self>) -> Void
  ) -> UpdateOf<Self> {
    Update(conflictResolution: conflictResolution, updates: Updates(updates))
  }
}

extension PrimaryKeyedTable {
  /// An update statement for the values of a given record.
  ///
  /// ```swift
  /// @Table
  /// struct Tag {
  ///   let id: Int
  ///   var name: String
  /// }
  ///
  /// Tag.update(Tag(id: 1, name: "home"))
  /// // UPDATE "tags" SET "name" = 'home' WHERE "id" = 1
  /// ```
  ///
  /// - Parameters:
  ///   - conflictResolution: A conflict resolution algorithm.
  ///   - row: A row to update.
  /// - Returns: An update statement.
  public static func update(
    or conflictResolution: ConflictResolution? = nil,
    _ row: Self
  ) -> UpdateOf<Self> {
    update(or: conflictResolution) { updates in
      for column in TableColumns.allColumns where column.name != columns.primaryKey.name {
        func open<Root, Value>(_ column: some TableColumnExpression<Root, Value>) {
          updates.set(
            column,
            Value(queryOutput: (row as! Root)[keyPath: column.keyPath]).queryFragment
          )
        }
        open(column)
      }
    }
    .where {
      $0.primaryKey.eq(TableColumns.PrimaryKey(queryOutput: row[keyPath: $0.primaryKey.keyPath]))
    }
  }
}

/// An `UPDATE` statement.
///
/// This type of statement is constructed from ``Table/update(or:set:)`` and
/// ``Where/update(or:set:)``.
///
/// To learn more, see <doc:Updates>.
public struct Update<From: Table, Returning> {
  var conflictResolution: ConflictResolution?
  var updates: Updates<From>
  var `where`: [QueryFragment] = []
  var returning: [QueryFragment] = []

  /// Adds a condition to an update statement.
  ///
  /// ```swift
  /// Reminder.update { $0.isFlagged = true }.where(\.isCompleted)
  /// // UPDATE "reminders" SET "isFlagged" = 1 WHERE "reminders"."isCompleted"
  /// ```
  ///
  /// - Parameter predicate: A predicate to add.
  /// - Returns: A statement with the added predicate.
  public func `where`(_ keyPath: KeyPath<From.TableColumns, some QueryExpression<Bool>>) -> Self {
    var update = self
    update.where.append(From.columns[keyPath: keyPath].queryFragment)
    return update
  }

  public func `where`(
    @QueryFragmentBuilder<_WhereClause> _ predicate: (From.TableColumns) -> [QueryFragment]
  ) -> Self {
    var update = self
    update.where.append(contentsOf: predicate(From.columns))
    return update
  }

  /// Adds a returning clause to an update statement.
  ///
  /// ```swift
  /// Reminder.update { $0.isFlagged = true }.returning { ($0.id, $0.title) }
  /// // UPDATE "reminders" SET "isFlagged" = 1 RETURNING "id", "title"
  ///
  /// Reminder.update { $0.isFlagged = true }.returning(\.self)
  /// // UPDATE "reminders" SET "isFlagged" = 1 RETURNING …
  /// ```
  ///
  /// - Parameter selection: Columns to return.
  /// - Returns: A statement with a returning clause.
  public func returning(
    _ selection: (From.TableColumns) -> From.TableColumns
  ) -> Update<From, From> {
    var returning: [QueryFragment] = []
    for resultColumn in From.TableColumns.allColumns {
      returning.append("\(quote: resultColumn.name)")
    }
    return Update<From, From>(
      conflictResolution: conflictResolution,
      updates: updates,
      where: `where`,
      returning: returning
    )
  }

  // NB: This overload allows for 'returning(\.self)'.
  /// Adds a returning clause to an update statement.
  ///
  /// - Parameter selection: Columns to return.
  /// - Returns: A statement with a returning clause.
  @_documentation(visibility: private)
  public func returning<each QueryValue: QueryRepresentable>(
    _ selection: (From.TableColumns) -> (repeat TableColumn<From, each QueryValue>)
  ) -> Update<From, (repeat (each QueryValue).QueryOutput)> {
    var returning: [QueryFragment] = []
    for resultColumn in repeat each selection(From.columns) {
      returning.append("\(quote: resultColumn.name)")
    }
    return Update<From, (repeat (each QueryValue).QueryOutput)>(
      conflictResolution: conflictResolution,
      updates: updates,
      where: `where`,
      returning: returning
    )
  }
}

public typealias UpdateOf<Base: Table> = Update<Base, ()>

extension Update: Statement {
  public typealias QueryValue = Returning

  public var query: QueryFragment {
    var query: QueryFragment = "UPDATE"
    if let conflictResolution {
      query.append(" OR \(conflictResolution.rawValue)")
    }
    query.append(" \(quote: From.tableName)")
    if let tableAlias = From.tableAlias {
      query.append(" AS \(quote: tableAlias)")
    }
    query.append("\(.newlineOrSpace)\(updates)")
    if !`where`.isEmpty {
      query.append("\(.newlineOrSpace)WHERE \(`where`.joined(separator: " AND "))")
    }
    if !returning.isEmpty {
      query.append("\(.newlineOrSpace)RETURNING \(returning.joined(separator: ", "))")
    }
    return query
  }
}
