import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct ColumnTests {
    @Table
    struct Author {
      struct ID: RawRepresentable, QueryBindable { var rawValue: Int }
      var id: ID
      var name: String
    }

    @Table
    struct Book {
      var id: Int64
      var name: String
      @Column(as: .iso8601)
      var published: Date
    }

    @Test func expression() {
      assertInlineSnapshot(of: Author.columns.id, as: .sql) {
        """
        "authors"."id"
        """
      }
    }

    @Test func rawRepresentable() {
      assertInlineSnapshot(of: Author.columns.id == Author.ID(rawValue: 42), as: .sql) {
        """
        ("authors"."id" = 42)
        """
      }
    }

    @Test func exoticInteger() {
      assertInlineSnapshot(of: Book.columns.id == 42 as Int64, as: .sql) {
        """
        ("books"."id" = 42)
        """
      }
    }

    @Test func strategy() {
      assertInlineSnapshot(
        of: Book.columns.published > .bind(Date(timeIntervalSince1970: 0), as: .iso8601),
        as: .sql
      ) {
        """
        ("books"."published" > '1970-01-01 00:00:00.000')
        """
      }
    }
  }
}
