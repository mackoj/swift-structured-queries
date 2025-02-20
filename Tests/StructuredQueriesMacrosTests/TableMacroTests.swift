import MacroTesting
import StructuredQueriesMacros
import Testing

@Suite(.macros(record: .failed, macros: [TableMacro.self]))
struct TableMacroTests {
  @Test func basics() {
    assertMacro {
      """
      @Table
      struct User {
        var id: Int
        var name: String
      }
      """
    } expansion: {
      #"""
      struct User {
        @Column("id", primaryKey: true)
        var id: Int
        @Column("name")
        var name: String
      }

      extension User: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
        public struct Columns: StructuredQueries.PrimaryKeyedSchema {
          public typealias QueryOutput = User
          public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
          public let name = StructuredQueries.Column<QueryOutput, String>("name", keyPath: \.name)
          public var primaryKey: some StructuredQueries.ColumnExpression<QueryOutput> & StructuredQueries.QueryExpression<Int> {
            self.id
          }
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.id), StructuredQueries.AnyColumnExpression<QueryOutput>(self.name)]
          }
        }
        public struct Draft: StructuredQueries.Draft {
          var name: String
          public struct Columns: StructuredQueries.DraftSchema {
            public typealias QueryOutput = Draft
            public let name = StructuredQueries.DraftColumn<QueryOutput, String>("name", keyPath: \.name)
            public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
              [StructuredQueries.AnyColumnExpression<QueryOutput>(self.name)]
            }
          }
          public static let columns = Columns()
          public var queryFragment: QueryFragment {
            var sql: QueryFragment = "("
            sql.append(
              [
                Self.columns.name.encode(self.name)
              ]
              .joined(separator: ", ")
            )
            sql.append(")")
            return sql
          }
        }
        public static let columns = Columns()
        public static let name = "users"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.id = try Self.columns.id.decode(decoder: decoder)
          self.name = try Self.columns.name.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.id.encode(self.id),
              Self.columns.name.encode(self.name)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func backticks() {
    assertMacro {
      """
      @Table
      struct Config {
        var `default` = 0
      }
      """
    } expansion: {
      #"""
      struct Config {
        @Column("default")
        var `default` = 0
      }

      extension Config: StructuredQueries.Table {
        public struct Columns: StructuredQueries.Schema {
          public typealias QueryOutput = Config
          public let `default` = StructuredQueries.Column<QueryOutput, Swift.Int>("default", keyPath: \.default, default: 0)
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.default)]
          }
        }
        public static let columns = Columns()
        public static let name = "configs"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.default = try Self.columns.default.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.default.encode(self.default)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func computedProperties() {
    assertMacro {
      #"""
      @Table
      struct User {
        var id: Int
        var description: String { "User #\(id)" }
      }
      """#
    } expansion: {
      #"""
      struct User {
        @Column("id", primaryKey: true)
        var id: Int
        var description: String { "User #\(id)" }
      }

      extension User: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
        public struct Columns: StructuredQueries.PrimaryKeyedSchema {
          public typealias QueryOutput = User
          public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
          public var primaryKey: some StructuredQueries.ColumnExpression<QueryOutput> & StructuredQueries.QueryExpression<Int> {
            self.id
          }
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.id)]
          }
        }
        public struct Draft: StructuredQueries.Draft {

          public struct Columns: StructuredQueries.DraftSchema {
            public typealias QueryOutput = Draft

            public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
              []
            }
          }
          public static let columns = Columns()
          public var queryFragment: QueryFragment {
            var sql: QueryFragment = "("
            sql.append(
              [

              ]
              .joined(separator: ", ")
            )
            sql.append(")")
            return sql
          }
        }
        public static let columns = Columns()
        public static let name = "users"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.id = try Self.columns.id.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.id.encode(self.id)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func columnsApplied() {
    assertMacro {
      #"""
      @Table
      struct User {
        @Column
        var id: Int
      }
      """#
    } expansion: {
      #"""
      struct User {
        @Column
        var id: Int
      }

      extension User: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
        public struct Columns: StructuredQueries.PrimaryKeyedSchema {
          public typealias QueryOutput = User
          public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
          public var primaryKey: some StructuredQueries.ColumnExpression<QueryOutput> & StructuredQueries.QueryExpression<Int> {
            self.id
          }
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.id)]
          }
        }
        public struct Draft: StructuredQueries.Draft {

          public struct Columns: StructuredQueries.DraftSchema {
            public typealias QueryOutput = Draft

            public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
              []
            }
          }
          public static let columns = Columns()
          public var queryFragment: QueryFragment {
            var sql: QueryFragment = "("
            sql.append(
              [

              ]
              .joined(separator: ", ")
            )
            sql.append(")")
            return sql
          }
        }
        public static let columns = Columns()
        public static let name = "users"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.id = try Self.columns.id.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.id.encode(self.id)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func customTableName() {
    assertMacro {
      #"""
      @Table("user")
      struct User {
        var id: Int
      }
      """#
    } expansion: {
      #"""
      struct User {
        @Column("id", primaryKey: true)
        var id: Int
      }

      extension User: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
        public struct Columns: StructuredQueries.PrimaryKeyedSchema {
          public typealias QueryOutput = User
          public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
          public var primaryKey: some StructuredQueries.ColumnExpression<QueryOutput> & StructuredQueries.QueryExpression<Int> {
            self.id
          }
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.id)]
          }
        }
        public struct Draft: StructuredQueries.Draft {

          public struct Columns: StructuredQueries.DraftSchema {
            public typealias QueryOutput = Draft

            public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
              []
            }
          }
          public static let columns = Columns()
          public var queryFragment: QueryFragment {
            var sql: QueryFragment = "("
            sql.append(
              [

              ]
              .joined(separator: ", ")
            )
            sql.append(")")
            return sql
          }
        }
        public static let columns = Columns()
        public static let name = "user"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.id = try Self.columns.id.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.id.encode(self.id)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func customColumnName() {
    assertMacro {
      #"""
      @Table
      struct User {
        @Column("user_id")
        var id: Int
      }
      """#
    } expansion: {
      #"""
      struct User {
        @Column("user_id")
        var id: Int
      }

      extension User: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
        public struct Columns: StructuredQueries.PrimaryKeyedSchema {
          public typealias QueryOutput = User
          public let id = StructuredQueries.Column<QueryOutput, Int>("user_id", keyPath: \.id)
          public var primaryKey: some StructuredQueries.ColumnExpression<QueryOutput> & StructuredQueries.QueryExpression<Int> {
            self.id
          }
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.id)]
          }
        }
        public struct Draft: StructuredQueries.Draft {

          public struct Columns: StructuredQueries.DraftSchema {
            public typealias QueryOutput = Draft

            public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
              []
            }
          }
          public static let columns = Columns()
          public var queryFragment: QueryFragment {
            var sql: QueryFragment = "("
            sql.append(
              [

              ]
              .joined(separator: ", ")
            )
            sql.append(")")
            return sql
          }
        }
        public static let columns = Columns()
        public static let name = "users"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.id = try Self.columns.id.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.id.encode(self.id)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func dateFieldDiagnostic() {
    assertMacro {
      #"""
      @Table
      struct User {
        /// Join date
        var joined: Date
      }
      """#
    } diagnostics: {
      """
      @Table
      struct User {
        /// Join date
        var joined: Date
                    ┬───
                    ╰─ 🛑 'Date' column requires a bind strategy
                       ✏️ Insert '@Column(as: .<#strategy#>)'
      }
      """
    } fixes: {
      """
      @Table
      struct User {
        /// Join date
        @Column(as: .<#strategy#>)
        var joined: Date
      }
      """
    } expansion: {
      #"""
      struct User {
        /// Join date
        @Column(as: .<#strategy#>)
        var joined: Date
      }

      extension User: StructuredQueries.Table {
        public struct Columns: StructuredQueries.Schema {
          public typealias QueryOutput = User
          public let joined = StructuredQueries.Column<QueryOutput, _>("joined", keyPath: \.joined, as: .<#strategy#>)
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.joined)]
          }
        }
        public static let columns = Columns()
        public static let name = "users"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.joined = try Self.columns.joined.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.joined.encode(self.joined)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func customBindingStrategy() {
    assertMacro {
      #"""
      @Table
      struct User {
        @Column(as: .iso8601)
        var joined: Date
      }
      """#
    } expansion: {
      #"""
      struct User {
        @Column(as: .iso8601)
        var joined: Date
      }

      extension User: StructuredQueries.Table {
        public struct Columns: StructuredQueries.Schema {
          public typealias QueryOutput = User
          public let joined = StructuredQueries.Column<QueryOutput, _>("joined", keyPath: \.joined, as: .iso8601)
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.joined)]
          }
        }
        public static let columns = Columns()
        public static let name = "users"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.joined = try Self.columns.joined.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.joined.encode(self.joined)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func capitalSelf() {
    assertMacro {
      """
      @Table
      struct User {
        var id: Tagged<Self, Int> = Tagged(Self.defaultID)
      }
      """
    } expansion: {
      #"""
      struct User {
        @Column("id", primaryKey: true)
        var id: Tagged<Self, Int> = Tagged(Self.defaultID)
      }

      extension User: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
        public struct Columns: StructuredQueries.PrimaryKeyedSchema {
          public typealias QueryOutput = User
          public let id = StructuredQueries.Column<QueryOutput, Tagged<QueryOutput, Int>>("id", keyPath: \.id, default: Tagged(QueryOutput.defaultID))
          public var primaryKey: some StructuredQueries.ColumnExpression<QueryOutput> & StructuredQueries.QueryExpression<Tagged<QueryOutput, Int>> {
            self.id
          }
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.id)]
          }
        }
        public struct Draft: StructuredQueries.Draft {

          public struct Columns: StructuredQueries.DraftSchema {
            public typealias QueryOutput = Draft

            public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
              []
            }
          }
          public static let columns = Columns()
          public var queryFragment: QueryFragment {
            var sql: QueryFragment = "("
            sql.append(
              [

              ]
              .joined(separator: ", ")
            )
            sql.append(")")
            return sql
          }
        }
        public static let columns = Columns()
        public static let name = "users"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.id = try Self.columns.id.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.id.encode(self.id)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func noTypeAnnotation() {
    assertMacro {
      """
      @Table
      struct User {
        var id = Int(0)
      }
      """
    } expansion: {
      #"""
      struct User {
        @Column("id", primaryKey: true)
        var id = Int(0)
      }

      extension User: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
        public struct Columns: StructuredQueries.PrimaryKeyedSchema {
          public typealias QueryOutput = User
          public let id = StructuredQueries.Column<QueryOutput, _>("id", keyPath: \.id, default: Int(0))
          public var primaryKey: some StructuredQueries.ColumnExpression<QueryOutput> & StructuredQueries.QueryExpression<_> {
            self.id
          }
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.id)]
          }
        }
        public struct Draft: StructuredQueries.Draft {

          public struct Columns: StructuredQueries.DraftSchema {
            public typealias QueryOutput = Draft

            public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
              []
            }
          }
          public static let columns = Columns()
          public var queryFragment: QueryFragment {
            var sql: QueryFragment = "("
            sql.append(
              [

              ]
              .joined(separator: ", ")
            )
            sql.append(")")
            return sql
          }
        }
        public static let columns = Columns()
        public static let name = "users"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.id = try Self.columns.id.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.id.encode(self.id)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func nested() {
    assertMacro {
      """
      struct Outer {
        @Table
        struct User {
          var id: Int
          var name: String
        }
      }
      """
    } expansion: {
      #"""
      struct Outer {
        struct User {
          @Column("id", primaryKey: true)
          var id: Int
          @Column("name")
          var name: String
        }
      }

      extension Outer.User: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
        public struct Columns: StructuredQueries.PrimaryKeyedSchema {
          public typealias QueryOutput = Outer.User
          public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
          public let name = StructuredQueries.Column<QueryOutput, String>("name", keyPath: \.name)
          public var primaryKey: some StructuredQueries.ColumnExpression<QueryOutput> & StructuredQueries.QueryExpression<Int> {
            self.id
          }
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.id), StructuredQueries.AnyColumnExpression<QueryOutput>(self.name)]
          }
        }
        public struct Draft: StructuredQueries.Draft {
          var name: String
          public struct Columns: StructuredQueries.DraftSchema {
            public typealias QueryOutput = Draft
            public let name = StructuredQueries.DraftColumn<QueryOutput, String>("name", keyPath: \.name)
            public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
              [StructuredQueries.AnyColumnExpression<QueryOutput>(self.name)]
            }
          }
          public static let columns = Columns()
          public var queryFragment: QueryFragment {
            var sql: QueryFragment = "("
            sql.append(
              [
                Self.columns.name.encode(self.name)
              ]
              .joined(separator: ", ")
            )
            sql.append(")")
            return sql
          }
        }
        public static let columns = Columns()
        public static let name = "users"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.id = try Self.columns.id.decode(decoder: decoder)
          self.name = try Self.columns.name.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.id.encode(self.id),
              Self.columns.name.encode(self.name)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func skipAutomaticPrimaryKeyApplication() {
    assertMacro {
      """
      @Table
      struct User {
        var id: String
        @Column("uuid", as: .bytes, primaryKey: true)
        var uuid: UUID
      }
      """
    } expansion: {
      #"""
      struct User {
        @Column("id")
        var id: String
        @Column("uuid", as: .bytes, primaryKey: true)
        var uuid: UUID
      }

      extension User: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
        public struct Columns: StructuredQueries.PrimaryKeyedSchema {
          public typealias QueryOutput = User
          public let id = StructuredQueries.Column<QueryOutput, String>("id", keyPath: \.id)
          public let uuid = StructuredQueries.Column<QueryOutput, _>("uuid", keyPath: \.uuid, as: .bytes)
          public var primaryKey: some StructuredQueries.ColumnExpression<QueryOutput> & StructuredQueries.QueryExpression<UUID> {
            self.uuid
          }
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.id), StructuredQueries.AnyColumnExpression<QueryOutput>(self.uuid)]
          }
        }
        public struct Draft: StructuredQueries.Draft {
          var uuid: UUID
          public struct Columns: StructuredQueries.DraftSchema {
            public typealias QueryOutput = Draft
            public let uuid = StructuredQueries.DraftColumn<QueryOutput, _>("uuid", keyPath: \.uuid, as: .bytes)
            public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
              [StructuredQueries.AnyColumnExpression<QueryOutput>(self.uuid)]
            }
          }
          public static let columns = Columns()
          public var queryFragment: QueryFragment {
            var sql: QueryFragment = "("
            sql.append(
              [
                Self.columns.uuid.encode(self.uuid)
              ]
              .joined(separator: ", ")
            )
            sql.append(")")
            return sql
          }
        }
        public static let columns = Columns()
        public static let name = "users"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.id = try Self.columns.id.decode(decoder: decoder)
          self.uuid = try Self.columns.uuid.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.id.encode(self.id),
              Self.columns.uuid.encode(self.uuid)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }

  @Test func multiplePrimaryKeysDiagnostic() {
    assertMacro {
      """
      @Table
      struct SyncUpAttendees {
        @Column(primaryKey: true)
        var syncUpID: Int
        @Column(primaryKey: true)
        var attendeeID: Int
      }
      """
    } diagnostics: {
      """
      @Table
      struct SyncUpAttendees {
        @Column(primaryKey: true)
        var syncUpID: Int
        @Column(primaryKey: true)
                ┬─────────
                ╰─ 🛑 '@Table' only supports a single primary key
                   ✏️ Remove 'primaryKey: true'
        var attendeeID: Int
      }
      """
    } fixes: {
      """
      @Table
      struct SyncUpAttendees {
        @Column(primaryKey: true)
        var syncUpID: Int
        @Column()
        var attendeeID: Int
      }
      """
    } expansion: {
      #"""
      struct SyncUpAttendees {
        @Column(primaryKey: true)
        var syncUpID: Int
        @Column()
        var attendeeID: Int
      }

      extension SyncUpAttendees: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
        public struct Columns: StructuredQueries.PrimaryKeyedSchema {
          public typealias QueryOutput = SyncUpAttendees
          public let syncUpID = StructuredQueries.Column<QueryOutput, Int>("syncUpID", keyPath: \.syncUpID)
          public let attendeeID = StructuredQueries.Column<QueryOutput, Int>("attendeeID", keyPath: \.attendeeID)
          public var primaryKey: some StructuredQueries.ColumnExpression<QueryOutput> & StructuredQueries.QueryExpression<Int> {
            self.syncUpID
          }
          public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
            [StructuredQueries.AnyColumnExpression<QueryOutput>(self.syncUpID), StructuredQueries.AnyColumnExpression<QueryOutput>(self.attendeeID)]
          }
        }
        public struct Draft: StructuredQueries.Draft {
          var syncUpID: Int
          var attendeeID: Int
          public struct Columns: StructuredQueries.DraftSchema {
            public typealias QueryOutput = Draft
            public let syncUpID = StructuredQueries.DraftColumn<QueryOutput, Int>("syncUpID", keyPath: \.syncUpID)
            public let attendeeID = StructuredQueries.DraftColumn<QueryOutput, Int>("attendeeID", keyPath: \.attendeeID)
            public var allColumns: [StructuredQueries.AnyColumnExpression<QueryOutput>] {
              [StructuredQueries.AnyColumnExpression<QueryOutput>(self.syncUpID), StructuredQueries.AnyColumnExpression<QueryOutput>(self.attendeeID)]
            }
          }
          public static let columns = Columns()
          public var queryFragment: QueryFragment {
            var sql: QueryFragment = "("
            sql.append(
              [
                Self.columns.syncUpID.encode(self.syncUpID),
                Self.columns.attendeeID.encode(self.attendeeID)
              ]
              .joined(separator: ", ")
            )
            sql.append(")")
            return sql
          }
        }
        public static let columns = Columns()
        public static let name = "syncUpAttendeeses"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.syncUpID = try Self.columns.syncUpID.decode(decoder: decoder)
          self.attendeeID = try Self.columns.attendeeID.decode(decoder: decoder)
        }
        public var queryFragment: QueryFragment {
          var sql: QueryFragment = "("
          sql.append(
            [
              Self.columns.syncUpID.encode(self.syncUpID),
              Self.columns.attendeeID.encode(self.attendeeID)
            ]
            .joined(separator: ", ")
          )
          sql.append(")")
          return sql
        }
      }
      """#
    }
  }
}
