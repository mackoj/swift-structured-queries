import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct PrimaryKeyedTableTests {
    @Test func count() throws {
      try assertQuery(Reminder.select { $0.count() }) {
        """
        SELECT count("reminders"."id") FROM "reminders"
        """
      } results: {
        """
        ┌────┐
        │ 10 │
        └────┘
        """
      }
    }
  }
}
