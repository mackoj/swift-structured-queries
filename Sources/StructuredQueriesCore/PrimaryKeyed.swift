public protocol PrimaryKeyedTable: Table where TableColumns: PrimaryKeyedTableDefinition {
  associatedtype Draft: Table
}

public protocol PrimaryKeyedTableDefinition<PrimaryKey>: TableDefinition
where QueryValue: PrimaryKeyedTable {
  associatedtype PrimaryKey: QueryBindable where PrimaryKey.QueryValue == PrimaryKey

  var primaryKey: TableColumn<QueryValue, PrimaryKey> { get }
}

extension PrimaryKeyedTableDefinition {
  public func count(
    filter: (some QueryExpression<Bool>)? = Bool?.none
  ) -> some QueryExpression<Int> {
    primaryKey.count(filter: filter)
  }
}
