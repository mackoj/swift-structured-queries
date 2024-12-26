import Foundation
import StructuredQueries
import Testing

struct ColumnTests {
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

  @Test func strategy() {
    let query = Book.columns.published > .bind(Date(timeIntervalSince1970: 0), as: .iso8601)
    #expect(
      query.queryString == """
        ("books"."published" > ?)
        """
    )
    #expect(
      query.queryBindings == [.text("1970-01-01T00:00:00Z")]
    )
  }
}
