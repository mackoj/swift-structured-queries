import StructuredQueries

struct SimpleSelect<Columns>: Statement {
  typealias From = Never

  var queryFragment: QueryFragment

  init(
    _ selection: () -> some QueryExpression<Columns>
  ) where Columns: QueryRepresentable  {
    queryFragment = "SELECT \(selection().queryFragment)"
  }

  init<each C: QueryExpression>(
    _ selection: () -> (repeat each C)
  ) where repeat (each C).QueryValue: QueryRepresentable, Columns == (repeat (each C).QueryValue) {
    let columns = Array(repeat each selection())
    queryFragment = "SELECT \(columns.map(\.queryFragment).joined(separator: ", "))"
  }
}
