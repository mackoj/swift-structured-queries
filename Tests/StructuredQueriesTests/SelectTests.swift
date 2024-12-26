import StructuredQueries
import Testing

struct SelectTests {
  @Table
  struct SyncUp: Equatable {
    var id: Int
    var isActive: Bool
    var title: String
  }

  @Table
  struct Attendee: Equatable {
    var id: Int
    var name: String
    var syncUpID: Int
  }

  @Test func basics() {
    #expect(
      SyncUp.all().queryString == """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps"
        """
    )
  }

  @Test func select() {
    #expect(
      SyncUp.all().select(\.id).queryString == """
        SELECT "syncUps"."id" \
        FROM "syncUps"
        """
    )
  }

  @Test func distinct() {
    #expect(
      SyncUp.all().select(distinct: true, \.self).queryString == """
        SELECT DISTINCT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps"
        """
    )
  }

  @Test func join() {
    #expect(
      SyncUp.all().join(Attendee.all()) { $0.id == $1.syncUpID }
        .queryString == """
          SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title", \
          "attendees"."id", "attendees"."name", "attendees"."syncUpID" \
          FROM "syncUps" \
          JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
          """
    )
    #expect(
      SyncUp.all().join(left: Attendee.all()) { $0.id == $1.syncUpID }
        .queryString == """
          SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title", \
          "attendees"."id", "attendees"."name", "attendees"."syncUpID" \
          FROM "syncUps" \
          LEFT JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
          """
    )
    #expect(
      SyncUp.all().join(right: Attendee.all()) { $0.id == $1.syncUpID }
        .queryString == """
          SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title", \
          "attendees"."id", "attendees"."name", "attendees"."syncUpID" \
          FROM "syncUps" \
          RIGHT JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
          """
    )
    #expect(
      SyncUp.all().join(full: Attendee.all()) { $0.id == $1.syncUpID }
        .queryString == """
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
        .queryString == """
          SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
          FROM "syncUps" \
          WHERE "syncUps"."isActive"
          """
    )
    #expect(
      SyncUp.all().where { $0.id == 1 && $0.isActive }.queryString
      == SyncUp.all().where { $0.id == 1 }.where(\.isActive).queryString
    )
  }

  @Test func order() {
    #expect(
      SyncUp.all().order(\.title)
        .queryString == """
          SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
          FROM "syncUps" \
          ORDER BY "syncUps"."title"
          """
    )
    #expect(
      SyncUp.all().order { ($0.title.descending(), $0.id) }
        .queryString == """
          SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
          FROM "syncUps" \
          ORDER BY "syncUps"."title" DESC, "syncUps"."id"
          """
    )
    let condition = false
    #expect(
      SyncUp.all().order {
        if condition {
          ($0.title.descending(), $0.id)
        } else {
          $0.title
        }
      }
      .queryString == """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps" \
        ORDER BY "syncUps"."title"
        """
    )
    #expect(
      SyncUp.all().order {
        if condition {
          $0.title
        }
      }
      .queryString == """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps"
        """
    )
  }
}
