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

public struct AnyColumnExpression<Root>: ColumnExpression {
  public typealias QueryOutput = Any

  public var base: any ColumnExpression<Root>

  public init(_ base: any ColumnExpression<Root>) {
    self.base = base
  }

  public var keyPath: PartialKeyPath<Root> { base.keyPath }
  public var name: String { base.name }
  public var queryFragment: QueryFragment { base.queryFragment }
}
