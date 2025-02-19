import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct AggregatesTests {
    @Table
    fileprivate struct User {
      var id: Int
      var name: String
      var isAdmin: Bool
    }

    @Test func average() {
      assertInlineSnapshot(of: User.columns.id.average(), as: .sql) {
        """
        avg("users"."id")
        """
      }
    }

    @Test func count() {
      assertInlineSnapshot(of: User.columns.id.count(), as: .sql) {
        """
        count("users"."id")
        """
      }
      assertInlineSnapshot(of: User.columns.id.count(distinct: true), as: .sql) {
        """
        count(DISTINCT "users"."id")
        """
      }
    }

    @Test func unqualifiedCount() {
      assertInlineSnapshot(of: User.all().select { _ in .count() }, as: .sql) {
        """
        SELECT count(*) FROM "users"
        """
      }
      assertInlineSnapshot(of: User.where(\.isAdmin).count(), as: .sql) {
        """
        SELECT count(*) FROM "users" WHERE "users"."isAdmin"
        """
      }
    }

    @Test func maximum() {
      assertInlineSnapshot(of: User.columns.id.maximum(), as: .sql) {
        """
        max("users"."id")
        """
      }
    }

    @Test func minimum() {
      assertInlineSnapshot(of: User.columns.id.minimum(), as: .sql) {
        """
        min("users"."id")
        """
      }
    }

    @Test func sum() {
      assertInlineSnapshot(of: User.columns.id.sum(), as: .sql) {
        """
        sum("users"."id")
        """
      }
      assertInlineSnapshot(of: User.columns.id.sum(distinct: true), as: .sql) {
        """
        sum(DISTINCT "users"."id")
        """
      }
    }

    @Test func total() {
      assertInlineSnapshot(of: User.columns.id.total(), as: .sql) {
        """
        total("users"."id")
        """
      }
      assertInlineSnapshot(of: User.columns.id.total(distinct: true), as: .sql) {
        """
        total(DISTINCT "users"."id")
        """
      }
    }

    @Test func groupConcat() {
      assertInlineSnapshot(
        of: User.select { $0.name.groupConcat() },
        as: .sql
      ) {
        """
        SELECT group_concat("users"."name") FROM "users"
        """
      }

      assertInlineSnapshot(
        of: User.select { $0.name.groupConcat(separator: "-") },
        as: .sql
      ) {
        """
        SELECT group_concat("users"."name", '-') FROM "users"
        """
      }

      assertInlineSnapshot(
        of: User.select { $0.name.groupConcat(separator: $0.id) },
        as: .sql
      ) {
        """
        SELECT group_concat("users"."name", "users"."id") FROM "users"
        """
      }

      assertInlineSnapshot(
        of: User.select { $0.name.groupConcat(order: $0.isAdmin.descending()) },
        as: .sql
      ) {
        """
        SELECT group_concat("users"."name" ORDER BY "users"."isAdmin" DESC) FROM "users"
        """
      }

      assertInlineSnapshot(
        of: User.select { $0.name.groupConcat(filter: $0.isAdmin) },
        as: .sql
      ) {
        """
        SELECT group_concat("users"."name") FILTER (WHERE "users"."isAdmin") FROM "users"
        """
      }
    }

    @Test func aggregateOfExpression() {
      assertInlineSnapshot(of: User.columns.name.length.count(distinct: true), as: .sql) {
        """
        count(DISTINCT length("users"."name"))
        """
      }

      assertInlineSnapshot(of: (User.columns.name + "!").groupConcat(separator: ", "), as: .sql) {
        """
        group_concat(("users"."name" || '!'), ', ')
        """
      }
    }

    @Test func invalid() {
      #warning("TODO: Can we get these to not compile?")
      assertInlineSnapshot(of: User.columns.id.count().count(), as: .sql) {
        """
        count(count("users"."id"))
        """
      }
    }
  }
}
