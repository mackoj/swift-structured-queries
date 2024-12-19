public protocol ColumnExpression<Root>: QueryExpression where Value: QueryDecodable {
  associatedtype Root: Table

  var name: String { get }
}
