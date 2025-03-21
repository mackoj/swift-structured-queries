extension Optional: Table where Wrapped: Table {
  public static var tableName: String {
    Wrapped.tableName
  }

  public static var columns: TableColumns {
    TableColumns()
  }

  fileprivate subscript<Member: QueryRepresentable>(
    member _: KeyPath<Member, Member> & Sendable,
    column keyPath: KeyPath<Wrapped, Member.QueryOutput> & Sendable
  ) -> Member.QueryOutput? {
    self?[keyPath: keyPath]
  }

  @dynamicMemberLookup
  public struct TableColumns: Schema {
    public typealias QueryValue = Optional

    public static var count: Int {
      Wrapped.TableColumns.count
    }

    public var allColumns: [any TableColumnExpression] {
      Wrapped.columns.allColumns
    }

    public subscript<Member>(
      dynamicMember keyPath: KeyPath<Wrapped.TableColumns, TableColumn<Wrapped, Member>>
    ) -> TableColumn<Optional, Member?> {
      let column = Wrapped.columns[keyPath: keyPath]
      return TableColumn<Optional, Member?>(
        column.name,
        keyPath: \.[member: \Member.self, column: column._keyPath]
      )
    }
  }
}

extension Optional: PrimaryKeyedTable where Wrapped: PrimaryKeyedTable {
  public typealias Draft = Wrapped.Draft?
}

extension Optional.TableColumns: PrimaryKeyedSchema where Wrapped.TableColumns: PrimaryKeyedSchema {
  public typealias PrimaryKey = Wrapped.TableColumns.PrimaryKey?

  public var primaryKey: TableColumn<Optional, Wrapped.TableColumns.PrimaryKey.QueryValue?> {
    self[dynamicMember: \.primaryKey]
  }
}
