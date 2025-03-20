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
    ctes: [CommonTableExpressionClause(tableName: CTE.tableName, select: select)]
  )
}

struct CommonTableExpressionClause: QueryExpression {
  typealias QueryValue = ()
  let tableName: String
  let select: any QueryExpression
  var queryFragment: QueryFragment {
    "\(raw: tableName.quoted()) AS \(select)"
  }
}
