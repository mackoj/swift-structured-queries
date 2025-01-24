import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct ColumnsTests {
    @Test func keyPathSubscript() {
      assertInlineSnapshot(of: User.columns.column(for: \.name), as: .sql) {
        """
        "users"."name"
        """
      }
      assertInlineSnapshot(of: User.columns.column(for: \.isAdmin), as: .sql) {
        """
        "users"."isAdmin"
        """
      }
    }

    @Test func keyPathComparator() {
      assertInlineSnapshot(
        of: User.columns.sort(by: KeyPathComparator(\.name, order: .forward)),
        as: .sql
      ) {
        """
        "users"."name" ASC
        """
      }
      assertInlineSnapshot(
        of: User.columns.sort(by: KeyPathComparator(\.name, order: .reverse)),
        as: .sql
      ) {
        """
        "users"."name" DESC
        """
      }
    }

    @Test func keyPathComparators() {
      assertInlineSnapshot(
        of: User.columns.sort(
          by: [
            KeyPathComparator(\.name, order: .forward),
            KeyPathComparator(\.isAdmin, order: .reverse),
          ]
        ),
        as: .sql
      ) {
        """
        "users"."name" ASC, "users"."isAdmin" DESC
        """
      }
    }

    @Table fileprivate struct User {
      var isAdmin: IsAdmin = IsAdmin(rawValue: false)
      var name = ""
      struct IsAdmin: RawRepresentable, QueryBindable, Comparable {
        var rawValue: Bool
        static func < (lhs: Self, rhs: Self) -> Bool {
          !lhs.rawValue && rhs.rawValue
        }
      }
    }
  }
}
