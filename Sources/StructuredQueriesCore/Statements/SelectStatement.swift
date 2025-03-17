public protocol SelectStatement<QueryValue, From, Joins>: Statement {
  func all() -> Select<QueryValue, From, Joins>
}

extension SelectStatement {
  public func selectStar<each J: Table>() -> Select<
    (From, repeat each J), From, (repeat each J)
  > where Joins == (repeat each J) {
    unsafeBitCast(all(), to: Select<(From, repeat each J), From, (repeat each J)>.self)
  }
}
