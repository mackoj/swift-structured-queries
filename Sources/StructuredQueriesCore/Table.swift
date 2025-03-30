@dynamicMemberLookup
public protocol Table: QueryRepresentable where TableColumns.QueryValue == Self {
  associatedtype TableColumns: Schema
  static var columns: TableColumns { get }
  static var tableName: String { get }
  static var tableAlias: String? { get }

  static var all: SelectOf<Self> { get }
}

extension Table {
  public static var all: SelectOf<Self> {
    Select()
  }
  public static var unscoped: SelectOf<Self> {
    Select()
  }
}

extension Table {
  public static var tableAlias: String? {
    nil
  }

  public static subscript<Member>(
    dynamicMember keyPath: KeyPath<TableColumns, TableColumn<Self, Member>>
  ) -> TableColumn<Self, Member> {
    columns[keyPath: keyPath]
  }
}

// TODO: Explore?
// @dynamicMemberLookup
// struct TableColumns<Base: Table> {
//   subscript<Member: QueryExpression>(
//     dynamicMember keyPath: KeyPath<Base.TableColumns, Member>
//   ) -> some QueryExpression<Member.QueryValue> {
//     Base.columns[keyPath: keyPath]
//   }
// }
