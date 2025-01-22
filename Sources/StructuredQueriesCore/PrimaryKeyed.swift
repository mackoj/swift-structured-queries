public protocol PrimaryKeyedTable: Table where Columns: PrimaryKeyedSchema {
  associatedtype Draft
}

public protocol PrimaryKeyedSchema<PrimaryKey>: Schema where QueryOutput: PrimaryKeyedTable {
  associatedtype PrimaryKey: ColumnExpression<QueryOutput> & QueryExpression
  where PrimaryKey.QueryOutput: QueryBindable<PrimaryKey.QueryOutput>
  var primaryKey: PrimaryKey { get }
}
