extension ColumnExpression {
  public func `in`<SubExpression: QueryExpression>(
    _ operation: () -> SubExpression
  ) -> some QueryExpression<Bool>
  where SubExpression.Value == [Value]
  {
    InSubquery(column: self, subquery: operation())
  }
}

public struct InSubquery<
  Root: Table,
  Column: ColumnExpression<Root>,
  SubExpression: QueryExpression
>: QueryExpression
where
SubExpression.Value == [Column.Value]
{
  public typealias Value = Bool
  let column: Column
  let subquery: SubExpression
  public var queryString: String {
    column.queryString + " IN (" + subquery.queryString + ")"
  }
  public var queryBindings: [QueryBinding] {
    subquery.queryBindings
  }
}
