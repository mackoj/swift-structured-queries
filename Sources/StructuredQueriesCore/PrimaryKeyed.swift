public protocol PrimaryKeyedTable: Table where TableColumns: PrimaryKeyedSchema {
  associatedtype Draft: Table
}

public protocol PrimaryKeyedSchema<PrimaryKey>: Schema where QueryValue: PrimaryKeyedTable {
  associatedtype PrimaryKey: TableColumnExpression
  where
    PrimaryKey.Root == QueryValue,
    PrimaryKey.QueryValue: QueryBindable,
    PrimaryKey.QueryValue.QueryValue == PrimaryKey.QueryValue

  var primaryKey: PrimaryKey { get }
}

extension PrimaryKeyedSchema {
  public func count() -> some QueryExpression<Int> {
    primaryKey.count()
  }
}
