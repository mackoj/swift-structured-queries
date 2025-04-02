public protocol TableDefinition<QueryValue>: QueryExpression where QueryValue: Table {
  static var allColumns: [any TableColumnExpression] { get }
}

extension TableDefinition {
  public var queryFragment: QueryFragment {
    Self.allColumns.map(\.queryFragment).joined(separator: ", ")
  }
}
