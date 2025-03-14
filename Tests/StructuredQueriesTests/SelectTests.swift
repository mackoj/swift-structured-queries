import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct SelectTests {
    func compileTimeTests() {
      _ = Reminder.select(\.id)
      _ = Reminder.select { $0.id }
      _ = Reminder.select { ($0.id, $0.isCompleted) }
      _ = Reminder.all().select(\.id)
      _ = Reminder.all().select { $0.id }
      _ = Reminder.all().select { ($0.id, $0.isCompleted) }
      _ = Reminder.where(\.isCompleted).select(\.id)
      _ = Reminder.where(\.isCompleted).select { $0.id }
      _ = Reminder.where(\.isCompleted).select { ($0.id, $0.isCompleted) }
    }

    @Test func selectAll() throws {
      try assertQuery(Tag.all()) {
        """
        SELECT "tags"."id", "tags"."name" FROM "tags"
        """
      } results: {
        """
        ┌────────────────────┐
        │ Tag(               │
        │   id: 1,           │
        │   name: "car"      │
        │ )                  │
        ├────────────────────┤
        │ Tag(               │
        │   id: 2,           │
        │   name: "kids"     │
        │ )                  │
        ├────────────────────┤
        │ Tag(               │
        │   id: 3,           │
        │   name: "someday"  │
        │ )                  │
        ├────────────────────┤
        │ Tag(               │
        │   id: 4,           │
        │   name: "optional" │
        │ )                  │
        └────────────────────┘
        """
      }
    }

    @Test func select() throws {
      try assertQuery(Reminder.select { ($0.id, $0.title) }) {
        """
        SELECT "reminders"."id", "reminders"."title" FROM "reminders"
        """
      } results: {
        """
        ┌────┬────────────────────────────┐
        │ 1  │ "Groceries"                │
        │ 2  │ "Haircut"                  │
        │ 3  │ "Doctor appointment"       │
        │ 4  │ "Take a walk"              │
        │ 5  │ "Buy concert tickets"      │
        │ 6  │ "Pick up kids from school" │
        │ 7  │ "Get laundry"              │
        │ 8  │ "Take out trash"           │
        │ 9  │ "Call accountant"          │
        │ 10 │ "Send weekly emails"       │
        └────┴────────────────────────────┘
        """
      }
    }

    @Test func selectSingleColumn() throws {
      try assertQuery(Tag.select(\.name)) {
        """
        SELECT "tags"."name" FROM "tags"
        """
      } results: {
        """
        ┌────────────┐
        │ "car"      │
        │ "kids"     │
        │ "someday"  │
        │ "optional" │
        └────────────┘
        """
      }
    }

    @Test func selectChaining() throws {
      try assertQuery(Tag.select(\.id).select(\.name)) {
        """
        SELECT "tags"."id", "tags"."name" FROM "tags"
        """
      } results: {
        """
        ┌───┬────────────┐
        │ 1 │ "car"      │
        │ 2 │ "kids"     │
        │ 3 │ "someday"  │
        │ 4 │ "optional" │
        └───┴────────────┘
        """
      }
    }

    @Test func join() throws {
      try assertQuery(
        RemindersList.join(Reminder.all()) { $0.id == $1.remindersListID }
      ) {
        """
        SELECT "remindersLists"."id", "remindersLists"."color", "remindersLists"."name", "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "remindersLists" JOIN "reminders" ON ("remindersLists"."id" = "reminders"."remindersListID")
        """
      }results: {
        #"""
        ┌────────────────────┬─────────────────────────────────────────┐
        │ RemindersList(     │ Reminder(                               │
        │   id: 1,           │   id: 1,                                │
        │   color: 4889071,  │   assignedUserID: 1,                    │
        │   name: "Personal" │   date: Date(2001-01-01T00:00:00.000Z), │
        │ )                  │   isCompleted: false,                   │
        │                    │   isFlagged: false,                     │
        │                    │   notes: "Milk, Eggs, Apples",          │
        │                    │   priority: nil,                        │
        │                    │   remindersListID: 1,                   │
        │                    │   title: "Groceries"                    │
        │                    │ )                                       │
        ├────────────────────┼─────────────────────────────────────────┤
        │ RemindersList(     │ Reminder(                               │
        │   id: 1,           │   id: 2,                                │
        │   color: 4889071,  │   assignedUserID: nil,                  │
        │   name: "Personal" │   date: Date(2000-12-30T00:00:00.000Z), │
        │ )                  │   isCompleted: false,                   │
        │                    │   isFlagged: true,                      │
        │                    │   notes: "",                            │
        │                    │   priority: nil,                        │
        │                    │   remindersListID: 1,                   │
        │                    │   title: "Haircut"                      │
        │                    │ )                                       │
        ├────────────────────┼─────────────────────────────────────────┤
        │ RemindersList(     │ Reminder(                               │
        │   id: 1,           │   id: 3,                                │
        │   color: 4889071,  │   assignedUserID: nil,                  │
        │   name: "Personal" │   date: Date(2001-01-01T00:00:00.000Z), │
        │ )                  │   isCompleted: false,                   │
        │                    │   isFlagged: false,                     │
        │                    │   notes: "Ask about diet",              │
        │                    │   priority: .high,                      │
        │                    │   remindersListID: 1,                   │
        │                    │   title: "Doctor appointment"           │
        │                    │ )                                       │
        ├────────────────────┼─────────────────────────────────────────┤
        │ RemindersList(     │ Reminder(                               │
        │   id: 1,           │   id: 4,                                │
        │   color: 4889071,  │   assignedUserID: nil,                  │
        │   name: "Personal" │   date: Date(2000-06-25T00:00:00.000Z), │
        │ )                  │   isCompleted: true,                    │
        │                    │   isFlagged: false,                     │
        │                    │   notes: "",                            │
        │                    │   priority: nil,                        │
        │                    │   remindersListID: 1,                   │
        │                    │   title: "Take a walk"                  │
        │                    │ )                                       │
        ├────────────────────┼─────────────────────────────────────────┤
        │ RemindersList(     │ Reminder(                               │
        │   id: 1,           │   id: 5,                                │
        │   color: 4889071,  │   assignedUserID: nil,                  │
        │   name: "Personal" │   date: nil,                            │
        │ )                  │   isCompleted: false,                   │
        │                    │   isFlagged: false,                     │
        │                    │   notes: "",                            │
        │                    │   priority: nil,                        │
        │                    │   remindersListID: 1,                   │
        │                    │   title: "Buy concert tickets"          │
        │                    │ )                                       │
        ├────────────────────┼─────────────────────────────────────────┤
        │ RemindersList(     │ Reminder(                               │
        │   id: 2,           │   id: 6,                                │
        │   color: 15567157, │   assignedUserID: nil,                  │
        │   name: "Family"   │   date: Date(2001-01-03T00:00:00.000Z), │
        │ )                  │   isCompleted: false,                   │
        │                    │   isFlagged: true,                      │
        │                    │   notes: "",                            │
        │                    │   priority: .high,                      │
        │                    │   remindersListID: 2,                   │
        │                    │   title: "Pick up kids from school"     │
        │                    │ )                                       │
        ├────────────────────┼─────────────────────────────────────────┤
        │ RemindersList(     │ Reminder(                               │
        │   id: 2,           │   id: 7,                                │
        │   color: 15567157, │   assignedUserID: nil,                  │
        │   name: "Family"   │   date: Date(2000-12-30T00:00:00.000Z), │
        │ )                  │   isCompleted: true,                    │
        │                    │   isFlagged: false,                     │
        │                    │   notes: "",                            │
        │                    │   priority: .low,                       │
        │                    │   remindersListID: 2,                   │
        │                    │   title: "Get laundry"                  │
        │                    │ )                                       │
        ├────────────────────┼─────────────────────────────────────────┤
        │ RemindersList(     │ Reminder(                               │
        │   id: 2,           │   id: 8,                                │
        │   color: 15567157, │   assignedUserID: nil,                  │
        │   name: "Family"   │   date: Date(2001-01-05T00:00:00.000Z), │
        │ )                  │   isCompleted: false,                   │
        │                    │   isFlagged: false,                     │
        │                    │   notes: "",                            │
        │                    │   priority: .high,                      │
        │                    │   remindersListID: 2,                   │
        │                    │   title: "Take out trash"               │
        │                    │ )                                       │
        ├────────────────────┼─────────────────────────────────────────┤
        │ RemindersList(     │ Reminder(                               │
        │   id: 3,           │   id: 9,                                │
        │   color: 11689427, │   assignedUserID: nil,                  │
        │   name: "Business" │   date: Date(2001-01-03T00:00:00.000Z), │
        │ )                  │   isCompleted: false,                   │
        │                    │   isFlagged: false,                     │
        │                    │   notes: """                            │
        │                    │     Status of tax return                │
        │                    │     Expenses for next year              │
        │                    │     Changing payroll company            │
        │                    │     """,                                │
        │                    │   priority: nil,                        │
        │                    │   remindersListID: 3,                   │
        │                    │   title: "Call accountant"              │
        │                    │ )                                       │
        ├────────────────────┼─────────────────────────────────────────┤
        │ RemindersList(     │ Reminder(                               │
        │   id: 3,           │   id: 10,                               │
        │   color: 11689427, │   assignedUserID: nil,                  │
        │   name: "Business" │   date: Date(2000-12-30T00:00:00.000Z), │
        │ )                  │   isCompleted: true,                    │
        │                    │   isFlagged: false,                     │
        │                    │   notes: "",                            │
        │                    │   priority: .medium,                    │
        │                    │   remindersListID: 3,                   │
        │                    │   title: "Send weekly emails"           │
        │                    │ )                                       │
        └────────────────────┴─────────────────────────────────────────┘
        """#
      }
      // TODO: Get coverage on optional relations.
      assertInlineSnapshot(
        of: RemindersList.leftJoin(Reminder.all()) { $0.id == $1.remindersListID },
        as: .sql
      ) {
        """
        SELECT "remindersLists"."id", "remindersLists"."color", "remindersLists"."name", "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "remindersLists" LEFT JOIN "reminders" ON ("remindersLists"."id" = "reminders"."remindersListID")
        """
      }
      assertInlineSnapshot(
        of: RemindersList.rightJoin(Reminder.all()) { $0.id == $1.remindersListID },
        as: .sql
      ) {
        """
        SELECT "remindersLists"."id", "remindersLists"."color", "remindersLists"."name", "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "remindersLists" RIGHT JOIN "reminders" ON ("remindersLists"."id" = "reminders"."remindersListID")
        """
      }
      assertInlineSnapshot(
        of: RemindersList.fullJoin(Reminder.all()) { $0.id == $1.remindersListID },
        as: .sql
      ) {
        """
        SELECT "remindersLists"."id", "remindersLists"."color", "remindersLists"."name", "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "remindersLists" FULL JOIN "reminders" ON ("remindersLists"."id" = "reminders"."remindersListID")
        """
      }

      try assertQuery(
        RemindersList
          .join(Reminder.all()) { $0.id == $1.remindersListID }
          .select { ($0.name, $1.title) }
      ) {
        """
        SELECT "remindersLists"."name", "reminders"."title" FROM "remindersLists" JOIN "reminders" ON ("remindersLists"."id" = "reminders"."remindersListID")
        """
      } results: {
        """
        ┌────────────┬────────────────────────────┐
        │ "Personal" │ "Groceries"                │
        │ "Personal" │ "Haircut"                  │
        │ "Personal" │ "Doctor appointment"       │
        │ "Personal" │ "Take a walk"              │
        │ "Personal" │ "Buy concert tickets"      │
        │ "Family"   │ "Pick up kids from school" │
        │ "Family"   │ "Get laundry"              │
        │ "Family"   │ "Take out trash"           │
        │ "Business" │ "Call accountant"          │
        │ "Business" │ "Send weekly emails"       │
        └────────────┴────────────────────────────┘
        """
      }
    }

    @Test func `where`() throws {
      try assertQuery(
        Reminder.where(\.isCompleted)
      ) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "reminders" WHERE "reminders"."isCompleted"
        """
      }results: {
        """
        ┌─────────────────────────────────────────┐
        │ Reminder(                               │
        │   id: 4,                                │
        │   assignedUserID: nil,                  │
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
        │   id: 7,                                │
        │   assignedUserID: nil,                  │
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
        │   id: 10,                               │
        │   assignedUserID: nil,                  │
        │   date: Date(2000-12-30T00:00:00.000Z), │
        │   isCompleted: true,                    │
        │   isFlagged: false,                     │
        │   notes: "",                            │
        │   priority: .medium,                    │
        │   remindersListID: 3,                   │
        │   title: "Send weekly emails"           │
        │ )                                       │
        └─────────────────────────────────────────┘
        """
      }
    }

    @Test func group() throws {
      try assertQuery(
        Reminder.group(by: \.isCompleted)
      ) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "reminders" GROUP BY "reminders"."isCompleted"
        """
      }results: {
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
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 4,                                │
        │   assignedUserID: nil,                  │
        │   date: Date(2000-06-25T00:00:00.000Z), │
        │   isCompleted: true,                    │
        │   isFlagged: false,                     │
        │   notes: "",                            │
        │   priority: nil,                        │
        │   remindersListID: 1,                   │
        │   title: "Take a walk"                  │
        │ )                                       │
        └─────────────────────────────────────────┘
        """
      }
    }

    @Test func having() {
      assertInlineSnapshot(
        of: Reminder.having(\.isCompleted),
        as: .sql
      ) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "reminders" HAVING "reminders"."isCompleted"
        """
      }
    }

    @Test func order() throws {
      try assertQuery(
        Reminder
          .select(\.title)
          .order(by: \.title)
      ) {
        """
        SELECT "reminders"."title" FROM "reminders" ORDER BY "reminders"."title"
        """
      } results: {
        """
        ┌────────────────────────────┐
        │ "Buy concert tickets"      │
        │ "Call accountant"          │
        │ "Doctor appointment"       │
        │ "Get laundry"              │
        │ "Groceries"                │
        │ "Haircut"                  │
        │ "Pick up kids from school" │
        │ "Send weekly emails"       │
        │ "Take a walk"              │
        │ "Take out trash"           │
        └────────────────────────────┘
        """
      }
      try assertQuery(
        Reminder
          .select { ($0.isCompleted, $0.date) }
          .order { ($0.isCompleted.asc(), $0.date.desc()) }
      ) {
        """
        SELECT "reminders"."isCompleted", "reminders"."date" FROM "reminders" ORDER BY "reminders"."isCompleted" ASC, "reminders"."date" DESC
        """
      } results: {
        """
        ┌───────┬────────────────────────────────┐
        │ false │ Date(2001-01-05T00:00:00.000Z) │
        │ false │ Date(2001-01-03T00:00:00.000Z) │
        │ false │ Date(2001-01-03T00:00:00.000Z) │
        │ false │ Date(2001-01-01T00:00:00.000Z) │
        │ false │ Date(2001-01-01T00:00:00.000Z) │
        │ false │ Date(2000-12-30T00:00:00.000Z) │
        │ false │ nil                            │
        │ true  │ Date(2000-12-30T00:00:00.000Z) │
        │ true  │ Date(2000-12-30T00:00:00.000Z) │
        │ true  │ Date(2000-06-25T00:00:00.000Z) │
        └───────┴────────────────────────────────┘
        """
      }
      try assertQuery(
        Reminder
          .select { ($0.priority, $0.date) }
          .order {
            if true {
              (
                $0.priority.asc(nulls: .last),
                $0.date.desc(nulls: .first),
                $0.title.collate(.nocase).desc()
              )
            }
          }
      ) {
        """
        SELECT "reminders"."priority", "reminders"."date" FROM "reminders" ORDER BY "reminders"."priority" ASC NULLS LAST, "reminders"."date" DESC NULLS FIRST, ("reminders"."title" COLLATE NOCASE) DESC
        """
      } results: {
        """
        ┌─────────┬────────────────────────────────┐
        │ .low    │ Date(2000-12-30T00:00:00.000Z) │
        │ .medium │ Date(2000-12-30T00:00:00.000Z) │
        │ .high   │ Date(2001-01-05T00:00:00.000Z) │
        │ .high   │ Date(2001-01-03T00:00:00.000Z) │
        │ .high   │ Date(2001-01-01T00:00:00.000Z) │
        │ nil     │ nil                            │
        │ nil     │ Date(2001-01-03T00:00:00.000Z) │
        │ nil     │ Date(2001-01-01T00:00:00.000Z) │
        │ nil     │ Date(2000-12-30T00:00:00.000Z) │
        │ nil     │ Date(2000-06-25T00:00:00.000Z) │
        └─────────┴────────────────────────────────┘
        """
      }
    }

    @Test func limit() throws {
      try assertQuery(Reminder.select(\.id).limit(2)) {
        """
        SELECT "reminders"."id" FROM "reminders" LIMIT 2
        """
      } results: {
        """
        ┌───┐
        │ 1 │
        │ 2 │
        └───┘
        """
      }
      try assertQuery(Reminder.select(\.id).limit(2, offset: 2)) {
        """
        SELECT "reminders"."id" FROM "reminders" LIMIT 2 OFFSET 2
        """
      } results: {
        """
        ┌───┐
        │ 3 │
        │ 4 │
        └───┘
        """
      }
    }

    @Test func count() throws {
      try assertQuery(Reminder.count()) {
        """
        SELECT count(*) FROM "reminders"
        """
      } results: {
        """
        ┌────┐
        │ 10 │
        └────┘
        """
      }
    }

    #if compiler(>=6.1)
      @Test func dynamicMember() throws {
        try assertQuery(
          RemindersList
            .limit(1)
            .select(\.name)
            .withReminderCount
        ) {
          """
          SELECT "remindersLists"."name", count("reminders"."id") FROM "remindersLists" JOIN "reminders" ON ("remindersLists"."id" = "reminders"."remindersListID") GROUP BY "remindersLists"."id" LIMIT 1
          """
        } results: {
          """
          ┌────────────┬───┐
          │ "Personal" │ 5 │
          └────────────┴───┘
          """
        }
      }
    #endif

    @Test func selfJoin() {
      // TODO: This is not currently possible.
    }
  }
}
