import CustomDump
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
  var maxColumnSpan: [Int] = []
  var hasMultiLineRows = false
  for _ in repeat (each C).self {
    maxColumnSpan.append(0)
  }
  var table: [([[Substring]], maxRowSpan: Int)] = []
  for row in rows {
    var columns: [[Substring]] = []
    var index = 0
    var maxRowSpan = 0
    for column in repeat each row {
      defer { index += 1 }
      var cell = ""
      customDump(column, to: &cell)
      let lines = cell.split(separator: "\n")
      hasMultiLineRows = hasMultiLineRows || lines.count > 1
      maxRowSpan = max(maxRowSpan, lines.count)
      maxColumnSpan[index] = max(maxColumnSpan[index], lines.map(\.count).max() ?? 0)
      columns.append(lines)
    }
    table.append((columns, maxRowSpan))
  }
  output.write("┌─")
  output.write(
    maxColumnSpan
      .map { String(repeating: "─", count: $0) }
      .joined(separator: "─┬─")
  )
  output.write("─┐\n")
  for (offset, rowAndMaxRowSpan) in table.enumerated() {
    let (row, maxRowSpan) = rowAndMaxRowSpan
    for rowOffset in 0..<maxRowSpan {
      output.write("│ ")
      var line: [String] = []
      for (columns, maxColumnSpan) in zip(row, maxColumnSpan) {
        if columns.count <= rowOffset {
          line.append(String(repeating: " ", count: maxColumnSpan))
        } else {
          line.append(
            columns[rowOffset]
              + String(repeating: " ", count: maxColumnSpan - columns[rowOffset].count)
          )
        }
      }
      output.write(line.joined(separator: " │ "))
      output.write(" │\n")
    }
    if hasMultiLineRows, offset != table.count - 1 {
      output.write("├─")
      output.write(
        maxColumnSpan
          .map { String(repeating: "─", count: $0) }
          .joined(separator: "─┼─")
      )
      output.write("─┤\n")
    }
  }
  output.write("└─")
  output.write(
    maxColumnSpan
      .map { String(repeating: "─", count: $0) }
      .joined(separator: "─┴─")
  )
  output.write("─┘")
}
