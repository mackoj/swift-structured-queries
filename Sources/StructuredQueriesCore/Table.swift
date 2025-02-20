public protocol Table: QueryDecodable, OptionalPromotable, Sendable {
  associatedtype Columns: Schema

  // TODO: Rename tableName
  // TODO: Move to Schema protocol
  // TODO: Add argument to @Table macro: @Table(name: …)
  static var name: String { get }

  static var columns: Columns { get }

  var queryFragment: QueryFragment { get }
}

extension Optional: Table where Wrapped: Table {
  public typealias Columns = Wrapped.Columns

  public static var name: String {
    Wrapped.name
  }

  public static var columns: Wrapped.Columns {
    Wrapped.columns
  }

  public var queryFragment: QueryFragment {
    self?.queryFragment ?? ""
  }
}
