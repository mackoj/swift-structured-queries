import MacroTesting
import StructuredQueriesMacros
import Testing

extension SnapshotTests {
  @Suite
  struct SelectionMacroTests {
    @Test func basics() {
      assertMacro {
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

        extension PlayerAndTeam: StructuredQueries.QueryRepresentable {
          public struct Columns: StructuredQueries.QueryExpression {
            public typealias QueryValue = PlayerAndTeam
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
      assertMacro {
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

    @Test func optionalField() {
      assertMacro {
        """
        @Selection 
        struct ReminderTitleAndListTitle {
          var reminderTitle: String 
          var listTitle: String?
        }
        """
      } expansion: {
        #"""
        struct ReminderTitleAndListTitle {
          var reminderTitle: String 
          var listTitle: String?
        }

        extension ReminderTitleAndListTitle: StructuredQueries.QueryRepresentable {
          public struct Columns: StructuredQueries.QueryExpression {
            public typealias QueryValue = ReminderTitleAndListTitle
            public let queryFragment: QueryFragment
            public init(
              reminderTitle: some StructuredQueries.QueryExpression<String>,
              listTitle: some StructuredQueries.QueryExpression<String?>
            ) {
              self.queryFragment = "\(reminderTitle.queryFragment), \(listTitle.queryFragment)"
            }
          }
          public init(decoder: some StructuredQueries.QueryDecoder) throws {
            self.reminderTitle = try decoder.decode(String.self)
            self.listTitle = try decoder.decode(String?.self)
          }
        }
        """#
      }
    }

    @Test func date() {
      assertMacro {
        """
        @Selection struct ReminderDate {
          @Column(as: Date.ISO8601Representation.self)
          var date: Date
        }
        """
      }
    }

    @Test func dateDiagnostic() {
      assertMacro {
        """
        @Selection struct ReminderDate {
          var date: Date
        }
        """
      }
    }
  }
}
