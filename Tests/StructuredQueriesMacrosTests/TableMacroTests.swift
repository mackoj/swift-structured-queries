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
          var id: Int
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
            id = try decoder.decode(Int.self)
            name = try decoder.decode(String.self)
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
            id = try decoder.decode(Int.self)
          }
        }
        """#
      }
    }
  }
}
