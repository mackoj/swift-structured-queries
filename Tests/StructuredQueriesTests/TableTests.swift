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
        assertQuery(Row.select(\.id)) {
          """
          SELECT "rows"."id"
          FROM "rows"
          WHERE NOT ("rows"."isDeleted")
          """
        } results: {
          """
          ┌───┐
          │ 1 │
          └───┘
          """
        }
        assertQuery(Row.unscoped) {
          """
          SELECT "rows"."id", "rows"."isDeleted"
          FROM "rows"
          """
        } results: {
          """
          ┌─────────────────────────────────────────────┐
          │ SnapshotTests.TableTests.DefaultSelect.Row( │
          │   id: 1,                                    │
          │   isDeleted: false                          │
          │ )                                           │
          ├─────────────────────────────────────────────┤
          │ SnapshotTests.TableTests.DefaultSelect.Row( │
          │   id: 2,                                    │
          │   isDeleted: true                           │
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

      init() throws {
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
      }

      @Test func basics() throws {
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
        // TODO: Can we de-dupe this 'where' condition?
        assertQuery(Row.select(\.id)) {
          """
          SELECT "rows"."id"
          FROM "rows"
          WHERE NOT ("rows"."isDeleted") AND NOT ("rows"."isDeleted")
          """
        } results: {
          """
          ┌───┐
          │ 1 │
          └───┘
          """
        }
        assertQuery(Row.unscoped) {
          """
          SELECT "rows"."id", "rows"."isDeleted"
          FROM "rows"
          """
        } results: {
          """
          ┌────────────────────────────────────────────┐
          │ SnapshotTests.TableTests.DefaultWhere.Row( │
          │   id: 1,                                   │
          │   isDeleted: false                         │
          │ )                                          │
          ├────────────────────────────────────────────┤
          │ SnapshotTests.TableTests.DefaultWhere.Row( │
          │   id: 2,                                   │
          │   isDeleted: true                          │
          │ )                                          │
          └────────────────────────────────────────────┘
          """
        }
      }

      @Test func delete() throws {
        assertQuery(
          Row
            .where { $0.id > 0 }
            .delete()
            .returning(\.self)
        ) {
          """
          DELETE FROM "rows"
          WHERE NOT ("rows"."isDeleted") AND ("rows"."id" > 0)
          RETURNING "id", "isDeleted"
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

        assertQuery(
          Row
            .unscoped
            .where { $0.id > 0 }
            .delete()
            .returning(\.self)
        ) {
          """
          DELETE FROM "rows"
          WHERE ("rows"."id" > 0)
          RETURNING "id", "isDeleted"
          """
        } results: {
          """
          ┌────────────────────────────────────────────┐
          │ SnapshotTests.TableTests.DefaultWhere.Row( │
          │   id: 2,                                   │
          │   isDeleted: true                          │
          │ )                                          │
          └────────────────────────────────────────────┘
          """
        }
      }

      @Test func update() throws {
        assertQuery(
          Row
            .where { $0.id > 0 }
            .update { $0.isDeleted.toggle() }
            .returning(\.self)
        ) {
          """
          UPDATE "rows"
          SET "isDeleted" = NOT ("rows"."isDeleted")
          WHERE NOT ("rows"."isDeleted") AND ("rows"."id" > 0)
          RETURNING "id", "isDeleted"
          """
        } results: {
          """
          ┌────────────────────────────────────────────┐
          │ SnapshotTests.TableTests.DefaultWhere.Row( │
          │   id: 1,                                   │
          │   isDeleted: true                          │
          │ )                                          │
          └────────────────────────────────────────────┘
          """
        }

        assertQuery(
          Row
            .unscoped
            .where { $0.id > 0 }
            .update { $0.isDeleted.toggle() }
            .returning(\.self)
        ) {
          """
          UPDATE "rows"
          SET "isDeleted" = NOT ("rows"."isDeleted")
          WHERE ("rows"."id" > 0)
          RETURNING "id", "isDeleted"
          """
        } results: {
          """
          ┌────────────────────────────────────────────┐
          │ SnapshotTests.TableTests.DefaultWhere.Row( │
          │   id: 1,                                   │
          │   isDeleted: false                         │
          │ )                                          │
          ├────────────────────────────────────────────┤
          │ SnapshotTests.TableTests.DefaultWhere.Row( │
          │   id: 2,                                   │
          │   isDeleted: false                         │
          │ )                                          │
          └────────────────────────────────────────────┘
          """
        }
      }
    }
  }
}
