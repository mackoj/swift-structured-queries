public struct With<QueryValue>: Statement {
  public typealias From = Never

  let recursive: Bool
  var ctes: [CommonTableExpressionClause]
  var statement: QueryFragment

  @_disfavoredOverload
  public init(
    recursive: Bool = false,
    @CommonTableExpressionBuilder _ ctes: () -> [CommonTableExpressionClause],
    query statement: () -> some Statement<QueryValue>
  ) {
    self.ctes = ctes()
    self.recursive = recursive
    self.statement = statement().query
  }

  public init<S: SelectStatement, each J: Table>(
    recursive: Bool = false,
    @CommonTableExpressionBuilder _ ctes: () -> [CommonTableExpressionClause],
    query statement: () -> S
  ) where
    S.QueryValue == (),
    S.Joins == (repeat each J),
    QueryValue == (S.From, repeat each J)
  {
    self.ctes = ctes()
    self.recursive = recursive
    self.statement = statement().query
  }

  public var query: QueryFragment {
    var sql: QueryFragment = "WITH "
    if recursive {
      sql.append("RECURSIVE ")
    }
    sql.append("\(ctes.map(\.queryFragment).joined(separator: ", ")) \(statement)")
    return sql
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
