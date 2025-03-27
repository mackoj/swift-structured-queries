public protocol Schema<QueryValue>: QueryExpression where QueryValue: Table {
  static var allColumns: [any TableColumnExpression] { get }
}

extension Schema {
  public var queryFragment: QueryFragment {
    Self.allColumns.map(\.queryFragment).joined(separator: ", ")
  }
}
