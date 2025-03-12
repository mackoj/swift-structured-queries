import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct QueryFragmentTests {
    @Test func string() {
      assertInlineSnapshot(
        of: RawQueryExpression("'What''s the point?'", as: String.self),
        as: .sql
      ) {
        """
        'What''s the point?'
        """
      }
    }
    @Test func identifier() {
      assertInlineSnapshot(
        of: RawQueryExpression(#""What's the point?""#, as: String.self),
        as: .sql
      ) {
        """
        "What's the point?"
        """
      }
    }
    @Test func brackets() {
      assertInlineSnapshot(
        of: RawQueryExpression("[What's the point?]", as: String.self),
        as: .sql
      ) {
        """
        [What's the point?]
        """
      }
    }
    @Test func backticks() {
      assertInlineSnapshot(
        of: RawQueryExpression("`What's the point?`", as: String.self),
        as: .sql
      ) {
        """
        `What's the point?`
        """
      }
    }
  }
}
