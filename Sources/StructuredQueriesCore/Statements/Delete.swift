extension Table {
  public static func delete() -> Delete<Self, Void> {
    Delete()
  }
}

extension PrimaryKeyedTable {
  public static func delete(_ row: Self) -> Delete<Self, Void> {
    Delete()
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

public struct Delete<From: Table, Returning> {
  var `where`: [any QueryExpression] = []
  var returning: [any QueryExpression] = []

  public func `where`(_ predicate: (From.Columns) -> some QueryExpression<Bool>) -> Self {
    var update = self
    update.where.append(predicate(From.columns))
    return update
  }

  public func returning<each ResultColumn: QueryExpression>(
    _ selection: (From.Columns) -> (repeat each ResultColumn)
  ) -> Delete<From, (repeat (each ResultColumn).QueryValue)>
  where repeat (each ResultColumn).QueryValue: QueryDecodable {
    Delete<From, (repeat (each ResultColumn).QueryValue)>(
      where: `where`,
      returning: Array(repeat each selection(From.columns))
    )
  }
}

public typealias DeleteOf<From: Table> = Delete<From, ()>

extension Delete: Statement {
  public typealias Columns = Returning

  public var queryFragment: QueryFragment {
    var query: QueryFragment = "DELETE FROM \(raw: From.tableName.quoted())"
    if !`where`.isEmpty {
      query.append(" WHERE \(`where`.map(\.queryFragment).joined(separator: " AND "))")
    }
    if !returning.isEmpty {
      query.append(" RETURNING \(returning.map(\.queryFragment).joined(separator: ", "))")
    }
    return query
  }
}
