import StructuredQueries
import Testing

@Table
private struct User {
  var id: Int
  var name: String
}

struct OrderingTests {
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
    #expect(
      User.columns.id.ascending().descending().queryString == """
        "users"."id" DESC
        """
    )
    #expect(
      User.columns.id.descending().ascending().queryString == """
        "users"."id" ASC
        """
    )
  }
}
