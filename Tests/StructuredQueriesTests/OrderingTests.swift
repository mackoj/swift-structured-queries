import StructuredQueries
import Testing

struct OrderingTests {
  @Table
  struct User {
    var id: Int
    var name: String
  }

  @Test func basics() {
    #expect(
      User.columns.id.ascending().queryString == """
        "users"."id" ASC
        """
    )
    #expect(
      User.columns.id.descending().queryString == """
        "users"."id" DESC
        """
    )
  }
}
