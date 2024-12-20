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
      SyncUp.delete().queryString == """
        DELETE FROM "syncUps"
        """
    )
  }

  @Test func `where`() {
    #expect(
      SyncUp
        .delete()
        .where(\.isActive)
        .queryString == """
          DELETE FROM "syncUps" \
          WHERE "syncUps"."isActive"
          """
    )
    #expect(
      SyncUp.delete().where { $0.id == 1 && $0.isActive }.queryString
        == SyncUp.delete().where { $0.id == 1 }.where(\.isActive).queryString
    )
  }

  @Test func returning() {
    #expect(
      SyncUp
        .delete()
        .returning(\.self)
        .queryString == """
          DELETE FROM "syncUps" \
          RETURNING "syncUps"."id", "syncUps"."isActive", "syncUps"."title"
          """
    )
  }
}
