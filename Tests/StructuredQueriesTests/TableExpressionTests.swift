import Foundation
import StructuredQueries
import Testing

@Suite
struct TableExpressionTests {
  @Test func keyPathSubscript() {
    #expect(User.columns.column(for: \.name)?.queryString == User.columns.name.queryString)
    #expect(User.columns.column(for: \.isAdmin)?.queryString == User.columns.isAdmin.queryString)
  }

  @Test func keyPathComparator() {
    #expect(
      User.columns.sort(by: KeyPathComparator(\.name, order: .forward)).queryString
      == User.columns.name.ascending().queryString
    )
    #expect(
      User.columns.sort(by: KeyPathComparator(\.name, order: .reverse)).queryString
      == User.columns.name.descending().queryString
    )
  }
}

@Table private struct User {
  var isAdmin = false
  var name = ""
}
