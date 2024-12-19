import StructuredQueries
import Testing

@Table
private struct SyncUp: Equatable {
  var id: Int
  var isActive: Bool
  var title: String
}

struct DeleteTests {
  @Test func basics() {
    #expect(
      SyncUp.delete().sql == """
        DELETE FROM "syncUps"
        """
    )
  }

  @Test func `where`() {
    #expect(
      SyncUp
        .delete()
        .where(\.isActive)
        .sql == """
          DELETE FROM "syncUps" \
          WHERE "syncUps"."isActive"
          """
    )
  }

  @Test func returning() {
    #expect(
      SyncUp
        .delete()
        .returning(\.self)
        .sql == """
          DELETE FROM "syncUps" \
          RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."title"
          """
    )
  }
}
