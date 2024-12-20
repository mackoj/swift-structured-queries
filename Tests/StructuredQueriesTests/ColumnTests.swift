import StructuredQueries
import Testing

@Table
private struct Author {
  struct ID: RawRepresentable, QueryBindable { var rawValue: Int }
  var id: ID
  var name: String
}

@Table
private struct Book {
  var id: Int64
  var name: String
}

struct ColumnTests {
  @Test func expression() {
    #expect(
      Author.columns.id.queryString == """
        "authors"."id"
        """
    )
  }

  @Test func rawRepresentable() {
    #expect(
      (Author.columns.id == Author.ID(rawValue: 42)).queryString == #"("authors"."id" = ?)"#
    )
  }

  @Test func exoticInteger() {
    #expect(
      (Book.columns.id == 42 as Int64).queryString == #"("books"."id" = ?)"#
    )
  }
}
