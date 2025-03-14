import Foundation
import StructuredQueries
import StructuredQueriesSQLite
import Testing

struct DecodingTests {
  let db: Database

  init() throws {
    db = try Database()
  }

  @Test func basics() throws {
    #expect(try db.execute(SimpleSelect { #sql("0", as: Bool.self) }).first == false)
    #expect(try db.execute(SimpleSelect { #sql("1", as: Bool.self) }).first == true)
    #expect(try db.execute(SimpleSelect { #sql("2", as: Int.self) }).first == 2)
    #expect(try db.execute(SimpleSelect { #sql("3", as: Int8.self) }).first == Int8(3))
    #expect(try db.execute(SimpleSelect { #sql("4", as: Int16.self) }).first == Int16(4))
    #expect(try db.execute(SimpleSelect { #sql("5", as: Int32.self) }).first == Int32(5))
    #expect(try db.execute(SimpleSelect { #sql("6", as: Int64.self) }).first == Int64(6))
    #expect(try db.execute(SimpleSelect { #sql("7", as: UInt8.self) }).first == UInt8(7))
    #expect(try db.execute(SimpleSelect { #sql("8", as: UInt16.self) }).first == UInt16(8))
    #expect(try db.execute(SimpleSelect { #sql("9", as: UInt32.self) }).first == UInt32(9))
    #expect(try db.execute(SimpleSelect { #sql("10", as: Float.self) }).first == Float(10))
    #expect(try db.execute(SimpleSelect { #sql("11", as: Double.self) }).first == 11.0)
    #expect(try db.execute(SimpleSelect { #sql("'Blob'", as: String.self) }).first == "Blob")
  }

  @Test func blob() throws {
    #expect(
      try db.execute(
        SimpleSelect { "deadbeef".unhex() }
      )
      .first == ContiguousArray<UInt8>([
        0xDE, 0xAD, 0xBE, 0xEF
      ])
    )
  }

  @Test func rawRepresentable() throws {
    enum Priority: Int, QueryBindable { case low = 1, medium, high }
    #expect(
      try db.execute(
        SimpleSelect { #sql("3", as: Priority.self) }
      )
      .first == .high
    )
    #expect(
      try db.execute(
        SimpleSelect { #sql("\(Priority.high)", as: Priority.self) }
      )
      .first == .high
    )
  }

  @Test func queryRepresentable() throws {
    #expect(
      try db.execute(
        SimpleSelect { #sql("'2001-01-01 00:00:00'", as: Date.ISO8601Representation.self) }
      )
      .first == Date(timeIntervalSinceReferenceDate: 0)
    )
    #expect(
      try db.execute(
        SimpleSelect { #sql("1234567890", as: Date.UnixTimeRepresentation.self) }
      )
      .first == Date(timeIntervalSince1970: 1234567890)
    )
    #expect(
      try db.execute(
        SimpleSelect { #sql("2451910.5", as: Date.JulianDayRepresentation.self) }
      )
      .first == Date(timeIntervalSinceReferenceDate: 0)
    )
    #expect(
      try db.execute(
        SimpleSelect {
          #sql("'deadbeef-dead-beef-dead-beefdeadbeef'", as: UUID.LowercasedRepresentation.self)
        }
      )
      .first == UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")
    )
    #expect(
      try db.execute(
        SimpleSelect {
          #sql("'DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF'", as: UUID.UppercasedRepresentation.self)
        }
      )
      .first == UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")
    )
    #expect(
      try db.execute(
        SimpleSelect {
          "deadbeef-dead-beef-dead-beefdeadbeef".unhex("-").cast(as: UUID.BytesRepresentation.self)
        }
      )
      .first == UUID(
        uuid: (
          0xDE, 0xAD, 0xBE, 0xEF,
          0xDE, 0xAD,
          0xBE, 0xEF,
          0xDE, 0xAD,
          0xBE, 0xEF, 0xDE, 0xAD, 0xBE, 0xEF
        )
      )
    )
  }

  func compileTime() throws {
    _ = try #require(
      try db.execute(
        SimpleSelect { #bind(Date(timeIntervalSince1970: 0), as: Date.ISO8601Representation.self) }
      )
      .first
    )
  }
}
