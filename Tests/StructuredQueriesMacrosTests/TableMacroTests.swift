import MacroTesting
import StructuredQueriesMacros
import Testing

extension SnapshotTests {
  @MainActor
  @Suite struct TableMacroTests {
    @Test func basics() {
      assertMacro {
        """
        @Table
        struct Foo {
          var bar: Int
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar: Int
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, Int>("bar", keyPath: \QueryValue.bar)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode(Int.self)
          }
        }
        """#
      }
    }

    @Test func tableName() {
      assertMacro {
        """
        @Table("foo")
        struct Foo {
          var bar: Int
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar: Int
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, Int>("bar", keyPath: \QueryValue.bar)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foo"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode(Int.self)
          }
        }
        """#
      }
    }

    @Test func tableNameNil() {
      assertMacro {
        """
        @Table(nil)
        struct Foo {
          var bar: Int
        }
        """
      } diagnostics: {
        """
        @Table(nil)
               ┬──
               ╰─ 🛑 Argument must be a non-empty string literal
        struct Foo {
          var bar: Int
        }
        """
      }
    }

    @Test func tableNameEmpty() {
      assertMacro {
        """
        @Table(nil)
        struct Foo {
          var bar: Int
        }
        """
      } diagnostics: {
        """
        @Table(nil)
               ┬──
               ╰─ 🛑 Argument must be a non-empty string literal
        struct Foo {
          var bar: Int
        }
        """
      }
    }

    @Test func literals() {
      assertMacro {
        """
        @Table
        struct Foo {
          var c1 = true
          var c2 = 1
          var c3 = 1.2
          var c4 = ""
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var c1 = true
          var c2 = 1
          var c3 = 1.2
          var c4 = ""
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              4
            }
            public let c1 = StructuredQueries.TableColumn<QueryValue, Swift.Bool>("c1", keyPath: \QueryValue.c1, default: true)
            public let c2 = StructuredQueries.TableColumn<QueryValue, Swift.Int>("c2", keyPath: \QueryValue.c2, default: 1)
            public let c3 = StructuredQueries.TableColumn<QueryValue, Swift.Double>("c3", keyPath: \QueryValue.c3, default: 1.2)
            public let c4 = StructuredQueries.TableColumn<QueryValue, Swift.String>("c4", keyPath: \QueryValue.c4, default: "")
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.c1, self.c2, self.c3, self.c4]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.c1 = try decoder.decode(Swift.Bool.self)
            self.c2 = try decoder.decode(Swift.Int.self)
            self.c3 = try decoder.decode(Swift.Double.self)
            self.c4 = try decoder.decode(Swift.String.self)
          }
        }
        """#
      }
    }

    @Test func columnName() {
      assertMacro {
        """
        @Table
        struct Foo {
          @Column("Bar")
          var bar: Int
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar: Int
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, Int>("Bar", keyPath: \QueryValue.bar)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode(Int.self)
          }
        }
        """#
      }
    }

    @Test func columnNameNil() {
      assertMacro {
        """
        @Table
        struct Foo {
          @Column(nil)
          var bar: Int
        }
        """
      } diagnostics: {
        """
        @Table
        struct Foo {
          @Column(nil)
                  ┬──
                  ╰─ 🛑 Argument must be a non-empty string literal
          var bar: Int
        }
        """
      }
    }

    @Test func columnNameEmpty() {
      assertMacro {
        """
        @Table
        struct Foo {
          @Column("")
          var bar: Int
        }
        """
      } diagnostics: {
        """
        @Table
        struct Foo {
          @Column("")
                  ┬─
                  ╰─ 🛑 Argument must be a non-empty string literal
          var bar: Int
        }
        """
      }
    }

    @Test func representable() {
      assertMacro {
        """
        @Table
        struct Foo {
          @Column(as: Date.ISO8601Representation.self)
          var bar: Int
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar: Int
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, Date.ISO8601Representation>("bar", keyPath: \QueryValue.bar)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode(Date.ISO8601Representation.self)
          }
        }
        """#
      }
    }

    @Test func computed() {
      assertMacro {
        """
        @Table
        struct Foo {
          var bar: Int
          var baz: Int { 42 }
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar: Int
          var baz: Int { 42 }
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, Int>("bar", keyPath: \QueryValue.bar)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode(Int.self)
          }
        }
        """#
      }
    }

    @Test func `static`() {
      assertMacro {
        """
        @Table
        struct Foo {
          var bar: Int
          static var baz: Int { 42 }
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar: Int
          static var baz: Int { 42 }
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, Int>("bar", keyPath: \QueryValue.bar)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode(Int.self)
          }
        }
        """#
      }
    }

