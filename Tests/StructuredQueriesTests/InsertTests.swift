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

  @Test func conflictResolution() {
    #expect(
      SyncUp
        .insert(or: .abort) {
          ($0.isActive, $0.title)
        }
        .sql == """
          INSERT OR ABORT INTO "syncUps" \
          ("isActive", "title") \
          DEFAULT VALUES
          """
    )
    #expect(
      SyncUp
        .insert(or: .abort)
        .sql == """
          INSERT OR ABORT INTO "syncUps" \
          DEFAULT VALUES
          """
    )
    #expect(
      SyncUp
        .insert(or: .fail)
        .sql == """
          INSERT OR FAIL INTO "syncUps" \
          DEFAULT VALUES
          """
    )
    #expect(
      SyncUp
        .insert(or: .ignore)
        .sql == """
          INSERT OR IGNORE INTO "syncUps" \
          DEFAULT VALUES
          """
    )
    #expect(
      SyncUp
        .insert(or: .replace)
        .sql == """
          INSERT OR REPLACE INTO "syncUps" \
          DEFAULT VALUES
          """
    )
    #expect(
      SyncUp
        .insert(or: .rollback)
        .sql == """
          INSERT OR ROLLBACK INTO "syncUps" \
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

  @Test func onConflict() {
    #expect(
      SyncUp
        .insert { ($0.isActive, $0.title) }
        .values { (true, "Engineering") }
        .onConflict { $0.title += " Copy" }
        .sql == """
          INSERT INTO "syncUps" \
          ("isActive", "title") \
          VALUES \
          (?, ?) \
          ON CONFLICT DO UPDATE SET "title" = ("syncUps"."title" || ?)
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
