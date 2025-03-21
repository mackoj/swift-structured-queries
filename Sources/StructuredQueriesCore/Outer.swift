public struct Outer<Base: Table>: _OptionalPromotable, Table {
  public static var tableName: String {
    Base.tableName
  }

  public static var columns: TableColumns {
    TableColumns()
  }

  let base: Base?

  public var _wrapped: Base? { base }

  fileprivate subscript<Member: QueryRepresentable>(
    member _: KeyPath<Member, Member> & Sendable,
    column keyPath: KeyPath<Base, Member.QueryOutput> & Sendable
  ) -> Member.QueryOutput? {
    base?[keyPath: keyPath]
  }

  @dynamicMemberLookup
  public struct TableColumns: Schema {
    public var allColumns: [any TableColumnExpression] {
      Base.columns.allColumns
    }

    public static var count: Int {
      Base.TableColumns.count
    }

    public typealias QueryValue = Outer

    public subscript<Member>(
      dynamicMember keyPath: KeyPath<Base.TableColumns, TableColumn<Base, Member>>
    ) -> TableColumn<Outer, Member?> {
      let column = Base.columns[keyPath: keyPath]
      return TableColumn<Outer, Member?>(
        column.name,
        keyPath: \.[member: \Member.self, column: column._keyPath]
      )
    }
  }
}

extension Outer: PrimaryKeyedTable where Base: PrimaryKeyedTable {
  public typealias Draft = Outer<Base.Draft>
}

extension Outer.TableColumns: PrimaryKeyedSchema where Base.TableColumns: PrimaryKeyedSchema {
  public typealias PrimaryKey = Base.TableColumns.PrimaryKey?

  public var primaryKey: TableColumn<Outer, Base.TableColumns.PrimaryKey.QueryValue?> {
    self[dynamicMember: \.primaryKey]
  }
}

extension Outer: QueryExpression where Base: QueryExpression {
  public typealias QueryValue = Base.QueryValue?

  public var queryFragment: QueryFragment {
    base?.queryFragment ?? QueryFragment("?", [.null])
  }
}

extension Outer: QueryBindable where Base: QueryBindable {
  public var queryBinding: QueryBinding {
    base?.queryBinding ?? .null
  }
}

extension Outer: QueryDecodable where Base: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    self.init(base: try decoder.decodeColumns(Base?.self))
  }
}

extension Outer: QueryRepresentable where Base: QueryRepresentable {
  public typealias QueryOutput = Base.QueryOutput?

  public init(queryOutput: Base.QueryOutput?) {
    self.init(base: queryOutput.map(Base.init(queryOutput:)))
  }

  public var queryOutput: Base.QueryOutput? {
    base?.queryOutput
  }
}

extension Outer: Sendable where Base: Sendable {}
