import SQLite3
import StructuredQueries

final class SQLiteQueryDecoder: QueryDecoder {
  private var statement: OpaquePointer
  private var currentIndex: Int32 = 0

  init(statement: OpaquePointer) {
    self.statement = statement
  }

  func next() {
    currentIndex = 0
  }

  func decodeNil() throws -> Bool {
    guard currentIndex < sqlite3_column_count(statement) else { throw SQLiteError() }
    let isNil = sqlite3_column_type(statement, currentIndex) == SQLITE_NULL
    if isNil { currentIndex += 1 }
    return isNil
  }

  func decode(_ type: Double.Type) throws -> Double {
    defer { currentIndex += 1 }
    guard currentIndex < sqlite3_column_count(statement) else { throw SQLiteError() }
    return sqlite3_column_double(statement, currentIndex)
  }

  func decode(_ type: Int64.Type) throws -> Int64 {
    defer { currentIndex += 1 }
    guard currentIndex < sqlite3_column_count(statement) else { throw SQLiteError() }
    return sqlite3_column_int64(statement, currentIndex)
  }

  func decode(_ type: String.Type) throws -> String {
    defer { currentIndex += 1 }
    guard currentIndex < sqlite3_column_count(statement) else { throw SQLiteError() }
    return String(cString: sqlite3_column_text(statement, currentIndex))
  }

  func decode(_ type: [UInt8].Type) throws -> [UInt8] {
    defer { currentIndex += 1 }
    guard currentIndex < sqlite3_column_count(statement) else { throw SQLiteError() }
    return sqlite3_column_blob(statement, currentIndex).load(as: [UInt8].self)
  }
}
