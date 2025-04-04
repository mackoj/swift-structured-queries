import Dependencies
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct TableTests {
    struct DefaultSelect {
      @Dependency(\.defaultDatabase) var db

      @Table
      struct Row {
        static let all = unscoped.where { !$0.isDeleted }
        let id: Int
        var isDeleted = false
      }

      @Test func basics() throws {
        try db.execute(
          #sql(
            """
            CREATE TABLE \(Row.self) (
              \(quote: Row.id.name) INTEGER PRIMARY KEY AUTOINCREMENT,
              \(quote: Row.isDeleted.name) BOOLEAN NOT NULL DEFAULT 0
            )
            """
          )
        )
        try db.execute(
          Row.insert([
            Row.Draft(isDeleted: false),
            Row.Draft(isDeleted: true),
          ])
        )
        assertQuery(Row.where { $0.id > 0 }) {
          """
          SELECT "rows"."id", "rows"."isDeleted"
          FROM "rows"
          WHERE NOT ("rows"."isDeleted") AND ("rows"."id" > 0)
          """
        } results: {
          """
          ┌─────────────────────────────────────────────┐
          │ SnapshotTests.TableTests.DefaultSelect.Row( │
          │   id: 1,                                    │
          │   isDeleted: false                          │
          │ )                                           │
          └─────────────────────────────────────────────┘
          """
        }
      }
    }

    struct DefaultWhere {
      @Dependency(\.defaultDatabase) var db

      @Table
      struct Row {
        static let all = Self.where { !$0.isDeleted }
        let id: Int
        var isDeleted = false
      }

      @Test func basics() throws {
        try db.execute(
          #sql(
            """
            CREATE TABLE \(Row.self) (
              \(quote: Row.id.name) INTEGER PRIMARY KEY AUTOINCREMENT,
              \(quote: Row.isDeleted.name) BOOLEAN NOT NULL DEFAULT 0
            )
            """
          )
        )
        try db.execute(
          Row.insert([
            Row.Draft(isDeleted: false),
            Row.Draft(isDeleted: true),
          ])
        )
        assertQuery(Row.where { $0.id > 0 }) {
          """
          SELECT "rows"."id", "rows"."isDeleted"
          FROM "rows"
          WHERE NOT ("rows"."isDeleted") AND ("rows"."id" > 0)
          """
        } results: {
          """
          ┌────────────────────────────────────────────┐
          │ SnapshotTests.TableTests.DefaultWhere.Row( │
          │   id: 1,                                   │
          │   isDeleted: false                         │
          │ )                                          │
          └────────────────────────────────────────────┘
          """
        }
      }
    }
  }
}
