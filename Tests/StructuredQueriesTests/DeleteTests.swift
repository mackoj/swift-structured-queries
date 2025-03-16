import Dependencies
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct DeleteTests {
    @Test func deleteAll() throws {
      try assertQuery(Reminder.delete().returning(\.id)) {
        """
        DELETE FROM "reminders" RETURNING "reminders"."id"
        """
      }results: {
        """
        ┌────┐
        │ 1  │
        │ 2  │
        │ 3  │
        │ 4  │
        │ 5  │
        │ 6  │
        │ 7  │
        │ 8  │
        │ 9  │
        │ 10 │
        └────┘
        """
      } results: {
        #"""
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
        ├─────────────────────────────────────────┤
        │ Reminder(                               │
        │   id: 3,                                │
        │   assignedUserID: nil,                  │
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
        │   id: 5,                                │
        │   assignedUserID: nil,                  │
        │   date: nil,                            │
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
        │   assignedUserID: nil,                  │
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
        │   id: 8,                                │
        │   assignedUserID: nil,                  │
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
        │   assignedUserID: nil,                  │
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
        """#
      }
      try assertQuery(Reminder.count()) {
        """
        SELECT count(*) FROM "reminders"
        """
      } results: {
        """
        ┌───┐
        │ 0 │
        └───┘
        """
      }
    }

    @Test func deleteID1() throws {
      try assertQuery(Reminder.delete().where { $0.id == 1 }.returning(\.self)) {
        """
        DELETE FROM "reminders" WHERE ("reminders"."id" = 1) RETURNING "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title"
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
      try assertQuery(Reminder.count()) {
        """
        SELECT count(*) FROM "reminders"
        """
      } results: {
        """
        ┌───┐
        │ 9 │
        └───┘
        """
      }
    }

    @Test func primaryKey() throws {
      try assertQuery(Reminder.delete(Reminder(id: 1, remindersListID: 1))) {
        """
        DELETE FROM "reminders" WHERE ("reminders"."id" = 1)
        """
      }
      try assertQuery(Reminder.count()) {
        """
        SELECT count(*) FROM "reminders"
        """
      } results: {
        """
        ┌───┐
        │ 9 │
        └───┘
        """
      }
    }
  }
}
