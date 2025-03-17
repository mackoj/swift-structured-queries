public protocol Schema<QueryValue>: QueryExpression where QueryValue: Table {
  // TODO: Make this static to avoid polluting query builder autocomplete.
  var allColumns: [any ColumnExpression] { get }
  static var count: Int { get }
}

extension Schema {
  public var queryFragment: QueryFragment {
    allColumns.map(\.queryFragment).joined(separator: ", ")
  }
}

extension Never: Schema {
  public typealias QueryValue = Never

  public var allColumns: [any ColumnExpression] { [] }

  public static var count: Int { 0 }
}
