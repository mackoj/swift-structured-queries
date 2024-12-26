import StructuredQueries
import Testing

struct InsertTests {
  @Table
  struct SyncUp: Equatable {
    var id: Int
    var isActive: Bool
    var seconds: Double
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
      SyncUp.insert {
        ($0.isActive, $0.title)
      } values: {
        (true, "Engineering")
      }
      .queryString == """
        INSERT INTO "syncUps" \
        ("isActive", "title") \
        VALUES \
        (?, ?)
        """
    )
  }

  @Test func conflictResolution() {
    #expect(
      SyncUp.insert(or: .abort) {
        ($0.isActive, $0.title)
      } values: {
        (true, "Engineering")
      }
      .queryString == """
        INSERT OR ABORT INTO "syncUps" \
        ("isActive", "title") \
        VALUES \
        (?, ?)
        """
    )
    #expect(
      SyncUp.insert(or: .fail) {
        ($0.isActive, $0.title)
      } values: {
        (true, "Engineering")
      }
      .queryString == """
        INSERT OR FAIL INTO "syncUps" \
        ("isActive", "title") \
        VALUES \
        (?, ?)
        """
    )
    #expect(
      SyncUp.insert(or: .ignore) {
        ($0.isActive, $0.title)
      } values: {
        (true, "Engineering")
      }
      .queryString == """
        INSERT OR IGNORE INTO "syncUps" \
        ("isActive", "title") \
        VALUES \
        (?, ?)
        """
    )
    #expect(
      SyncUp.insert(or: .replace) {
        ($0.isActive, $0.title)
      } values: {
        (true, "Engineering")
      }
      .queryString == """
        INSERT OR REPLACE INTO "syncUps" \
        ("isActive", "title") \
        VALUES \
        (?, ?)
        """
    )
    #expect(
      SyncUp.insert(or: .rollback) {
        ($0.isActive, $0.title)
      } values: {
        (true, "Engineering")
      }
      .queryString == """
        INSERT OR ROLLBACK INTO "syncUps" \
        ("isActive", "title") \
        VALUES \
        (?, ?)
        """
    )
  }

  @Test func multipleValues() {
    #expect(
      SyncUp.insert {
        ($0.isActive, $0.title)
      } values: {
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
      Attendee.insert {
        ($0.name, $0.syncUpID)
      } select: {
        SyncUp.all().select { ($0.title + " Lead", $0.id) }
      }
      .queryString == """
        INSERT INTO "attendees" \
        ("name", "syncUpID") \
        SELECT ("syncUps"."title" || ?), "syncUps"."id" FROM "syncUps"
        """
    )
  }

  @Test func onConflict() {
    #expect(
      SyncUp.insert {
        ($0.isActive, $0.title)
      } values: {
        (true, "Engineering")
      } onConflict: {
        $0.title += " Copy"
      }
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
      SyncUp.insert(\.title) {
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
      SyncUp.insert(\.title) {
        Attendee.all().select(\.name)
      }
      .queryString == """
        INSERT INTO "syncUps" \
        ("title") \
        SELECT "attendees"."name" FROM "attendees"
        """
    )
  }

  @Test func inference() {
    #expect(
      SyncUp.insert(\.seconds) { 60 }
        .queryString == """
          INSERT INTO "syncUps" \
          ("seconds") \
          VALUES \
          (?)
          """
    )
    #expect(
      SyncUp.insert {
        ($0.title, $0.seconds)
      } values: {
        (.untitled, 60)
      }
      .queryString == """
        INSERT INTO "syncUps" \
        ("title", "seconds") \
        VALUES \
        (?, ?)
        """
    )
  }

  @Test func builder() {
    let titles = ["Design", "Engineering", "Product"]
    let random = true
    #expect(
      SyncUp.insert(\.title)  {
        for title in titles {
          title
        }
        if random {
          "Random"
        }
        if random {
          "Truth"
        } else {
          "Fallacy"
        }
      }
      .queryString == """
        INSERT INTO "syncUps" \
        ("title") \
        VALUES \
        (?), \
        (?), \
        (?), \
        (?), \
        (?)
        """
    )
  }

  @Test func records() {
    #expect(
      SyncUp.insert([
        SyncUp(id: 1, isActive: true, seconds: 60, title: "Engineering"),
        SyncUp(id: 2, isActive: false, seconds: 15 * 60, title: "Product"),
      ])
      .queryString == """
        INSERT INTO "syncUps" \
        ("id", "isActive", "seconds", "title") \
        VALUES \
        (?, ?, ?, ?), \
        (?, ?, ?, ?)
        """
    )
    #expect(SyncUp.insert([]).queryString.isEmpty)
  }
}

extension String {
  fileprivate static let untitled: Self = "Untitled"
}
