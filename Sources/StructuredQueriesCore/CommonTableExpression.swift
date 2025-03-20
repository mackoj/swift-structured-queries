// TODO: Make builder variant?
//   with {
//     Reminder.all().…
//     Reminder.all().…
//     Reminder.all().…
//   }
//   .select { … }
// TODO: Support cross/back-referencing?
// TODO: Support in 'INSERT', 'UPDATE', 'DELETE', etc.?
public func with<CTE: Table>(
  _ select: some Statement<CTE>
) -> Select<(), CTE, ()> {
  Select(
    ctes: [CommonTableExpressionClause(tableName: CTE.tableName, select: select.queryFragment)]
  )
}

struct CommonTableExpressionClause: QueryExpression {
  typealias QueryValue = ()
  let tableName: String
  let select: QueryFragment
  var queryFragment: QueryFragment {
    "\(quote: tableName) AS \(select)"
  }
}
