import Dependencies
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct UpdateTests {
    @Dependency(\.defaultDatabase) var db

    @Test func basics() {
      assertQuery(
        Reminder
          .update { $0.isCompleted.toggle() }
          .returning { ($0.title, $0.priority, $0.isCompleted) }
      ) {
        """
        UPDATE "reminders"
        SET "isCompleted" = NOT ("reminders"."isCompleted")
        RETURNING "title", "priority", "isCompleted"
        """
      } results: {
        """
        ┌────────────────────────────┬─────────┬───────┐
        │ "Groceries"                │ nil     │ true  │
        │ "Haircut"                  │ nil     │ true  │
        │ "Doctor appointment"       │ .high   │ true  │
        │ "Take a walk"              │ nil     │ false │
        │ "Buy concert tickets"      │ nil     │ true  │
        │ "Pick up kids from school" │ .high   │ true  │
        │ "Get laundry"              │ .low    │ false │
        │ "Take out trash"           │ .high   │ true  │
        │ "Call accountant"          │ nil     │ true  │
        │ "Send weekly emails"       │ .medium │ false │
        └────────────────────────────┴─────────┴───────┘
        """
      }
      assertQuery(
        Reminder
          .where { $0.priority == nil }
          .update { $0.isCompleted = true }
          .returning { ($0.title, $0.priority, $0.isCompleted) }
      ) {
        """
        UPDATE "reminders"
        SET "isCompleted" = 1
        WHERE ("reminders"."priority" IS NULL)
        RETURNING "title", "priority", "isCompleted"
        """
      } results: {
        """
        ┌───────────────────────┬─────┬──────┐
        │ "Groceries"           │ nil │ true │
        │ "Haircut"             │ nil │ true │
        │ "Take a walk"         │ nil │ true │
        │ "Buy concert tickets" │ nil │ true │
        │ "Call accountant"     │ nil │ true │
        └───────────────────────┴─────┴──────┘
        """
      }
    }

    @Test func primaryKey() throws {
      var reminder = try #require(try db.execute(Reminder.all).first)
      reminder.isCompleted.toggle()
      assertQuery(
        Reminder
          .update(reminder)
          .returning(\.self)
      ) {
        """
        UPDATE "reminders"
        SET "assignedUserID" = 1, "date" = '2001-01-01 00:00:00.000', "isCompleted" = 1, "isFlagged" = 0, "notes" = 'Milk, Eggs, Apples', "priority" = NULL, "remindersListID" = 1, "title" = 'Groceries'
        WHERE ("reminders"."id" = 1)
        RETURNING "id", "assignedUserID", "date", "isCompleted", "isFlagged", "notes", "priority", "remindersListID", "title"
        """
      } results: {
        """
        ┌─────────────────────────────────────────┐
        │ Reminder(                               │
        │   id: 1,                                │
        │   assignedUserID: 1,                    │
        │   date: Date(2001-01-01T00:00:00.000Z), │
        │   isCompleted: true,                    │
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

    @Test func toggleAssignment() {
      assertInlineSnapshot(
        of: Reminder.update {
          $0.isCompleted = !$0.isCompleted
        },
        as: .sql
      ) {
        """
        UPDATE "reminders"
        SET "isCompleted" = NOT ("reminders"."isCompleted")
        """
      }
    }

    @Test func toggleBoolean() {
      assertInlineSnapshot(
        of: Reminder.update { $0.isCompleted.toggle() },
        as: .sql
      ) {
        """
        UPDATE "reminders"
        SET "isCompleted" = NOT ("reminders"."isCompleted")
        """
      }
    }

    @Test func multipleMutations() {
      assertInlineSnapshot(
        of: Reminder.update {
          $0.title += "!"
          $0.title += "?"
        },
        as: .sql
      ) {
        """
        UPDATE "reminders"
        SET "title" = ("reminders"."title" || '!'), "title" = ("reminders"."title" || '?')
        """
      }
    }

    @Test func conflictResolution() {
      assertInlineSnapshot(
        of: Reminder.update(or: .abort) { $0.isCompleted = true },
        as: .sql
      ) {
        """
        UPDATE OR ABORT "reminders"
        SET "isCompleted" = 1
        """
      }
      assertInlineSnapshot(
        of: Reminder.update(or: .fail) { $0.isCompleted = true },
        as: .sql
      ) {
        """
        UPDATE OR FAIL "reminders"
        SET "isCompleted" = 1
        """
      }
      assertInlineSnapshot(
        of: Reminder.update(or: .ignore) { $0.isCompleted = true },
        as: .sql
      ) {
        """
        UPDATE OR IGNORE "reminders"
        SET "isCompleted" = 1
        """
      }
      assertInlineSnapshot(
        of: Reminder.update(or: .replace) { $0.isCompleted = true },
        as: .sql
      ) {
        """
        UPDATE OR REPLACE "reminders"
        SET "isCompleted" = 1
        """
      }
      assertInlineSnapshot(
        of: Reminder.update(or: .rollback) { $0.isCompleted = true },
        as: .sql
      ) {
        """
        UPDATE OR ROLLBACK "reminders"
        SET "isCompleted" = 1
        """
      }
    }

    @Test func rawBind() {
      assertInlineSnapshot(
        of: Reminder.update {
          $0.date = #sql("CURRENT_TIMESTAMP")
        },
        as: .sql
      ) {
        """
        UPDATE "reminders"
        SET "date" = CURRENT_TIMESTAMP
        """
      }
    }

    @Test func aliasName() {
      enum R: AliasName {}
      assertQuery(
        Reminder.as(R.self)
          .where { $0.id.eq(1) }
          .update { $0.title += " 2" }
          .returning(\.self)
      ) {
        """
        UPDATE "reminders" AS "rs"
        SET "title" = ("rs"."title" || ' 2')
        WHERE ("rs"."id" = 1)
        RETURNING "id", "assignedUserID", "date", "isCompleted", "isFlagged", "notes", "priority", "remindersListID", "title"
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
        │   title: "Groceries 2"                  │
        │ )                                       │
        └─────────────────────────────────────────┘
        """
      }
    }
  }
}
