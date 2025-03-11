public protocol PrimaryKeyedTable: Table where Columns: PrimaryKeyedSchema {
  associatedtype Draft: Table
}

public protocol PrimaryKeyedSchema<PrimaryKey>: Schema where QueryValue: PrimaryKeyedTable {
  associatedtype PrimaryKey: ColumnExpression
  where
    PrimaryKey.Root == QueryValue,
    PrimaryKey.QueryValue: QueryBindable,
    PrimaryKey.QueryValue.QueryValue == PrimaryKey.QueryValue

  var primaryKey: PrimaryKey { get }
}
