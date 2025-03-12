public protocol SelectStatement<QueryValue, From, Joins>: Statement {
  func all() -> Select<QueryValue, From, Joins>
}
