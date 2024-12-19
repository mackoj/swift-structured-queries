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

  @Test func select() {
    #expect(
      SyncUp.all().select(\.id).sql == """
        SELECT "syncUps"."id" \
        FROM "syncUps"
        """
    )
  }

  @Test func distinct() {
    #expect(
      SyncUp.all().select(distinct: true, \.self).sql == """
        SELECT DISTINCT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
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
    #expect(
      SyncUp.all().join(left: Attendee.all()) { $0.id == $1.syncUpID }
        .sql == """
          SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title", \
          "attendees"."id", "attendees"."name", "attendees"."syncUpID" \
          FROM "syncUps" \
          LEFT JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
          """
    )
    #expect(
      SyncUp.all().join(right: Attendee.all()) { $0.id == $1.syncUpID }
        .sql == """
          SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title", \
          "attendees"."id", "attendees"."name", "attendees"."syncUpID" \
          FROM "syncUps" \
          RIGHT JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
          """
    )
    #expect(
      SyncUp.all().join(full: Attendee.all()) { $0.id == $1.syncUpID }
        .sql == """
          SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title", \
          "attendees"."id", "attendees"."name", "attendees"."syncUpID" \
          FROM "syncUps" \
          FULL JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
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
    #expect(
      SyncUp.all().where { $0.id == 1 && $0.isActive }.sql
        == SyncUp.all().where { $0.id == 1 }.where(\.isActive).sql
    )
  }
}
