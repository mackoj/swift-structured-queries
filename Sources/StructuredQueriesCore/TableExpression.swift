public protocol TableExpression<Value>: QueryExpression where Value: Table {
  var allColumns: [any ColumnExpression<Value>] { get }
}

extension TableExpression {
  public var sql: String { allColumns.map(\.sql).joined(separator: ", ") }
  public var bindings: [QueryBinding] { [] }
}
