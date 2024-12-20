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

  @Test func literals() {
    let id = Column<User, Int64>("id")
    #expect(
      (id == Int64(42)).sql == "(id = ?)"
    )
    // (id == 24).sql == "(id = ?)"
  }
}
