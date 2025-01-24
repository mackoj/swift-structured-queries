import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct DeleteTests {
    @Table
    struct SyncUp: Equatable {
      var id: Int
      var isActive: Bool
      var title: String
    }

    @Test func basics() {
      assertInlineSnapshot(of: SyncUp.delete(), as: .sql) {
        """
        DELETE FROM "syncUps"
        """
      }
    }

    @Test func `where`() {
      assertInlineSnapshot(of: SyncUp.delete().where(\.isActive), as: .sql) {
        """
        DELETE FROM "syncUps" WHERE "syncUps"."isActive"
        """
      }
      assertInlineSnapshot(of: SyncUp.where(\.isActive).delete(), as: .sql) {
        """
        DELETE FROM "syncUps" WHERE "syncUps"."isActive"
        """
      }

      #expect(
        SyncUp.delete().where { $0.id == 1 && $0.isActive }.queryFragment
          == SyncUp.delete().where { $0.id == 1 }.where(\.isActive).queryFragment
      )
    }

    @Test func returning() {
      assertInlineSnapshot(of: SyncUp.delete().returning(\.self), as: .sql) {
        """
        DELETE FROM "syncUps" RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."title"
        """
      }
      assertInlineSnapshot(of: SyncUp.delete().returning(\.id), as: .sql) {
        """
        DELETE FROM "syncUps" RETURNING "syncUps"."id"
        """
      }
    }

    @Test func primaryKey() {
      let syncUp = SyncUp(id: 1, isActive: true, title: "Morning Sync")
      assertInlineSnapshot(of: SyncUp.delete([syncUp]), as: .sql) {
        """
        DELETE FROM "syncUps" WHERE ("syncUps"."id" IN (1))
        """
      }
    }
  }
}
