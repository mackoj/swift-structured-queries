public protocol Table: QueryDecodable, Sendable {
  associatedtype Columns: TableExpression where Columns.Value == Self

  static var name: String { get }

  static var columns: Columns { get }
}
