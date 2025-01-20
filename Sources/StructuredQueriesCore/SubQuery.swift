extension ColumnExpression {
  public func `in`<SubExpression: QueryExpression>(
    _ operation: SubExpression
  ) -> some QueryExpression<Bool>
  where SubExpression.Value == [Value]
  {
    BinaryOperator(lhs: self, operator: "IN", rhs: Parenthesize(operation))
  }
}
