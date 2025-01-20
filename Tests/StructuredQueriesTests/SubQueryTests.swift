import CustomDump
import InlineSnapshotTesting
import StructuredQueries
import Testing

@Suite struct SubQueryTests {
  @Test func subquery() async throws {
    let query = Player.all()
      .where {
        $0.teamID.in(
          Team.all()
            .select(\.id)
            .where { $0.name.length >= 8 }
        )
      }

    expectNoDifference(
      query.queryString,
      """
      SELECT "players"."id", "players"."teamID" FROM "players" \
      WHERE ("players"."teamID" IN (\
      SELECT "teams"."id" FROM "teams" WHERE (length("teams"."name") >= ?))\
      )
      """
    )
    #expect(query.queryBindings == [.int(8)])
  }

  @Test func subqueryContains() async throws {
    let query = Player.all()
      .where {
        Team.all()
          .select(\.id)
          .where { $0.name.length >= 8 }
          .contains($0.teamID)
      }

    assertInlineSnapshot(of: query.queryString, as: .lines) {
      """
      SELECT "players"."id", "players"."teamID" FROM "players" WHERE ("players"."teamID" IN (SELECT "teams"."id" FROM "teams" WHERE (length("teams"."name") >= ?)))
      """
    }
    #expect(query.queryBindings == [.int(8)])
  }

  @Test func subqueryWithArray() async throws {
    let query = Player.all()
      .where { $0.teamID.in([1, 2, 3]) }

    #expect(
      query.queryString
      == """
      SELECT "players"."id", "players"."teamID" FROM "players" WHERE ("players"."teamID" IN ((?, ?, ?)))
      """
    )
    #expect(query.queryBindings == [.int(1), .int(2), .int(3)])
  }
}

@Table private struct Player {
  let id: Int
  var teamID: Int
}
@Table private struct Team {
  let id: Int
  var name = ""
}


