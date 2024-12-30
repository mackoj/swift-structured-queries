//import IssueReporting

public protocol TableExpression<Value>: QueryExpression where Value: Table {
  var allColumns: [any ColumnExpression<Value>] { get }
}

extension TableExpression {
  public var queryString: String { allColumns.map(\.queryString).joined(separator: ", ") }
  public var queryBindings: [QueryBinding] { [] }

  // TODO: Make this more efficient with an OrderedDictionary?
  // TODO: Should we force unwrap this or can a builder handle it for us (+ a reportIssue)
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
          return _KeyPathComparatorExpression(columnAndOrders: [(column, keyPathComparator.order)])
        }
      }
//      reportIssue(
//        """
//        Could not find column for key path '\(keyPathComparator.keyPath)'. This is only supported \
//        for  key paths of stored properties.
//        """
//      )
      fatalError(
        """
        Could not find column for key path '\(keyPathComparator.keyPath)'. This is only supported \
        for  key paths of stored properties.
        """
      )
    }

    public func sort(
      by keyPathComparators: [KeyPathComparator<Value>]
    ) -> some QueryExpression<Bool> {
      let columnAndOrders = keyPathComparators.compactMap { keyPathComparator in
        for column in allColumns {
          if column.keyPath == keyPathComparator.keyPath {
            return (column, keyPathComparator.order)
          }
        }
//        reportIssue(
//          """
//          Could not find column for key path '\(keyPathComparator.keyPath)'. This is only supported \
//          for  key paths of stored properties.
//          """
//        )
        fatalError(
          """
          Could not find column for key path '\(keyPathComparator.keyPath)'. This is only \
          supported for  key paths of stored properties.
          """
        )
      }
      return _KeyPathComparatorExpression(columnAndOrders: columnAndOrders)
    }
  }

  private struct _KeyPathComparatorExpression<Table>: QueryExpression {
    typealias Value = Bool
    let columnAndOrders: [(any ColumnExpression<Table>, SortOrder)]

    var queryString: String {
      var query = ""
      for (index, (column, order)) in columnAndOrders.enumerated() {
        query += """
          \(column.queryString) \
          \(order == .forward ? "ASC" : "DESC")\
          \(index < columnAndOrders.count - 1 ? ", " : "")
          """
      }
      return query
    }

    var queryBindings: [QueryBinding] { [] }
  }
#endif
