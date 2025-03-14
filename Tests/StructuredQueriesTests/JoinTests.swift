import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct JoinTests {
    @Test func basics() {
      assertInlineSnapshot(
        of: SyncUp.join(Attendee.all()) { $0.id.eq($1.syncUpID) }
          .order { syncUps, _ in syncUps.createdAt.desc() },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."duration", "syncUps"."title", "syncUps"."isActive", "syncUps"."createdAt", "attendees"."id", "attendees"."syncUpID", "attendees"."name", "attendees"."createdAt" FROM "syncUps" JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID") ORDER BY "syncUps"."createdAt" DESC
        """
      }
    }
  }
}

@Table
private struct SyncUp {
  let id: Int
  var duration: Int
  var title: String
  var isActive: Bool
  @Column(as: Date.ISO8601Representation.self)
  var createdAt: Date
}

@Table
private struct Attendee {
  let id: Int
  var syncUpID: Int
  var name: String
  @Column(as: Date.ISO8601Representation.self)
  var createdAt: Date
}
