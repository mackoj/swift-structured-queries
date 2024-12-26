public protocol PrimaryKeyed<ID>: TableExpression {
  associatedtype ID: QueryBindable where ID.Value == ID
  var primaryKey: Column<Value, ID> { get }
}
