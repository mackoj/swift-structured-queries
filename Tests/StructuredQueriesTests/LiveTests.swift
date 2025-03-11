import Foundation
import InlineSnapshotTesting
@testable import StructuredQueries
import StructuredQueriesSQLite
import Testing

extension SnapshotTests {
  @Suite struct LiveTests {
    @Test func basics() throws {
      let db = try Database()
      try db.execute(
        """
        CREATE TABLE "syncUps" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
          "isActive" BOOLEAN NOT NULL DEFAULT 1,
          "title" TEXT NOT NULL DEFAULT '',
          "createdAt" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        """
      )
      try db.execute(
        """
        CREATE TABLE "attendees" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
          "name" TEXT NOT NULL DEFAULT '',
          "syncUpID" INTEGER NOT NULL,
          "createdAt" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        """
      )
      try db.execute(
        SyncUp.insert()
      )
      #expect(
        try #require(
          try db.execute(SyncUp.all().select(\.createdAt)).first
        )
        .timeIntervalSinceNow < 1
      )

      #expect(
        try #require(try db.execute(SyncUp.all()).first).id == 1
      )
    }

    @Table
    struct SyncUp {
      let id: Int
      var isActive: Bool
      var title: String
      @Column(as: Date.ISO8601Representation.self)
      var createdAt: Date
    }

    @Table
    struct Attendee {
      let id: Int
      var name: String
      var syncUpID: Int
      @Column(as: Date.ISO8601Representation.self)
      var createdAt: Date
    }
  }
}
