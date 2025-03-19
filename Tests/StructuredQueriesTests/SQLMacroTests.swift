import Dependencies
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct SQLMacroTests {
    @Test func rawSelect() {
      // TODO: \(quoted:) or \(identifier:)
      assertQuery(
        #sql(
          """
          SELECT \(Reminder.columns) 
          FROM \(raw: Reminder.tableName)
          ORDER BY \(Reminder.columns.id)
          LIMIT 1
          """,
          as: Reminder.self
        )
      ) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" 
        FROM reminders
        ORDER BY "reminders"."id"
        LIMIT 1
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
    }

    @Test func join() {
      assertQuery(
        #sql(
          """
          SELECT \(Reminder.columns), \(RemindersList.columns) 
          FROM \(raw: Reminder.tableName) \
          JOIN \(raw: RemindersList.tableName) \
            ON \(Reminder.columns.remindersListID) = \(RemindersList.columns.id) \
          LIMIT 1
          """,
          as: (Reminder, RemindersList).self
        )
      ) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title", "remindersLists"."id", "remindersLists"."color", "remindersLists"."name" 
        FROM reminders JOIN remindersLists   ON "reminders"."remindersListID" = "remindersLists"."id" LIMIT 1
        """
      }results: {
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
        └─────────────────────────────────────────┴────────────────────┘
        """
      }
    }

    @Test func selection() {
      assertQuery(
        #sql(
          """
          SELECT \(Reminder.columns), \(RemindersList.columns) 
          FROM \(raw: Reminder.tableName) \
          JOIN \(raw: RemindersList.tableName) \
          ON \(Reminder.columns.remindersListID) = \(RemindersList.columns.id) \
          LIMIT 1
          """,
          as: ReminderWithList.self
        )
      ) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title", "remindersLists"."id", "remindersLists"."color", "remindersLists"."name" 
        FROM reminders JOIN remindersLists ON "reminders"."remindersListID" = "remindersLists"."id" LIMIT 1
        """
      }results: {
        """
        ┌───────────────────────────────────────────┐
        │ ReminderWithList(                         │
        │   reminder: Reminder(                     │
        │     id: 1,                                │
        │     assignedUserID: 1,                    │
        │     date: Date(2001-01-01T00:00:00.000Z), │
        │     isCompleted: false,                   │
        │     isFlagged: false,                     │
        │     notes: "Milk, Eggs, Apples",          │
        │     priority: nil,                        │
        │     remindersListID: 1,                   │
        │     title: "Groceries"                    │
        │   ),                                      │
        │   list: RemindersList(                    │
        │     id: 1,                                │
        │     color: 4889071,                       │
        │     name: "Personal"                      │
        │   )                                       │
        │ )                                         │
        └───────────────────────────────────────────┘
        """
      }
    }
  }
}

@Selection
private struct ReminderWithList {
  let reminder: Reminder
  let list: RemindersList
}