    @Test func dateDiagnostic() {
      assertMacro {
        """
        @Table
        struct Foo {
          var bar: Date
        }
        """
      } diagnostics: {
        """
        @Table
        struct Foo {
          var bar: Date
          ┬────────────
          ╰─ 🛑 'Date' column requires a query representation
             ✏️ Insert '@Column(as: Date.ISO8601Representation.self)'
             ✏️ Insert '@Column(as: Date.UnixTimeRepresentation.self)'
             ✏️ Insert '@Column(as: Date.JulianDayRepresentation.self)'
        }
        """
      } fixes: {
        """
        @Table
        struct Foo {
          @Column(as: Date.ISO8601Representation.self)
          var bar: Date
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar: Date
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, Date.ISO8601Representation>("bar", keyPath: \QueryValue.bar)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode(Date.ISO8601Representation.self)
          }
        }
        """#
      }
    }

    @Test func optionalDateDiagnostic() {
      assertMacro {
        """
        @Table
        struct Foo {
          var bar: Date?
        }
        """
      } diagnostics: {
        """
        @Table
        struct Foo {
          var bar: Date?
          ┬─────────────
          ╰─ 🛑 'Date' column requires a query representation
             ✏️ Insert '@Column(as: Date.ISO8601Representation?.self)'
             ✏️ Insert '@Column(as: Date.UnixTimeRepresentation?.self)'
             ✏️ Insert '@Column(as: Date.JulianDayRepresentation?.self)'
        }
        """
      } fixes: {
        """
        @Table
        struct Foo {
          @Column(as: Date.ISO8601Representation?.self)
          var bar: Date?
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar: Date?
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, Date.ISO8601Representation?>("bar", keyPath: \QueryValue.bar)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode(Date.ISO8601Representation?.self)
          }
        }
        """#
      }
    }

    @Test func optionalTypeDateDiagnostic() {
      assertMacro {
        """
        @Table
        struct Foo {
          var bar: Optional<Date>
        }
        """
      } diagnostics: {
        """
        @Table
        struct Foo {
          var bar: Optional<Date>
          ┬──────────────────────
          ╰─ 🛑 'Date' column requires a query representation
             ✏️ Insert '@Column(as: Date.ISO8601Representation?.self)'
             ✏️ Insert '@Column(as: Date.UnixTimeRepresentation?.self)'
             ✏️ Insert '@Column(as: Date.JulianDayRepresentation?.self)'
        }
        """
      } fixes: {
        """
        @Table
        struct Foo {
          @Column(as: Date.ISO8601Representation?.self)
          var bar: Optional<Date>
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar: Optional<Date>
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, Date.ISO8601Representation?>("bar", keyPath: \QueryValue.bar)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode(Date.ISO8601Representation?.self)
          }
        }
        """#
      }
    }

    @Test func defaultDateDiagnostic() {
      assertMacro {
        """
        @Table
        struct Foo {
          var bar = Date()
        }
        """
      } diagnostics: {
        """
        @Table
        struct Foo {
          var bar = Date()
          ┬───────────────
          ╰─ 🛑 'Date' column requires a query representation
             ✏️ Insert '@Column(as: Date.ISO8601Representation.self)'
             ✏️ Insert '@Column(as: Date.UnixTimeRepresentation.self)'
             ✏️ Insert '@Column(as: Date.JulianDayRepresentation.self)'
        }
        """
      } fixes: {
        """
        @Table
        struct Foo {
          @Column(as: Date.ISO8601Representation.self)
          var bar = Date()
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar = Date()
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, Date.ISO8601Representation>("bar", keyPath: \QueryValue.bar, default: Date())
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode(Date.ISO8601Representation.self)
          }
        }
        """#
      }
    }

    @Test func backticks() {
      assertMacro {
        """
        @Table
        struct Foo {
          var `bar`: Int
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var `bar`: Int
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let `bar` = StructuredQueries.TableColumn<QueryValue, Int>("bar", keyPath: \QueryValue.`bar`)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.`bar`]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.`bar` = try decoder.decode(Int.self)
          }
        }
        """#
      }
    }

    @Test func capitalSelf() {
      assertMacro {
        """
        @Table
        struct Foo {
          var bar: ID<Self>
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar: ID<Self>
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, ID<Foo>>("bar", keyPath: \QueryValue.bar)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode(ID<Foo>.self)
          }
        }
        """#
      }
    }

