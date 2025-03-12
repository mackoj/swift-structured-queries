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
      throw SQLiteError()
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
      throw SQLiteError()
    }
  }

  public func execute<S: Statement>(_ query: S) throws where S.QueryValue == () {
    _ = try execute(query) as [()]
  }

  public func execute<S: Statement>(
    _ query: S
  ) throws -> [S.QueryValue.QueryOutput]
  where S.QueryValue: QueryRepresentable {
    var statement: OpaquePointer?
    let sql = query.query
    guard
      sqlite3_prepare_v2(handle, sql.string, -1, &statement, nil) == SQLITE_OK,
      let statement
    else {
      throw SQLiteError()
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
      guard result == SQLITE_OK else { throw SQLiteError() }
    }
    var results: [S.QueryValue.QueryOutput] = []
    let decoder = SQLiteQueryDecoder(statement: statement)
    loop: while true {
      let code = sqlite3_step(statement)
      switch code {
      case SQLITE_ROW:
        try results.append(S.QueryValue(decoder: decoder).queryOutput)
        decoder.next()
      case SQLITE_DONE:
        break loop
      default:
        throw SQLiteError()
      }
    }
    return results
  }

  public func execute<S: Statement, each V: QueryRepresentable>(
    _ query: S
  ) throws -> [(repeat (each V).QueryOutput)]
  where S.QueryValue == (repeat each V) {
    var statement: OpaquePointer?
    let sql = query.query
    guard
      sqlite3_prepare_v2(handle, sql.string, -1, &statement, nil) == SQLITE_OK,
      let statement
    else {
      throw SQLiteError()
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
      guard result == SQLITE_OK else { throw SQLiteError() }
    }
    var results: [(repeat (each V).QueryOutput)] = []
    let decoder = SQLiteQueryDecoder(statement: statement)
    loop: while true {
      let code = sqlite3_step(statement)
      switch code {
      case SQLITE_ROW:
        try results.append((repeat (each V)(decoder: decoder).queryOutput))
        decoder.next()
      case SQLITE_DONE:
        break loop
      default:
        throw SQLiteError()
      }
    }
    return results
  }

  public func execute<S: SelectStatement, each J: Table>(
    _ query: S
  ) throws -> [(S.From.QueryOutput, repeat (each J).QueryOutput)]
  where S.QueryValue == (), S.Joins == (repeat each J) {
    var statement: OpaquePointer?
    let sql = query.query
    guard
      sqlite3_prepare_v2(handle, sql.string, -1, &statement, nil) == SQLITE_OK,
      let statement
    else {
      throw SQLiteError()
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
      guard result == SQLITE_OK else { throw SQLiteError() }
    }
    var results: [(S.From.QueryOutput, repeat (each J).QueryOutput)] = []
    let decoder = SQLiteQueryDecoder(statement: statement)
    loop: while true {
      let code = sqlite3_step(statement)
      switch code {
      case SQLITE_ROW:
        try results
          .append(
            (S.From(decoder: decoder).queryOutput, repeat (each J)(decoder: decoder).queryOutput)
          )
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

struct SQLiteError: Error {}
