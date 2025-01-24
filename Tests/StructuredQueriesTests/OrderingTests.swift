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
    }
  }
}
