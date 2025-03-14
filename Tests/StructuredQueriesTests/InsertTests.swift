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
        .returning(\.self)
      ) {
        """
        INSERT INTO "reminders" ("remindersListID", "title", "isCompleted", "date", "priority") VALUES (1, 'Groceries', 1, '2001-01-01 00:00:00.000', 3), (2, 'Haircut', 0, '1970-01-01 00:00:00.000', 1) ON CONFLICT DO UPDATE SET "title" = ("reminders"."title" || ' Copy') RETURNING "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title"
        """
      }results: {
        """
        ┌─────────────────────────────────────────┐
        │ Reminder(                               │
        │   id: 11,                               │
        │   assignedUserID: nil,                  │
        │   date: Date(2001-01-01T00:00:00.000Z), │
        │   isCompleted: true,                    │
        │   isFlagged: false,                     │
        │   notes: "",                            │
        │   priority: .high,                      │
        │   remindersListID: 1,                   │
        │   title: "Groceries"                    │
        │ )                                       │
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 12,                               │
        │   assignedUserID: nil,                  │
        │   date: Date(1970-01-01T00:00:00.000Z), │
        │   isCompleted: false,                   │
        │   isFlagged: false,                     │
        │   notes: "",                            │
        │   priority: .low,                       │
        │   remindersListID: 2,                   │
        │   title: "Haircut"                      │
        │ )                                       │
        └─────────────────────────────────────────┘
        """
      }
    }

    @Test func testSingleColumn() throws {
      try assertQuery(
        Reminder
          .insert(\.remindersListID) { 1 }
          .returning(\.self)
      ) {
        """
        INSERT INTO "reminders" ("remindersListID") VALUES (1) RETURNING "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title"
        """
      }results: {
        """
        ┌────────────────────────┐
        │ Reminder(              │
        │   id: 11,              │
        │   assignedUserID: nil, │
        │   date: nil,           │
        │   isCompleted: false,  │
        │   isFlagged: false,    │
        │   notes: "",           │
        │   priority: nil,       │
        │   remindersListID: 1,  │
        │   title: ""            │
        │ )                      │
        └────────────────────────┘
        """
      }
    }

    @Test
    func emptyValues() {
      #expect(SyncUp.insert(\.id) { return [] }.query.isEmpty)
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

    @Test func upsertWithID() throws {
      try assertQuery(Reminder.where { $0.id == 1 }) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "reminders" WHERE ("reminders"."id" = 1)
        """
      } results: {
        """
        ┌─────────────────────────────────────────┐
        │ Reminder(                               │
        │   id: 1,                                │
        │   assignedUserID: 1,                    │
        │   date: Date(2001-01-01T00:00:00.000Z), │
        │   isCompleted: false,                   │
        │   isFlagged: false,                     │
        │   notes: "Milk, Eggs, Apples",          │
        │   priority: nil,                        │
        │   remindersListID: 1,                   │
        │   title: "Groceries"                    │
        │ )                                       │
        └─────────────────────────────────────────┘
        """
      }
      try assertQuery(
        Reminder
          .upsert(Reminder.Draft(id: 1, remindersListID: 1, title: "Cash check"))
          .returning(\.self)
      ) {
        """
        INSERT INTO "reminders" ("id", "assignedUserID", "date", "isCompleted", "isFlagged", "notes", "priority", "remindersListID", "title") VALUES (1, NULL, NULL, 0, 0, '', NULL, 1, 'Cash check') ON CONFLICT DO UPDATE SET "assignedUserID" = excluded."assignedUserID", "date" = excluded."date", "isCompleted" = excluded."isCompleted", "isFlagged" = excluded."isFlagged", "notes" = excluded."notes", "priority" = excluded."priority", "remindersListID" = excluded."remindersListID", "title" = excluded."title" RETURNING "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title"
        """
      } results: {
        """
        ┌────────────────────────┐
        │ Reminder(              │
        │   id: 1,               │
        │   assignedUserID: nil, │
        │   date: nil,           │
        │   isCompleted: false,  │
        │   isFlagged: false,    │
        │   notes: "",           │
        │   priority: nil,       │
        │   remindersListID: 1,  │
        │   title: "Cash check"  │
        │ )                      │
        └────────────────────────┘
        """
      }
    }

    @Test func upsertWithoutID() throws {
      try assertQuery(Reminder.select { $0.id.max() }) {
        """
        SELECT max("reminders"."id") FROM "reminders"
        """
      }results: {
        """
        ┌────┐
        │ 10 │
        └────┘
        """
      }
      try assertQuery(
        Reminder.upsert(Reminder.Draft(remindersListID: 1))
          .returning(\.self)
      ) {
        """
        INSERT INTO "reminders" ("id", "assignedUserID", "date", "isCompleted", "isFlagged", "notes", "priority", "remindersListID", "title") VALUES (NULL, NULL, NULL, 0, 0, '', NULL, 1, '') ON CONFLICT DO UPDATE SET "assignedUserID" = excluded."assignedUserID", "date" = excluded."date", "isCompleted" = excluded."isCompleted", "isFlagged" = excluded."isFlagged", "notes" = excluded."notes", "priority" = excluded."priority", "remindersListID" = excluded."remindersListID", "title" = excluded."title" RETURNING "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title"
        """
      } results: {
        """
        ┌────────────────────────┐
        │ Reminder(              │
        │   id: 11,              │
        │   assignedUserID: nil, │
        │   date: nil,           │
        │   isCompleted: false,  │
        │   isFlagged: false,    │
        │   notes: "",           │
        │   priority: nil,       │
        │   remindersListID: 1,  │
        │   title: ""            │
        │ )                      │
        └────────────────────────┘
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
