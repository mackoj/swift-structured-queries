import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct SelectTests {
    @Table
    struct SyncUp: Equatable {
      var id: Int
      var isActive: Bool
      var title: String
      //var isDeleted = false

      // TODO: Should we move `all()` to a protocol requirement and have macro generate this so that people can override it with special conditions
      //    public static func all() -> SelectOf<Self> {
      //      Select().where { !$0.isDeleted }
      //    }

      //    static let withAttendees: SelectOf<SyncUp, Attendee> = SyncUp
      //      .notDeleted
      //      .join(Attendee.notDeleted) { $0.id == $1.syncUpID }
      //
      //    static let notDeleted = all().where { !$0.isDeleted }
    }

    @Table
    struct Attendee: Equatable {
      var id: Int
      var name: String
      var syncUpID: Int
      //    var isDeleted = false

      //    static let notDeleted = all().where { !$0.isDeleted }
      //
      //    // TODO: Can we have a SelectOneOf to force that a single row will be returned
      //    var syncUpQuery: SelectOf<SyncUp> {
      //      SyncUp.notDeleted.where { $0.id == syncUpID }.limit(1)
      //    }
    }

    @Test func basics() {
      assertInlineSnapshot(of: SyncUp.all(), as: .sql) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" FROM "syncUps"
        """
      }
    }

    @Test func select() {
      assertInlineSnapshot(of: SyncUp.all().select(\.id), as: .sql) {
        """
        SELECT "syncUps"."id" FROM "syncUps"
        """
      }
      assertInlineSnapshot(of: SyncUp.all().select(distinct: true, \.self), as: .sql) {
        """
        SELECT DISTINCT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" FROM "syncUps"
        """
      }
    }

    @Test func join() {
      assertInlineSnapshot(
        of: SyncUp.all().join(Attendee.all()) { $0.id == $1.syncUpID },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title", \
        "attendees"."id", "attendees"."name", "attendees"."syncUpID" \
        FROM "syncUps" \
        JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
        """
      }
      assertInlineSnapshot(
        of: SyncUp.all().leftJoin(Attendee.all()) { $0.id == $1.syncUpID },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title", \
        "attendees"."id", "attendees"."name", "attendees"."syncUpID" \
        FROM "syncUps" \
        LEFT JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
        """
      }
      assertInlineSnapshot(
        of: SyncUp.all().rightJoin(Attendee.all()) { $0.id == $1.syncUpID },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title", \
        "attendees"."id", "attendees"."name", "attendees"."syncUpID" \
        FROM "syncUps" \
        RIGHT JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
        """
      }
      assertInlineSnapshot(
        of: SyncUp.all().fullJoin(Attendee.all()) { $0.id == $1.syncUpID },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title", \
        "attendees"."id", "attendees"."name", "attendees"."syncUpID" \
        FROM "syncUps" \
        FULL JOIN "attendees" ON ("syncUps"."id" = "attendees"."syncUpID")
        """
      }
    }

    @Test func `where`() {
      assertInlineSnapshot(of: SyncUp.where(\.isActive), as: .sql) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps" \
        WHERE "syncUps"."isActive"
        """
      }
      #expect(
        SyncUp.all().where { $0.id == 1 && $0.isActive }.queryFragment
          == SyncUp.all().where { $0.id == 1 }.where(\.isActive).queryFragment
      )
    }

    @Test func order() {
      assertInlineSnapshot(of: SyncUp.all().order(\.title), as: .sql) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps" \
        ORDER BY "syncUps"."title"
        """
      }
      assertInlineSnapshot(of: SyncUp.all().order { $0.title.descending() }, as: .sql) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps" \
        ORDER BY "syncUps"."title" DESC
        """
      }
      assertInlineSnapshot(of: SyncUp.all().order { ($0.title.descending(), $0.id) }, as: .sql) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps" \
        ORDER BY "syncUps"."title" DESC, "syncUps"."id"
        """
      }
      let condition = false
      assertInlineSnapshot(
        of: SyncUp.all().order {
          if condition {
            ($0.title.descending(), $0.id)
          } else {
            $0.title
          }
        },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps" \
        ORDER BY "syncUps"."title"
        """
      }
      assertInlineSnapshot(
        of: SyncUp.all().order {
          if condition {
            $0.title
          }
        },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps"
        """
      }
      assertInlineSnapshot(
        of:
          SyncUp
          .where(\.isActive)
          .order {
            switch condition {
            case true:
              $0.title
            case false:
              $0.isActive
            }
          },
        as: .sql
      ) {
        """
        SELECT "syncUps"."id", "syncUps"."isActive", "syncUps"."title" \
        FROM "syncUps" \
        WHERE "syncUps"."isActive" \
        ORDER BY "syncUps"."isActive"
        """
      }
    }

    @Test func selfJoin() {
      assertInlineSnapshot(
        of: Person.all(as: "p1")
          .join(Person.all(as: "p2")) { $0.referrerID == $1.id },
        as: .sql
      ) {
        """
        SELECT "p1"."id", "p1"."name", "p1"."referrerID", \
        "p2"."id", "p2"."name", "p2"."referrerID" \
        FROM "persons" AS "p1" \
        JOIN "persons" AS "p2" ON ("p1"."referrerID" = "p2"."id")
        """
      }
    }

    @Table fileprivate struct Person {
      let id: Int
      let name: String
      let referrerID: Int?
    }
  }
}
