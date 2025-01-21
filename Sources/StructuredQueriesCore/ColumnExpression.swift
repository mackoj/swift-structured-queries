public protocol ColumnExpression<Root>: QueryExpression, _OrderingTerm {
  associatedtype Root: Table

  var keyPath: PartialKeyPath<Root> { get }
  var name: String { get }
}

extension ColumnExpression {
  public var _orderingTerm: OrderingTerm { OrderingTerm(base: self) }
}
