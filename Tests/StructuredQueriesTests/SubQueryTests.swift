import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct SubQueryTests {
    @Test func subquery() async throws {
      assertInlineSnapshot(
        of: Player.all()
          .where {
            $0.teamID.in(
              Team.all()
                .select(\.id)
                .where { $0.name.length >= 8 }
            )
          },
        as: .sql
      ) {
        """
        SELECT "players"."id", "players"."teamID" FROM "players" \
        WHERE ("players"."teamID" IN (\
        SELECT "teams"."id" FROM "teams" WHERE (length("teams"."name") >= 8)\
        ))
        """
      }
    }

    @Test func subqueryContains() async throws {
      assertInlineSnapshot(
        of: Player.all()
          .where {
            Team.all()
              .select(\.id)
              .where { $0.name.length >= 8 }
              .contains($0.teamID)
          },
        as: .sql
      ) {
        """
        SELECT "players"."id", "players"."teamID" FROM "players" \
        WHERE ("players"."teamID" IN (\
        SELECT "teams"."id" FROM "teams" WHERE (length("teams"."name") >= 8)\
        ))
        """
      }
    }

    @Test func subqueryWithArray() async throws {
      assertInlineSnapshot(
        of: Player.where { $0.teamID.in([1, 2, 3]) },
        as: .sql
      ) {
        """
        SELECT "players"."id", "players"."teamID" FROM "players" \
        WHERE ("players"."teamID" IN (1, 2, 3))
        """
      }
    }

    @Table fileprivate struct Player {
      let id: Int
      var teamID: Int
    }

    @Table fileprivate struct Team {
      let id: Int
      var name = ""
    }
  }
}
