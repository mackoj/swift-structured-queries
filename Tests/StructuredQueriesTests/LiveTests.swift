import Foundation
import InlineSnapshotTesting
import StructuredQueries
import StructuredQueriesSQLite
import Testing

extension SnapshotTests {
  @Suite struct LiveTests {
    @Test func selectAll() throws {
      try assertQuery(Reminder.all()) {
        """
        SELECT "reminders"."id", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "reminders"
        """
      } results: {
        #"""
        ┌─────────────────────────────────────────┐
        │ Reminder(                               │
        │   id: 1,                                │
        │   date: Date(2001-01-01T00:00:00.000Z), │
        │   isCompleted: false,                   │
        │   isFlagged: false,                     │
        │   notes: """                            │
        │     Milk                                │
        │     Eggs                                │
        │     Apples                              │
        │     Oatmeal                             │
        │     Spinach                             │
        │     """,                                │
        │   priority: nil,                        │
        │   remindersListID: 1,                   │
        │   title: "Groceries"                    │
        │ )                                       │
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 2,                                │
        │   date: Date(2000-12-30T00:00:00.000Z), │
        │   isCompleted: false,                   │
        │   isFlagged: true,                      │
        │   notes: "",                            │
        │   priority: nil,                        │
        │   remindersListID: 1,                   │
        │   title: "Haircut"                      │
        │ )                                       │
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 3,                                │
        │   date: Date(2001-01-01T00:00:00.000Z), │
        │   isCompleted: false,                   │
        │   isFlagged: false,                     │
        │   notes: "Ask about diet",              │
        │   priority: .high,                      │
        │   remindersListID: 1,                   │
        │   title: "Doctor appointment"           │
        │ )                                       │
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 4,                                │
        │   date: Date(2000-06-25T00:00:00.000Z), │
        │   isCompleted: true,                    │
        │   isFlagged: false,                     │
        │   notes: "",                            │
        │   priority: nil,                        │
        │   remindersListID: 1,                   │
        │   title: "Take a walk"                  │
        │ )                                       │
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 5,                                │
        │   date: Date(2001-01-01T00:00:00.000Z), │
        │   isCompleted: false,                   │
        │   isFlagged: false,                     │
        │   notes: "",                            │
        │   priority: nil,                        │
        │   remindersListID: 1,                   │
        │   title: "Buy concert tickets"          │
        │ )                                       │
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 6,                                │
        │   date: Date(2001-01-03T00:00:00.000Z), │
        │   isCompleted: false,                   │
        │   isFlagged: true,                      │
        │   notes: "",                            │
        │   priority: .high,                      │
        │   remindersListID: 2,                   │
        │   title: "Pick up kids from school"     │
        │ )                                       │
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 7,                                │
        │   date: Date(2000-12-30T00:00:00.000Z), │
        │   isCompleted: true,                    │
        │   isFlagged: false,                     │
        │   notes: "",                            │
        │   priority: .low,                       │
        │   remindersListID: 2,                   │
        │   title: "Get laundry"                  │
        │ )                                       │
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 8,                                │
        │   date: Date(2001-01-05T00:00:00.000Z), │
        │   isCompleted: false,                   │
        │   isFlagged: false,                     │
        │   notes: "",                            │
        │   priority: .high,                      │
        │   remindersListID: 2,                   │
        │   title: "Take out trash"               │
        │ )                                       │
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 9,                                │
        │   date: Date(2001-01-03T00:00:00.000Z), │
        │   isCompleted: false,                   │
        │   isFlagged: false,                     │
        │   notes: """                            │
        │     Status of tax return                │
        │     Expenses for next year              │
        │     Changing payroll company            │
        │     """,                                │
        │   priority: nil,                        │
        │   remindersListID: 3,                   │
        │   title: "Call accountant"              │
        │ )                                       │
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 10,                               │
        │   date: Date(2000-12-30T00:00:00.000Z), │
        │   isCompleted: true,                    │
        │   isFlagged: false,                     │
        │   notes: "",                            │
        │   priority: .medium,                    │
        │   remindersListID: 3,                   │
        │   title: "Send weekly emails"           │
        │ )                                       │
        └─────────────────────────────────────────┘
        """#
      }
    }

    @Test func select() throws {
      let averagePriority = Reminder.select { $0.priority.cast(as: Int.self).avg() ?? 0 }
      try assertQuery(
        Reminder
          .select { ($0.title, $0.priority, averagePriority) }
          .where { $0.priority.cast(as: Double.self) > averagePriority }
      ) {
        """
        SELECT "reminders"."title", "reminders"."priority", (SELECT coalesce(avg(CAST("reminders"."priority" AS NUMERIC)), 0.0) FROM "reminders") FROM "reminders" WHERE (CAST("reminders"."priority" AS NUMERIC) > (SELECT coalesce(avg(CAST("reminders"."priority" AS NUMERIC)), 0.0) FROM "reminders"))
        """
      } results: {
        """
        ┌────────────────────────────┬───────┬─────┐
        │ "Doctor appointment"       │ .high │ 2.4 │
        │ "Pick up kids from school" │ .high │ 2.4 │
        │ "Take out trash"           │ .high │ 2.4 │
        └────────────────────────────┴───────┴─────┘
        """
      }
    }

    @Test func remindersListWithReminderCount() throws {
      try assertQuery(
        RemindersList
          .group(by: \.id)
          .join(Reminder.all()) { $0.id == $1.remindersListID }
          .select { ($0, $1.id.count()) }
      ) {
        """
        SELECT "remindersLists"."id", "remindersLists"."color", "remindersLists"."name", count("reminders"."id") FROM "remindersLists" JOIN "reminders" ON ("remindersLists"."id" = "reminders"."remindersListID") GROUP BY "remindersLists"."id"
        """
      } results: {
        """
        ┌────────────────────┬───┐
        │ RemindersList(     │ 5 │
        │   id: 1,           │   │
        │   color: 4889071,  │   │
        │   name: "Personal" │   │
        │ )                  │   │
        ├────────────────────┼───┤
        │ RemindersList(     │ 3 │
        │   id: 2,           │   │
        │   color: 15567157, │   │
        │   name: "Family"   │   │
        │ )                  │   │
        ├────────────────────┼───┤
        │ RemindersList(     │ 2 │
        │   id: 3,           │   │
        │   color: 11689427, │   │
        │   name: "Business" │   │
        │ )                  │   │
        └────────────────────┴───┘
        """
      }
    }

    @Test func remindersWithTags() throws {
      // TODO: Does removing tuple destructure overloads make it possible to write this query in one expression?
      let query = Reminder
        .group(by: \.id)
        .join(ReminderTag.all()) { $0.id == $1.reminderID }
        .join(Tag.all()) { $1.tagID == $2.id }
      try assertQuery(
        query.select { ($0, $2.name.groupConcat()) }
      ) {
        """
        SELECT "reminders"."id", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title", group_concat("tags"."name") FROM "reminders" JOIN "remindersTags" ON ("reminders"."id" = "remindersTags"."reminderID") JOIN "tags" ON ("remindersTags"."tagID" = "tags"."id") GROUP BY "reminders"."id"
        """
      } results: {
        #"""
        ┌─────────────────────────────────────────┬────────────────────┐
        │ Reminder(                               │ "someday,optional" │
        │   id: 1,                                │                    │
        │   date: Date(2001-01-01T00:00:00.000Z), │                    │
        │   isCompleted: false,                   │                    │
        │   isFlagged: false,                     │                    │
        │   notes: """                            │                    │
        │     Milk                                │                    │
        │     Eggs                                │                    │
        │     Apples                              │                    │
        │     Oatmeal                             │                    │
        │     Spinach                             │                    │
        │     """,                                │                    │
        │   priority: nil,                        │                    │
        │   remindersListID: 1,                   │                    │
        │   title: "Groceries"                    │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ "someday,optional" │
        │   id: 2,                                │                    │
        │   date: Date(2000-12-30T00:00:00.000Z), │                    │
        │   isCompleted: false,                   │                    │
        │   isFlagged: true,                      │                    │
        │   notes: "",                            │                    │
        │   priority: nil,                        │                    │
        │   remindersListID: 1,                   │                    │
        │   title: "Haircut"                      │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ "car,kids"         │
        │   id: 4,                                │                    │
        │   date: Date(2000-06-25T00:00:00.000Z), │                    │
        │   isCompleted: true,                    │                    │
        │   isFlagged: false,                     │                    │
        │   notes: "",                            │                    │
        │   priority: nil,                        │                    │
        │   remindersListID: 1,                   │                    │
        │   title: "Take a walk"                  │                    │
        │ )                                       │                    │
        └─────────────────────────────────────────┴────────────────────┘
        """#
      }
    }

    @Test func basics() throws {
      let db = try Database()
      try db.execute(
        """
        CREATE TABLE "syncUps" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
          "isActive" BOOLEAN NOT NULL DEFAULT 1,
          "title" TEXT NOT NULL DEFAULT '',
          "createdAt" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        """
      )
      try db.execute(
        """
        CREATE TABLE "attendees" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
          "name" TEXT NOT NULL DEFAULT '',
          "syncUpID" INTEGER NOT NULL,
          "createdAt" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        """
      )
      try db.execute(
        SyncUp.insert()
      )
      #expect(
        try #require(
          try db.execute(SyncUp.all().select(\.createdAt)).first
        )
        .timeIntervalSinceNow < 1
      )

      #expect(
        try #require(try db.execute(SyncUp.all()).first).id == 1
      )
    }

    @Table
    struct SyncUp {
      let id: Int
      var isActive: Bool
      var title: String
      @Column(as: Date.ISO8601Representation.self)
      var createdAt: Date
    }

    @Table
    struct Attendee {
      let id: Int
      var name: String
      var syncUpID: Int
      @Column(as: Date.ISO8601Representation.self)
      var createdAt: Date
    }
  }
}
