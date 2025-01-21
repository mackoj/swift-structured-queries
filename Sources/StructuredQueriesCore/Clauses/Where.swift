struct WhereClause {
  var predicate: any QueryExpression<Bool>
}
extension WhereClause: QueryExpression {
  typealias QueryOutput = Void
  var queryString: String { "WHERE \(predicate.queryString)" }
  var queryBindings: [QueryBinding] { predicate.queryBindings }
}
