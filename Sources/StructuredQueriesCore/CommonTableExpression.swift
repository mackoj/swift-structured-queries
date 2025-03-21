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
    ctes: [CommonTableExpressionClause(table: CTE.self, select: select.queryFragment)]
  )
}

struct CommonTableExpressionClause: QueryExpression {
  typealias QueryValue = ()
  let table: any Table.Type
  let select: QueryFragment
  var queryFragment: QueryFragment {
    "\(table) AS \(select)"
  }
}
