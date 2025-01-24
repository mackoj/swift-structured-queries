import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct FunctionsTests {
    @Table
    struct User {
      var id: Int
      var name: String
      var isAdmin: Bool
      var salary: Double
      var referrerID: Int?
      @Column(as: .iso8601)
      var updatedAt: Date
    }

    @Test func arithmetic() {
      assertInlineSnapshot(of: User.columns.id.signum(), as: .sql) {
        """
        sign("users"."id")
        """
      }
      assertInlineSnapshot(of: User.columns.salary.sign, as: .sql) {
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
    @Test func strftime() {
      assertInlineSnapshot(of: User.columns.updatedAt.strftime("%Y.%m%d"), as: .sql) {
        """
        strftime('%Y.%m%d', "users"."updatedAt")
        """
      }
    }
    // TODO: Support something like .raw/.sql for SQL fragments too complex to make in the builder?
    // TODO: $0.updatedAt.strftime("%Y.%m%d").cast(as: Double.self)
    // TODO: "now".as.strftime("%Y.%m%d").cast(as: Double.self) - $0.updatedAt.strftime("%Y.%m%d").cast(as: Double.self)
    // TODO: $0.bornAt.yearsOld
    @Test func strings() {
      assertInlineSnapshot(of: User.columns.name.lowercased(), as: .sql) {
        """
        lower("users"."name")
        """
      }
      assertInlineSnapshot(of: User.columns.name.uppercased(), as: .sql) {
        """
        upper("users"."name")
        """
      }
      assertInlineSnapshot(of: User.columns.name.count, as: .sql) {
        """
        length("users"."name")
        """
      }
      assertInlineSnapshot(of: User.columns.name.length, as: .sql) {
        """
        length("users"."name")
        """
      }
    }
  }
}
