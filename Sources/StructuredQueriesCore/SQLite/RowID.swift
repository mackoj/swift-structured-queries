extension Schema {
  public var rowid: some QueryExpression<Int> {
    SQLQueryExpression(
      """
      \(QueryValue.self)."rowid"
      """
    )
  }
}
