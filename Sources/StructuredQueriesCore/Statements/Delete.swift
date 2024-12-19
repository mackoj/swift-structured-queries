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
    copy.`where` = if let `where` {
      open(`where`.predicate)
    } else {
      WhereClause(predicate: predicate(Base.columns))
    }
    return copy
  }

  public func returning<each O: QueryExpression>(
    _ selection: (Base.Columns) -> (repeat each O)
  ) -> Delete<Base, (repeat (each O).Value)>
  where repeat (each O).Value: QueryDecodable {
    Delete<Base, (repeat (each O).Value)>(
      where: `where`,
      returning: ReturningClause(repeat each selection(Base.columns))
    )
  }
}

extension Delete: Statement {
  public typealias Value = [Output]

  public var sql: String {
    var sql = "DELETE FROM \(Base.name.quoted())"
    if let `where` {
      sql.append(" \(`where`.sql)")
    }
    if let returning {
      sql.append(" \(returning.sql)")
    }
    return sql
  }

  public var bindings: [QueryBinding] {
    var bindings: [QueryBinding] = []
    if let `where` {
      bindings.append(contentsOf: `where`.bindings)
    }
    if let returning {
      bindings.append(contentsOf: returning.bindings)
    }
    return bindings
  }
}

private struct ReturningClause {
  var columns: [any QueryExpression]
  init?<each O: QueryExpression>(_ columns: repeat each O) {
    var expressions: [any QueryExpression] = []
    for column in repeat each columns {
      expressions.append(column)
    }
    guard !expressions.isEmpty else { return nil }
    self.columns = expressions
  }
}
extension ReturningClause: QueryExpression {
  typealias Value = Void
  var sql: String { "RETURNING \(columns.map(\.sql).joined(separator: ", "))" }
  var bindings: [QueryBinding] { columns.flatMap(\.bindings) }
}
