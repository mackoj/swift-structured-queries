import StructuredQueries
import Testing

@Table
private struct SyncUp: Equatable {
  var id: Int
  var isActive: Bool
  var title: String
}

struct UpdateTests {
  @Test func basics() {
    #expect(
      SyncUp
        .update {
          $0.isActive = true
          $0.title = "Engineering"
        }
        .sql == """
          UPDATE "syncUps" SET "isActive" = ?, "title" = ?
          """
    )
  }

  @Test func `where`() {
    // TODO: Support chaining from SELECT or WHERE builders?
    //       - 'SyncUp.all().where(\.isActive).update { $0.isActive.toggle() }'
    //         (Runtime warn when 'Select" contains irrelevant clauses?)
    //       - 'SyncUp.where(\.isActive).update { $0.isActive.toggle() }'`
    #expect(
      SyncUp
        .update {
          $0.isActive = true
          $0.title = "Engineering"
        }
        .where(\.isActive)
        .sql == """
          UPDATE "syncUps" SET "isActive" = ?, "title" = ? \
          WHERE "syncUps"."isActive"
          """
    )
  }

  @Test func returning() {
    #expect(
      SyncUp
        .update {
          $0.isActive = true
          $0.title = "Engineering"
        }
        .returning(\.self)
        .sql == """
          UPDATE "syncUps" SET "isActive" = ?, "title" = ? \
          RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."title"
          """
    )
  }
}
