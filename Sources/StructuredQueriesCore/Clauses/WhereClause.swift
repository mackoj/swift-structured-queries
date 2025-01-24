struct WhereClause {
  var predicate: any QueryExpression<Bool>
}
extension WhereClause: QueryExpression {
  typealias QueryOutput = Void
  var queryFragment: QueryFragment { "WHERE \(predicate.queryFragment)" }
}
