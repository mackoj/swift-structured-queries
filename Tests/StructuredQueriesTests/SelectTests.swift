import StructuredQueries
import Testing

@Table
private struct SyncUp: Equatable {
  var id: Int
  var isActive: Bool
  var title: String
}

@Table
private struct Attendee: Equatable {
  var id: Int
  var name: String
  var syncUpID: Int
}

struct SelectTests {
  @Test func basics() {
    #expect(
      SyncUp.all().sql == """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps"
        """
    )
  }

  @Test func join() {
    #expect(
      SyncUp.all().join(Attendee.all()) { $0.id == $1.syncUpID }
        .sql == """
          SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title", \
          "attendees"."id", "attendees"."name", "attendees"."syncUpID" \
          FROM "syncUps" \
          JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
          """
    )
  }

  @Test func `where`() {
    #expect(
      SyncUp.all().where(\.isActive)
        .sql == """
          SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
          FROM "syncUps" \
          WHERE "syncUps"."isActive"
          """
    )
  }
}
