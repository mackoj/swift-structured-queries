import SwiftSyntax
import SwiftSyntaxMacros

public enum RawMacro: ExpressionMacro {
  public static func expansion<N: FreestandingMacroExpansionSyntax, C: MacroExpansionContext>(
    of node: N,
    in context: C
  ) -> ExprSyntax {
    guard let argument = node.arguments.first?.expression else { fatalError() }
    return "StructuredQueries.RawQueryExpression(\(argument))"
  }
}
