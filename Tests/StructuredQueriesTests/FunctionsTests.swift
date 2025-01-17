import Foundation
import StructuredQueries
import Testing

struct FunctionsTests {
  @Table
  struct User {
    var id: Int
    var name: String
    var isAdmin: Bool
    var salary: Double
    var referrerID: Int?
    @Column(as: .iso8601)
    var updatedAt: Date
  }

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
  @Test func round() {
    #expect(User.columns.salary.round(2).queryString == #"round("users"."salary", ?)"#)
  }
  @Test func strftime() {
    #expect(
      User.columns.updatedAt.strftime("%Y.%m%d").queryString
        == #"strftime(?, "users"."updatedAt")"#
    )
  }
  // TODO: $0.updatedAt.strftime("%Y.%m%d").cast(as: Double.self)
  // TODO: "now".as.strftime("%Y.%m%d").cast(as: Double.self) - $0.updatedAt.strftime("%Y.%m%d").cast(as: Double.self)
  // TODO: $0.bornAt.yearsOld
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
