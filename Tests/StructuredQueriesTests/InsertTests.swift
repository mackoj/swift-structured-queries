import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
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
      assertInlineSnapshot(
        of: SyncUp.insert {
          ($0.isActive, $0.title)
        } values: {
          (true, "Engineering")
        },
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" ("isActive", "title") VALUES (1, 'Engineering')
        """
      }
    }

    @Test func conflictResolution() {
      assertInlineSnapshot(
        of: SyncUp.insert(or: .abort) {
          ($0.isActive, $0.title)
        } values: {
          (true, "Engineering")
        },
        as: .sql
      ) {
        """
        INSERT OR ABORT INTO "syncUps" ("isActive", "title") VALUES (1, 'Engineering')
        """
      }
      assertInlineSnapshot(
        of: SyncUp.insert(or: .fail) {
          ($0.isActive, $0.title)
        } values: {
          (true, "Engineering")
        },
        as: .sql
      ) {
        """
        INSERT OR FAIL INTO "syncUps" ("isActive", "title") VALUES (1, 'Engineering')
        """
      }
      assertInlineSnapshot(
        of: SyncUp.insert(or: .ignore) {
          ($0.isActive, $0.title)
        } values: {
          (true, "Engineering")
        },
        as: .sql
      ) {
        """
        INSERT OR IGNORE INTO "syncUps" ("isActive", "title") VALUES (1, 'Engineering')
        """
      }
      assertInlineSnapshot(
        of: SyncUp.insert(or: .replace) {
          ($0.isActive, $0.title)
        } values: {
          (true, "Engineering")
        },
        as: .sql
      ) {
        """
        INSERT OR REPLACE INTO "syncUps" ("isActive", "title") VALUES (1, 'Engineering')
        """
      }
      assertInlineSnapshot(
        of: SyncUp.insert(or: .rollback) {
          ($0.isActive, $0.title)
        } values: {
          (true, "Engineering")
        },
        as: .sql
      ) {
        """
        INSERT OR ROLLBACK INTO "syncUps" ("isActive", "title") VALUES (1, 'Engineering')
        """
      }
    }

    @Test func multipleValues() {
      assertInlineSnapshot(
        of: SyncUp.insert(or: .abort) {
          ($0.isActive, $0.title)
        } values: {
          (true, "Engineering")
          (false, "Design")
        },
        as: .sql
      ) {
        """
        INSERT OR ABORT INTO "syncUps" ("isActive", "title") \
        VALUES (1, 'Engineering'), (0, 'Design')
        """
      }
    }

    @Test func select() {
      assertInlineSnapshot(
        of: Attendee.insert {
          ($0.name, $0.syncUpID)
        } select: {
          SyncUp.all().select { ($0.title + " Lead", $0.id) }
        },
        as: .sql
      ) {
        """
        INSERT INTO "attendees" ("name", "syncUpID") \
        SELECT ("syncUps"."title" || ' Lead'), "syncUps"."id" FROM "syncUps"
        """
      }
    }

    @Test func onConflict() {
      assertInlineSnapshot(
        of: SyncUp.insert {
          ($0.isActive, $0.title)
        } values: {
          (true, "Engineering")
        } onConflict: {
          $0.title += " Copy"
        },
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" ("isActive", "title") VALUES (1, 'Engineering') \
        ON CONFLICT DO UPDATE SET "title" = ("syncUps"."title" || ' Copy')
        """
      }
    }

    @Test func returning() {
      assertInlineSnapshot(
        of: SyncUp
          .insert()
          .returning(\.self),
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" DEFAULT VALUES \
        RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."seconds", "syncUps"."title"
        """
      }
    }

    @Test func singleColumn() {
      assertInlineSnapshot(
        of: SyncUp.insert(\.title) {
          "Engineering"
          "Product"
        },
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" ("title") VALUES ('Engineering'), ('Product')
        """
      }
      assertInlineSnapshot(
        of: SyncUp.insert(\.title) {
          Attendee.all().select(\.name)
        },
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" ("title") SELECT "attendees"."name" FROM "attendees"
        """
      }
    }

    @Test func inference() {
      assertInlineSnapshot(
        of: SyncUp.insert(\.seconds) { 60 },
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" ("seconds") VALUES (60.0)
        """
      }
      assertInlineSnapshot(
        of: SyncUp.insert {
          ($0.title, $0.seconds)
        } values: {
          (.untitled, 60)
        },
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" ("title", "seconds") VALUES ('Untitled', 60.0)
        """
      }
    }

    @Test func builder() {
      let titles = ["Design", "Engineering", "Product"]
      let condition = true
      assertInlineSnapshot(
        of: SyncUp.insert(\.title) {
          for title in titles {
            title
          }
          if condition {
            "Random"
          }
          if condition {
            "Truth"
          } else {
            "Fallacy"
          }
        },
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" ("title") \
        VALUES ('Design'), ('Engineering'), ('Product'), ('Random'), ('Truth')
        """
      }
    }

    @Test func records() {
      assertInlineSnapshot(
        of: SyncUp.insert([
          SyncUp(id: 1, isActive: true, seconds: 60, title: "Engineering"),
          SyncUp(id: 2, isActive: false, seconds: 15 * 60, title: "Product"),
        ]),
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" ("id", "isActive", "seconds", "title") \
        VALUES (1, 1, 60.0, 'Engineering'), (2, 0, 900.0, 'Product')
        """
      }
      #expect(SyncUp.insert([]).queryFragment.isEmpty)
    }

    @Test func upsert() {
      assertInlineSnapshot(
        of: SyncUp.upsert(SyncUp.Draft(isActive: true, seconds: 60, title: "Engineering")),
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" ("id", "isActive", "seconds", "title") \
        VALUES (NULL, 1, 60.0, 'Engineering') \
        ON CONFLICT DO UPDATE SET "isActive" = 1, "seconds" = 60.0, "title" = 'Engineering'
        """
      }
      assertInlineSnapshot(
        of: SyncUp.upsert(SyncUp.Draft(id: 1, isActive: true, seconds: 60, title: "Engineering")),
        as: .sql
      ) {
        """
        INSERT INTO "syncUps" ("id", "isActive", "seconds", "title") \
        VALUES (1, 1, 60.0, 'Engineering') \
        ON CONFLICT DO UPDATE SET "isActive" = 1, "seconds" = 60.0, "title" = 'Engineering'
        """
      }
    }
  }
}

extension String {
  fileprivate static let untitled: Self = "Untitled"
}
