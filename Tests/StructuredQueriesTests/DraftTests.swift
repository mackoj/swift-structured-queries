import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct DraftTests {
    @Table
    struct SyncUp: Equatable {
      var id: Int
      var isActive: Bool
      var seconds: Double
      var title: String
    }

    @Test func basics() {
      assertInlineSnapshot(
        of:
          SyncUp
          .insert([SyncUp.Draft(isActive: true, seconds: 60, title: "Engineering")])
          .returning(\.self),
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" ("id", "isActive", "seconds", "title") VALUES (NULL, 1, 60.0, 'Engineering') RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."seconds", "syncUps"."title"
        """
      }
    }
  }
}
