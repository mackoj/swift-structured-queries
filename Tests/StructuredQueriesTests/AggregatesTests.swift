import StructuredQueries
import Testing

struct AggregatesTests {
  @Table
  struct User {
    var id: Int
    var name: String
    var isAdmin: Bool
  }

  @Test func average() {
    #expect(
      User.columns.id.average().queryString == """
        avg("users"."id")
        """
    )
    #expect(
      User.columns.id.average(distinct: true).queryString == """
        avg(DISTINCT "users"."id")
        """
    )
  }

  @Test func count() {
    #expect(
      User.columns.id.count().queryString == """
        count("users"."id")
        """
    )
    #expect(
      User.columns.id.count(distinct: true).queryString == """
        count(DISTINCT "users"."id")
        """
    )
  }

  @Test func unqualifiedCount() {
    #expect(
      User.all().select { _ in .count() }.queryString
      == #"SELECT count(*) FROM "users""#
    )
    #expect(
      User.all().where(\.isAdmin).count().queryString
      == #"SELECT count(*) FROM "users" WHERE "users"."isAdmin""#
    )
  }

  @Test func maximum() {
    #expect(
      User.columns.id.maximum().queryString == """
        max("users"."id")
        """
    )
  }

  @Test func minimum() {
    #expect(
      User.columns.id.minimum().queryString == """
        min("users"."id")
        """
    )
  }

  @Test func sum() {
    #expect(
      User.columns.id.sum().queryString == """
        sum("users"."id")
        """
    )
    #expect(
      User.columns.id.sum(distinct: true).queryString == """
        sum(DISTINCT "users"."id")
        """
    )
  }

  @Test func total() {
    #expect(
      User.columns.id.total().queryString == """
        total("users"."id")
        """
    )
    #expect(
      User.columns.id.total(distinct: true).queryString == """
        total(DISTINCT "users"."id")
        """
    )
  }

  @Test func invalid() {
    #warning("TODO: Can we get these to not compile?")
    #expect(
      User.columns.id.count().count().queryString == """
        count(count("users"."id"))
        """
    )
  }
}
