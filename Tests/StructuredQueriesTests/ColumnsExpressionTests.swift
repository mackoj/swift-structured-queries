import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct ColumnsExpressionTests {
    @Table
    struct User {
      var id: Int
      var name: String
    }

    @Test func expression() {
      assertInlineSnapshot(of: User.columns, as: .sql) {
        """
        "users"."id", "users"."name"
        """
      }
    }
  }
}
