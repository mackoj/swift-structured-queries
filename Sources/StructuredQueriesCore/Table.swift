public protocol Table: QueryDecodable {
  associatedtype Columns: TableExpression

  static var name: String { get }

  static var columns: Columns { get }
}
