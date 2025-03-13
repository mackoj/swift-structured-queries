import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct InsertTests {
    @Test func basics() throws {
      try assertQuery(
        Reminder.insert {
          ($0.remindersListID, $0.title, $0.isCompleted, $0.date, $0.priority)
        } values: {
          (1, "Groceries", true, Date(timeIntervalSinceReferenceDate: 0), .high)
          (2, "Haircut", false, Date(timeIntervalSince1970: 0), .low)
        } onConflict: {
          $0.title += " Copy"
        }
      ) {
        """
        INSERT INTO "reminders" ("remindersListID", "title", "isCompleted", "date", "priority") VALUES (1, 'Groceries', 1, '2001-01-01 00:00:00.000', 3), (2, 'Haircut', 0, '1970-01-01 00:00:00.000', 1) ON CONFLICT DO UPDATE SET "title" = ("reminders"."title" || ' Copy')
        """
      } results: {
        """

        """
      }
    }

    @Test func testSingleColumn() {
      assertInlineSnapshot(
        of: SyncUp.insert(\.createdAt) {
          Date(timeIntervalSinceReferenceDate: 0)
        },
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" \
        ("createdAt") \
        VALUES \
        ('2001-01-01 00:00:00.000')
        """
      }
    }

    @Test
    func emptyValues() {
      assertInlineSnapshot(
        of: SyncUp.insert(\.id) { return [] },
        as: .sql
      ) {
        """

        """
      }
    }

    @Test
    func records() {
      assertInlineSnapshot(
        of: SyncUp.insert {
          $0
        } values: {
          SyncUp(
            id: 1,
            title: "Engineering",
            isActive: true,
            createdAt: Date(timeIntervalSinceReferenceDate: 0)
          )
        },
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" \
        ("id", "title", "isActive", "createdAt") \
        VALUES \
        (1, 'Engineering', 1, '2001-01-01 00:00:00.000')
        """
      }
      assertInlineSnapshot(
        of: SyncUp.insert {
          SyncUp(
            id: 1,
            title: "Engineering",
            isActive: true,
            createdAt: Date(timeIntervalSinceReferenceDate: 0)
          )
        },
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" \
        ("id", "title", "isActive", "createdAt") \
        VALUES \
        (1, 'Engineering', 1, '2001-01-01 00:00:00.000')
        """
      }
      assertInlineSnapshot(
        of: SyncUp.insert([
          SyncUp(
            id: 1,
            title: "Engineering",
            isActive: true,
            createdAt: Date(timeIntervalSinceReferenceDate: 0)
          )
        ]),
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" \
        ("id", "title", "isActive", "createdAt") \
        VALUES \
        (1, 'Engineering', 1, '2001-01-01 00:00:00.000')
        """
      }
      assertInlineSnapshot(
        of: SyncUp.insert(
          SyncUp(
            id: 1,
            title: "Engineering",
            isActive: true,
            createdAt: Date(timeIntervalSinceReferenceDate: 0)
          )
        ),
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" \
        ("id", "title", "isActive", "createdAt") \
        VALUES \
        (1, 'Engineering', 1, '2001-01-01 00:00:00.000')
        """
      }
    }

    @Test func select() {
      assertInlineSnapshot(
        of: Attendee.insert {
          ($0.name, $0.syncUpID)
        } select: {
          SyncUp.all().select { ($0.title + " Lead", $0.id) }
        },
        as: .sql
      ) {
        """
        INSERT INTO "attendees" ("name", "syncUpID") \
        SELECT ("syncUps"."title" || ' Lead'), "syncUps"."id" FROM "syncUps"
        """
      }
    }

    @Test func draft() {
      assertInlineSnapshot(
        of: SyncUp.insert {
          SyncUp.Draft(
            title: "Engineering",
            isActive: true,
            createdAt: Date(timeIntervalSinceReferenceDate: 0)
          )
        }
        .returning(\.self),
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" \
        ("id", "title", "isActive", "createdAt") \
        VALUES \
        (NULL, 'Engineering', 1, '2001-01-01 00:00:00.000') \
        RETURNING "syncUps"."id", "syncUps"."title", "syncUps"."isActive", "syncUps"."createdAt"
        """
      }

      assertInlineSnapshot(
        of: SyncUp.insert(
          SyncUp.Draft(
            title: "Engineering",
            isActive: true,
            createdAt: Date(timeIntervalSinceReferenceDate: 0)
          )
        )
        .returning(\.self),
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" \
        ("id", "title", "isActive", "createdAt") \
        VALUES (NULL, 'Engineering', 1, '2001-01-01 00:00:00.000') \
        RETURNING "syncUps"."id", "syncUps"."title", "syncUps"."isActive", "syncUps"."createdAt"
        """
      }

      assertInlineSnapshot(
        of: SyncUp.insert(
          [
            SyncUp.Draft(
              title: "Engineering",
              isActive: true,
              createdAt: Date(timeIntervalSinceReferenceDate: 0)
            ),
            SyncUp.Draft(
              title: "Design",
              isActive: false,
              createdAt: Date(timeIntervalSinceReferenceDate: 1234567890)
            )
          ]
        )
        .returning(\.self),
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" \
        ("id", "title", "isActive", "createdAt") \
        VALUES \
        (NULL, 'Engineering', 1, '2001-01-01 00:00:00.000'), \
        (NULL, 'Design', 0, '2040-02-14 23:31:30.000') \
        RETURNING "syncUps"."id", "syncUps"."title", "syncUps"."isActive", "syncUps"."createdAt"
        """
      }
    }

    @Test func upsert() {
      assertInlineSnapshot(
        of: SyncUp.upsert(
          SyncUp.Draft(id: 1, isActive: true, createdAt: Date(timeIntervalSinceReferenceDate: 0))
        ),
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" \
        ("id", "title", "isActive", "createdAt") \
        VALUES \
        (1, '', 1, '2001-01-01 00:00:00.000') \
        ON CONFLICT DO UPDATE SET \
        "title" = excluded."title", \
        "isActive" = excluded."isActive", \
        "createdAt" = excluded."createdAt"
        """
      }
    }
  }
}

@Table
private struct SyncUp {
  let id: Int
  var title = ""
  var isActive = true
  @Column(as: Date.ISO8601Representation.self)
  var createdAt: Date
}

@Table
private struct Attendee {
  let id: Int
  var syncUpID: Int
  var name = ""
  @Column(as: Date.ISO8601Representation.self)
  var createdAt: Date
}
