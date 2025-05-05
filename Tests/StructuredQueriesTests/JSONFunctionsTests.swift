import Dependencies
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @MainActor
  @Suite struct JSONFunctionsTests {
    @Dependency(\.defaultDatabase) var db

    @Test func jsonGroupArray() {
      assertQuery(
        Reminder.select {
          $0.title.jsonGroupArray()
        }
      ) {
        """
        SELECT json_group_array("reminders"."title")
        FROM "reminders"
        """
      } results: {
        """
        ┌────────────────────────────────────┐
        │ [                                  │
        │   [0]: "Groceries",                │
        │   [1]: "Haircut",                  │
        │   [2]: "Doctor appointment",       │
        │   [3]: "Take a walk",              │
        │   [4]: "Buy concert tickets",      │
        │   [5]: "Pick up kids from school", │
        │   [6]: "Get laundry",              │
        │   [7]: "Take out trash",           │
        │   [8]: "Call accountant",          │
        │   [9]: "Send weekly emails"        │
        │ ]                                  │
        └────────────────────────────────────┘
        """
      }
    }

    @Test func jsonArrayLength() {
      assertQuery(
        Reminder.select {
          $0.title.jsonGroupArray().jsonArrayLength()
        }
      ) {
        """
        SELECT json_array_length(json_group_array("reminders"."title"))
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

    @Test func queryJSON() throws {
      try db.execute(Reminder.delete())
      try db.execute(
        Reminder.insert(
          [
            Reminder.Draft(
              notes: #"""
                [{"body": "* Milk\n* Eggs"},{"body": "* Eggs"},]
                """#,
              remindersListID: 1,
              title: "Get groceries"
            ),
            Reminder.Draft(
              notes: "[]",
              remindersListID: 1,
              title: "Call accountant"
            ),
          ]
        )
      )

      assertQuery(
        Reminder
          .select {
            (
              $0.title,
              #sql("\($0.notes) ->> '$[#-1].body'", as: String?.self)
            )
          }
      ) {
        """
        SELECT "reminders"."title", "reminders"."notes" ->> '$[#-1].body'
        FROM "reminders"
        """
      } results: {
        """
        ┌───────────────────┬──────────┐
        │ "Get groceries"   │ "* Eggs" │
        │ "Call accountant" │ nil      │
        └───────────────────┴──────────┘
        """
      }
    }
    
    @Test func jsonGroupArrayMultiplePrimaryKeys() {
      assertQuery(
        Reminder
          .join(ReminderTag.all) { $0.id.eq($1.reminderID) }
          .select {
            ReminderTagList.Columns(
              reminder: $0,
              tags: $1.jsonGroupArray()
            )
          }
      ) {
        """
        SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."dueDate", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title" AS "reminder", json_group_array("remindersTags"."reminderID", "remindersTags"."tagID") AS "tags"
        FROM "reminders"
        JOIN "remindersTags" ON ("reminders"."id" = "remindersTags"."reminderID")
        """
      } results: {
        """
        wrong number of arguments to function json_group_array()
        """
      }
    }
  }
}

@Selection
struct ReminderTagList {
  let reminder: Reminder
  @Column(as: JSONRepresentation<[ReminderTag]>.self)
  let tags: [ReminderTag]
}
