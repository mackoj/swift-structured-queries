import MacroTesting
import StructuredQueriesMacros
import Testing

extension SnapshotTests {
  @Suite
  struct TableSelectionMacroTests {
    @Test func basics() {
      assertMacro {
        """
        @Table @Selection
        struct ReminderListWithCount {
          let reminderList: ReminderList 
          let remindersCount: Int
        }
        """
      } expansion: {
        #"""
        struct ReminderListWithCount {
          let reminderList: ReminderList 
          let remindersCount: Int
        }

        extension ReminderListWithCount: StructuredQueries.Table {
          public struct TableColumns: StructuredQueries.Schema {
            public typealias QueryValue = ReminderListWithCount
            public static var count: Int {
              2
            }
            public let reminderList = StructuredQueries.TableColumn<QueryValue, ReminderList>("reminderList", keyPath: \QueryValue.reminderList)
            public let remindersCount = StructuredQueries.TableColumn<QueryValue, Int>("remindersCount", keyPath: \QueryValue.remindersCount)
            public var allColumns: [any StructuredQueries.TableColumnExpression] {
              [self.reminderList, self.remindersCount]
            }
          }
          public static let columns = TableColumns()
          public static let tableName = "reminderListWithCounts"
        }

        extension ReminderListWithCount: StructuredQueries.QueryRepresentable {
          public struct Columns: StructuredQueries.QueryExpression {
            public typealias QueryValue = ReminderListWithCount
            public let queryFragment: StructuredQueries.QueryFragment
            public init(
              reminderList: some StructuredQueries.QueryExpression<ReminderList>,
              remindersCount: some StructuredQueries.QueryExpression<Int>
            ) {
              self.queryFragment = """
              \(reminderList.queryFragment) AS "reminderList", \(remindersCount.queryFragment) AS "remindersCount"
              """
            }
          }
          public init(decoder: inout some StructuredQueries.QueryDecoder) throws {
            let reminderList = try decoder.decode(ReminderList.self)
            let remindersCount = try decoder.decode(Int.self)
            guard let reminderList else {
              throw QueryDecodingError.missingRequiredColumn
            }
            guard let remindersCount else {
              throw QueryDecodingError.missingRequiredColumn
            }
            self.reminderList = reminderList
            self.remindersCount = remindersCount
          }
        }
        """#
      }
    }
  }
}
