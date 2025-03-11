public protocol Table: QueryRepresentable where Columns.QueryValue == Self {
  associatedtype Columns: Schema
  static var columns: Columns { get }
  static var tableName: String { get }
}

// TODO: Explore
// @dynamicMemberLookup
// struct TableColumns<Base: Table> {
//   subscript<Member: QueryExpression>(
//     dynamicMember keyPath: KeyPath<Base.Columns, Member>
//   ) -> some QueryExpression<Member.QueryValue> {
//     Base.columns[keyPath: keyPath]
//   }
// }
