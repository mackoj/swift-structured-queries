extension Table {
  public static func update(
    or conflictResolution: ConflictResolution? = nil,
    set updates: (inout Record<Self>) -> Void
  ) -> Update<Self, Void> {
    var record = Record<Self>()
    updates(&record)
    return Update(conflictResolution: conflictResolution, record: record)
  }
}

extension PrimaryKeyedTable {
  public static func update(
    or conflictResolution: ConflictResolution? = nil,
    _ record: Self
  ) -> Update<Self, Void>
  where Columns: PrimaryKeyedSchema {
    update(or: conflictResolution) {
      for column in columns.allColumns where column.name != columns.primaryKey.name {
        $0.updates.append((column, record[keyPath: column.keyPath] as! any QueryExpression))
      }
    }
    .where {
      $0.primaryKey == record[keyPath: $0.primaryKey.keyPath] as! Columns.PrimaryKey.QueryOutput
    }
  }
}

public struct Update<Base: Table, Output> {
  var conflictResolution: ConflictResolution?
  var record: Record<Base>
  var `where`: WhereClause?
  var returning: ReturningClause?

  public func `where`(_ predicate: (Base.Columns) -> some QueryExpression<Bool>) -> Self {
    func open(_ `where`: some QueryExpression<Bool>) -> WhereClause {
      WhereClause(predicate: `where` && predicate(Base.columns))
    }
    var copy = self
    copy.`where` =
      if let `where` {
        open(`where`.predicate)
      } else {
        WhereClause(predicate: predicate(Base.columns))
      }
    return copy
  }

  public func returning<each O: QueryExpression>(
    _ selection: (Base.Columns) -> (repeat each O)
  ) -> Update<Base, (repeat (each O).QueryOutput)>
  where repeat (each O).QueryOutput: QueryDecodable {
    Update<Base, (repeat (each O).QueryOutput)>(
      conflictResolution: conflictResolution,
      record: record,
      where: `where`,
      returning: ReturningClause(repeat each selection(Base.columns))
    )
  }
}

public typealias UpdateOf<T: Table> = Update<T, Void>

extension Update: Statement {
  public typealias QueryOutput = [Output]

  public var queryFragment: QueryFragment {
    guard !record.updates.isEmpty else {
      return QueryFragment()
    }
    var sql: QueryFragment = "UPDATE"
    if let conflictResolution {
      sql.append(" OR \(bind: conflictResolution)")
    }
    sql.append(" \(raw: Base.name.quoted()) \(bind: record)")
    if let `where` {
      sql.append(" \(bind: `where`)")
    }
    if let returning {
      sql.append(" \(bind: returning)")
    }
    return sql
  }
}
