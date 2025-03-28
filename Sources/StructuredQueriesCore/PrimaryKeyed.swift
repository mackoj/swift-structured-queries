public protocol PrimaryKeyedTable: Table where TableColumns: PrimaryKeyedSchema {
  associatedtype Draft: Table
}

public protocol PrimaryKeyedSchema<PrimaryKey>: Schema where QueryValue: PrimaryKeyedTable {
  associatedtype PrimaryKey: QueryBindable where PrimaryKey.QueryValue == PrimaryKey

  var primaryKey: TableColumn<QueryValue, PrimaryKey> { get }
}

extension PrimaryKeyedSchema {
  public func count(
    filter: (some QueryExpression<Bool>)? = Bool?.none
  ) -> some QueryExpression<Int> {
    primaryKey.count(filter: filter)
  }
}
