import CustomDump
import InlineSnapshotTesting
import StructuredQueries
import Testing

struct DraftTests {
  // @Table
  struct SyncUp: Equatable {
    // @Column("id", .primaryKey)
    var id: Int
    var isActive: Bool
    var seconds: Double
    var title: String
  }

  @Test func basics() {
    assertInlineSnapshot(
      of:
        SyncUp
        .insert([SyncUp.Draft(isActive: true, seconds: 60, title: "Engineering")])
        .returning(\.self)
        .queryString,
      as: .lines
    ) {
      """
      INSERT INTO "syncUps" ("isActive", "seconds", "title") VALUES (?, ?, ?) RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."seconds", "syncUps"."title"
      """
    }
  }
}

// TODO: macro needs to generate PrimaryKeyedTable and PrimaryKeyedSchema conformances
extension DraftTests.SyncUp: StructuredQueries.PrimaryKeyedTable {
  public struct Columns: StructuredQueries.PrimaryKeyedSchema {
    public typealias QueryOutput = DraftTests.SyncUp
    public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
    public let isActive = StructuredQueries.Column<QueryOutput, Bool>(
      "isActive", keyPath: \.isActive)
    public let seconds = StructuredQueries.Column<QueryOutput, Double>(
      "seconds", keyPath: \.seconds)
    public let title = StructuredQueries.Column<QueryOutput, String>("title", keyPath: \.title)
    public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
      [id, isActive, seconds, title]
    }
    // TODO: macro needs to generate this
    public var primaryKey: Column<QueryOutput, Int> { id }
  }
  public static let columns = Columns()
  public static let name = "syncUps"
  public init(decoder: some StructuredQueries.QueryDecoder) throws {
    self.id = try Self.columns.id.decode(decoder: decoder)
    self.isActive = try Self.columns.isActive.decode(decoder: decoder)
    self.seconds = try Self.columns.seconds.decode(decoder: decoder)
    self.title = try Self.columns.title.decode(decoder: decoder)
  }
}

// TODO: macro needs to generate this
extension DraftTests.SyncUp {
  public struct Draft: StructuredQueriesCore.Draft {
    public static var columns: Columns { Columns() }

    public var isActive: Bool
    public var seconds: Double
    public var title: String
    public struct Columns: StructuredQueries.DraftSchema {
      public typealias QueryOutput = DraftTests.SyncUp.Draft
      public let isActive = StructuredQueries.DraftColumn<QueryOutput, Bool>(
        "isActive", keyPath: \.isActive)
      public let seconds = StructuredQueries.DraftColumn<QueryOutput, Double>(
        "seconds", keyPath: \.seconds)
      public let title = StructuredQueries.DraftColumn<QueryOutput, String>("title", keyPath: \.title)
      public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
        [isActive, seconds, title]
      }
    }
  }
}
