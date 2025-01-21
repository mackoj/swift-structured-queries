public protocol PrimaryKeyedTable: Table where Columns: PrimaryKeyedSchema {
  associatedtype Draft
}

public protocol PrimaryKeyedSchema<ID>: Schema where QueryOutput: PrimaryKeyedTable {
  associatedtype ID: QueryBindable where ID.QueryOutput == ID
  var primaryKey: Column<QueryOutput, ID> { get }
}
