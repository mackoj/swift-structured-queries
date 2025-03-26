public protocol _SelectStatement<QueryValue>: Statement {}

extension _SelectStatement where Self: Table, QueryValue == Self {
  public var query: QueryFragment {
    var query: QueryFragment = "SELECT "
    func open<Root, Value>(_ column: some TableColumnExpression<Root, Value>) -> QueryFragment {
      let root = self as! Root
      let value = Value(queryOutput: root[keyPath: column.keyPath])
      return "\(value) AS \(quote: column.name)"
    }
    query.append(Self.TableColumns.allColumns.map { open($0) }.joined(separator: ", "))
    return query
  }
}

public protocol SelectStatement<QueryValue, From, Joins>: _SelectStatement {
  func all() -> Select<QueryValue, From, Joins>
}

extension SelectStatement {
  public func selectStar<each J: Table>() -> Select<
    (From, repeat each J), From, (repeat each J)
  > where Joins == (repeat each J) {
    unsafeBitCast(all(), to: Select<(From, repeat each J), From, (repeat each J)>.self)
  }
}
