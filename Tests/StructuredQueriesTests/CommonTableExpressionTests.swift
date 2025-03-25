import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct CommonTableExpressionTests {
    @Test func basics() {
      assertQuery(
        With {
          Reminder
            .where { !$0.isCompleted }
            .select { IncompleteReminder.Columns(isFlagged: $0.isFlagged, title: $0.title) }
        } query: {
          IncompleteReminder
            .where { $0.title.collate(.nocase).contains("groceries") }
        }
      ) {
        """
        WITH "incompleteReminders" AS (SELECT "reminders"."isFlagged" AS "isFlagged", "reminders"."title" AS "title" FROM "reminders" WHERE NOT ("reminders"."isCompleted")) SELECT "incompleteReminders"."isFlagged", "incompleteReminders"."title" FROM "incompleteReminders" WHERE (("incompleteReminders"."title" COLLATE NOCASE) LIKE '%groceries%')
        """
      } results: {
        """
        ┌──────────────────────┐
        │ IncompleteReminder(  │
        │   isFlagged: false,  │
        │   title: "Groceries" │
        │ )                    │
        └──────────────────────┘
        """
      }
    }

    @Test func insert() {
      assertQuery(
        With {
          Reminder
            .where { !$0.isCompleted }
            .select { IncompleteReminder.Columns(isFlagged: $0.isFlagged, title: $0.title) }
        } query: {
          Reminder.insert {
            ($0.remindersListID, $0.title, $0.isFlagged, $0.isCompleted)
          } select: {
            IncompleteReminder
              .join(Reminder.all()) { $0.title.eq($1.title) }
              .select { ($1.remindersListID, $0.title, !$0.isFlagged, true) }
              .limit(1)
          }
          .returning(\.self)
        }
      ) {
        """
        WITH "incompleteReminders" AS (SELECT "reminders"."isFlagged" AS "isFlagged", "reminders"."title" AS "title" FROM "reminders" WHERE NOT ("reminders"."isCompleted")) INSERT INTO "reminders" ("remindersListID", "title", "isFlagged", "isCompleted") SELECT "reminders"."remindersListID", "incompleteReminders"."title", NOT ("incompleteReminders"."isFlagged"), 1 FROM "incompleteReminders" JOIN "reminders" ON ("incompleteReminders"."title" = "reminders"."title") LIMIT 1 RETURNING "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title"
        """
      } results: {
        """
        ┌────────────────────────┐
        │ Reminder(              │
        │   id: 11,              │
        │   assignedUserID: nil, │
        │   date: nil,           │
        │   isCompleted: true,   │
        │   isFlagged: true,     │
        │   notes: "",           │
        │   priority: nil,       │
        │   remindersListID: 1,  │
        │   title: "Groceries"   │
        │ )                      │
        └────────────────────────┘
        """
      }
    }
  }
}

@Table @Selection
private struct IncompleteReminder {
  let isFlagged: Bool
  let title: String
}

// TODO: How to support:
// @Table @Selection
// private struct RemindersListWithRemindersCount {
//   let remindersList: RemindersList
//   let remindersCount: Int
// }
