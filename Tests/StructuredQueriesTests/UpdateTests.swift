import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct UpdateTests {
    @Test func basics() {
      assertInlineSnapshot(
        of:
          SyncUp
          .update { $0.isActive = true },
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "isActive" = 1
        """
      }
      assertInlineSnapshot(
        of:
          SyncUp
          .update { $0.isActive = true }
          .returning(\.self),
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "isActive" = 1 RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt", "syncUps"."title"
        """
      }
      assertInlineSnapshot(
        of:
          SyncUp
          .update { $0.isActive = false }
          .where(\.isActive)
          .returning(\.self),
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "isActive" = 0 WHERE "syncUps"."isActive" RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt", "syncUps"."title"
        """
      }
    }

    @Test func primaryKey() {
      assertInlineSnapshot(
        of:
          SyncUp
          .update(
            SyncUp(id: 1, isActive: true, createdAt: Date(timeIntervalSinceReferenceDate: 0))
          ),
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "isActive" = 1, "createdAt" = '2001-01-01 00:00:00.000', "title" = '' WHERE ("syncUps"."id" = 1)
        """
      }
    }

    @Test func toggleAssignment() {
      assertInlineSnapshot(
        of: SyncUp.update {
          $0.isActive = !$0.isActive
        },
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "isActive" = NOT ("syncUps"."isActive")
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
        UPDATE "syncUps" SET "isActive" = 1, "title" = 'Engineering' RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."createdAt", "syncUps"."title"
        """
      }
    }

    @Test func record() {
      assertInlineSnapshot(
        of: SyncUp.update(
          SyncUp(
            id: 42,
            isActive: true,
            createdAt: Date(timeIntervalSince1970: 123456789),
            title: "Engineering"
          )
        ),
        as: .sql
      ) {
        """
        UPDATE \
        "syncUps" SET "isActive" = 1, "createdAt" = '1973-11-29 21:33:09.000', "title" = 'Engineering' \
        WHERE ("syncUps"."id" = 42)
        """
      }
    }

    @Test func date() {
      assertInlineSnapshot(
        of: SyncUp.update {
          $0.createdAt = Date(timeIntervalSinceReferenceDate: 0)
        },
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "createdAt" = '2001-01-01 00:00:00.000'
        """
      }
    }

    @Test func rawBind() {
      assertInlineSnapshot(
        of: SyncUp.update {
          $0.createdAt = RawQueryExpression("CURRENT_TIMESTAMP")
          // TODO: does not compile, but also may be removing '.raw'
          _ = $0
        },
        as: .sql
      ) {
        """
        UPDATE "syncUps" SET "createdAt" = CURRENT_TIMESTAMP
        """
      }
    }
  }
}

@Table
private struct SyncUp {
  let id: Int
  var isActive: Bool
  @Column(as: Date.ISO8601Representation.self)
  var createdAt: Date
  var title = ""
}

@Table
private struct Attendee {
  let id: Int
  var syncUpID: Int
  var name: String
  @Column(as: Date.ISO8601Representation.self)
  var createdAt: Date
}
