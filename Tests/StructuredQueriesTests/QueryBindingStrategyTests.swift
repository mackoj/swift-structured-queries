import InlineSnapshotTesting
import Foundation
import StructuredQueries
import Testing

extension SnapshotTests {
  struct QueryBindingStrategyTests {
    @Table
    fileprivate struct Todo {
      let id: Int
      @Column("deleted", as: .iso8601)
      var deleted: Date?

      static let deleted = Self.where { $0.deleted != nil }
    }

    @Test func optionality() {
      assertInlineSnapshot(of: Todo.deleted, as: .sql) {
        """
        SELECT "todos"."id", "todos"."deleted" FROM "todos" WHERE ("todos"."deleted" IS NOT NULL)
        """
      }
      let date = Date(timeIntervalSince1970: 0)
      assertInlineSnapshot(of: Todo.insert([Todo.Draft(deleted: date)]), as: .sql) {
        """
        INSERT INTO "todos" ("deleted") VALUES ('1970-01-01T00:00:00Z')
        """
      }
      assertInlineSnapshot(of: Todo.insert([Todo.Draft(deleted: nil)]), as: .sql) {
        """
        INSERT INTO "todos" ("deleted") VALUES (NULL)
        """
      }
    }
  }
}
