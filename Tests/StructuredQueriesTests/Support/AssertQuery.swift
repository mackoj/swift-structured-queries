import Dependencies
import InlineSnapshotTesting
import StructuredQueries

func assertQuery<S: SelectStatement, each J: Table>(
  _ query: S,
  sql: (() -> String)? = nil,
  results: (() -> String)? = nil,
  fileID: StaticString = #fileID,
  filePath: StaticString = #filePath,
  function: StaticString = #function,
  line: UInt = #line,
  column: UInt = #column
) throws where S.QueryValue == (), S.Joins == (repeat each J) {
  assertInlineSnapshot(
    of: query,
    as: .sql,
    message: "Query did not match",
    syntaxDescriptor: InlineSnapshotSyntaxDescriptor(
      trailingClosureLabel: "sql",
      trailingClosureOffset: 0
    ),
    matches: sql,
    fileID: fileID,
    file: filePath,
    function: function,
    line: line,
    column: column
  )
  @Dependency(\.defaultDatabase) var db
  let rows = try db.execute(query)
  var table = ""
  printTable(rows, to: &table)
  assertInlineSnapshot(
    of: table,
    as: .lines,
    message: "Results did not match",
    syntaxDescriptor: InlineSnapshotSyntaxDescriptor(
      trailingClosureLabel: "results",
      trailingClosureOffset: 1
    ),
    matches: results,
    fileID: fileID,
    file: filePath,
    function: function,
    line: line,
    column: column
  )
}

//func assertQuery<S: Statement>(
//  _ query: S,
//  sql: (() -> String)? = nil,
//  results: (() -> String)? = nil,
//  fileID: StaticString = #fileID,
//  filePath: StaticString = #filePath,
//  function: StaticString = #function,
//  line: UInt = #line,
//  column: UInt = #column
//) throws where S.QueryValue: QueryRepresentable {
//  try _assertQuery(
//    query,
//    sql: sql,
//    results: results,
//    fileID: fileID,
//    filePath: filePath,
//    function: function,
//    line: line,
//    column: column
//  )
//}

func assertQuery<S: Statement, each V: QueryRepresentable>(
  _ query: S,
  sql: (() -> String)? = nil,
  results: (() -> String)? = nil,
  fileID: StaticString = #fileID,
  filePath: StaticString = #filePath,
  function: StaticString = #function,
  line: UInt = #line,
  column: UInt = #column
) throws where S.QueryValue == (repeat each V) {
  assertInlineSnapshot(
    of: query,
    as: .sql,
    message: "Query did not match",
    syntaxDescriptor: InlineSnapshotSyntaxDescriptor(
      trailingClosureLabel: "sql",
      trailingClosureOffset: 0
    ),
    matches: sql,
    fileID: fileID,
    file: filePath,
    function: function,
    line: line,
    column: column
  )
  @Dependency(\.defaultDatabase) var db
  let rows = try db.execute(query)
  var table = ""
  printTable(rows, to: &table)
  assertInlineSnapshot(
    of: table,
    as: .lines,
    message: "Results did not match",
    syntaxDescriptor: InlineSnapshotSyntaxDescriptor(
      trailingClosureLabel: "results",
      trailingClosureOffset: 1
    ),
    matches: results,
    fileID: fileID,
    file: filePath,
    function: function,
    line: line,
    column: column
  )
}

func printTable<each C>(_ rows: [(repeat each C)], to output: inout some TextOutputStream) {
  var maxLengths: [Int] = []
  for _ in repeat (each C).self {
    maxLengths.append(0)
  }
  var table: [[String]] = []
  for row in rows {
    var columns: [String] = []
    var index = 0
    for column in repeat each row {
      defer { index += 1 }
      var cell = ""
      print(column, terminator: "", to: &cell)
      maxLengths[index] = max(maxLengths[index], cell.count)
      columns.append(cell)
    }
    table.append(columns)
  }
  output.write("┌─")
  output.write(
    maxLengths
      .map { String(repeating: "─", count: $0) }
      .joined(separator: "─┬─")
  )
  output.write("─┐\n")
  for row in table {
    let row = zip(row, maxLengths)
      .map { $0 + String(repeating: " ", count: $1 - $0.count) }
    output.write("│ \(row.joined(separator: " │ ")) │\n")
  }
  output.write("└─")
  output.write(
    maxLengths
      .map { String(repeating: "─", count: $0) }
      .joined(separator: "─┴─")
  )
  output.write("─┘")
}
