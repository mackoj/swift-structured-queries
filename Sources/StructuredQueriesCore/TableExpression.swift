public protocol TableExpression<Value>: QueryExpression where Value: Table {
  var allColumns: [any ColumnExpression<Value>] { get }
}

extension TableExpression {
  public var queryString: String { allColumns.map(\.queryString).joined(separator: ", ") }
  public var queryBindings: [QueryBinding] { [] }

  // TODO: Make this more efficient with an OrderedDictionary?
  // TODO: Shuold we force unwrap this or can a builder handle it for us (+ a reportIssue)
  public func column<Member>(for keyPath: KeyPath<Value, Member>) -> Column<Value, Member>? {
    for column in allColumns {
      if column.keyPath == keyPath {
        return (column as! Column<Value, Member>)
      }
    }
    return nil
  }
}

#if canImport(Foundation)
  import Foundation
  extension TableExpression {
    public func sort(
      by keyPathComparator: KeyPathComparator<Value>
    ) -> some QueryExpression<Bool> {
      for column in allColumns {
        if column.keyPath == keyPathComparator.keyPath {
          return _KeyPathComparatorExpression(column: column, order: keyPathComparator.order)
        }
      }
      fatalError(
        """
        Could not find column for key path. This is only supported for key paths of stored properties.
        """)
    }

    @available(*, unavailable)
    public func sort(
      by keyPathComparator: [KeyPathComparator<Value>]
    ) -> any/*some*/ QueryExpression<Bool> {
      fatalError("Unimplemented")
    }
  }

  private struct _KeyPathComparatorExpression<Table>: QueryExpression {
    typealias Value = Bool
    let column: any ColumnExpression<Table>
    let order: SortOrder

    var queryString: String {
      """
      \(column.queryString) \(order == .forward ? "ASC" : "DESC")
      """
    }

    var queryBindings: [QueryBinding] { [] }
  }
#endif
