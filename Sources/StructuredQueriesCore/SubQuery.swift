extension Column {
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
  ColumnValue: QueryBindable,
  SubExpression: QueryExpression
>: QueryExpression
where
SubExpression.Value == [ColumnValue]
{
  public typealias Value = Bool
  let column: Column<Root, ColumnValue>
  let subquery: SubExpression
  public var queryString: String {
    column.queryString + " IN (" + subquery.queryString + ")"
  }
  public var queryBindings: [QueryBinding] {
    subquery.queryBindings
  }
}
