public protocol Table: QueryDecodable, OptionalPromotable, Sendable {
  associatedtype Columns: Schema where Columns.QueryOutput == Self

  // TODO: Rename tableName
  // TODO: Move to Schema protocol
  // TODO: Add argument to @Table macro: @Table(name: …)
  static var name: String { get }

  static var columns: Columns { get }

  var queryFragment: QueryFragment { get }
}
