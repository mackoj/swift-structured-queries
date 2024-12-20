struct WhereClause {
  var predicate: any QueryExpression<Bool>
}
extension WhereClause: QueryExpression {
  typealias Value = Void
  var queryString: String { "WHERE \(predicate.queryString)" }
  var queryBindings: [QueryBinding] { predicate.queryBindings }
}
