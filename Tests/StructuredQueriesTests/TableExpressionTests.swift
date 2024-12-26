import Foundation
import StructuredQueries
import Testing

@Suite
struct TableExpressionTests {
  @Test func keyPathSubscript() {
    #expect(User.columns.column(for: \.name)?.queryString == #""users"."name""#)
    #expect(User.columns.column(for: \.isAdmin)?.queryString == #""users"."isAdmin""#)
  }

  @Test func keyPathComparator() {
    #expect(
      User.columns.sort(by: KeyPathComparator(\.name, order: .forward)).queryString
      == #""users"."name" ASC"#
    )
    #expect(
      User.columns.sort(by: KeyPathComparator(\.name, order: .reverse)).queryString
      == #""users"."name" DESC"#
    )
  }

  @Test func keyPathComparators() {
    #expect(
      User.columns.sort(
        by: [
          KeyPathComparator(\.name, order: .forward),
          KeyPathComparator(\.isAdmin, order: .reverse),
        ]
      ).queryString
      == """
      "users"."name" ASC, "users"."isAdmin" DESC
      """
    )
  }
}

@Table private struct User {
  var isAdmin: IsAdmin = IsAdmin(rawValue: false)
  var name = ""
  struct IsAdmin: RawRepresentable, QueryBindable, Comparable {
    var rawValue: Bool
    static func < (lhs: Self, rhs: Self) -> Bool {
      !lhs.rawValue && rhs.rawValue
    }
  }
}
