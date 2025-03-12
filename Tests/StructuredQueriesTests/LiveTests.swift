import Foundation
import InlineSnapshotTesting
@testable import StructuredQueries
import StructuredQueriesSQLite
import Testing

extension SnapshotTests {
  @Suite struct LiveTests {
    @Test func select() throws {
      let averagePriority = Reminder.select { $0.priority.cast(as: Int.self).avg() ?? 0 }
      try assertQuery(
        Reminder
          .select { ($0.title, $0.priority, averagePriority) }
          .where { $0.priority.cast(as: Double.self) > averagePriority }
      ) {
        """
        SELECT "reminders"."title", "reminders"."priority", (SELECT coalesce(avg(CAST("reminders"."priority" AS NUMERIC)), 0.0) FROM "reminders") FROM "reminders" WHERE (CAST("reminders"."priority" AS NUMERIC) > (SELECT coalesce(avg(CAST("reminders"."priority" AS NUMERIC)), 0.0) FROM "reminders"))
        """
      } results: {
        """
        ┌──────────────────────────┬────────────────────────────────────────────────┬─────┐
        │ Doctor appointment       │ Optional(StructuredQueriesTests.Priority.high) │ 2.4 │
        │ Pick up kids from school │ Optional(StructuredQueriesTests.Priority.high) │ 2.4 │
        │ Take out trash           │ Optional(StructuredQueriesTests.Priority.high) │ 2.4 │
        └──────────────────────────┴────────────────────────────────────────────────┴─────┘
        """
      }
    }

    @Test func basics() throws {
      let db = try Database()
      try db.execute(
        """
        CREATE TABLE "syncUps" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
          "isActive" BOOLEAN NOT NULL DEFAULT 1,
          "title" TEXT NOT NULL DEFAULT '',
          "createdAt" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        """
      )
      try db.execute(
        """
        CREATE TABLE "attendees" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
          "name" TEXT NOT NULL DEFAULT '',
          "syncUpID" INTEGER NOT NULL,
          "createdAt" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        """
      )
      try db.execute(
        SyncUp.insert()
      )
      #expect(
        try #require(
          try db.execute(SyncUp.all().select(\.createdAt)).first
        )
        .timeIntervalSinceNow < 1
      )

      #expect(
        try #require(try db.execute(SyncUp.all()).first).id == 1
      )
    }

    @Table
    struct SyncUp {
      let id: Int
      var isActive: Bool
      var title: String
      @Column(as: Date.ISO8601Representation.self)
      var createdAt: Date
    }

    @Table
    struct Attendee {
      let id: Int
      var name: String
      var syncUpID: Int
      @Column(as: Date.ISO8601Representation.self)
      var createdAt: Date
    }
  }
}
