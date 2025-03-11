import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct ScalarFunctionTests {
    @Table
    struct User {
      var id: Int
      var name: String
      var isAdmin: Bool
      var salary: Double
      var referrerID: Int?
      @Column(as: Date.ISO8601Representation.self)
      var updatedAt: Date
    }

    @Test func arithmetic() {
      assertInlineSnapshot(of: User.columns.id.sign(), as: .sql) {
        """
        sign("users"."id")
        """
      }
      assertInlineSnapshot(of: User.columns.salary.sign(), as: .sql) {
        """
        sign("users"."salary")
        """
      }
    }

    @Test func round() {
      assertInlineSnapshot(of: User.columns.salary.round(), as: .sql) {
        """
        round("users"."salary")
        """
      }
      assertInlineSnapshot(of: User.columns.salary.round(2), as: .sql) {
        """
        round("users"."salary", 2)
        """
      }
    }

    // TODO: Bring back?
    // @Test func strftime() {
    //   assertInlineSnapshot(of: User.columns.updatedAt.strftime("%Y.%m%d"), as: .sql) {
    //     """
    //     strftime('%Y.%m%d', "users"."updatedAt")
    //     """
    //   }
    // }

    @Test func strings() {
      assertInlineSnapshot(of: User.columns.name.lower(), as: .sql) {
        """
        lower("users"."name")
        """
      }
      assertInlineSnapshot(of: User.columns.name.upper(), as: .sql) {
        """
        upper("users"."name")
        """
      }
      assertInlineSnapshot(of: User.columns.name.length(), as: .sql) {
        """
        length("users"."name")
        """
      }
    }

    @available(*, deprecated)
    @Test func deprecatedCount() {
      assertInlineSnapshot(of: User.columns.name.count, as: .sql) {
        """
        length("users"."name")
        """
      }
    }

    @available(*, deprecated)
    @Test func deprecatedCoalesce() {
      assertInlineSnapshot(of: User.columns.name ?? User.columns.name, as: .sql) {
        """
        coalesce("users"."name", "users"."name")
        """
      }
    }
  }
}
