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
      .select { player, team in
        PlayerNameAndTeamIsActive.Select(playerName: player.name, teamIsActive: team.isActive)
      }
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
      .select { TeamWithPlayerCount.Select(playerCount: $0.id.count(), team: $1) }
      .group { _, team in team.id }
    let results = try db.execute(query)
    #expect(
      results == [
        TeamWithPlayerCount(playerCount: 2, team: Team(id: 1, name: "Bluejays", isActive: true)),
        TeamWithPlayerCount(playerCount: 1, team: Team(id: 2, name: "Tigers", isActive: false)),
        TeamWithPlayerCount(playerCount: 1, team: Team(id: 3, name: "Panthers", isActive: true)),
      ]
    )
  }

  @Test func playerAndTeam() throws {
    let query = Player.all()
      .join(Team.all()) { $0.teamID == $1.id }
      .select { player, team in PlayerAndTeam.Select(team: team, player: player) }
      .order { ($0.id, $1.id) }
    let results = try db.execute(query)
    #expect(
      results == [
        PlayerAndTeam(
          team: Team(id: 1, name: "Bluejays", isActive: true),
          player: Player(id: 1, name: "Blob", teamID: 1)
        ),
        PlayerAndTeam(
          team: Team(id: 2, name: "Tigers", isActive: false),
          player: Player(id: 2, name: "Blob Jr", teamID: 2)
        ),
        PlayerAndTeam(
          team: Team(id: 3, name: "Panthers", isActive: true),
          player: Player(id: 3, name: "Blob Sr", teamID: 3)
        ),
        PlayerAndTeam(
          team: Team(id: 1, name: "Bluejays", isActive: true),
          player: Player(id: 4, name: "Blob Esq", teamID: 1)
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
private struct TeamWithPlayerCount: Equatable {
//  @Table(Player.self, aggregates: .count(\.id))
  var playerCount: Int
  var team: Team
}
// @Selection
private struct PlayerAndTeam: Equatable {
  var team: Team
  var player: Player
}

// Boilerplate to generate with a macro:
extension PlayerNameAndTeamIsActive: QueryDecodable {
  fileprivate struct Select: QueryExpression {
    typealias Value = PlayerNameAndTeamIsActive
    let playerName: Column<Player, String>
    let teamIsActive: Column<Team, Bool>
    init(playerName: Column<Player, String>, teamIsActive: Column<Team, Bool>) {
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
extension TeamWithPlayerCount: QueryDecodable {
  fileprivate struct Select: QueryExpression {
    typealias Value = TeamWithPlayerCount
    let playerCount: any QueryExpression<Int>
    let team: any QueryExpression<Team>
    init(playerCount: some QueryExpression<Int>, team: some QueryExpression<Team>) {
      self.playerCount = playerCount
      self.team = team
    }
    var queryString: String {
      "\(playerCount.queryString), \(team.queryString)"
    }
    var queryBindings: [QueryBinding] { [] }
  }
  public init(decoder: any StructuredQueries.QueryDecoder) throws {
    playerCount = try decoder.decode(Int.self)
    team = try decoder.decode(Team.self)
  }
}

extension PlayerAndTeam: QueryDecodable {
  fileprivate struct Select: QueryExpression {
    typealias Value = PlayerAndTeam
    let team: any QueryExpression<Team>
    let player: any QueryExpression<Player>
    init(team: some QueryExpression<Team>, player: some QueryExpression<Player>) {
      self.team = team
      self.player = player
    }
    var queryString: String {
      "\(player.queryString), \(team.queryString)"
    }
    var queryBindings: [QueryBinding] { [] }
  }
  public init(decoder: any StructuredQueries.QueryDecoder) throws {
    team = try decoder.decode(Team.self)
    player = try decoder.decode(Player.self)
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
