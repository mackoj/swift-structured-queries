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
      // TODO: assertInlineSnapshot(of: Todo.insert([Todo.Draft(deleted: Date())]), as: .sql)
    }
  }
}
