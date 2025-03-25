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
        } do: {
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