    @Test func capitalSelfDefault() {
      assertMacro {
        """
        @Table
        struct Foo {
          var bar = ID<Self>()
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var bar = ID<Self>()
        }

        extension Foo: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let bar = StructuredQueries.TableColumn<QueryValue, _>("bar", keyPath: \QueryValue.bar, default: ID<Foo>())
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.bar]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.bar = try decoder.decode()
          }
        }
        """#
      }
    }

    @Test func ephemeralField() {
      assertMacro {
        """
        @Table struct SyncUp {
          var name: String
          @Ephemeral
          var computed: Int
        }
        """
      } expansion: {
        #"""
        struct SyncUp {
          var name: String
          var computed: Int
        }

        extension SyncUp: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = SyncUp
            public static var count: Int {
              1
            }
            public let name = StructuredQueries.TableColumn<QueryValue, String>("name", keyPath: \QueryValue.name)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.name]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "syncUps"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.name = try decoder.decode(String.self)
          }
        }
        """#
      }
    }

    // NB: This test shows that invalid Swift code is generated when providing a default with an
    //     expression and not specifying a type.
    @Test func noType() {
      assertMacro {
        """
        @Table struct SyncUp {
          var seconds = 60 * 5
        }
        """
      } expansion: {
        #"""
        struct SyncUp {
          var seconds = 60 * 5
        }

