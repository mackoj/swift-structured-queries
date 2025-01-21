import CustomDump
import InlineSnapshotTesting
import StructuredQueries
import StructuredQueriesSQLite
import Testing

@Table private struct Player: Equatable {
  let id: Int
  var name: String
  var teamID: Int
}
@Table private struct Team: Equatable {
  let id: Int
  var name: String
  var isActive: Bool
}

@Selection
private struct PlayerNameAndTeamIsActive: Equatable {
  var playerName: String
  var teamIsActive: Bool
}
@Selection
private struct PlayerCountAndTeam: Equatable {
  var team: Team
  var playerCount: Int
}
@Selection
private struct PlayerAndTeam: Equatable {
  var player: Player
  var team: Team
}

@Suite struct CustomSelectTests {
  let db: Database
  init() throws {
    db = try .test
    _ = try db.execute(
      Team.insert([
        Team(id: 1, name: "Bluejays", isActive: true),
        Team(id: 2, name: "Tigers", isActive: false),
        Team(id: 3, name: "Panthers", isActive: true),
      ])
    )
    _ = try db.execute(
      Player.insert([
        Player(id: 1, name: "Blob", teamID: 1),
        Player(id: 2, name: "Blob Jr", teamID: 2),
        Player(id: 3, name: "Blob Sr", teamID: 3),
        Player(id: 4, name: "Blob Esq", teamID: 1),
      ])
    )
  }

  @Test func playerNameAndTeamIsActive() throws {
    let query = Player.all()
      .join(Team.all()) { $0.teamID == $1.id }
      .select { PlayerNameAndTeamIsActive.Columns(playerName: $0.name, teamIsActive: $1.isActive) }
    let results = try db.execute(query)
    #expect(
      results == [
        PlayerNameAndTeamIsActive(playerName: "Blob", teamIsActive: true),
        PlayerNameAndTeamIsActive(playerName: "Blob Jr", teamIsActive: false),
        PlayerNameAndTeamIsActive(playerName: "Blob Sr", teamIsActive: true),
        PlayerNameAndTeamIsActive(playerName: "Blob Esq", teamIsActive: true),
      ]
    )
  }

  @Test func teamWithPlayerCount() throws {
    let query = Player.all()
      .join(Team.all()) { $0.teamID == $1.id }
      .select {
        PlayerCountAndTeam.Columns(team: $1, playerCount: $0.id.count())
      }
      .group { _, team in team.id }
    assertInlineSnapshot(of: query.queryString, as: .lines) {
      """
      SELECT "teams"."id", "teams"."name", "teams"."isActive", count("players"."id") FROM "players" JOIN "teams" ON ("players"."teamID" = "teams"."id") GROUP BY "teams"."id"
      """
    }
    let results = try db.execute(query)
    expectNoDifference(
      results,
      [
        PlayerCountAndTeam(team: Team(id: 1, name: "Bluejays", isActive: true), playerCount: 2),
        PlayerCountAndTeam(team: Team(id: 2, name: "Tigers", isActive: false), playerCount: 1),
        PlayerCountAndTeam(team: Team(id: 3, name: "Panthers", isActive: true), playerCount: 1),
      ]
    )
  }

  @Test func playerAndTeam() throws {
    let query = Player.all()
      .join(Team.all()) { $0.teamID == $1.id }
      .select(PlayerAndTeam.Columns.init)
      .order { ($0.id, $1.id) }
    let results = try db.execute(query)
    expectNoDifference(
      results,
      [
        PlayerAndTeam(
          player: Player(id: 1, name: "Blob", teamID: 1),
          team: Team(id: 1, name: "Bluejays", isActive: true)
        ),
        PlayerAndTeam(
          player: Player(id: 2, name: "Blob Jr", teamID: 2),
          team: Team(id: 2, name: "Tigers", isActive: false)
        ),
        PlayerAndTeam(
          player: Player(id: 3, name: "Blob Sr", teamID: 3),
          team: Team(id: 3, name: "Panthers", isActive: true)
        ),
        PlayerAndTeam(
          player: Player(id: 4, name: "Blob Esq", teamID: 1),
          team: Team(id: 1, name: "Bluejays", isActive: true)
        ),
      ]
    )
  }
}

extension Database {
  fileprivate static var test: Database {
    get throws {
      let db = try Database()
      try db.execute(
        """
        CREATE TABLE "players" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
          "name" TEXT NOT NULL,
          "teamID" INTEGER NOT NULL
        )
        """
      )
      try db.execute(
        """
        CREATE TABLE "teams" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
          "name" TEXT NOT NULL,
          "isActive" BOOLEAN NOT NULL
        )
        """
      )
      return db
    }
  }
}
