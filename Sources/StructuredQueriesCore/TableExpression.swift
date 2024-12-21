public protocol TableExpression<Value>: QueryExpression where Value: Table {
  var allColumns: [any ColumnExpression] { get }
}

extension TableExpression {
  public var queryString: String { allColumns.map(\.queryString).joined(separator: ", ") }
  public var queryBindings: [QueryBinding] { [] }
}
