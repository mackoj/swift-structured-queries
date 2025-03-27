import Dependencies
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct CommonTableExpressionTests {
    @Dependency(\.defaultDatabase) var db

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
        WITH "incompleteReminders" AS (
          SELECT "reminders"."isFlagged" AS "isFlagged", "reminders"."title" AS "title"
          FROM "reminders"
          WHERE NOT ("reminders"."isCompleted")
        )
        SELECT "incompleteReminders"."isFlagged", "incompleteReminders"."title"
        FROM "incompleteReminders"
        WHERE (("incompleteReminders"."title" COLLATE NOCASE) LIKE '%groceries%')
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
        WITH "incompleteReminders" AS (
          SELECT "reminders"."isFlagged" AS "isFlagged", "reminders"."title" AS "title"
          FROM "reminders"
          WHERE NOT ("reminders"."isCompleted")
        )
        INSERT INTO "reminders"
        ("remindersListID", "title", "isFlagged", "isCompleted")
        SELECT "reminders"."remindersListID", "incompleteReminders"."title", NOT ("incompleteReminders"."isFlagged"), 1
        FROM "incompleteReminders"
        JOIN "reminders" ON ("incompleteReminders"."title" = "reminders"."title")
        LIMIT 1
        RETURNING "reminders"."id", "reminders"."assignedUserID", "reminders"."date", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title"
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

    @Test func update() {
      assertQuery(
        With {
          Reminder
            .where { !$0.isCompleted }
            .select { IncompleteReminder.Columns(isFlagged: $0.isFlagged, title: $0.title) }
        } query: {
          Reminder
            .where { $0.title.in(IncompleteReminder.select(\.title)) }
            .update { $0.title = $0.title.upper() }
            .returning(\.title)
        }
      ) {
        """
        WITH "incompleteReminders" AS (
          SELECT "reminders"."isFlagged" AS "isFlagged", "reminders"."title" AS "title"
          FROM "reminders"
          WHERE NOT ("reminders"."isCompleted")
        )
        UPDATE "reminders"
        SET "title" = upper("reminders"."title")
        WHERE ("reminders"."title" IN (SELECT "incompleteReminders"."title"
        FROM "incompleteReminders"))
        RETURNING "reminders"."title"
        """
      } results: {
        """
        ┌────────────────────────────┐
        │ "GROCERIES"                │
        │ "HAIRCUT"                  │
        │ "DOCTOR APPOINTMENT"       │
        │ "BUY CONCERT TICKETS"      │
        │ "PICK UP KIDS FROM SCHOOL" │
        │ "TAKE OUT TRASH"           │
        │ "CALL ACCOUNTANT"          │
        └────────────────────────────┘
        """
      }
    }

    @Test func delete() {
      assertQuery(
        With {
          Reminder
            .where { !$0.isCompleted }
            .select { IncompleteReminder.Columns(isFlagged: $0.isFlagged, title: $0.title) }
        } query: {
          Reminder
            .where { $0.title.in(IncompleteReminder.select(\.title)) }
            .delete()
            .returning(\.title)
        }
      ) {
        """
        WITH "incompleteReminders" AS (
          SELECT "reminders"."isFlagged" AS "isFlagged", "reminders"."title" AS "title"
          FROM "reminders"
          WHERE NOT ("reminders"."isCompleted")
        )
        DELETE FROM "reminders"
        WHERE ("reminders"."title" IN (SELECT "incompleteReminders"."title"
        FROM "incompleteReminders"))
        RETURNING "reminders"."title"
        """
      } results: {
        """
        ┌────────────────────────────┐
        │ "Groceries"                │
        │ "Haircut"                  │
        │ "Doctor appointment"       │
        │ "Buy concert tickets"      │
        │ "Pick up kids from school" │
        │ "Take out trash"           │
        │ "Call accountant"          │
        └────────────────────────────┘
        """
      }
    }

    @Test func recursive() {
      assertQuery(
        With {
          Count(value: 1)
            .union(Count.select { Count.Columns(value: $0.value + 1) })
        } query: {
          Count.limit(4)
        }
      ) {
        """
        WITH "counts" AS (
          SELECT 1 AS "value"
            UNION
          SELECT ("counts"."value" + 1) AS "value"
          FROM "counts"
        )
        SELECT "counts"."value"
        FROM "counts"
        LIMIT 4
        """
      } results: {
        """
        ┌───┐
        │ 1 │
        │ 2 │
        │ 3 │
        │ 4 │
        └───┘
        """
      }
    }

    @Test func cte2() {
      assertQuery(
        With {
          Reminder
            .where { !$0.isCompleted }
            .select { IncompleteReminder.Columns(isFlagged: $0.isFlagged, title: $0.title) }
        } query: {
          IncompleteReminder
            .where { $0.title.collate(.nocase).contains("groceries") }
            .select { $0.isFlagged }
        }
      ) {
        """
        WITH "incompleteReminders" AS (
          SELECT "reminders"."isFlagged" AS "isFlagged", "reminders"."title" AS "title"
          FROM "reminders"
          WHERE NOT ("reminders"."isCompleted")
        )
        SELECT "incompleteReminders"."isFlagged"
        FROM "incompleteReminders"
        WHERE (("incompleteReminders"."title" COLLATE NOCASE) LIKE '%groceries%')
        """
      } results: {
        """
        ┌───────┐
        │ false │
        └───────┘
        """
      }
    }

    @Test func avg() throws {
      try db.execute(
        #sql(
          """
          CREATE TABLE "employees" (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT,
            "bossID" INTEGER REFERENCES "employees",
            "height" INTEGER NOT NULL,
            "name" TEXT NOT NULL
          )
          """
        )
      )
      try db.execute(
        Employee.insert([
          Employee.Draft(name: "Root", bossID: nil, height: 100),
          Employee.Draft(name: "Alice", bossID: 1, height: 120),
          Employee.Draft(name: "Blob", bossID: 2, height: 90),
          Employee.Draft(name: "Blob Jr", bossID: 3, height: 80),
          Employee.Draft(name: "Blob Sr", bossID: 3, height: 150),
          Employee.Draft(name: "Blob Esq", bossID: 1, height: 1000),
        ])
      )

      assertQuery(
        With {
          WorksForAlice(id: 2, name: "Alice")
            .union(
              Employee
                .select { WorksForAlice.Columns(id: $0.id, name: $0.name) }
                .join(WorksForAlice.all()) { $0.bossID.eq($1.id) }
            )
        } query: {
          Employee
            .select { $0.height.avg() }
            .where { $0.id.neq(2) && $0.name.in(WorksForAlice.select(\.name)) }
        }
      ) {
        """
        WITH "worksForAlices" AS (
          SELECT 2 AS "id", 'Alice' AS "name"
            UNION
          SELECT "employees"."id" AS "id", "employees"."name" AS "name"
          FROM "employees"
          JOIN "worksForAlices" ON ("employees"."bossID" = "worksForAlices"."id")
        )
        SELECT avg("employees"."height")
        FROM "employees"
        WHERE (("employees"."id" <> 2) AND ("employees"."name" IN (SELECT "worksForAlices"."name"
        FROM "worksForAlices")))
        """
      } results: {
        """
        ┌────────────────────┐
        │ 106.66666666666667 │
        └────────────────────┘
        """
      }

      assertQuery(
        #sql(
          """
          WITH \(WorksForAlice.self) AS (
            \(WorksForAlice(id: 2, name: "Alice"))
            UNION 
            SELECT \(Employee.id), \(Employee.name)
            FROM \(Employee.self) 
            JOIN \(WorksForAlice.self) ON (\(Employee.bossID) = \(WorksForAlice.id))
          ) 
          SELECT \(Employee.height.avg())
          FROM \(Employee.self) 
          WHERE \(Employee.name) IN (\(WorksForAlice.select(\.name)))
          AND \(Employee.id) <> 2
          """,
          as: Double.self
        )
      ) {
        """
        WITH "worksForAlices" AS (
          SELECT 2 AS "id", 'Alice' AS "name"
          UNION 
          SELECT "employees"."id", "employees"."name"
          FROM "employees" 
          JOIN "worksForAlices" ON ("employees"."bossID" = "worksForAlices"."id")
        ) 
        SELECT avg("employees"."height")
        FROM "employees" 
        WHERE "employees"."name" IN (SELECT "worksForAlices"."name"
        FROM "worksForAlices")
        AND "employees"."id" <> 2
        """
      } results: {
        """
        ┌────────────────────┐
        │ 106.66666666666667 │
        └────────────────────┘
        """
      }
    }

    // TODO: Get an example of tree printing
    // https://www.sqlite.org/lang_with.html
  }
}

@Table @Selection
private struct IncompleteReminder {
  let isFlagged: Bool
  let title: String
}

// TODO: How to support, e.g., '.select { $0.remindersList.name }'
// @Table @Selection
// private struct RemindersListWithRemindersCount {
//   let remindersList: RemindersList
//   let remindersCount: Int
// }

@Table @Selection
private struct Count {
  let value: Int
}

extension Count {
  init(queryOutput: Int) {
    value = queryOutput
  }
  var queryOutput: Int {
    value
  }
}

@Table
struct Employee {
  let id: Int
  let name: String
  let bossID: Int?
  let height: Int
}

@Table @Selection
struct WorksForAlice {
  let id: Int
  let name: String
}
