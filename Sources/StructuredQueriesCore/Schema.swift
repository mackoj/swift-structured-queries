public protocol Schema<QueryValue>: QueryExpression where QueryValue: Table {
  var allColumns: [any ColumnExpression] { get }
}

extension Schema {
  public var queryFragment: QueryFragment {
    allColumns.map(\.queryFragment).joined(separator: ", ")
  }
}
