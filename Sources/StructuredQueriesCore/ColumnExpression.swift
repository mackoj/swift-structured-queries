// TODO: Can this be a hierarchy?
// PartialColumnExpression<Root>
// ColumnExpression<Root, Value>: PartialColumnExpression

public protocol ColumnExpression<Root>: QueryExpression, _OrderingTerm {
  associatedtype Root
  var keyPath: PartialKeyPath<Root> { get }
  var name: String { get }
}

extension ColumnExpression {
  public var _orderingTerm: OrderingTerm { OrderingTerm(base: self) }
}
