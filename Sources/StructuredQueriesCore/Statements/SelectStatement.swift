public protocol SelectStatement<Columns, From, Joins>: Statement {
  func all() -> Select<Columns, From, Joins>
}
