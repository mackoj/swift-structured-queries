import MacroTesting
import StructuredQueriesMacros
import Testing

@Suite struct SelectionMacroTests {
  @Test
  func basics() {
    assertMacro([SelectionMacro.self], record: .failed) {
      """
      @Selection
      struct PlayerAndTeam {
        let player: Player 
        let team: Team
      }
      """
    } expansion: {
      #"""
      struct PlayerAndTeam {
        let player: Player 
        let team: Team
      }

      extension PlayerAndTeam: StructuredQueries.QueryDecodable {
        public struct Columns: StructuredQueries.QueryExpression {
          public typealias Value = PlayerAndTeam
          public let queryString: String
          public let queryBindings: [StructuredQueries.QueryBinding]
          public init(player: some StructuredQueries.QueryExpression<Player>, team: some StructuredQueries.QueryExpression<Team>) {
            queryString = "\(player.queryString), \(team.queryString)"
            queryBindings = player.queryBindings + team.queryBindings
          }
        }
        public init(decoder: any StructuredQueries.QueryDecoder) throws {
          player = try decoder.decode(Player.self)
          team = try decoder.decode(Team.self)
        }
      }
      """#
    }
  }

  @Test func `enum`() {
    assertMacro([SelectionMacro.self]) {
      """
      @Selection
      enum S {}
      """
    } diagnostics: {
      """
      @Selection
      ╰─ 🛑 '@Selection' can only be applied to struct types
      enum S {}
      """
    }
  }
}
