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
      User.columns.id.signum().queryString == """
        sign("users"."id")
        """
    )
    #expect(
      User.columns.salary.sign.queryString == """
        sign("users"."salary")
        """
    )
  }
  @Test func strings() {
    #expect(
      User.columns.name.lowercased().queryString == """
        lower("users"."name")
        """
    )
    #expect(
      User.columns.name.uppercased().queryString == """
        upper("users"."name")
        """
    )
    #expect(
      User.columns.name.count.queryString == """
        length("users"."name")
        """
    )
    #expect(
      User.columns.name.length.queryString == """
        length("users"."name")
        """
    )
  }
}
