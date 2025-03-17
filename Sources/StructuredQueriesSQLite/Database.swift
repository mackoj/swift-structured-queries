import Foundation
import SQLite3
import StructuredQueries

public final class Database {
  private var handle: OpaquePointer?

  public init(path: String = ":memory:") throws {
    guard
      sqlite3_open_v2(
        path,
        &handle,
        SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
        nil
      ) == SQLITE_OK
    else {
      throw SQLiteError(handle)
    }
  }

  deinit {
    sqlite3_close_v2(handle)
  }

  public func execute(
    _ sql: String
  ) throws {
    guard sqlite3_exec(handle, sql, nil, nil, nil) == SQLITE_OK
    else {
      throw SQLiteError(handle)
    }
  }

  public func execute(_ query: some Statement<()>) throws {
    _ = try execute(query) as [()]
  }

  public func execute<QueryValue: QueryRepresentable>(
    _ query: some Statement<QueryValue>
  ) throws -> [QueryValue.QueryOutput] {
    try withStatement(query) { statement in
      var results: [QueryValue.QueryOutput] = []
      let decoder = SQLiteQueryDecoder(database: handle, statement: statement)
      loop: while true {
        let code = sqlite3_step(statement)
        switch code {
        case SQLITE_ROW:
          try results.append(QueryValue(decoder: decoder).queryOutput)
          decoder.next()
        case SQLITE_DONE:
          break loop
        default:
          throw SQLiteError(handle)
        }
      }
      return results
    }
  }

  public func execute<each V: QueryRepresentable>(
    _ query: some Statement<(repeat each V)>
  ) throws -> [(repeat (each V).QueryOutput)] {
    try withStatement(query) { statement in
      var results: [(repeat (each V).QueryOutput)] = []
      let decoder = SQLiteQueryDecoder(database: handle, statement: statement)
      loop: while true {
        let code = sqlite3_step(statement)
        switch code {
        case SQLITE_ROW:
          try results.append((repeat (each V)(decoder: decoder).queryOutput))
          decoder.next()
        case SQLITE_DONE:
          break loop
        default:
          throw SQLiteError(handle)
        }
      }
      return results
    }
  }

  public func execute<S: SelectStatement, each J: Table>(
    _ query: S
  ) throws -> [(S.From.QueryOutput, repeat (each J).QueryOutput)]
  where S.QueryValue == (), S.Joins == (repeat each J) {
    try withStatement(query) { statement in
      var results: [(S.From.QueryOutput, repeat (each J).QueryOutput)] = []
      let decoder = SQLiteQueryDecoder(database: handle, statement: statement)
      loop: while true {
        let code = sqlite3_step(statement)
        switch code {
        case SQLITE_ROW:
          try results.append(
            (
              decoder.decodeColumns(S.From.self).queryOutput,
              repeat decoder.decodeColumns((each J).self).queryOutput
            )
          )
          decoder.next()
        case SQLITE_DONE:
          break loop
        default:
          throw SQLiteError(handle)
        }
      }
      return results
    }
  }

  private func withStatement<R>(
    _ query: some Statement, body: (OpaquePointer) throws -> R
  ) throws -> R {
    var statement: OpaquePointer?
    let sql = query.query
    guard
      sqlite3_prepare_v2(handle, sql.string, -1, &statement, nil) == SQLITE_OK,
      let statement
    else {
      throw SQLiteError(handle)
    }
    defer { sqlite3_finalize(statement) }
    for (index, binding) in zip(Int32(1)..., sql.bindings) {
      let result =
        switch binding {
        case let .blob(blob):
          sqlite3_bind_blob(statement, index, Array(blob), -1, SQLITE_TRANSIENT)
        case let .double(double):
          sqlite3_bind_double(statement, index, double)
        case let .int(int):
          sqlite3_bind_int64(statement, index, Int64(int))
        case .null:
          sqlite3_bind_null(statement, index)
        case let .text(text):
          sqlite3_bind_text(statement, index, text, -1, SQLITE_TRANSIENT)
        }
      guard result == SQLITE_OK else { throw SQLiteError(handle) }
    }
    return try body(statement)
  }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

struct SQLiteError: Error {
  let message: String

  init(_ handle: OpaquePointer?) {
    self.message = String(cString: sqlite3_errmsg(handle))
  }
}
