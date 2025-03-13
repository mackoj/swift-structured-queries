import SQLite3
import StructuredQueries

final class SQLiteQueryDecoder: QueryDecoder {
  private let database: OpaquePointer?
  private let statement: OpaquePointer
  private var currentIndex: Int32 = 0

  init(database: OpaquePointer?, statement: OpaquePointer) {
    self.database = database
    self.statement = statement
  }

  func next() {
    currentIndex = 0
  }

  func decodeNil() throws -> Bool {
    guard currentIndex < sqlite3_column_count(statement) else { throw SQLiteError(database) }
    let isNil = sqlite3_column_type(statement, currentIndex) == SQLITE_NULL
    if isNil { currentIndex += 1 }
    return isNil
  }

  func decode(_ type: Double.Type) throws -> Double {
    defer { currentIndex += 1 }
    guard currentIndex < sqlite3_column_count(statement) else { throw SQLiteError(database) }
    return sqlite3_column_double(statement, currentIndex)
  }

  func decode(_ type: Int64.Type) throws -> Int64 {
    defer { currentIndex += 1 }
    guard currentIndex < sqlite3_column_count(statement) else { throw SQLiteError(database) }
    return sqlite3_column_int64(statement, currentIndex)
  }

  func decode(_ type: String.Type) throws -> String {
    defer { currentIndex += 1 }
    guard currentIndex < sqlite3_column_count(statement) else { throw SQLiteError(database) }
    return String(cString: sqlite3_column_text(statement, currentIndex))
  }

  func decode(_ type: ContiguousArray<UInt8>.Type) throws -> ContiguousArray<UInt8> {
    defer { currentIndex += 1 }
    guard currentIndex < sqlite3_column_count(statement) else { throw SQLiteError(database) }
    return ContiguousArray<UInt8>(
      UnsafeRawBufferPointer(
        start: sqlite3_column_blob(statement, currentIndex),
        count: Int(sqlite3_column_bytes(statement, currentIndex))
      )
    )
  }
}
