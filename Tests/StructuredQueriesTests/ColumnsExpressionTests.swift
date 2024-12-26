import StructuredQueries
import Testing

struct ColumnsExpressionTests {
  @Table
  struct User {
    var id: Int
    var name: String
  }

  @Test func expression() {
    #expect(
      User.columns.queryString == """
        "users"."id", "users"."name"
        """
    )
  }
}
