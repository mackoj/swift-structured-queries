public protocol PrimaryKeyed<ID>: Schema {
  associatedtype ID: QueryBindable where ID.Value == ID
  var primaryKey: Column<Value, ID> { get }
}
