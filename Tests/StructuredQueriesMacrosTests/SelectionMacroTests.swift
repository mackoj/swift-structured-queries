import MacroTesting
import StructuredQueriesMacros
import Testing

@Suite/*(.macros(record: .failed, macros: [SelectionMacro.self]))*/ struct SelectionMacroTests {
  @Test func basics() {
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
          public typealias QueryOutput = PlayerAndTeam
          public let queryFragment: QueryFragment
          public init(
            player: some StructuredQueries.QueryExpression<Player>,
            team: some StructuredQueries.QueryExpression<Team>
          ) {
            self.queryFragment = "\(player.queryFragment), \(team.queryFragment)"
          }
        }
        public init(decoder: some StructuredQueries.QueryDecoder) throws {
          self.player = try decoder.decode(Player.self)
          self.team = try decoder.decode(Team.self)
        }
      }
      """#
    }
  }

  @Test func `enum`() {
    assertMacro([SelectionMacro.self], record: .failed) {
      """
      @Selection
      public enum S {}
      """
    } diagnostics: {
      """
      @Selection
      public enum S {}
             ┬───
             ╰─ 🛑 '@Selection' can only be applied to struct types
      """
    }
  }
}
