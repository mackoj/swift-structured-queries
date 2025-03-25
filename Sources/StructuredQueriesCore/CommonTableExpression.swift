// TODO: Make builder variant?
//   with {
//     Reminder.all().…
//     Reminder.all().…
//     Reminder.all().…
//   }
//   .select { … }
// TODO: Support cross/back-referencing?
// TODO: Support in 'INSERT', 'UPDATE', 'DELETE', etc.?
public func with<S: SelectStatement>(
  @CommonTableExpressionBuilder _ ctes: () -> [CommonTableExpressionClause],
  select: () -> S
) -> Select<S.QueryValue, S.From, S.Joins> {
  var select = select().all()
  select.ctes = ctes()
  return select
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
    _ components: CommonTableExpressionClause...
  ) -> [CommonTableExpressionClause] {
    components
  }
}
