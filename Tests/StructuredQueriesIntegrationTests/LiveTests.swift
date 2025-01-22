import StructuredQueries
import StructuredQueriesSQLite
import Testing

@Table
struct SyncUp: Equatable {
  var id: Int
  var isActive: Bool
  var title: String
}

@Table
struct Attendee: Equatable {
  var id: Int
  var name: String
  var syncUpID: Int
}

@Test func live() async throws {
  let db = try Database()
  try db.execute(
    """
    CREATE TABLE "syncUps" (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
      "isActive" BOOLEAN NOT NULL,
      "title" TEXT NOT NULL
    )
    """
  )
  try db.execute(
    """
    CREATE TABLE "attendees" (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
      "syncUpID" INTEGER NOT NULL,
      "name" TEXT NOT NULL
    )
    """
  )

  let syncUp = try #require(
    try db
      .execute(
        SyncUp.insert {
          ($0.isActive, $0.title)
        } values: {
          (true, "Engineering")
        }
        .returning(\.self)
      )
      .first
  )
  #expect(syncUp == SyncUp(id: 1, isActive: true, title: "Engineering"))

  let attendees = try db.execute(
    Attendee.insert {
      ($0.name, $0.syncUpID)
    } values: {
      ("Blob", syncUp.id)
      ("Blob Jr", syncUp.id)
      ("Blob Sr", syncUp.id)
    }
    .returning(\.self)
  )
  #expect(
    attendees == [
      Attendee(id: 1, name: "Blob", syncUpID: 1),
      Attendee(id: 2, name: "Blob Jr", syncUpID: 1),
      Attendee(id: 3, name: "Blob Sr", syncUpID: 1),
    ]
  )

  let syncUps = try db.execute(SyncUp.all())
  #expect(syncUps == [SyncUp(id: 1, isActive: true, title: "Engineering")])

  let leadAttendee = try #require(
    try db.execute(
      Attendee.insert {
        ($0.name, $0.syncUpID)
      } select: {
        SyncUp.all().select { ($0.title + " Lead", $0.id) }
      }
      .returning(\.self)
    )
    .first
  )
  #expect(leadAttendee == Attendee(id: 4, name: "Engineering Lead", syncUpID: 1))

  do {
    let (syncUp, attendeesCount) = try #require(
      try db.execute(
        SyncUp.all()
          .where(\.isActive)
          .group(by: \.id)
          .leftJoin(Attendee.all()) { $0.id == $1.syncUpID }
          .select { ($0, $1.id.count(distinct: true)) }
          .order { $1.id.count(distinct: true).descending() }
      )
      .first
    )
    #expect(syncUp == SyncUp(id: 1, isActive: true, title: "Engineering"))
    #expect(attendeesCount == 4)
  }

  _ = try db.execute(
    SyncUp
      .update { $0.isActive.toggle() }
      .where { $0.id == 1 }
  )

  do {
    let (syncUp, attendeesCount) = try #require(
      try db.execute(
        SyncUp.all()
          .where { !$0.isActive }
          .group(by: \.id)
          .leftJoin(Attendee.all()) { $0.id == $1.syncUpID }
          .select { ($0, $1.id.count(distinct: true)) }
          .order { $1.id.count(distinct: true).descending() }
      )
      .first
    )
    #expect(syncUp == SyncUp(id: 1, isActive: false, title: "Engineering"))
    #expect(attendeesCount == 4)
  }

  _ = try db.execute(
    Attendee.delete()
  )
  let attendeesCount = try #require(
    try db.execute(
      Attendee.all().select { $0.id.count() }
    )
    .first
  )
  #expect(attendeesCount == 0)
}
