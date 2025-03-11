import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct SelectTests {
    func f() {
      _ = SyncUp.select(\.id)
      _ = SyncUp.select { $0.id }
      _ = SyncUp.select { ($0.id, $0.isActive) }
      _ = SyncUp.all().select(\.id)
      _ = SyncUp.all().select { $0.id }
      _ = SyncUp.all().select { ($0.id, $0.isActive) }
      _ = SyncUp.where(\.isActive).select(\.id)
      _ = SyncUp.where(\.isActive).select { $0.id }
      _ = SyncUp.where(\.isActive).select { ($0.id, $0.isActive) }
    }

    @Test func basics() {
      assertInlineSnapshot(
        of: SyncUp.all(),
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt" \
        FROM "syncUps"
        """
      }
    }

    @Test func select() {
      assertInlineSnapshot(
        of: SyncUp.all().select { ($0.id, $0.createdAt) },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."createdAt" \
        FROM "syncUps"
        """
      }
    }

    @Test func selectSingleColumn() {
      assertInlineSnapshot(
        of: SyncUp.all().select(\.id),
        as: .sql
      ) {
        """
        SELECT "syncUps"."id" FROM "syncUps"
        """
      }
    }

    @Test func chaining() {
      assertInlineSnapshot(
        of: SyncUp.all().select(\.id).select { ($0.createdAt, $0.isActive) },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."createdAt", "syncUps"."isActive" \
        FROM "syncUps"
        """
      }
    }

    @Test func join() {
      assertInlineSnapshot(
        of: SyncUp.all().join(Attendee.all()) { $0.id == $1.syncUpID },
        as: .sql
      ) {
        """
        SELECT \
        "syncUps"."id", \
        "syncUps"."isActive", \
        "syncUps"."createdAt", \
        "attendees"."id", \
        "attendees"."syncUpID", \
        "attendees"."name", \
        "attendees"."createdAt" \
        FROM "syncUps" \
        JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
        """
      }
      assertInlineSnapshot(
        of: SyncUp.all().leftJoin(Attendee.all()) { $0.id == $1.syncUpID },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", \
        "syncUps"."isActive", \
        "syncUps"."createdAt", \
        "attendees"."id", \
        "attendees"."syncUpID", \
        "attendees"."name", \
        "attendees"."createdAt" \
        FROM "syncUps" \
        LEFT JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
        """
      }
      assertInlineSnapshot(
        of: SyncUp.all().rightJoin(Attendee.all()) { $0.id == $1.syncUpID },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", \
        "syncUps"."isActive", \
        "syncUps"."createdAt", \
        "attendees"."id", \
        "attendees"."syncUpID", \
        "attendees"."name", \
        "attendees"."createdAt" \
        FROM "syncUps" \
        RIGHT JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
        """
      }
      assertInlineSnapshot(
        of: SyncUp.all().fullJoin(Attendee.all()) { $0.id == $1.syncUpID },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", \
        "syncUps"."isActive", \
        "syncUps"."createdAt", \
        "attendees"."id", \
        "attendees"."syncUpID", \
        "attendees"."name", \
        "attendees"."createdAt" \
        FROM "syncUps" \
        FULL JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
        """
      }

      assertInlineSnapshot(
        of: SyncUp.all().join(Attendee.all()) { $0.id == $1.syncUpID }.select { ($0.id, $1.id) },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "attendees"."id" \
        FROM "syncUps" \
        JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
        """
      }
    }

    @Test func `where`() {
      assertInlineSnapshot(
        of: SyncUp.all().where(\.isActive),
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt" \
        FROM "syncUps" \
        WHERE "syncUps"."isActive"
        """
      }
    }

    @Test func group() {
      assertInlineSnapshot(
        of: SyncUp.all().group(by: \.id),
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt" \
        FROM "syncUps" \
        GROUP BY "syncUps"."id"
        """
      }
    }

    @Test func having() {
      assertInlineSnapshot(
        of: SyncUp.all().having(\.isActive),
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt" \
        FROM "syncUps" \
        HAVING "syncUps"."isActive"
        """
      }
    }

    @Test func order() {
      assertInlineSnapshot(
        of: SyncUp.all().order(by: \.id),
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt" \
        FROM "syncUps" \
        ORDER BY "syncUps"."id"
        """
      }
      assertInlineSnapshot(
        of: SyncUp.all().order(by: { ($0.isActive.asc(), $0.createdAt.desc()) }),
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt" \
        FROM "syncUps" \
        ORDER BY "syncUps"."isActive" ASC, "syncUps"."createdAt" DESC
        """
      }
      assertInlineSnapshot(
        of: SyncUp.all().order {
          if true {
            ($0.isActive.asc(nulls: .last), $0.createdAt.desc(nulls: .first))
          } else {
            $0.createdAt
          }
        },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt" \
        FROM "syncUps" \
        ORDER BY "syncUps"."isActive" ASC NULLS LAST, "syncUps"."createdAt" DESC NULLS FIRST
        """
      }
    }

    @Test func limit() {
      assertInlineSnapshot(
        of: SyncUp.all().limit(10),
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt" \
        FROM "syncUps" \
        LIMIT 10
        """
      }
      assertInlineSnapshot(
        of: SyncUp.all().limit(10, offset: 10),
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt" \
        FROM "syncUps" \
        LIMIT 10 \
        OFFSET 10
        """
      }
    }

    #if compiler(>=6.1)
      @Test func dynamicMember1() {
        assertInlineSnapshot(
          of: SyncUp.all().active.withAttendeeCount.select { syncUp, _ in syncUp },
          as: .sql
        ) {
          """
          SELECT \
          count("attendees"."id"), "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt" \
          FROM "syncUps" \
          LEFT JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID") \
          WHERE "syncUps"."isActive" \
          GROUP BY "syncUps"."id"
          """
        }
      }
    #endif

    @Test func selfJoin() {
      assertInlineSnapshot(
        of: SyncUp.join(SyncUp.all()) { $0.id == $1.id },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt", \
        "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt" \
        FROM "syncUps" JOIN "syncUps" ON ("syncUps"."id" = "syncUps"."id")
        """
      }
    }

    @Table
    struct SyncUp {
      static let active = Self.where(\.isActive)
      static let withAttendeeCount = group(by: \.id)
        .leftJoin(Attendee.all()) { $0.id == $1.syncUpID }
        .select { $1.id.count() }

      let id: Int
      var isActive: Bool
      @Column(as: Date.ISO8601Representation.self)
      var createdAt: Date
    }

    @Table
    struct Attendee {
      let id: Int
      var syncUpID: Int
      var name: String
      @Column(as: Date.ISO8601Representation.self)
      var createdAt: Date
    }
  }
}
