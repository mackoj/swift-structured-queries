import CustomDump
import InlineSnapshotTesting
import StructuredQueries
import Testing

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
        .returning(\.self)
        .queryString,
      as: .lines
    ) {
      """
      INSERT INTO "syncUps" ("isActive", "seconds", "title") VALUES (?, ?, ?) RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."seconds", "syncUps"."title"
      """
    }
  }
}
