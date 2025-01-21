extension ColumnExpression {
  public func `in`(
    _ expression: some QueryExpression<[QueryOutput]>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "IN", rhs: Parenthesize(expression))
  }
}
