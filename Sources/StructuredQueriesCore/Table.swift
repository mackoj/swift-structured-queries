public protocol Table: QueryRepresentable where Columns.QueryValue == Self {
  associatedtype Columns: Schema
  static var columns: Columns { get }
  static var tableName: String { get }
}

extension Never: Table {
  public struct Columns: Schema {
    public typealias QueryValue = Never
    public var allColumns: [any ColumnExpression] { [] }
  }

  public static var columns: Columns {
    Columns()
  }

  public static var tableName: String { "nevers" }

  public init(decoder: some QueryDecoder) throws {
    throw DecodingError()
  }

  private struct DecodingError: Error {}
}

// TODO: Explore?
// @dynamicMemberLookup
// struct TableColumns<Base: Table> {
//   subscript<Member: QueryExpression>(
//     dynamicMember keyPath: KeyPath<Base.Columns, Member>
//   ) -> some QueryExpression<Member.QueryValue> {
//     Base.columns[keyPath: keyPath]
//   }
// }
