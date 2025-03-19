import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct JoinTests {
    @Test func basics() {
      assertQuery(
        Reminder.join(RemindersList.all()) { $0.remindersListID.eq($1.id) }
          .order { reminders, _ in reminders.date.desc() }
          .select { ($0.title, $1.name) }
      ) {
        """
        SELECT "reminders"."title", "remindersLists"."name" FROM "reminders" JOIN "remindersLists" ON ("reminders"."remindersListID" = "remindersLists"."id") ORDER BY "reminders"."date" DESC
        """
      } results: {
        """
        ┌────────────────────────────┬────────────┐
        │ "Take out trash"           │ "Family"   │
        │ "Pick up kids from school" │ "Family"   │
        │ "Call accountant"          │ "Business" │
        │ "Groceries"                │ "Personal" │
        │ "Doctor appointment"       │ "Personal" │
        │ "Haircut"                  │ "Personal" │
        │ "Get laundry"              │ "Family"   │
        │ "Send weekly emails"       │ "Business" │
        │ "Take a walk"              │ "Personal" │
        │ "Buy concert tickets"      │ "Personal" │
        └────────────────────────────┴────────────┘
        """
      }
    }
  }
}
