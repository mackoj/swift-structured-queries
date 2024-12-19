struct WhereClause {
  var predicate: any QueryExpression<Bool>
}
extension WhereClause: QueryExpression {
  typealias Value = Void
  var sql: String { "WHERE \(predicate.sql)" }
  var bindings: [QueryBinding] { predicate.bindings }
}
