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
    #expect(try db.execute(SimpleSelect { .raw("0", as: Bool.self) }).first == false)
    #expect(try db.execute(SimpleSelect { .raw("1", as: Bool.self) }).first == true)
    #expect(try db.execute(SimpleSelect { .raw("2", as: Int.self) }).first == 2)
    #expect(try db.execute(SimpleSelect { .raw("3", as: Int8.self) }).first == Int8(3))
    #expect(try db.execute(SimpleSelect { .raw("4", as: Int16.self) }).first == Int16(4))
    #expect(try db.execute(SimpleSelect { .raw("5", as: Int32.self) }).first == Int32(5))
    #expect(try db.execute(SimpleSelect { .raw("6", as: Int64.self) }).first == Int64(6))
    #expect(try db.execute(SimpleSelect { .raw("7", as: UInt8.self) }).first == UInt8(7))
    #expect(try db.execute(SimpleSelect { .raw("8", as: UInt16.self) }).first == UInt16(8))
    #expect(try db.execute(SimpleSelect { .raw("9", as: UInt32.self) }).first == UInt32(9))
    #expect(try db.execute(SimpleSelect { .raw("10", as: Float.self) }).first == Float(10))
    #expect(try db.execute(SimpleSelect { .raw("11", as: Double.self) }).first == 11.0)
    #expect(try db.execute(SimpleSelect { .raw("'Blob'", as: String.self) }).first == "Blob")
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
        SimpleSelect { .raw("3", as: Priority.self) }
      )
      .first == .high
    )
    #expect(
      try db.execute(
        SimpleSelect { .raw("\(Priority.high)", as: Priority.self) }
      )
      .first == .high
    )
  }
}
