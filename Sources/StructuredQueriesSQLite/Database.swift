import Foundation
import SQLite3
import StructuredQueries

public struct Database {
  private let storage: Storage

  public init(_ ptr: OpaquePointer) {
    self.storage = .unowned(ptr)
  }

  public init(path: String = ":memory:") throws {
    var handle: OpaquePointer?
    let code = sqlite3_open_v2(
      path,
      &handle,
      SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
      nil
    )
    guard code == SQLITE_OK, let handle else { throw SQLiteError(code: code) }
    self.storage = .owned(Storage.Autoreleasing(handle))
  }

  public func execute(
    _ sql: String
  ) throws {
    guard sqlite3_exec(storage.handle, sql, nil, nil, nil) == SQLITE_OK
    else { throw SQLiteError(db: storage.handle) }
  }

  public func execute(_ query: some Statement<()>) throws {
    _ = try execute(query) as [()]
  }

  public func execute<QueryValue: QueryRepresentable>(
    _ query: some Statement<QueryValue>
  ) throws -> [QueryValue.QueryOutput] {
    let query = query.query
    guard !query.isEmpty else { return [] }
    return try withStatement(query) { statement in
      var results: [QueryValue.QueryOutput] = []
      let decoder = SQLiteQueryDecoder(database: storage.handle, statement: statement)
      loop: while true {
        let code = sqlite3_step(statement)
        switch code {
        case SQLITE_ROW:
          try results.append(QueryValue(decoder: decoder).queryOutput)
          decoder.next()
        case SQLITE_DONE:
          break loop
        default:
          throw SQLiteError(db: storage.handle)
        }
      }
      return results
    }
  }

  public func execute<each V: QueryRepresentable>(
    _ query: some Statement<(repeat each V)>
  ) throws -> [(repeat (each V).QueryOutput)] {
    let query = query.query
    guard !query.isEmpty else { return [] }
    return try withStatement(query) { statement in
      var results: [(repeat (each V).QueryOutput)] = []
      let decoder = SQLiteQueryDecoder(database: storage.handle, statement: statement)
      loop: while true {
        let code = sqlite3_step(statement)
        switch code {
        case SQLITE_ROW:
          try results.append((repeat (each V)(decoder: decoder).queryOutput))
          decoder.next()
        case SQLITE_DONE:
          break loop
        default:
          throw SQLiteError(db: storage.handle)
        }
      }
      return results
    }
  }

  public func execute<S: SelectStatement, each J: Table>(
    _ query: S
  ) throws -> [(S.From.QueryOutput, repeat (each J).QueryOutput)]
  where S.QueryValue == (), S.Joins == (repeat each J) {
    try execute(query.selectStar())
  }

  private func withStatement<R>(
    _ query: QueryFragment, body: (OpaquePointer) throws -> R
  ) throws -> R {
    var statement: OpaquePointer?
    let code = sqlite3_prepare_v2(storage.handle, query.string, -1, &statement, nil)
    guard code == SQLITE_OK, let statement
    else { throw SQLiteError(db: storage.handle) }
    defer { sqlite3_finalize(statement) }
    for (index, binding) in zip(Int32(1)..., query.bindings) {
      let result =
        switch binding {
        case let .blob(blob):
          sqlite3_bind_blob(statement, index, Array(blob), Int32(blob.count), SQLITE_TRANSIENT)
        case let .double(double):
          sqlite3_bind_double(statement, index, double)
        case let .int(int):
          sqlite3_bind_int64(statement, index, Int64(int))
        case .null:
          sqlite3_bind_null(statement, index)
        case let .text(text):
          sqlite3_bind_text(statement, index, text, -1, SQLITE_TRANSIENT)
        }
      guard result == SQLITE_OK else { throw SQLiteError(db: storage.handle) }
    }
    return try body(statement)
  }

  private enum Storage {
    case owned(Autoreleasing)
    case unowned(OpaquePointer)

    var handle: OpaquePointer {
      switch self {
      case let .owned(storage):
        return storage.handle
      case let .unowned(handle):
        return handle
      }
    }

    final class Autoreleasing {
      fileprivate var handle: OpaquePointer

      init(_ handle: OpaquePointer) {
        self.handle = handle
      }

      deinit {
        sqlite3_close_v2(handle)
      }
    }
  }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

struct SQLiteError: LocalizedError {
  let message: String

  init(db handle: OpaquePointer?) {
    self.message = String(cString: sqlite3_errmsg(handle))
  }

  init(code: Int32) {
    self.message = String(cString: sqlite3_errstr(code))
  }

  var errorDescription: String? {
    message
  }
}
