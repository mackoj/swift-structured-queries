import StructuredQueries
import Testing

struct UpdateTests {
  @Table
  struct SyncUp: Equatable {
    var id: Int
    var isActive: Bool
    var title: String
  }

  @Test func basics() {
    #expect(
      SyncUp
        .update {
          $0.isActive = true
          $0.title = "Engineering"
        }
        .queryString == """
          UPDATE "syncUps" SET "isActive" = ?, "title" = ?
          """
    )
  }

  @Test func conflictResolution() {
    #expect(
      SyncUp
        .update(or: .abort) { $0.isActive = true }
        .queryString == """
          UPDATE OR ABORT "syncUps" SET "isActive" = ?
          """
    )
    #expect(
      SyncUp
        .update(or: .fail) { $0.isActive = true }
        .queryString == """
          UPDATE OR FAIL "syncUps" SET "isActive" = ?
          """
    )
    #expect(
      SyncUp
        .update(or: .ignore) { $0.isActive = true }
        .queryString == """
          UPDATE OR IGNORE "syncUps" SET "isActive" = ?
          """
    )
    #expect(
      SyncUp
        .update(or: .replace) { $0.isActive = true }
        .queryString == """
          UPDATE OR REPLACE "syncUps" SET "isActive" = ?
          """
    )
    #expect(
      SyncUp
        .update(or: .rollback) { $0.isActive = true }
        .queryString == """
          UPDATE OR ROLLBACK "syncUps" SET "isActive" = ?
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
        .queryString == """
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
        .queryString == """
          UPDATE "syncUps" SET "isActive" = ?, "title" = ? \
          RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."title"
          """
    )
  }

  @Test func record() {
    let query = SyncUp.update(SyncUp(id: 42, isActive: true, title: "Engineering"))
    #expect(
      query.queryString == """
        UPDATE "syncUps" SET "isActive" = ?, "title" = ? \
        WHERE ("syncUps"."id" = ?)
        """
    )
    #expect(query.queryBindings == [.int(1), .text("Engineering"), .int(42)])
  }
}

extension UpdateTests.SyncUp.Columns: PrimaryKeyed {
  var primaryKey: Column<Value, Int> { id }
}
