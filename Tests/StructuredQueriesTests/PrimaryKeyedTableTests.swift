import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct PrimaryKeyedTableTests {
    @Test func count() {
      assertQuery(Reminder.select { $0.count() }) {
        """
        SELECT count("reminders"."id")
        FROM "reminders"
        """
      } results: {
        """
        ┌────┐
        │ 10 │
        └────┘
        """
      }
    }

    @Test func joinWith() {
      //RemindersList.join(Reminder.all, with: \.remindersListID)
      //Reminder.join(RemindersList.all, with: \.remindersListID)
    }
  }
}
