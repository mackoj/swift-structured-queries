import Foundation
import SQLite3
import StructuredQueries

public final class Database {
  private var db: OpaquePointer?

  public init(path: String = ":memory:") throws {
    guard
      sqlite3_open_v2(
        path,
        &db,
        SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
        nil
      ) == SQLITE_OK
    else {
      throw SQLiteError()
    }
  }

  deinit {
    sqlite3_close_v2(db)
  }

  public func execute(
    _ sql: String
  ) throws {
    guard sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK
    else {
      throw SQLiteError()
    }
  }

  public func execute<each Value: QueryDecodable>(
    _ query: some Statement<[(repeat each Value)]>
  ) throws -> [(repeat each Value)] {
    var statement: OpaquePointer?
    guard
      sqlite3_prepare_v2(db, query.queryString, -1, &statement, nil) == SQLITE_OK,
      let statement
    else {
      throw SQLiteError()
    }
    defer { sqlite3_finalize(statement) }
    for (index, binding) in zip(Int32(1)..., query.queryBindings) {
      let result =
        switch binding {
        case let .blob(blob):
          sqlite3_bind_blob(statement, index, blob, -1, SQLITE_TRANSIENT)
        case let .double(double):
          sqlite3_bind_double(statement, index, double)
        case let .int(int):
          sqlite3_bind_int64(statement, index, Int64(int))
        case .null:
          sqlite3_bind_null(statement, index)
        case let .text(text):
          sqlite3_bind_text(statement, index, text, -1, SQLITE_TRANSIENT)
        }
      guard result == SQLITE_OK else { throw SQLiteError() }
    }
    var results: [(repeat each Value)] = []
    let decoder = SQLiteQueryDecoder(statement: statement)
    loop: while true {
      let code = sqlite3_step(statement)
      switch code {
      case SQLITE_ROW:
        try results.append((repeat (each Value)(decoder: decoder)))
        decoder.next()
      case SQLITE_DONE:
        break loop
      default:
        throw SQLiteError()
      }
    }
    return results
  }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
