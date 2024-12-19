struct ReturningClause {
  var columns: [any QueryExpression]
  init?<each O: QueryExpression>(_ columns: repeat each O) {
    var expressions: [any QueryExpression] = []
    for column in repeat each columns {
      expressions.append(column)
    }
    guard !expressions.isEmpty else { return nil }
    self.columns = expressions
  }
}
extension ReturningClause: QueryExpression {
  typealias Value = Void
  var sql: String { "RETURNING \(columns.map(\.sql).joined(separator: ", "))" }
  var bindings: [QueryBinding] { columns.flatMap(\.bindings) }
}
