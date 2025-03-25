public struct With<QueryValue>: Statement {
  public typealias From = Never

  var ctes: [CommonTableExpressionClause]
  var statement: QueryFragment

  @_disfavoredOverload
  public init(
    @CommonTableExpressionBuilder _ ctes: () -> [CommonTableExpressionClause],
    do statement: () -> some Statement<QueryValue>
  ) {
    self.ctes = ctes()
    self.statement = statement().query
  }

  public init<S: SelectStatement, each J: Table>(
    @CommonTableExpressionBuilder _ ctes: () -> [CommonTableExpressionClause],
    do statement: () -> S
  ) where
    S.QueryValue == (),
    S.Joins == (repeat each J),
    QueryValue == (S.From, repeat each J)
  {
    self.ctes = ctes()
    self.statement = statement().query
  }

  public var query: QueryFragment {
    "WITH \(ctes.map(\.queryFragment).joined(separator: ", ")) \(statement)"
  }
}

public struct CommonTableExpressionClause: QueryExpression {
  public typealias QueryValue = ()
  let tableName: String
  let select: QueryFragment
  public var queryFragment: QueryFragment {
    "\(quote: tableName) AS (\(select))"
  }
}

@resultBuilder
public enum CommonTableExpressionBuilder {
  public static func buildExpression<CTETable: Table>(
    _ expression: some _SelectStatement<CTETable>
  ) -> CommonTableExpressionClause {
    CommonTableExpressionClause(tableName: CTETable.tableName, select: expression.query)
  }

  public static func buildBlock(
    _ component: CommonTableExpressionClause
  ) -> [CommonTableExpressionClause] {
    [component]
  }

  public static func buildPartialBlock(
    first: CommonTableExpressionClause
  ) -> [CommonTableExpressionClause] {
    [first]
  }

  public static func buildPartialBlock(
    accumulated: [CommonTableExpressionClause],
    next: CommonTableExpressionClause
  ) -> [CommonTableExpressionClause] {
    accumulated + [next]
  }
}
