import InlineSnapshotTesting
import StructuredQueries
import Testing

@Table
struct Player {
  let id: Int
  var name: String
  var isInjured: Bool
  var teamID: Int

  var slug: String {
    "\(id)-\(name)"
  }
}

@Table
struct Team {
  let id: Int
  var name: String
}

@Test func basics() {
  assertInlineSnapshot(of: Player.all(), as: .sql) {
    """
    SELECT "players"."id", "players"."name", "players"."isInjured" FROM "players"
    """
  }

  assertInlineSnapshot(
    of: Player
      .all()
      .select(\.name)
      .where { !$0.isInjured },
    as: .sql
  ) {
    """
    SELECT "players"."name" FROM "players" WHERE NOT ("players"."isInjured")
    """
  }

  assertInlineSnapshot(
    of: Team
      .all()
      .group(by: \.id)
      .join(Player.all().where { $0.name != "Blob" }) { $0.id == $1.teamID }
      .select { ($0, $1.id.count()) },
    as: .sql
  ) {
    """
    SELECT "teams"."id", "teams"."name", count("players"."id") FROM "teams" JOIN "players" ON ("teams"."id" = "players"."teamID") WHERE ("players"."name" <> 'Blob') GROUP BY "teams"."id"
    """
  }

  let blob = Player.Draft(
    name: "Blob",
    isInjured: false,
    teamID: 1
  )
  assertInlineSnapshot(
    of: Player.insert([blob]).returning(\.self),
    as: .sql
  ) {
    """
    INSERT INTO "players" ("name", "isInjured", "teamID") VALUES ('Blob', 0, 1) RETURNING "players"."id", "players"."name", "players"."isInjured", "players"."teamID"
    """
  }

  assertInlineSnapshot(
    of: Player.update {
      $0.name += ", Esq."
    },
    as: .sql
  ) {
    """
    UPDATE "players" SET "name" = ("players"."name" || ', Esq.')
    """
  }
}
