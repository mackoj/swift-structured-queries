import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct UpdateTests {
    @Table
    fileprivate struct SyncUp: Equatable {
      var id: Int
      var isActive: Bool
      var title: String
    }

    @Test func basics() {
      assertInlineSnapshot(
        of: SyncUp.update {
          $0.isActive = true
          $0.title = "Engineering"
        },
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "isActive" = 1, "title" = 'Engineering'
        """
      }
    }

    @Test func toggleBoolean() {
      assertInlineSnapshot(
        of: SyncUp.update { $0.isActive.toggle() },
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "isActive" = NOT ("syncUps"."isActive")
        """
      }
    }

    @Test func multipleMutations() {
      assertInlineSnapshot(
        of: SyncUp.update {
          $0.title += "!"
          $0.title += "?"
        },
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "title" = ("syncUps"."title" || '!'), "title" = ("syncUps"."title" || '?')
        """
      }
    }

    @Test func conflictResolution() {
      assertInlineSnapshot(
        of: SyncUp.update(or: .abort) { $0.isActive = true },
        as: .sql
      ) {
        """
        UPDATE OR ABORT "syncUps" SET "isActive" = 1
        """
      }
      assertInlineSnapshot(
        of: SyncUp.update(or: .fail) { $0.isActive = true },
        as: .sql
      ) {
        """
        UPDATE OR FAIL "syncUps" SET "isActive" = 1
        """
      }
      assertInlineSnapshot(
        of: SyncUp.update(or: .ignore) { $0.isActive = true },
        as: .sql
      ) {
        """
        UPDATE OR IGNORE "syncUps" SET "isActive" = 1
        """
      }
      assertInlineSnapshot(
        of: SyncUp.update(or: .replace) { $0.isActive = true },
        as: .sql
      ) {
        """
        UPDATE OR REPLACE "syncUps" SET "isActive" = 1
        """
      }
      assertInlineSnapshot(
        of: SyncUp.update(or: .rollback) { $0.isActive = true },
        as: .sql
      ) {
        """
        UPDATE OR ROLLBACK "syncUps" SET "isActive" = 1
        """
      }
    }

    @Test func `where`() {
      assertInlineSnapshot(
        of: SyncUp
          .update {
            $0.isActive = true
            $0.title = "Engineering"
          }
          .where(\.isActive),
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "isActive" = 1, "title" = 'Engineering' WHERE "syncUps"."isActive"
        """
      }
      assertInlineSnapshot(
        of: SyncUp
          .where(\.isActive)
          .update {
            $0.isActive = true
            $0.title = "Engineering"
          },
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "isActive" = 1, "title" = 'Engineering' WHERE "syncUps"."isActive"
        """
      }
    }

    @Test func returning() {
      assertInlineSnapshot(
        of: SyncUp
          .update {
            $0.isActive = true
            $0.title = "Engineering"
          }
          .returning(\.self),
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "isActive" = 1, "title" = 'Engineering' \
        RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."title"
        """
      }
    }

    @Test func record() {
      assertInlineSnapshot(
        of: SyncUp.update(SyncUp(id: 42, isActive: true, title: "Engineering")),
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "isActive" = 1, "title" = 'Engineering' WHERE ("syncUps"."id" = 42)
        """
      }
    }

    @Table
    fileprivate struct Meeting: Equatable {
      @Column(as: .iso8601)
      var date: Date
    }

    @Test func explicitBind() {
      assertInlineSnapshot(
        of: Meeting.update {
          $0.date = .bind(Date(timeIntervalSinceReferenceDate: 0))
        },
        as: .sql
      ) {
        """
        UPDATE "meetings" SET "date" = '2001-01-01 00:00:00'
        """
      }
    }

    @Test func implicitBind() {
      assertInlineSnapshot(
        of: Meeting.update {
          $0.date = Date(timeIntervalSinceReferenceDate: 0)
        },
        as: .sql
      ) {
        """
        UPDATE "meetings" SET "date" = '2001-01-01 00:00:00'
        """
      }
    }
  }
}
