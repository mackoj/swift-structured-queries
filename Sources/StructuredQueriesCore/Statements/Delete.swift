extension Table {
  public static func delete() -> Delete<Self, Void> {
    Delete()
  }
}

public struct Delete<Base: Table, Output> {
  var `where`: (any QueryExpression<Bool>)?
  var returning: [any QueryExpression] = []

  public func `where`(_ predicate: (Base.Columns) -> some QueryExpression<Bool>) -> Self {
    let input = Base.columns
    func open(_ `where`: some QueryExpression<Bool>) -> some QueryExpression<Bool> {
      `where` && predicate(input)
    }
    return Self(
      where: `where`.map { open($0) } ?? predicate(input)
    )
  }

  public func returning<each O: QueryExpression>(
    _ selection: (Base.Columns) -> (repeat each O)
  ) -> Delete<Base, (repeat (each O).Value)>
  where repeat (each O).Value: QueryDecodable {
    var returning: [any QueryExpression] = []
    for o in repeat each selection(Base.columns) {
      returning.append(o)
    }
    return Delete<Base, (repeat (each O).Value)>(
      where: `where`,
      returning: returning
    )
  }
}

extension Delete: Statement {
  public typealias Value = [Output]

  public var sql: String {
    var sql = """
      DELETE FROM \(Base.name.quoted())
      """
    if let `where` {
      sql.append(" WHERE \(`where`.sql)")
    }
    if !returning.isEmpty {
      sql.append(" RETURNING ")
      sql.append(returning.map(\.sql).joined(separator: ", "))
    }
    return sql
  }

  public var bindings: [QueryBinding] {
    var bindings: [QueryBinding] = []
    if let `where` {
      bindings.append(contentsOf: `where`.bindings)
    }
    return bindings
  }
}
