import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct DeleteTests {
    @Test func basics() {
      assertInlineSnapshot(
        of:
          SyncUp
          .delete(),
        as: .sql
      ) {
        """
        DELETE FROM "syncUps"
        """
      }
      assertInlineSnapshot(
        of:
          SyncUp
          .delete()
          .returning(\.self),
        as: .sql
      ) {
        """
        DELETE FROM "syncUps" RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt"
        """
      }
      assertInlineSnapshot(
        of:
          SyncUp
          .delete()
          .where(\.isActive)
          .returning(\.self),
        as: .sql
      ) {
        """
        DELETE FROM "syncUps" WHERE "syncUps"."isActive" RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt"
        """
      }
    }

    @Test func primaryKey() {
      assertInlineSnapshot(
        of:
          SyncUp
          .delete(SyncUp(id: 1, isActive: true, createdAt: Date(timeIntervalSinceNow: 0)))
          .returning(\.self),
        as: .sql
      ) {
        """
        DELETE FROM "syncUps" WHERE ("syncUps"."id" = 1) RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt"
        """
      }
    }

    @Table
    struct SyncUp {
      let id: Int
      var isActive: Bool
      @Column(as: Date.ISO8601Representation.self)
      var createdAt: Date
    }

    @Table
    struct Attendee {
      let id: Int
      var syncUpID: Int
      var name: String
      @Column(as: Date.ISO8601Representation.self)
      var createdAt: Date
    }
  }
}
