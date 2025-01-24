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
  typealias QueryOutput = Void
  var queryFragment: QueryFragment {
    "RETURNING \(columns.map(\.queryFragment).joined(separator: ", "))"
  }
}
