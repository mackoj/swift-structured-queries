import Dependencies
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct EphemeralTests {
    @Test func basics() {
      assertInlineSnapshot(
        of: TestTable.select { $0.firstName + ", " + $0.lastName },
        as: .sql
      ) {
        """
        SELECT (("testTables"."firstName" || ', ') || "testTables"."lastName") FROM "testTables"
        """
      }
    }
  }
}

@Table private struct TestTable {
  var firstName = ""
  var lastName = ""
  @Ephemeral
  var displayName = ""
}