        extension SyncUp: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = SyncUp
            public static var count: Int {
              1
            }
            public let seconds = StructuredQueries.TableColumn<QueryValue, _>("seconds", keyPath: \QueryValue.seconds, default: 60 * 5)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.seconds]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "syncUps"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.seconds = try decoder.decode()
          }
        }
        """#
      }
    }
  }

  @Test func willSet() {
    assertMacro {
      """
      @Table
      struct Foo {
        var name: String {
          willSet { print(newValue) }
        }
      }
      """
    } expansion: {
      #"""
      struct Foo {
        var name: String {
          willSet { print(newValue) }
        }
      }

      extension Foo: StructuredQueries.Table {
        public struct TableColumns: StructuredQueries.Schema {
          public typealias QueryValue = Foo
          public static var count: Int {
            1
          }
          public let name = StructuredQueries.TableColumn<QueryValue, String>("name", keyPath: \QueryValue.name)
          public var allColumns: [any StructuredQueries.TableColumnExpression] {
            [self.name]
          }
        }
        public static let columns = TableColumns()
        public static let tableName = "foos"
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.name = try decoder.decode(String.self)
        }
      }
      """#
    }
  }

  @MainActor
  @Suite struct PrimaryKeyTests {
    @Test func basics() {
      assertMacro {
        """
        @Table
        struct Foo {
          let id: Int
        }
        """
      } expansion: {
        #"""
        struct Foo {
          let id: Int
        }

        extension Foo: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
          public struct TableColumns: StructuredQueries.Schema, StructuredQueries.PrimaryKeyedSchema {
            public typealias QueryValue = Foo
            public static var count: Int {
              1
            }
            public let id = StructuredQueries.TableColumn<QueryValue, Int>("id", keyPath: \QueryValue.id)
            public var primaryKey: StructuredQueries.TableColumn<QueryValue, Int> {
              self.id
            }
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.id]
            }
          }
          public struct Draft: StructuredQueries.Table {
            @Column(primaryKey: false) let id: Int?
            public struct TableColumns: StructuredQueries.Schema {
              public typealias QueryValue = Foo.Draft
              public static var count: Int {
                1
              }
              public let id = StructuredQueries.TableColumn<QueryValue, Int?>("id", keyPath: \QueryValue.id)
              public var allColumns: [any StructuredQueries.TableColumnExpression] {
                [self.id]
              }
            }
            public static let columns = TableColumns()
            public static let tableName = Foo.tableName
            public init(decoder: some StructuredQueries.QueryDecoder) throws {
              self.id = try decoder.decode(Int?.self)
            }
            public init(_ other: Foo) {
              self.id = other.id
            }
            public init(
              id: Int? = nil
            ) {
              self.id = id
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try decoder.decode(Int.self)
          }
          public init?(_ other: Draft) {
            guard let id = other.id else {
              return nil
            }
            self.id = id
          }
        }
        """#
      }

      assertMacro {
        #"""
        struct Foo {
          @Column("id", primaryKey: true)
          let id: Int
        }

        extension Foo: StructuredQueries.Table {
          public struct Columns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public let id = StructuredQueries.Column<QueryValue, Int>("id", keyPath: \QueryValue.id)
            public var allColumns: [any StructuredQueries.ColumnExpression] {
              [self.id]
            }
          }
          @_Draft(Foo.self)
          public struct Draft {
            @Column(primaryKey: false)
            let id: Int
          }
          public static let columns = Columns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try decoder.decode(Int.self)
          }
        }
        """#
      } expansion: {
        #"""
        struct Foo {
          let id: Int
        }

        extension Foo: StructuredQueries.Table {
          public struct Columns: StructuredQueries.Schema {
            public typealias QueryValue = Foo
            public let id = StructuredQueries.Column<QueryValue, Int>("id", keyPath: \QueryValue.id)
            public var allColumns: [any StructuredQueries.ColumnExpression] {
              [self.id]
            }
          }
          public struct Draft {
            let id: Int
          }
          public static let columns = Columns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try decoder.decode(Int.self)
          }
        }

        extension Foo.Draft: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = Foo.Draft
            public static var count: Int {
              1
            }
            public let id = StructuredQueries.TableColumn<QueryValue, Int>("id", keyPath: \QueryValue.id)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.id]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = Foo.tableName
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try decoder.decode(Int.self)
          }
          public init(_ other: Foo) {
            self.id = other.id
          }
        }
        """#
      }
    }

    @Test func willSet() {
      assertMacro {
        """
        @Table
        struct Foo {
          var id: Int {
            willSet { print(newValue) }
          }
          var name: String {
            willSet { print(newValue) }
          }
        }
        """
      } expansion: {
        #"""
        struct Foo {
          var id: Int {
            willSet { print(newValue) }
          }
          var name: String {
            willSet { print(newValue) }
          }
        }

        extension Foo: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
          public struct TableColumns: StructuredQueries.Schema, StructuredQueries.PrimaryKeyedSchema {
            public typealias QueryValue = Foo
            public static var count: Int {
              2
            }
            public let id = StructuredQueries.TableColumn<QueryValue, Int>("id", keyPath: \QueryValue.id)
            public let name = StructuredQueries.TableColumn<QueryValue, String>("name", keyPath: \QueryValue.name)
            public var primaryKey: StructuredQueries.TableColumn<QueryValue, Int> {
              self.id
            }
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.id, self.name]
            }
          }
          public struct Draft: StructuredQueries.Table {
            @Column(primaryKey: false)
            var id: Int?
            var name: String
            public struct TableColumns: StructuredQueries.Schema {
              public typealias QueryValue = Foo.Draft
              public static var count: Int {
                2
              }
              public let id = StructuredQueries.TableColumn<QueryValue, Int?>("id", keyPath: \QueryValue.id)
              public let name = StructuredQueries.TableColumn<QueryValue, String>("name", keyPath: \QueryValue.name)
              public var allColumns: [any StructuredQueries.TableColumnExpression] {
                [self.id, self.name]
              }
            }
            public static let columns = TableColumns()
            public static let tableName = Foo.tableName
            public init(decoder: some StructuredQueries.QueryDecoder) throws {
              self.id = try decoder.decode(Int?.self)
              self.name = try decoder.decode(String.self)
            }
            public init(_ other: Foo) {
              self.id = other.id
              self.name = other.name
            }
            public init(
              id: Int? = nil,
              name: String
            ) {
              self.id = id
              self.name = name
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "foos"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try decoder.decode(Int.self)
            self.name = try decoder.decode(String.self)
          }
          public init?(_ other: Draft) {
            guard let id = other.id else {
              return nil
            }
            self.id = id
            self.name = other.name
          }
        }
        """#
      }
    }

    @Test func advanced() {
      assertMacro {
        """
        @Table
        struct Reminder {
          let id: Int
          var title = ""
          @Column(as: Date.UnixTimeRepresentation?.self)
          var date: Date?
          var priority: Priority?
        }
        """
      } expansion: {
        #"""
        struct Reminder {
          let id: Int
          var title = ""
          var date: Date?
          var priority: Priority?
        }

        extension Reminder: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
          public struct TableColumns: StructuredQueries.Schema, StructuredQueries.PrimaryKeyedSchema {
            public typealias QueryValue = Reminder
            public static var count: Int {
              4
            }
            public let id = StructuredQueries.TableColumn<QueryValue, Int>("id", keyPath: \QueryValue.id)
            public let title = StructuredQueries.TableColumn<QueryValue, Swift.String>("title", keyPath: \QueryValue.title, default: "")
            public let date = StructuredQueries.TableColumn<QueryValue, Date.UnixTimeRepresentation?>("date", keyPath: \QueryValue.date)
            public let priority = StructuredQueries.TableColumn<QueryValue, Priority?>("priority", keyPath: \QueryValue.priority)
            public var primaryKey: StructuredQueries.TableColumn<QueryValue, Int> {
              self.id
            }
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.id, self.title, self.date, self.priority]
            }
          }
          public struct Draft: StructuredQueries.Table {
            @Column(primaryKey: false) let id: Int?
            var title = ""
            @Column(as: Date.UnixTimeRepresentation?.self) var date: Date?
            var priority: Priority?
            public struct TableColumns: StructuredQueries.Schema {
              public typealias QueryValue = Reminder.Draft
              public static var count: Int {
                4
              }
              public let id = StructuredQueries.TableColumn<QueryValue, Int?>("id", keyPath: \QueryValue.id)
              public let title = StructuredQueries.TableColumn<QueryValue, Swift.String>("title", keyPath: \QueryValue.title, default: "")
              public let date = StructuredQueries.TableColumn<QueryValue, Date.UnixTimeRepresentation?>("date", keyPath: \QueryValue.date)
              public let priority = StructuredQueries.TableColumn<QueryValue, Priority?>("priority", keyPath: \QueryValue.priority)
              public var allColumns: [any StructuredQueries.TableColumnExpression] {
                [self.id, self.title, self.date, self.priority]
              }
            }
            public static let columns = TableColumns()
            public static let tableName = Reminder.tableName
            public init(decoder: some StructuredQueries.QueryDecoder) throws {
              self.id = try decoder.decode(Int?.self)
              self.title = try decoder.decode(Swift.String.self)
              self.date = try decoder.decode(Date.UnixTimeRepresentation?.self)
              self.priority = try decoder.decode(Priority?.self)
            }
            public init(_ other: Reminder) {
              self.id = other.id
              self.title = other.title
              self.date = other.date
              self.priority = other.priority
            }
            public init(
              id: Int? = nil,
              title: Swift.String = "",
              date: Date? = nil,
              priority: Priority? = nil
            ) {
              self.id = id
              self.title = title
              self.date = date
              self.priority = priority
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "reminders"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try decoder.decode(Int.self)
            self.title = try decoder.decode(Swift.String.self)
            self.date = try decoder.decode(Date.UnixTimeRepresentation?.self)
            self.priority = try decoder.decode(Priority?.self)
          }
          public init?(_ other: Draft) {
            guard let id = other.id else {
              return nil
            }
            self.id = id
            self.title = other.title
            self.date = other.date
            self.priority = other.priority
          }
        }
        """#
      }
    }

    @Test func uuid() {
      assertMacro {
        """
        @Table
        struct Reminder {
          @Column(as: UUID.BytesRepresentation.self)
          let id: UUID
        }
        """
      } expansion: {
        #"""
        struct Reminder {
          let id: UUID
        }

        extension Reminder: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
          public struct TableColumns: StructuredQueries.Schema, StructuredQueries.PrimaryKeyedSchema {
            public typealias QueryValue = Reminder
            public static var count: Int {
              1
            }
            public let id = StructuredQueries.TableColumn<QueryValue, UUID.BytesRepresentation>("id", keyPath: \QueryValue.id)
            public var primaryKey: StructuredQueries.TableColumn<QueryValue, UUID.BytesRepresentation> {
              self.id
            }
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.id]
            }
          }
          public struct Draft: StructuredQueries.Table {
            @Column(as: UUID.BytesRepresentation?.self, primaryKey: false) let id: UUID?
            public struct TableColumns: StructuredQueries.Schema {
              public typealias QueryValue = Reminder.Draft
              public static var count: Int {
                1
              }
              public let id = StructuredQueries.TableColumn<QueryValue, UUID.BytesRepresentation?>("id", keyPath: \QueryValue.id)
              public var allColumns: [any StructuredQueries.TableColumnExpression] {
                [self.id]
              }
            }
            public static let columns = TableColumns()
            public static let tableName = Reminder.tableName
            public init(decoder: some StructuredQueries.QueryDecoder) throws {
              self.id = try decoder.decode(UUID.BytesRepresentation?.self)
            }
            public init(_ other: Reminder) {
              self.id = other.id
            }
            public init(
              id: UUID? = nil
            ) {
              self.id = id
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "reminders"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try decoder.decode(UUID.BytesRepresentation.self)
          }
          public init?(_ other: Draft) {
            guard let id = other.id else {
              return nil
            }
            self.id = id
          }
        }
        """#
      }
    }
  }
}
