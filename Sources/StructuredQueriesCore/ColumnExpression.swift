public protocol _ColumnExpression<Root>: Sendable {
  associatedtype Root
  var keyPath: PartialKeyPath<Root> { get }
  var name: String { get }
}

public protocol ColumnExpression<Root>: _ColumnExpression, QueryExpression, _OrderingTerm
where Root: Table {}

extension ColumnExpression {
  public var _orderingTerm: OrderingTerm { OrderingTerm(base: self) }
}
