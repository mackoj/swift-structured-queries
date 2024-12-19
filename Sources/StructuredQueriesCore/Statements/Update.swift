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
    copy.`where` = if let `where` {
      open(`where`.predicate)
    } else {
      WhereClause(predicate: predicate(Base.columns))
    }
    return copy
  }

  public func returning<each O: QueryExpression>(
    _ selection: (Base.Columns) -> (repeat each O)
  ) -> Update<Base, (repeat (each O).Value)>
  where repeat (each O).Value: QueryDecodable {
    Update<Base, (repeat (each O).Value)>(
      conflictResolution: conflictResolution,
      record: record,
      where: `where`,
      returning: ReturningClause(repeat each selection(Base.columns))
    )
  }
}

extension Update: Statement {
  public typealias Value = [Output]

  public var sql: String {
    guard !record.updates.isEmpty else {
      return ""
    }
    var sql = "UPDATE"
    if let conflictResolution {
      sql.append(" OR \(conflictResolution.sql)")
    }
    sql.append(" \(Base.name.quoted()) \(record.sql)")
    if let `where` {
      sql.append(" \(`where`.sql)")
    }
    if let returning {
      sql.append(" \(returning.sql)")
    }
    return sql
  }

  public var bindings: [QueryBinding] {
    guard !record.updates.isEmpty else {
      return []
    }
    var bindings = record.bindings
    if let `where` {
      bindings.append(contentsOf: `where`.bindings)
    }
    if let returning {
      bindings.append(contentsOf: returning.bindings)
    }
    return bindings
  }
}
