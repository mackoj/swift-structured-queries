import MacroTesting
import StructuredQueriesMacros
import Testing

struct TableMacroTests {
  @Test
  func basics() {
    withMacroTesting(
      record: .failed,
      macros: [TableMacro.self]
    ) {
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
          @Column
          var id: Int
          @Column
          var name: String
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.Schema {
            public typealias QueryOutput = User
            public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
            public let name = StructuredQueries.Column<QueryOutput, String>("name", keyPath: \.name)
            public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
              [id, name]
            }
          }
          public static let columns = Columns()
          public static let name = "users"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try Self.columns.id.decode(decoder: decoder)
            self.name = try Self.columns.name.decode(decoder: decoder)
          }
        }
        """#
      }
    }
  }

  @Test
  func computedProperties() {
    withMacroTesting(
      record: .failed,
      macros: [TableMacro.self]
    ) {
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
          @Column
          var id: Int
          var description: String { "User #\(id)" }
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.Schema {
            public typealias QueryOutput = User
            public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
            public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
              [id]
            }
          }
          public static let columns = Columns()
          public static let name = "users"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try Self.columns.id.decode(decoder: decoder)
          }
        }
        """#
      }
    }
  }

  @Test
  func columnsApplied() {
    withMacroTesting(
      record: .failed,
      macros: [TableMacro.self]
    ) {
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

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.Schema {
            public typealias QueryOutput = User
            public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
            public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
              [id]
            }
          }
          public static let columns = Columns()
          public static let name = "users"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try Self.columns.id.decode(decoder: decoder)
          }
        }
        """#
      }
    }
  }

  @Test
  func customTableName() {
    withMacroTesting(
      record: .failed,
      macros: [TableMacro.self]
    ) {
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
          @Column
          var id: Int
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.Schema {
            public typealias QueryOutput = User
            public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
            public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
              [id]
            }
          }
          public static let columns = Columns()
          public static let name = "user"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try Self.columns.id.decode(decoder: decoder)
          }
        }
        """#
      }
    }
  }

  @Test
  func customColumnName() {
    withMacroTesting(
      record: .failed,
      macros: [TableMacro.self]
    ) {
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

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.Schema {
            public typealias QueryOutput = User
            public let id = StructuredQueries.Column<QueryOutput, Int>("user_id", keyPath: \.id)
            public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
              [id]
            }
          }
          public static let columns = Columns()
          public static let name = "users"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try Self.columns.id.decode(decoder: decoder)
          }
        }
        """#
      }
    }
  }

  @Test
  func dateFieldDiagnostic() {
    // TODO: generate diagnostic with fixit when using bare date
    withMacroTesting(
      record: .failed,
      macros: [TableMacro.self]
    ) {
      assertMacro {
        #"""
        @Table
        struct User {
          var joined: Date
        }
        """#
      } expansion: {
        #"""
        struct User {
          @Column
          var joined: Date
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.Schema {
            public typealias QueryOutput = User
            public let joined = StructuredQueries.Column<QueryOutput, Date>("joined", keyPath: \.joined)
            public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
              [joined]
            }
          }
          public static let columns = Columns()
          public static let name = "users"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.joined = try Self.columns.joined.decode(decoder: decoder)
          }
        }
        """#
      }
    }
  }

  @Test
  func customBindingStrategy() {
    withMacroTesting(
      record: .failed,
      macros: [TableMacro.self]
    ) {
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
            public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
              [joined]
            }
          }
          public static let columns = Columns()
          public static let name = "users"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.joined = try Self.columns.joined.decode(decoder: decoder)
          }
        }
        """#
      }
    }
  }

  @Test
  func capitalSelf() {
    withMacroTesting(
      record: .failed,
      macros: [TableMacro.self]
    ) {
      assertMacro {
        """
        @Table
        struct User {
          var id: Tagged<Self, Int>
        }
        """
      } expansion: {
        #"""
        struct User {
          @Column
          var id: Tagged<Self, Int>
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.Schema {
            public typealias QueryOutput = User
            public let id = StructuredQueries.Column<QueryOutput, Tagged<User, Int>>("id", keyPath: \.id)
            public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
              [id]
            }
          }
          public static let columns = Columns()
          public static let name = "users"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try Self.columns.id.decode(decoder: decoder)
          }
        }
        """#
      }
    }
  }

  @Test
  func noTypeAnnotation() {
    withMacroTesting(
      record: .failed,
      macros: [TableMacro.self]
    ) {
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
          @Column
          var id = Int(0)
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.Schema {
            public typealias QueryOutput = User
            public let id = StructuredQueries.Column<QueryOutput, _>("id", keyPath: \.id, default: Int(0))
            public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
              [id]
            }
          }
          public static let columns = Columns()
          public static let name = "users"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try Self.columns.id.decode(decoder: decoder)
          }
        }
        """#
      }
    }
  }

  @Test
  func nested() {
    withMacroTesting(
      record: .failed,
      macros: [TableMacro.self]
    ) {
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
            @Column
            var id: Int
            @Column
            var name: String
          }
        }

        extension Outer.User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.Schema {
            public typealias QueryOutput = Outer.User
            public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
            public let name = StructuredQueries.Column<QueryOutput, String>("name", keyPath: \.name)
            public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
              [id, name]
            }
          }
          public static let columns = Columns()
          public static let name = "users"
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.id = try Self.columns.id.decode(decoder: decoder)
            self.name = try Self.columns.name.decode(decoder: decoder)
          }
        }
        """#
      }
    }
  }
}
