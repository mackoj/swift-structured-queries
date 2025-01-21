public protocol PrimaryKeyed<ID>: Schema {
  associatedtype ID: QueryBindable where ID.QueryOutput == ID
  // TODO: associatedtype Draft
  var primaryKey: Column<QueryOutput, ID> { get }
}
