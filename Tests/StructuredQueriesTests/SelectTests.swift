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

    @Test func selectAll() {
      assertQuery(Tag.all()) {
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

    @Test func select() {
      assertQuery(Reminder.select { ($0.id, $0.title) }) {
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

    @Test func selectSingleColumn() {
      assertQuery(Tag.select(\.name)) {
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

    @Test func selectChaining() {
      assertQuery(Tag.select(\.id).select(\.name)) {
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

    @Test func join() {
      assertQuery(
        Reminder
          .join(RemindersList.all()) { $0.remindersListID.eq($1.id) }
      ) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title", "remindersLists"."id", "remindersLists"."color", "remindersLists"."name" FROM "reminders" JOIN "remindersLists" ON ("reminders"."remindersListID" = "remindersLists"."id")
        """
      } results: {
        #"""
        ┌─────────────────────────────────────────┬────────────────────┐
        │ Reminder(                               │ RemindersList(     │
        │   id: 1,                                │   id: 1,           │
        │   assignedUserID: 1,                    │   color: 4889071,  │
        │   date: Date(2001-01-01T00:00:00.000Z), │   name: "Personal" │
        │   isCompleted: false,                   │ )                  │
        │   isFlagged: false,                     │                    │
        │   notes: "Milk, Eggs, Apples",          │                    │
        │   priority: nil,                        │                    │
        │   remindersListID: 1,                   │                    │
        │   title: "Groceries"                    │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ RemindersList(     │
        │   id: 2,                                │   id: 1,           │
        │   assignedUserID: nil,                  │   color: 4889071,  │
        │   date: Date(2000-12-30T00:00:00.000Z), │   name: "Personal" │
        │   isCompleted: false,                   │ )                  │
        │   isFlagged: true,                      │                    │
        │   notes: "",                            │                    │
        │   priority: nil,                        │                    │
        │   remindersListID: 1,                   │                    │
        │   title: "Haircut"                      │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ RemindersList(     │
        │   id: 3,                                │   id: 1,           │
        │   assignedUserID: nil,                  │   color: 4889071,  │
        │   date: Date(2001-01-01T00:00:00.000Z), │   name: "Personal" │
        │   isCompleted: false,                   │ )                  │
        │   isFlagged: false,                     │                    │
        │   notes: "Ask about diet",              │                    │
        │   priority: .high,                      │                    │
        │   remindersListID: 1,                   │                    │
        │   title: "Doctor appointment"           │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ RemindersList(     │
        │   id: 4,                                │   id: 1,           │
        │   assignedUserID: nil,                  │   color: 4889071,  │
        │   date: Date(2000-06-25T00:00:00.000Z), │   name: "Personal" │
        │   isCompleted: true,                    │ )                  │
        │   isFlagged: false,                     │                    │
        │   notes: "",                            │                    │
        │   priority: nil,                        │                    │
        │   remindersListID: 1,                   │                    │
        │   title: "Take a walk"                  │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ RemindersList(     │
        │   id: 5,                                │   id: 1,           │
        │   assignedUserID: nil,                  │   color: 4889071,  │
        │   date: nil,                            │   name: "Personal" │
        │   isCompleted: false,                   │ )                  │
        │   isFlagged: false,                     │                    │
        │   notes: "",                            │                    │
        │   priority: nil,                        │                    │
        │   remindersListID: 1,                   │                    │
        │   title: "Buy concert tickets"          │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ RemindersList(     │
        │   id: 6,                                │   id: 2,           │
        │   assignedUserID: nil,                  │   color: 15567157, │
        │   date: Date(2001-01-03T00:00:00.000Z), │   name: "Family"   │
        │   isCompleted: false,                   │ )                  │
        │   isFlagged: true,                      │                    │
        │   notes: "",                            │                    │
        │   priority: .high,                      │                    │
        │   remindersListID: 2,                   │                    │
        │   title: "Pick up kids from school"     │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ RemindersList(     │
        │   id: 7,                                │   id: 2,           │
        │   assignedUserID: nil,                  │   color: 15567157, │
        │   date: Date(2000-12-30T00:00:00.000Z), │   name: "Family"   │
        │   isCompleted: true,                    │ )                  │
        │   isFlagged: false,                     │                    │
        │   notes: "",                            │                    │
        │   priority: .low,                       │                    │
        │   remindersListID: 2,                   │                    │
        │   title: "Get laundry"                  │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ RemindersList(     │
        │   id: 8,                                │   id: 2,           │
        │   assignedUserID: nil,                  │   color: 15567157, │
        │   date: Date(2001-01-05T00:00:00.000Z), │   name: "Family"   │
        │   isCompleted: false,                   │ )                  │
        │   isFlagged: false,                     │                    │
        │   notes: "",                            │                    │
        │   priority: .high,                      │                    │
        │   remindersListID: 2,                   │                    │
        │   title: "Take out trash"               │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ RemindersList(     │
        │   id: 9,                                │   id: 3,           │
        │   assignedUserID: nil,                  │   color: 11689427, │
        │   date: Date(2001-01-03T00:00:00.000Z), │   name: "Business" │
        │   isCompleted: false,                   │ )                  │
        │   isFlagged: false,                     │                    │
        │   notes: """                            │                    │
        │     Status of tax return                │                    │
        │     Expenses for next year              │                    │
        │     Changing payroll company            │                    │
        │     """,                                │                    │
        │   priority: nil,                        │                    │
        │   remindersListID: 3,                   │                    │
        │   title: "Call accountant"              │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ RemindersList(     │
        │   id: 10,                               │   id: 3,           │
        │   assignedUserID: nil,                  │   color: 11689427, │
        │   date: Date(2000-12-30T00:00:00.000Z), │   name: "Business" │
        │   isCompleted: true,                    │ )                  │
        │   isFlagged: false,                     │                    │
        │   notes: "",                            │                    │
        │   priority: .medium,                    │                    │
        │   remindersListID: 3,                   │                    │
        │   title: "Send weekly emails"           │                    │
        │ )                                       │                    │
        └─────────────────────────────────────────┴────────────────────┘
        """#
      }

      assertQuery(
        RemindersList
          .join(Reminder.all()) { $0.id.eq($1.remindersListID) }
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

      assertQuery(
        Reminder.all()
          .leftJoin(User.all()) { $0.assignedUserID.eq($1.id) }
          .select { ($0.title, $1.name) }
          .limit(2)
      ) {
        """
        SELECT "reminders"."title", "users"."name" FROM "reminders" LEFT JOIN "users" ON ("reminders"."assignedUserID" = "users"."id") LIMIT 2
        """
      } results: {
        """
        ┌─────────────┬────────┐
        │ "Groceries" │ "Blob" │
        │ "Haircut"   │ nil    │
        └─────────────┴────────┘
        """
      }

      assertQuery(
        User.all()
          .rightJoin(Reminder.all()) { $0.id.is($1.assignedUserID) }
          .limit(2)
      ) {
        """
        SELECT "users"."id", "users"."name", "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "users" RIGHT JOIN "reminders" ON ("users"."id" IS "reminders"."assignedUserID") LIMIT 2
        """
      } results: {
        """
        ┌────────────────┬─────────────────────────────────────────┐
        │ User(          │ Reminder(                               │
        │   id: 1,       │   id: 1,                                │
        │   name: "Blob" │   assignedUserID: 1,                    │
        │ )              │   date: Date(2001-01-01T00:00:00.000Z), │
        │                │   isCompleted: false,                   │
        │                │   isFlagged: false,                     │
        │                │   notes: "Milk, Eggs, Apples",          │
        │                │   priority: nil,                        │
        │                │   remindersListID: 1,                   │
        │                │   title: "Groceries"                    │
        │                │ )                                       │
        ├────────────────┼─────────────────────────────────────────┤
        │ nil            │ Reminder(                               │
        │                │   id: 2,                                │
        │                │   assignedUserID: nil,                  │
        │                │   date: Date(2000-12-30T00:00:00.000Z), │
        │                │   isCompleted: false,                   │
        │                │   isFlagged: true,                      │
        │                │   notes: "",                            │
        │                │   priority: nil,                        │
        │                │   remindersListID: 1,                   │
        │                │   title: "Haircut"                      │
        │                │ )                                       │
        └────────────────┴─────────────────────────────────────────┘
        """
      }

      assertQuery(
        User.all()
          .rightJoin(Reminder.all()) { $0.id.is($1.assignedUserID) }
          .limit(2)
          .select { ($0, $1) }
      ) {
        """
        SELECT "users"."id", "users"."name", "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "users" RIGHT JOIN "reminders" ON ("users"."id" IS "reminders"."assignedUserID") LIMIT 2
        """
      } results: {
        """
        ┌────────────────┬─────────────────────────────────────────┐
        │ User(          │ Reminder(                               │
        │   id: 1,       │   id: 1,                                │
        │   name: "Blob" │   assignedUserID: 1,                    │
        │ )              │   date: Date(2001-01-01T00:00:00.000Z), │
        │                │   isCompleted: false,                   │
        │                │   isFlagged: false,                     │
        │                │   notes: "Milk, Eggs, Apples",          │
        │                │   priority: nil,                        │
        │                │   remindersListID: 1,                   │
        │                │   title: "Groceries"                    │
        │                │ )                                       │
        ├────────────────┼─────────────────────────────────────────┤
        │ nil            │ Reminder(                               │
        │                │   id: 2,                                │
        │                │   assignedUserID: nil,                  │
        │                │   date: Date(2000-12-30T00:00:00.000Z), │
        │                │   isCompleted: false,                   │
        │                │   isFlagged: true,                      │
        │                │   notes: "",                            │
        │                │   priority: nil,                        │
        │                │   remindersListID: 1,                   │
        │                │   title: "Haircut"                      │
        │                │ )                                       │
        └────────────────┴─────────────────────────────────────────┘
        """
      }

      assertQuery(
        User.all()
          .rightJoin(Reminder.all()) { $0.id.is($1.assignedUserID) }
          .select { ($1.title, $0.name) }
          .limit(2)
      ) {
        """
        SELECT "reminders"."title", "users"."name" FROM "users" RIGHT JOIN "reminders" ON ("users"."id" IS "reminders"."assignedUserID") LIMIT 2
        """
      } results: {
        """
        ┌─────────────┬────────┐
        │ "Groceries" │ "Blob" │
        │ "Haircut"   │ nil    │
        └─────────────┴────────┘
        """
      }

      assertQuery(
        Reminder.all()
          .fullJoin(User.all()) { $0.assignedUserID.eq($1.id) }
          .select { ($0.title, $1.name) }
          .limit(2)
      ) {
        """
        SELECT "reminders"."title", "users"."name" FROM "reminders" FULL JOIN "users" ON ("reminders"."assignedUserID" = "users"."id") LIMIT 2
        """
      } results: {
        """
        ┌─────────────┬────────┐
        │ "Groceries" │ "Blob" │
        │ "Haircut"   │ nil    │
        └─────────────┴────────┘
        """
      }
    }

    @Test func `where`() {
      assertQuery(
        Reminder.where(\.isCompleted)
      ) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM "reminders" WHERE "reminders"."isCompleted"
        """
      } results: {
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

    @Test func group() {
      assertQuery(
        Reminder.select { ($0.isCompleted, $0.id.count()) }.group(by: \.isCompleted)
      ) {
        """
        SELECT "reminders"."isCompleted", count("reminders"."id") FROM "reminders" GROUP BY "reminders"."isCompleted"
        """
      } results: {
        """
        ┌───────┬───┐
        │ false │ 7 │
        │ true  │ 3 │
        └───────┴───┘
        """
      }
    }

    @Test func having() {
      assertQuery(
        Reminder
          .select { ($0.isCompleted, $0.id.count()) }
          .group(by: \.isCompleted)
          .having { $0.id.count() > 3 }
      ) {
        """
        SELECT "reminders"."isCompleted", count("reminders"."id") FROM "reminders" GROUP BY "reminders"."isCompleted" HAVING (count("reminders"."id") > 3)
        """
      } results: {
        """
        ┌───────┬───┐
        │ false │ 7 │
        └───────┴───┘
        """
      }
    }

    @Test func order() {
      assertQuery(
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
      assertQuery(
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
      assertQuery(
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

    @Test func limit() {
      assertQuery(Reminder.select(\.id).limit(2)) {
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
      assertQuery(Reminder.select(\.id).limit(2, offset: 2)) {
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

    @Test func count() {
      assertQuery(Reminder.count()) {
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
      @Test func dynamicMember() {
        assertQuery(
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

    @Test func rawSelect() {
      // TODO: \(quoted:) or \(identifier:)
      assertQuery(
        #sql("SELECT \(Reminder.columns) FROM \(raw: Reminder.tableName) LIMIT 2", as: Reminder.self),
      ) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" FROM reminders LIMIT 2
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
        │   id: 2,                                │
        │   assignedUserID: nil,                  │
        │   date: Date(2000-12-30T00:00:00.000Z), │
        │   isCompleted: false,                   │
        │   isFlagged: true,                      │
        │   notes: "",                            │
        │   priority: nil,                        │
        │   remindersListID: 1,                   │
        │   title: "Haircut"                      │
        │ )                                       │
        └─────────────────────────────────────────┘
        """
      }
      assertQuery(
        #sql(
          """
          SELECT \(Reminder.columns), \(RemindersList.columns) FROM \(raw: Reminder.tableName) \
          JOIN \(raw: RemindersList.tableName) \
          ON \(Reminder.columns.remindersListID) = \(RemindersList.columns.id) \
          LIMIT 2
          """,
          as: (Reminder, RemindersList).self
        )
      ) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title", "remindersLists"."id", "remindersLists"."color", "remindersLists"."name" FROM reminders JOIN remindersLists ON "reminders"."remindersListID" = "remindersLists"."id" LIMIT 2
        """
      } results: {
        """
        ┌─────────────────────────────────────────┬────────────────────┐
        │ Reminder(                               │ RemindersList(     │
        │   id: 1,                                │   id: 1,           │
        │   assignedUserID: 1,                    │   color: 4889071,  │
        │   date: Date(2001-01-01T00:00:00.000Z), │   name: "Personal" │
        │   isCompleted: false,                   │ )                  │
        │   isFlagged: false,                     │                    │
        │   notes: "Milk, Eggs, Apples",          │                    │
        │   priority: nil,                        │                    │
        │   remindersListID: 1,                   │                    │
        │   title: "Groceries"                    │                    │
        │ )                                       │                    │
        ├─────────────────────────────────────────┼────────────────────┤
        │ Reminder(                               │ RemindersList(     │
        │   id: 2,                                │   id: 1,           │
        │   assignedUserID: nil,                  │   color: 4889071,  │
        │   date: Date(2000-12-30T00:00:00.000Z), │   name: "Personal" │
        │   isCompleted: false,                   │ )                  │
        │   isFlagged: true,                      │                    │
        │   notes: "",                            │                    │
        │   priority: nil,                        │                    │
        │   remindersListID: 1,                   │                    │
        │   title: "Haircut"                      │                    │
        │ )                                       │                    │
        └─────────────────────────────────────────┴────────────────────┘
        """
      }
    }
  }
}
