import StructuredQueries
import Testing

@Table
private struct User {
  struct ID: RawRepresentable, QueryBindable { var rawValue: Int }
  var id: ID
  var name: String
}

struct ColumnTests {
  @Test func expression() {
    #expect(
      User.columns.id.queryString == """
        "users"."id"
        """
    )
  }

  @Test func rawRepresentable() {
    #expect(
      (User.columns.id == 42).queryString == #"("users"."id" = ?)"#
    )
    #expect(
      (User.columns.id == User.ID(rawValue: 42)).queryString == #"("users"."id" = ?)"#
    )
  }
}
