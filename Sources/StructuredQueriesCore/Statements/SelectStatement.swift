public protocol _SelectStatement<QueryValue>: Statement {}

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



// VALUES(1, 'Hello', true)
// SELECT 1, 'Hello', true
// Values<Int, String>.all()

public struct Values<QueryValue>: _SelectStatement {
  public typealias From = Never

  let values: [QueryFragment]
  public init<each Value: QueryExpression>(
    _ values: repeat each Value
  ) where QueryValue == (repeat each Value) {
    //self.values = (repeat each values)
    self.values = [QueryFragment](repeat each values)
  }
//  public init<S: Schema>(_ columns: S) {
//    self.values = (repeat each values)
//  }

  public var query: QueryFragment {
    "SELECT \(values.joined(separator: ", "))"
  }
}
