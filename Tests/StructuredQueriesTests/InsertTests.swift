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

struct InsertTests {
  @Test func basics() {
    #expect(
      SyncUp
        .insert {
          ($0.isActive, $0.title)
        }
        .sql == """
          INSERT INTO "syncUps" \
          ("isActive", "title") \
          DEFAULT VALUES
          """
    )
  }

  @Test func values() {
    #expect(
      SyncUp
        .insert {
          ($0.isActive, $0.title)
        }
        .values {
          (true, "Engineering")
          (false, "Design")
        }
        .sql == """
          INSERT INTO "syncUps" \
          ("isActive", "title") \
          VALUES \
          (?, ?), \
          (?, ?)
          """
    )
  }

  @Test func select() {
    #expect(
      Attendee
        .insert { ($0.name, $0.syncUpID) }
        .select(
          SyncUp.all().select { ($0.title + " Lead", $0.id) }
        )
        .sql == """
          INSERT INTO "attendees" \
          ("name", "syncUpID") \
          SELECT ("syncUps"."title" || ?), "syncUps"."id" FROM "syncUps"
          """
    )
  }

  @Test func returning() {
    #expect(
      SyncUp
        .insert()
        .returning(\.self)
        .sql == """
          INSERT INTO "syncUps" \
          DEFAULT VALUES \
          RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."title"
          """
    )
  }
}
