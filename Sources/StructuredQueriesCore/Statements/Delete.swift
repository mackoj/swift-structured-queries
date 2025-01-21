extension Table {
  public static func delete() -> Delete<Self, Void> {
    Delete()
  }
}

public struct Delete<Base: Table, Output> {
  private var `where`: WhereClause?
  private var returning: ReturningClause?

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
