import MacroTesting
import StructuredQueriesMacros
import Testing

extension SnapshotTests {
  @MainActor
  @Suite(.macros(macros: [BindMacro.self])) struct BindMacroTests {
    @Test func basics() {
      assertMacro {
        #"""
        \(date) < #bind(Date())
        """#
      } expansion: {
        #"""
        \(date) < StructuredQueries.BindQueryExpression(Date())
        """#
      }
    }

    @Test func queryValueType() {
      assertMacro {
        #"""
        \(date) < #bind(Date(), as: Date.ISO8601Representation.self)
        """#
      } expansion: {
        #"""
        \(date) < StructuredQueries.BindQueryExpression(Date(), as: Date.ISO8601Representation.self)
        """#
      }
    }
  }
}
