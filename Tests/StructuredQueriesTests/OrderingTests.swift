import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct OrderingTests {
    @Table
    struct User {
      var id: Int
      var name: String
    }

    @Test func basics() {
      assertInlineSnapshot(of: User.columns.id.ascending(), as: .sql) {
        """
        "users"."id" ASC
        """
      }
      assertInlineSnapshot(of: User.columns.id.descending(), as: .sql) {
        """
        "users"."id" DESC
        """
      }
      assertInlineSnapshot(of: User.columns.id.ascending(nulls: .first), as: .sql) {
        """
        "users"."id" ASC NULLS FIRST
        """
      }
      assertInlineSnapshot(of: User.columns.id.descending(nulls: .first), as: .sql) {
        """
        "users"."id" DESC NULLS FIRST
        """
      }
      assertInlineSnapshot(of: User.columns.id.ascending(nulls: .last), as: .sql) {
        """
        "users"."id" ASC NULLS LAST
        """
      }
      assertInlineSnapshot(of: User.columns.id.descending(nulls: .last), as: .sql) {
        """
        "users"."id" DESC NULLS LAST
        """
      }
    }
  }
}
