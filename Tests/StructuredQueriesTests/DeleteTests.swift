import Dependencies
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct DeleteTests {
    @Test func deleteAll() {
      assertQuery(Reminder.delete().returning(\.id)) {
        """
        DELETE FROM "reminders"
        RETURNING "reminders"."id"
        """
      } results: {
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
      }
      assertQuery(Reminder.count()) {
        """
        SELECT count(*)
        FROM "reminders"
        """
      } results: {
        """
        ┌───┐
        │ 0 │
        └───┘
        """
      }
    }

    @Test func deleteID1() {
      assertQuery(Reminder.delete().where { $0.id == 1 }.returning(\.self)) {
        """
        DELETE FROM "reminders"
        WHERE ("reminders"."id" = 1)
        RETURNING "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title"
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
      assertQuery(Reminder.count()) {
        """
        SELECT count(*)
        FROM "reminders"
        """
      } results: {
        """
        ┌───┐
        │ 9 │
        └───┘
        """
      }
    }

    @Test func primaryKey() {
      assertQuery(Reminder.delete(Reminder(id: 1, remindersListID: 1))) {
        """
        DELETE FROM "reminders"
        WHERE ("reminders"."id" = 1)
        """
      }
      assertQuery(Reminder.count()) {
        """
        SELECT count(*)
        FROM "reminders"
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
