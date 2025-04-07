/*


 SelectStatement
 AnySelectStatement      SELECT 1
 Statement               SELECT 1 / DELETE / UPDATE / INSERT
 QueryExpression         1=1
 */


// TODO: Publicize this as 'ReadOnlyStatement'?
// TODO: Or as 'SelectStatement' renaming the other to 'SelectCoreStatement'?

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

/// A type representing a `SELECT` statement.
public protocol SelectStatement<QueryValue, From, Joins>: _SelectStatement {
  /// Creates a ``Select`` statement from this statement.
  ///
  /// - Returns: A select statement.
  func asSelect() -> Select<QueryValue, From, Joins>

  var _selectClauses: _SelectClauses { get }
}

extension SelectStatement {
  public func asSelect() -> Select<QueryValue, From, Joins> {
    Select(clauses: _selectClauses)
  }

  public var _selectClauses: _SelectClauses {
    asSelect().clauses
  }

  /// Explicitly selects all columns and tables from this statement.
  ///
  /// - Returns: A select statement.
  public func selectStar<each J: Table>() -> Select<
    (From, repeat each J), From, (repeat each J)
  > where Joins == (repeat each J) {
    unsafeBitCast(asSelect(), to: Select<(From, repeat each J), From, (repeat each J)>.self)
  }
}

public typealias SelectStatementOf<From: Table, each Join: Table> =
  SelectStatement<(), From, (repeat each Join)>

extension SelectStatement {
  public static func `where`<From>(
    _ predicate: (From.TableColumns) -> some QueryExpression<Bool>
  ) -> Self
  where Self == Where<From> {
    Self(predicates: [predicate(From.columns).queryFragment])
  }
}
