public protocol PrimaryKeyed<ID>: Schema {
  associatedtype ID: QueryBindable where ID.QueryOutput == ID
  var primaryKey: Column<QueryOutput, ID> { get }
}
