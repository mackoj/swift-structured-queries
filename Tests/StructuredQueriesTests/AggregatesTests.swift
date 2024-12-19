import StructuredQueries
import Testing

@Table
private struct User {
  var id: Int
  var name: String
  var isAdmin: Bool
}

struct AggregatesTests {
  @Test func average() {
    #expect(
      User.columns.id.average().sql == """
        avg("users"."id")
        """
    )
    #expect(
      User.columns.id.average(distinct: true).sql == """
        avg(DISTINCT "users"."id")
        """
    )
  }

  @Test func count() {
    #expect(
      User.columns.id.count().sql == """
        count("users"."id")
        """
    )
    #expect(
      User.columns.id.count(distinct: true).sql == """
        count(DISTINCT "users"."id")
        """
    )
  }

  @Test func maximum() {
    #expect(
      User.columns.id.maximum().sql == """
        max("users"."id")
        """
    )
  }

  @Test func minimum() {
    #expect(
      User.columns.id.minimum().sql == """
        min("users"."id")
        """
    )
  }

  @Test func sum() {
    #expect(
      User.columns.id.sum().sql == """
        sum("users"."id")
        """
    )
    #expect(
      User.columns.id.sum(distinct: true).sql == """
        sum(DISTINCT "users"."id")
        """
    )
  }

  @Test func total() {
    #expect(
      User.columns.id.total().sql == """
        total("users"."id")
        """
    )
    #expect(
      User.columns.id.total(distinct: true).sql == """
        total(DISTINCT "users"."id")
        """
    )
  }

  @Test func invalid() {
    #warning("TODO: Can we get these to not compile?")
    #expect(
      User.columns.id.count().count().sql == """
        count(count("users"."id"))
        """
    )
  }
}
