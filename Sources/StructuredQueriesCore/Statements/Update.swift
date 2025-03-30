extension Table {
  public static func update(
    or conflictResolution: ConflictResolution? = nil,
    set updates: (inout Record<Self>) -> Void
  ) -> Update<Self, ()> {
    var record = Record<Self>()
    updates(&record)
    return Update(conflictResolution: conflictResolution, record: record)
  }
}

extension PrimaryKeyedTable {
  public static func update(
    or conflictResolution: ConflictResolution? = nil,
    _ row: Self
  ) -> Update<Self, ()> {
    update(or: conflictResolution) { record in
      for column in TableColumns.allColumns where column.name != columns.primaryKey.name {
        func open<Root, Value>(_ column: some TableColumnExpression<Root, Value>) {
          record.updates.append(
            (
              column.name,
              Value(queryOutput: (row as! Root)[keyPath: column.keyPath]).queryFragment
            )
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

public struct Update<From: Table, Returning> {
  var conflictResolution: ConflictResolution?
  var record: Record<From>
  var `where`: [QueryFragment] = []
  var returning: [QueryFragment] = []

  public func `where`(_ predicate: (From.TableColumns) -> some QueryExpression<Bool>) -> Self {
    var update = self
    update.where.append(predicate(From.columns).queryFragment)
    return update
  }

  public func returning(
    _ selection: (From.TableColumns) -> From.TableColumns
  ) -> Update<From, From> {
    var returning: [QueryFragment] = []
    for resultColumn in From.TableColumns.allColumns {
      returning.append("\(quote: resultColumn.name)")
    }
    return Update<From, From>(
      conflictResolution: conflictResolution,
      record: record,
      where: `where`,
      returning: returning
    )
  }

  public func returning<each QueryValue: QueryRepresentable>(
    _ selection: (From.TableColumns) -> (repeat TableColumn<From, each QueryValue>)
  ) -> Update<From, (repeat (each QueryValue).QueryOutput)> {
    var returning: [QueryFragment] = []
    for resultColumn in repeat each selection(From.columns) {
      returning.append("\(quote: resultColumn.name)")
    }
    return Update<From, (repeat (each QueryValue).QueryOutput)>(
      conflictResolution: conflictResolution,
      record: record,
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
    query.append("\(.newlineOrSpace)\(record)")
    if !`where`.isEmpty {
      query.append("\(.newlineOrSpace)WHERE \(`where`.joined(separator: " AND "))")
    }
    if !returning.isEmpty {
      query.append("\(.newlineOrSpace)RETURNING \(returning.joined(separator: ", "))")
    }
    return query
  }
}
