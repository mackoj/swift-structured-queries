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
      for column in columns.allColumns where column.name != columns.primaryKey.name {
        func open<Root, Value>(_ column: some ColumnExpression<Root, Value>) {
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
      func open<C: ColumnExpression>(_ column: C) -> BinaryOperator<Bool, C, C.Value>
      where
        C.Root == Self,
        C.QueryValue.QueryValue == C.QueryValue
      {
        BinaryOperator(
          lhs: column,
          operator: "=",
          rhs: C.Value(queryOutput: row[keyPath: column.keyPath])
        )
      }
      return open($0.primaryKey)
    }
  }
}

public struct Update<From: Table, Returning> {
  var conflictResolution: ConflictResolution?
  var record: Record<From>
  var `where`: [any QueryExpression] = []
  var returning: [any QueryExpression] = []

  public func `where`(_ predicate: (From.Columns) -> some QueryExpression<Bool>) -> Self {
    var update = self
    update.where.append(predicate(From.columns))
    return update
  }

  public func returning<each ResultColumn: QueryExpression>(
    _ selection: (From.Columns) -> (repeat each ResultColumn)
  ) -> Update<From, (repeat (each ResultColumn).QueryValue)>
  where repeat (each ResultColumn).QueryValue: QueryDecodable {
    Update<From, (repeat (each ResultColumn).QueryValue)>(
      conflictResolution: conflictResolution,
      record: record,
      where: `where`,
      returning: Array(repeat each selection(From.columns))
    )
  }
}

public typealias UpdateOf<Base: Table> = Update<Base, ()>

extension Update: Statement {
  public typealias QueryValue = Returning

  public var query: QueryFragment {
    var query: QueryFragment = "UPDATE"
    if let conflictResolution {
      query.append(" OR \(raw: conflictResolution.rawValue)")
    }
    query.append(" \(raw: From.tableName.quoted()) \(bind: record)")
    if !`where`.isEmpty {
      query.append(" WHERE \(`where`.map(\.queryFragment).joined(separator: " AND "))")
    }
    if !returning.isEmpty {
      query.append(" RETURNING \(returning.map(\.queryFragment).joined(separator: ", "))")
    }
    return query
  }
}
