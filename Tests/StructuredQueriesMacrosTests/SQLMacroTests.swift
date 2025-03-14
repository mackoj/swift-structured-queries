import MacroTesting
import StructuredQueriesMacros
import Testing

extension SnapshotTests {
  @MainActor
  @Suite(.macros(macros: [SQLMacro.self])) struct SQLMacroTests {
    @Test func basics() {
      assertMacro {
        """
        #sql("CURRENT_TIMESTAMP")
        """
      } expansion: {
        """
        StructuredQueries.SQLQueryExpression("CURRENT_TIMESTAMP")
        """
      }
    }

    @Test func unmatchedDelimiters() {
      assertMacro {
        """
        #sql("date('now)")
        """
      } diagnostics: {
        """
        #sql("date('now)")
             ──────┬─────
                   ╰─ ⚠️ Cannot find "'" to match opening "'" in SQL string produces incomplete fragment; did you mean to make this explicit?
                      ✏️ Use 'SQLQueryExpression.init(_:)' to silence this warning
        """
      } fixes: {
        """
        SQLQueryExpression("date('now)")
        """
      } expansion: {
        """
        SQLQueryExpression("date('now)")
        """
      }
      assertMacro {
        #"""
        #sql("(\($0.id) = \($1.id)")
        """#
      } diagnostics: {
        #"""
        #sql("(\($0.id) = \($1.id)")
             ─┬────────────────────
              ╰─ ⚠️ Cannot find ')' to match opening '(' in SQL string produces incomplete fragment; did you mean to make this explicit?
                 ✏️ Use 'SQLQueryExpression.init(_:)' to silence this warning
        """#
      } fixes: {
        #"""
        SQLQueryExpression("(\($0.id) = \($1.id)")
        """#
      } expansion: {
        #"""
        SQLQueryExpression("(\($0.id) = \($1.id)")
        """#
      }
    }

    @Test func escapedDelimiters() {
      assertMacro {
        """
        #sql("'('")
        """
      } expansion: {
        """
        StructuredQueries.SQLQueryExpression("'('")
        """
      }
      assertMacro {
        """
        #sql("[it's fine]")
        """
      } expansion: {
        """
        StructuredQueries.SQLQueryExpression("[it's fine]")
        """
      }
    }

    @Test func unexpectedBind() {
      assertMacro {
        """
        #sql("CURRENT_TIMESTAMP = ?")
        """
      } diagnostics: {
        """
        #sql("CURRENT_TIMESTAMP = ?")
             ─────────────────────┬─
                                  ╰─ 🛑 Invalid bind parameter in literal; use interpolation to bind values into SQL
        """
      }
      assertMacro {
        """
        #sql("CURRENT_TIMESTAMP = ?1")
        """
      } diagnostics: {
        """
        #sql("CURRENT_TIMESTAMP = ?1")
             ─────────────────────┬──
                                  ╰─ 🛑 Invalid bind parameter in literal; use interpolation to bind values into SQL
        """
      }
      assertMacro {
        """
        #sql("CURRENT_TIMESTAMP = :timestamp")
        """
      } diagnostics: {
        """
        #sql("CURRENT_TIMESTAMP = :timestamp")
             ─────────────────────┬──────────
                                  ╰─ 🛑 Invalid bind parameter in literal; use interpolation to bind values into SQL
        """
      }
      assertMacro {
        """
        #sql("CURRENT_TIMESTAMP = @timestamp")
        """
      } diagnostics: {
        """
        #sql("CURRENT_TIMESTAMP = @timestamp")
             ─────────────────────┬──────────
                                  ╰─ 🛑 Invalid bind parameter in literal; use interpolation to bind values into SQL
        """
      }
      assertMacro {
        """
        #sql("CURRENT_TIMESTAMP = $timestamp")
        """
      } diagnostics: {
        """
        #sql("CURRENT_TIMESTAMP = $timestamp")
             ─────────────────────┬──────────
                                  ╰─ 🛑 Invalid bind parameter in literal; use interpolation to bind values into SQL
        """
      }
    }

    @Test func escapedBind() {
      assertMacro {
        """
        #sql(#""text" = 'hello?'"#)
        """
      } expansion: {
        """
        StructuredQueries.SQLQueryExpression(#""text" = 'hello?'"#)
        """
      }
      assertMacro {
        """
        #sql(#""text" = 'hello?1'"#)
        """
      } expansion: {
        """
        StructuredQueries.SQLQueryExpression(#""text" = 'hello?1'"#)
        """
      }
      assertMacro {
        """
        #sql(#""text" = 'hello:hi'"#)
        """
      } expansion: {
        """
        StructuredQueries.SQLQueryExpression(#""text" = 'hello:hi'"#)
        """
      }
      assertMacro {
        """
        #sql(#""text" = 'hello@hi'"#)
        """
      } expansion: {
        """
        StructuredQueries.SQLQueryExpression(#""text" = 'hello@hi'"#)
        """
      }
      assertMacro {
        """
        #sql(#""text" = 'hello$hi'"#)
        """
      } expansion: {
        """
        StructuredQueries.SQLQueryExpression(#""text" = 'hello$hi'"#)
        """
      }
    }

    @Test func invalidBind() {
      assertMacro {
        #"""
        #sql("'\(42)'")
        """#
      } diagnostics: {
        #"""
        #sql("'\(42)'")
               ┬────
               ╰─ 🛑 Bind after opening "'" in SQL string produces invalid fragment
        """#
      }
    }
  }
}
