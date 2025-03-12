import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct QueryFragmentTests {
    @Test func snapshotting() {
      assertInlineSnapshot(
        of: RawQueryExpression("'What''s the point?'", as: String.self),
        as: .sql
      ) {
        """
        'What''s the point?'
        """
      }
    }
  }
}
