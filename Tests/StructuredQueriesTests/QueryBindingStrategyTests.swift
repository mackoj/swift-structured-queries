import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

struct QueryBindingStrategyTests {
  @Test func optionality() {
    assertInlineSnapshot(of: Todo.deleted.queryString, as: .lines) {
      """
      SELECT "todos"."id", "todos"."deleted" FROM "todos" WHERE ("todos"."deleted" IS NOT NULL)
      """
    }
    assertInlineSnapshot(of: Todo.insert([Todo.Draft(deleted: Date())]).queryString, as: .lines) {
      """
      INSERT INTO "todos" ("deleted") VALUES (?)
      """
    }
  }
}

@Table
fileprivate struct Todo {
  let id: Int
  @Column("deleted", as: .iso8601)
  var deleted: Date?

  static let deleted = Self.where { $0.deleted != nil }
}
