import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct SelectionTests {
    @Test func attendeeNameAndSyncUpIsActive() {
      assertInlineSnapshot(
        of: Attendee
          .join(SyncUp.all()) { $0.syncUpID == $1.id }
          .select {
            AttendeeNameAndSyncUpIsActive.Columns(
              attendeeName: $0.name,
              syncUpIsActive: $1.isActive
            )
          },
        as: .sql
      ) {
        """
        SELECT "attendees"."name", "syncUps"."isActive" \
        FROM "attendees" \
        JOIN "syncUps" ON ("attendees"."syncUpID" = "syncUps"."id")
        """
      }
    }

    @Test func syncUpWithAttendeeCount() {
      assertInlineSnapshot(
        of: SyncUp
          .join(Attendee.all()) { $0.id == $1.syncUpID }
          .select {
            SyncUpWithAttendeeCount.Columns(
              attendeeCount: $1.id.count(),
              syncUp: $0
            )
          },
        as: .sql
      ) {
        """
        SELECT count("attendees"."id"), \
        "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt", "syncUps"."title" \
        FROM "syncUps" JOIN "attendees" \
        ON ("syncUps"."id" = "attendees"."syncUpID")
        """
      }
    }

    @Test func attendeeAndSyncUp() {
      assertInlineSnapshot(
        of: Attendee
          .join(SyncUp.all()) { $0.syncUpID == $1.id }
          .select(AttendeeAndSyncUp.Columns.init(attendee:syncUp:)),
        as: .sql
      ) {
        """
        SELECT \
        "attendees"."id", "attendees"."syncUpID", "attendees"."name", "attendees"."createdAt", \
        "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt", "syncUps"."title" \
        FROM "attendees" \
        JOIN "syncUps" ON ("attendees"."syncUpID" = "syncUps"."id")
        """
      }
    }
  }
}

@Table
private struct SyncUp {
  let id: Int
  var isActive: Bool
  @Column(as: Date.ISO8601Representation.self)
  var createdAt: Date
  var title = ""
}

@Table
private struct Attendee {
  let id: Int
  var syncUpID: Int
  var name: String
  @Column(as: Date.ISO8601Representation.self)
  var createdAt: Date
}

@Selection
private struct AttendeeNameAndSyncUpIsActive {
  var attendeeName: String
  var syncUpIsActive: Bool
}

@Selection
private struct SyncUpWithAttendeeCount {
  var attendeeCount: Int
  var syncUp: SyncUp
}

@Selection
private struct AttendeeAndSyncUp {
  var attendee: Attendee
  var syncUp: SyncUp
}
