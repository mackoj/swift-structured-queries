public protocol ColumnExpression<Root>: QueryExpression where Value: QueryDecodable {
  associatedtype Root: Table

  var keyPath: PartialKeyPath<Root> { get }
  var name: String { get }
}
