import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct UnionTests {
    @Test func basics() throws {
      try assertQuery(
        Reminder.select { ("reminder", $0.title) }
          .union(RemindersList.select { ("list", $0.name) })
          .union(Tag.select { ("tag", $0.name) })
      ) {
        """
        SELECT 'reminder', "reminders"."title" FROM "reminders" UNION SELECT 'list', "remindersLists"."name" FROM "remindersLists" UNION SELECT 'tag', "tags"."name" FROM "tags"
        """
      } results: {
        """
        ┌────────────┬────────────────────────────┐
        │ "list"     │ "Business"                 │
        │ "list"     │ "Family"                   │
        │ "list"     │ "Personal"                 │
        │ "reminder" │ "Buy concert tickets"      │
        │ "reminder" │ "Call accountant"          │
        │ "reminder" │ "Doctor appointment"       │
        │ "reminder" │ "Get laundry"              │
        │ "reminder" │ "Groceries"                │
        │ "reminder" │ "Haircut"                  │
        │ "reminder" │ "Pick up kids from school" │
        │ "reminder" │ "Send weekly emails"       │
        │ "reminder" │ "Take a walk"              │
        │ "reminder" │ "Take out trash"           │
        │ "tag"      │ "car"                      │
        │ "tag"      │ "kids"                     │
        │ "tag"      │ "optional"                 │
        │ "tag"      │ "someday"                  │
        └────────────┴────────────────────────────┘
        """
      }
    }
  }
}
