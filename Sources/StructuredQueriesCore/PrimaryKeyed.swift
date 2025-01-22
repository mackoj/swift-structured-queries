public protocol PrimaryKeyedTable: Table where Columns: PrimaryKeyedSchema {
  associatedtype Draft
}

public protocol PrimaryKeyedSchema<PrimaryKey>: Schema where QueryOutput: PrimaryKeyedTable {
  associatedtype PrimaryKey: ColumnExpression<QueryOutput>
  var primaryKey: PrimaryKey { get }
}
