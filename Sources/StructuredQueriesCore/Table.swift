public protocol Table: QueryDecodable, Sendable {
  associatedtype Columns: TableExpression where Columns.Value == Self

  // TODO: Rename tableName
  // TODO: Move to Schema protocol
  // TODO: Add argument to @Table macro: @Table(name: …)
  static var name: String { get }

  static var columns: Columns { get }
}
