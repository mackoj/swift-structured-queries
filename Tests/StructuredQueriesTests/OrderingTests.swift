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
      User.columns.id.ascending().sql == """
        "users"."id" ASC
        """
    )
    #expect(
      User.columns.id.descending().sql == """
        "users"."id" DESC
        """
    )
    #expect(
      User.columns.id.ascending().descending().sql == """
        "users"."id" DESC
        """
    )
    #expect(
      User.columns.id.descending().ascending().sql == """
        "users"."id" ASC
        """
    )
  }
}
