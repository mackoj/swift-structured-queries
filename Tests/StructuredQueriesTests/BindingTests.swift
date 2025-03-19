import Dependencies
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct BindingTests {
    @Test func bytes() throws {
      @Dependency(\.defaultDatabase) var db
      try db.execute(
        """
        CREATE TABLE records (id BLOB PRIMARY KEY, name TEXT);
        """
      )
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
        INSERT INTO "records" ("id", "name") VALUES ('\u{07AD}��ޭ��ޭ��ޭ��', 'Blob') RETURNING "records"."id", "records"."name"
        """#
      } results: {
        """
        ┌───────────────────────────────────────────────────┐
        │ Record(                                           │
        │   id: UUID(DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF), │
        │   name: "Blob"                                    │
        │ )                                                 │
        └───────────────────────────────────────────────────┘
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
}
