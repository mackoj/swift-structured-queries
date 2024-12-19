extension Table {
  public static func update(
    set updates: (inout Record<Self>) -> Void
  ) -> Update<Self, Void> {
    var record = Record<Self>()
    updates(&record)
    return Update(record: record)
  }
}

public struct Update<Base: Table, Output> {
  let record: Record<Base>
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
      // TODO: reportIssue()
      return "SELECT NULL"
    }
    var sql = """
      UPDATE \(Base.name.quoted()) \(record.sql)
      """
    if let `where` {
      sql.append(" \(`where`.sql)")
    }
    if let returning {
      sql.append(" \(returning.sql)")
    }
    return sql
  }

  public var bindings: [QueryBinding] {
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

@dynamicMemberLookup
public struct Record<Base: Table>: Sendable {
  var updates: [(any ColumnExpression, any QueryExpression)] = []

  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Value>>
  ) -> some QueryExpression<Value> {
    Base.columns[keyPath: keyPath]
  }

  @_disfavoredOverload
  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Value>>
  ) -> any QueryExpression<Value> {
    get { Base.columns[keyPath: keyPath] }
    set { updates.append((Base.columns[keyPath: keyPath], newValue)) }
  }

  @_disfavoredOverload
  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Value>>
  ) -> AnyQueryExpression<Value> {
    get { AnyQueryExpression(Base.columns[keyPath: keyPath]) }
    set { updates.append((Base.columns[keyPath: keyPath], newValue)) }
  }
}

extension Record: QueryExpression {
  public typealias Value = Void
  public var sql: String {
    "SET \(updates.map { "\($0.name.quoted()) = \($1.sql)" }.joined(separator: ", "))"
  }
  public var bindings: [QueryBinding] { updates.flatMap { $0.bindings + $1.bindings } }
}
