extension Table {
  public static func delete() -> Delete<Self, Void> {
    Delete()
  }
}

extension PrimaryKeyedTable {
  // TODO: Should this be 'delete(_ ids: [Columns.PrimaryKey.QueryOutput])' instead?
  public static func delete(_ records: [Self]) -> Delete<Self, Void> {
    Delete().where { columns in
      records
        .map { $0[keyPath: columns.primaryKey.keyPath] as! Columns.PrimaryKey.QueryOutput }
        .contains(columns.primaryKey)
    }
  }
}

public struct Delete<Base: Table, Output> {
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
  ) -> Delete<Base, (repeat (each O).QueryOutput)>
  where repeat (each O).QueryOutput: QueryDecodable {
    Delete<Base, (repeat (each O).QueryOutput)>(
      where: `where`,
      returning: ReturningClause(repeat each selection(Base.columns))
    )
  }
}

public typealias DeleteOf<T: Table> = Delete<T, Void>

extension Delete: Statement {
  public typealias QueryOutput = [Output]

  public var queryString: String {
    var sql = "DELETE FROM \(Base.name.quoted())"
    if let `where` {
      sql.append(" \(`where`.queryString)")
    }
    if let returning {
      sql.append(" \(returning.queryString)")
    }
    return sql
  }

  public var queryBindings: [QueryBinding] {
    var bindings: [QueryBinding] = []
    if let `where` {
      bindings.append(contentsOf: `where`.queryBindings)
    }
    if let returning {
      bindings.append(contentsOf: returning.queryBindings)
    }
    return bindings
  }
}
