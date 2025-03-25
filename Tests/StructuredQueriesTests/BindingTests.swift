import Dependencies
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct BindingTests {
    @Dependency(\.defaultDatabase) var db
    init() throws {
      try db.execute(
        """
        CREATE TABLE records (id BLOB PRIMARY KEY, name TEXT, duration INTEGER);
        """
      )
    }

    @Test func bytes() throws {
      assertQuery(
        Record
          .insert(
            Record.Draft(
              id: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef"),
              name: "Blob"
            )
          )
          .returning(\.self)
      ) {
        #"""
        INSERT INTO "records" ("id", "name", "duration") VALUES ('\u{07AD}��ޭ��ޭ��ޭ��', 'Blob', 0) RETURNING "records"."id", "records"."name", "records"."duration"
        """#
      }results: {
        """
        ┌───────────────────────────────────────────────────┐
        │ Record(                                           │
        │   id: UUID(DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF), │
        │   name: "Blob",                                   │
        │   duration: 0                                     │
        │ )                                                 │
        └───────────────────────────────────────────────────┘
        """
      }
    }

    @Test func overflow() throws {
      assertQuery(
        Record
          .insert(
            Record.Draft(
              id: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef"),
              duration: UInt64.max
            )
          )
          .returning(\.self)
      ) {
        #"""
        INSERT INTO "records" ("id", "name", "duration") VALUES ('\u{07AD}��ޭ��ޭ��ޭ��', '', <The operation couldn’t be completed. (StructuredQueriesCore.OverflowError error 1.)>) RETURNING "records"."id", "records"."name", "records"."duration"
        """#
      }results: {
        """
        The operation couldn’t be completed. (StructuredQueriesCore.OverflowError error 1.)
        """
      }
    }
  }
}

@Table
private struct Record: Equatable {
  @Column(as: UUID.BytesRepresentation.self)
  var id: UUID
  var name = ""
  var duration: UInt64 = 0
}
