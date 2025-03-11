import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct OperatorsTests {
    @Test func toggle() {
      assertInlineSnapshot(of: Row.update { $0.bool.toggle() }, as: .sql) {
        """
        UPDATE "rows" SET "bool" = NOT ("rows"."bool")
        """
      }
    }

    @Test func coalesce() {
      assertInlineSnapshot(of: Row.columns.a ?? Row.columns.b ?? Row.columns.c, as: .sql) {
        """
        coalesce("rows"."a", "rows"."b", "rows"."c")
        """
      }
    }

    @Test func `in`() async throws {
      assertInlineSnapshot(
        of: Row.where {
          $0.c.in(Row.select { $0.bool.cast(as: Int.self) })
        },
        as: .sql
      ) {
        """
        SELECT "rows"."a", "rows"."b", "rows"."c", "rows"."bool" FROM "rows" WHERE ("rows"."c" IN (SELECT CAST("rows"."bool" AS INTEGER) FROM "rows"))
        """
      }
    }

    @Test func contains() async throws {
      assertInlineSnapshot(
        of: Row.where {
          Row.select { $0.bool.cast(as: Int.self) }.contains($0.c)
        },
        as: .sql
      ) {
        """
        SELECT "rows"."a", "rows"."b", "rows"."c", "rows"."bool" FROM "rows" WHERE ("rows"."c" IN (SELECT CAST("rows"."bool" AS INTEGER) FROM "rows"))
        """
      }
    }

//    @Test func selectSubQuery() {
//      // TODO: Can we support this? The problem with that `Team.all().count()` has an output of an
//      //       instead of a single value. Needs a SelectOne?
//      assertInlineSnapshot(
//        of: Row.select { ($0.a, Row.count()) },
//        as: .sql
//      ) {
//        """
//        SELECT "players"."id", (SELECT count(*) FROM "teams") FROM "players"
//        """
//      }
//    }

    @available(*, deprecated)
    @Test func isNullWithNonNullableColumn() {
      assertInlineSnapshot(of: Row.columns.c == nil, as: .sql) {
        """
        ("rows"."c" IS NULL)
        """
      }
    }

    @available(*, deprecated)
    @Test func isNotNullWithNonNullableColumn() {
      assertInlineSnapshot(of: Row.columns.c != nil, as: .sql) {
        """
        ("rows"."c" IS NOT NULL)
        """
      }
    }

    @Table
    struct Row {
      var a: Int?
      var b: Int?
      var c: Int
      var bool: Bool
    }
  }
}
