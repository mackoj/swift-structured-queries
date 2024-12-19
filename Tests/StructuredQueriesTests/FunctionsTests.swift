import StructuredQueries
import Testing

@Table
private struct User {
  var id: Int
  var name: String
  var isAdmin: Bool
  var salary: Double
  var referrerID: Int?
}

struct FunctionsTests {
  @Test func arithmetic() {
    #expect(
      User.columns.id.signum().sql == """
        sign("users"."id")
        """
    )
    #expect(
      User.columns.salary.sign.sql == """
        sign("users"."salary")
        """
    )
  }
  @Test func strings() {
    #expect(
      User.columns.name.lowercased().sql == """
        lower("users"."name")
        """
    )
    #expect(
      User.columns.name.uppercased().sql == """
        upper("users"."name")
        """
    )
    #expect(
      User.columns.name.count.sql == """
        length("users"."name")
        """
    )
    #expect(
      User.columns.name.length.sql == """
        length("users"."name")
        """
    )
  }
}
