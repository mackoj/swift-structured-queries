public protocol Schema<QueryValue>: QueryExpression where QueryValue: Table {
  var allColumns: [any ColumnExpression] { get }
}

extension Schema {
  public var queryFragment: QueryFragment {
    allColumns.map(\.queryFragment).joined(separator: ", ")
  }
}

extension Never: Schema {
  public typealias QueryValue = Never

  public var allColumns: [any ColumnExpression] { [] }
}
