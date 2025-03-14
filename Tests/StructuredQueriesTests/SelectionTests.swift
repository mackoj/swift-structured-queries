import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct SelectionTests {
    @Test func remindersListAndReminderCount() throws {
      try assertQuery(
        RemindersList
          .group(by: \.id)
          .limit(2)
          .join(Reminder.all()) { $0.id.eq($1.remindersListID) }
          .select {
            RemindersListAndReminderCount.Columns(remindersList: $0, remindersCount: $1.id.count())
          }
      ) {
        """
        SELECT "remindersLists"."id", "remindersLists"."color", "remindersLists"."name", count("reminders"."id") FROM "remindersLists" JOIN "reminders" ON ("remindersLists"."id" = "reminders"."remindersListID") GROUP BY "remindersLists"."id" LIMIT 2
        """
      } results: {
        """
        ┌─────────────────────────────────┐
        │ RemindersListAndReminderCount(  │
        │   remindersList: RemindersList( │
        │     id: 1,                      │
        │     color: 4889071,             │
        │     name: "Personal"            │
        │   ),                            │
        │   remindersCount: 5             │
        │ )                               │
        ├─────────────────────────────────┤
        │ RemindersListAndReminderCount(  │
        │   remindersList: RemindersList( │
        │     id: 2,                      │
        │     color: 15567157,            │
        │     name: "Family"              │
        │   ),                            │
        │   remindersCount: 3             │
        │ )                               │
        └─────────────────────────────────┘
        """
      }
    }

    @Test func leftJoin() throws {
      try assertQuery(
      Reminder
        .limit(2)
        .leftJoin(User.all()) { $0.assignedUserID.eq($1.id) }
        .select {
          ReminderTitleAndAssignedUserName.Columns(
            reminderTitle: $0.title,
            assignedUserName: $1.name
          )
        }
      ) {
        """
        SELECT "reminders"."title", "users"."name" FROM "reminders" LEFT JOIN "users" ON ("reminders"."assignedUserID" = "users"."id") LIMIT 2
        """
      } results: {
        """
        ┌───────────────────────────────────┐
        │ ReminderTitleAndAssignedUserName( │
        │   reminderTitle: "Groceries",     │
        │   assignedUserName: "Blob"        │
        │ )                                 │
        ├───────────────────────────────────┤
        │ ReminderTitleAndAssignedUserName( │
        │   reminderTitle: "Haircut",       │
        │   assignedUserName: nil           │
        │ )                                 │
        └───────────────────────────────────┘
        """
      }
    }
  }
}

@Selection
struct ReminderTitleAndAssignedUserName {
  let reminderTitle: String
  let assignedUserName: String?
}

@Selection struct RemindersListAndReminderCount {
  let remindersList: RemindersList
  let remindersCount: Int
}
