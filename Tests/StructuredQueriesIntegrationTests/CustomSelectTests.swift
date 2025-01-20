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
      .select { PlayerCountAndTeam.Columns(team: $1, playerCount: $0.id.count()) }
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


// @Selection
private struct PlayerNameAndTeamIsActive: Equatable {
  //@Table(Player.self)
  var playerName: String
  var teamIsActive: Bool
}
// @Selection
private struct PlayerCountAndTeam: Equatable {
  var team: Team
  var playerCount: Int
}
// @Selection
// @Computed
// @View
// @Columns / @Table
private struct PlayerAndTeam: Equatable {
  var player: Player
  var team: Team
}

// Boilerplate to generate with a macro:
extension PlayerNameAndTeamIsActive: QueryDecodable {
  fileprivate struct Columns: QueryExpression {
    typealias Value = PlayerNameAndTeamIsActive
    let playerName: any QueryExpression<String>
    let teamIsActive: any QueryExpression<Bool>
    init(playerName: some QueryExpression<String>, teamIsActive: some QueryExpression<Bool>) {
      self.playerName = playerName
      self.teamIsActive = teamIsActive
    }
    var queryString: String {
      "\(playerName.queryString), \(teamIsActive.queryString)"
    }
    var queryBindings: [QueryBinding] { [] }
  }
  public init(decoder: any StructuredQueries.QueryDecoder) throws {
    playerName = try decoder.decode(String.self)
    teamIsActive = try decoder.decode(Bool.self)
  }
}

// Boilerplate to generate with a macro:
extension PlayerCountAndTeam: QueryDecodable {
  fileprivate struct Columns: QueryExpression {
    typealias Value = PlayerCountAndTeam
    let team: any QueryExpression<Team>
    let playerCount: any QueryExpression<Int>
    init(team: some QueryExpression<Team>, playerCount: some QueryExpression<Int>) {
      self.playerCount = playerCount
      self.team = team
    }
    var queryString: String {
      "\(team.queryString), \(playerCount.queryString)"
    }
    var queryBindings: [QueryBinding] { [] }
  }
  public init(decoder: any StructuredQueries.QueryDecoder) throws {
    team = try decoder.decode(Team.self)
    playerCount = try decoder.decode(Int.self)
  }
}

extension PlayerAndTeam: QueryDecodable {
  fileprivate struct Columns: QueryExpression {
    typealias Value = PlayerAndTeam
    let queryString: String
    let queryBindings: [QueryBinding]
    init(player: some QueryExpression<Player>, team: some QueryExpression<Team>) {
      queryString = "\(player.queryString), \(team.queryString)"
      queryBindings = player.queryBindings + team.queryBindings
    }
  }
  public init(decoder: any StructuredQueries.QueryDecoder) throws {
    player = try decoder.decode(Player.self)
    team = try decoder.decode(Team.self)
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
