import StructuredQueries
import Testing

@Table
private struct User {
  var id: Int
  var name: String
}

struct ColumnTests {
  @Test func expression() {
    #expect(
      User.columns.id.sql == """
        "users"."id"
        """
    )
  }
}
