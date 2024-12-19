import StructuredQueries
import Testing

@Table
private struct User {
  var id: Int
  var name: String
}

struct ColumnsExpressionTests {
  @Test func expression() {
    #expect(
      User.columns.sql == """
        "users"."id", "users"."name"
        """
    )
  }
}
