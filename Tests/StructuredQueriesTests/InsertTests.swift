import StructuredQueries
import Testing

@Table
private struct SyncUp: Equatable {
  var id: Int
  var isActive: Bool
  var seconds: Double
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
        .queryString == """
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
        .queryString == """
          INSERT OR ABORT INTO "syncUps" \
          ("isActive", "title") \
          DEFAULT VALUES
          """
    )
    #expect(
      SyncUp
        .insert(or: .abort)
        .queryString == """
          INSERT OR ABORT INTO "syncUps" \
          DEFAULT VALUES
          """
    )
    #expect(
      SyncUp
        .insert(or: .fail)
        .queryString == """
          INSERT OR FAIL INTO "syncUps" \
          DEFAULT VALUES
          """
    )
    #expect(
      SyncUp
        .insert(or: .ignore)
        .queryString == """
          INSERT OR IGNORE INTO "syncUps" \
          DEFAULT VALUES
          """
    )
    #expect(
      SyncUp
        .insert(or: .replace)
        .queryString == """
          INSERT OR REPLACE INTO "syncUps" \
          DEFAULT VALUES
          """
    )
    #expect(
      SyncUp
        .insert(or: .rollback)
        .queryString == """
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
        .queryString == """
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
        .queryString == """
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
        .queryString == """
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
        .queryString == """
          INSERT INTO "syncUps" \
          DEFAULT VALUES \
          RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."seconds", "syncUps"."title"
          """
    )
  }

  @Test func singleColumn() {
    #expect(
      SyncUp
        .insert(\.title)
        .values {
          "Engineering"
          "Product"
        }
        .queryString == """
          INSERT INTO "syncUps" \
          ("title") \
          VALUES \
          (?), \
          (?)
          """
    )
    #expect(
      SyncUp
        .insert(\.title)
        .select(Attendee.all().select(\.name))
        .queryString == """
          INSERT INTO "syncUps" \
          ("title") \
          SELECT "attendees"."name" FROM "attendees"
          """
    )
  }

  @Test func inference() {
    #expect(
      SyncUp
        .insert(\.seconds)
        .values { 60 }
        .queryString == """
          INSERT INTO "syncUps" \
          ("seconds") \
          VALUES \
          (?)
          """
    )
    #expect(
      SyncUp
        .insert { ($0.title, $0.seconds) }
        .values { (.untitled, 60) }
        .queryString == """
          INSERT INTO "syncUps" \
          ("title", "seconds") \
          VALUES \
          (?, ?)
          """
    )
  }

  @Test func arrayBuilder() {
    let titles = ["Design", "Engineering", "Product"]
    #expect(
      SyncUp
        .insert(\.title)
        .values {
          for title in titles {
            title
          }
        }
        .queryString == """
          INSERT INTO "syncUps" \
          ("title") \
          VALUES \
          (?), \
          (?), \
          (?)
          """
    )
  }
}

extension String {
  fileprivate static let untitled: Self = "Untitled"
}

public extension InsertValuesBuilder {
  static func buildArray(_ components: [[Value]]) -> [Value] {
    components.flatMap(\.self)
  }
  static func buildBlock(_ components: [Value]) -> [Value] {
    components
  }
}
