import StructuredQueries
import Testing

@Table fileprivate struct Player {
  let id: Int
  var name: String
  var teamID: Int
}
@Table fileprivate struct Team {
  let id: Int
  var name: String
  var isActive: Bool
}

fileprivate struct Result {
  var isActive: Bool
  var name: String
}
fileprivate struct TeamWithPlayerCount {
  var playerCount: Int
  var team: Team
}
fileprivate struct PlayerAndTeam {
  var player: Player
  var team: Team
}

@Suite struct ResultsTests {
  @Test func customResult() {
    let _: any QueryExpression<[Result]> = Player.all()
      .join(Team.all()) { $0.teamID == $1.id }
      .select { Result.Columns(name: $0.name, isActive: $1.isActive) }

    let _: any QueryExpression<[TeamWithPlayerCount]> = Player.all()
      .join(Team.all()) { $0.teamID == $1.id }
      .select {
        TeamWithPlayerCount.Columns(playerCount: $0.id.count(), team: $1)
      }

    let _: any QueryExpression<[PlayerAndTeam]> = Player.all()
      .join(Team.all()) { $0.teamID == $1.id }
      .select { player, team in PlayerAndTeam.Columns(player: player, team: team) }

    let _: any QueryExpression<[Player]> = Player.all()
      .join(Team.all()) { $0.teamID == $1.id }
      .where { _, team in team.isActive }
      .select { player, _ in player }
  }
}

// Boilerplate to generate with a macro:
extension Result: QueryDecodable {
  fileprivate struct Columns: QueryExpression {
    typealias Value = Result
    let name: Column<Player, String>
    let isActive: Column<Team, Bool>
    init(name: Column<Player, String>, isActive: Column<Team, Bool>) {
      self.name = name
      self.isActive = isActive
    }
    var queryString: String {
      "\(name.queryString), \(isActive.queryString)"
    }
    var queryBindings: [QueryBinding] { [] }
  }
  public init(decoder: any StructuredQueries.QueryDecoder) throws {
    name = try decoder.decode(String.self)
    isActive = try decoder.decode(Bool.self)
  }
}

// Boilerplate to generate with a macro:
extension TeamWithPlayerCount: QueryDecodable {
  fileprivate struct Columns: QueryExpression {
    typealias Value = TeamWithPlayerCount
    let playerCount: AnyQueryExpression<Int>
    let team: AnyQueryExpression<Team>
    init(playerCount: some QueryExpression<Int>, team: some QueryExpression<Team>) {
      self.playerCount = AnyQueryExpression(playerCount)
      self.team = AnyQueryExpression(team)
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
  fileprivate struct Columns: QueryExpression {
    typealias Value = PlayerAndTeam
    let player: AnyQueryExpression<Player>
    let team: AnyQueryExpression<Team>
    init(player: some QueryExpression<Player>, team: some QueryExpression<Team>) {
      self.player = AnyQueryExpression(player)
      self.team = AnyQueryExpression(team)
    }
    var queryString: String {
      "\(player.queryString), \(team.queryString)"
    }
    var queryBindings: [QueryBinding] { [] }
  }
  public init(decoder: any StructuredQueries.QueryDecoder) throws {
    player = try decoder.decode(Player.self)
    team = try decoder.decode(Team.self)
  }
}
