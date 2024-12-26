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
        """
        struct User {
          @Column
          var id: Int
          @Column
          var name: String
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.TableExpression {
            public typealias Value = User
            public let id = StructuredQueries.Column<Value, Int>("id")
            public let name = StructuredQueries.Column<Value, String>("name")
            public var allColumns: [any StructuredQueries.ColumnExpression<Value>] {
              [id, name]
            }
          }
          public static var columns: Columns {
            Columns()
          }
          public static let name = "users"
          public init(decoder: any StructuredQueries.QueryDecoder) throws {
            id = try Self.columns.id.decode(decoder: decoder)
            name = try Self.columns.name.decode(decoder: decoder)
          }
        }
        """
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
          public struct Columns: StructuredQueries.TableExpression {
            public typealias Value = User
            public let id = StructuredQueries.Column<Value, Int>("id")
            public var allColumns: [any StructuredQueries.ColumnExpression<Value>] {
              [id]
            }
          }
          public static var columns: Columns {
            Columns()
          }
          public static let name = "users"
          public init(decoder: any StructuredQueries.QueryDecoder) throws {
            id = try Self.columns.id.decode(decoder: decoder)
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
        """
        struct User {
          @Column
          var id: Int
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.TableExpression {
            public typealias Value = User
            public let id = StructuredQueries.Column<Value, Int>("id")
            public var allColumns: [any StructuredQueries.ColumnExpression<Value>] {
              [id]
            }
          }
          public static var columns: Columns {
            Columns()
          }
          public static let name = "users"
          public init(decoder: any StructuredQueries.QueryDecoder) throws {
            id = try Self.columns.id.decode(decoder: decoder)
          }
        }
        """
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
        """
        struct User {
          @Column
          var id: Int
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.TableExpression {
            public typealias Value = User
            public let id = StructuredQueries.Column<Value, Int>("id")
            public var allColumns: [any StructuredQueries.ColumnExpression<Value>] {
              [id]
            }
          }
          public static var columns: Columns {
            Columns()
          }
          public static let name = "user"
          public init(decoder: any StructuredQueries.QueryDecoder) throws {
            id = try Self.columns.id.decode(decoder: decoder)
          }
        }
        """
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
        """
        struct User {
          @Column("user_id")
          var id: Int
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.TableExpression {
            public typealias Value = User
            public let id = StructuredQueries.Column<Value, Int>("user_id")
            public var allColumns: [any StructuredQueries.ColumnExpression<Value>] {
              [id]
            }
          }
          public static var columns: Columns {
            Columns()
          }
          public static let name = "users"
          public init(decoder: any StructuredQueries.QueryDecoder) throws {
            id = try Self.columns.id.decode(decoder: decoder)
          }
        }
        """
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
        """
        struct User {
          @Column(as: .iso8601)
          var joined: Date
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.TableExpression {
            public typealias Value = User
            public let joined = StructuredQueries.Column<Value, _>("joined", as: .iso8601)
            public var allColumns: [any StructuredQueries.ColumnExpression<Value>] {
              [joined]
            }
          }
          public static var columns: Columns {
            Columns()
          }
          public static let name = "users"
          public init(decoder: any StructuredQueries.QueryDecoder) throws {
            joined = try Self.columns.joined.decode(decoder: decoder)
          }
        }
        """
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
        """
        struct User {
          @Column
          var id: Tagged<Self, Int>
        }

        extension User: StructuredQueries.Table {
          public struct Columns: StructuredQueries.TableExpression {
            public typealias Value = User
            public let id = StructuredQueries.Column<Value, Tagged<User, Int>>("id")
            public var allColumns: [any StructuredQueries.ColumnExpression<Value>] {
              [id]
            }
          }
          public static var columns: Columns {
            Columns()
          }
          public static let name = "users"
          public init(decoder: any StructuredQueries.QueryDecoder) throws {
            id = try Self.columns.id.decode(decoder: decoder)
          }
        }
        """
      }
    }
  }
}
