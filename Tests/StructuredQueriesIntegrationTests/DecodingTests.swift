import Testing
import StructuredQueries
import StructuredQueriesSQLite

@Suite struct DecodingTests {
  let db = {
    let db = try! Database()
    try! db.execute("""
      CREATE TABLE "numbers" (
        "number" REAL NOT NULL
      )
      """)
    for index in 1...10 {
      try! db.execute(#"INSERT INTO "numbers" VALUES (\#(index))"#)
    }
    return db
  }()

  @Test func decodeDouble() throws {
    #expect(
    try db.execute(Number.all())
    == Array(1...10).map { Number(number: Double($0)) }
    )
  }
}

/*@Table */fileprivate struct Number: Equatable, Table {
  var number: Double
  public struct Columns: StructuredQueries.TableExpression {
    public typealias Value = Number
    public let number = StructuredQueries.Column<Value, Double>("number", keyPath: \.number)
    public var allColumns: [any StructuredQueries.ColumnExpression<Value>] {
      [number]
    }
  }
  public static var columns: Columns {
    Columns()
  }
  public static let name = "numbers"
  public init(decoder: any StructuredQueries.QueryDecoder) throws {
    number = try Self.columns.number.decode(decoder: decoder)
  }
  init(number: Double) {
    self.number = number
  }
}
