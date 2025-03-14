import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public enum SQLMacro: ExpressionMacro {
  public static func expansion<N: FreestandingMacroExpansionSyntax, C: MacroExpansionContext>(
    of node: N,
    in context: C
  ) -> ExprSyntax {
    guard let argument = node.arguments.first?.expression else { fatalError() }
    let delimiters: [UInt8: UInt8] = [
      UInt8(ascii: #"""#): UInt8(ascii: #"""#),
      UInt8(ascii: "'"): UInt8(ascii: "'"),
      UInt8(ascii: "`"): UInt8(ascii: "`"),
      UInt8(ascii: "["): UInt8(ascii: "]"),
      UInt8(ascii: "("): UInt8(ascii: ")"),
    ]
    var parenStack: [(delimiter: UInt8, segment: StringSegmentSyntax, offset: Int)] = []
    var currentDelimiter: (delimiter: UInt8, segment: StringSegmentSyntax, offset: Int)?
    var unexpectedBind: (segment: StringSegmentSyntax, offset: Int)?
    var invalidBind = false
    if let string = argument.as(StringLiteralExprSyntax.self) {
      for segment in string.segments {
        guard let segment = segment.as(StringSegmentSyntax.self)
        else {
          if invalidBind, let currentDelimiter {
            let openingDelimiter = UnicodeScalar(currentDelimiter.delimiter)
            let q = openingDelimiter == "'" ? #"""# : "'"
            context.diagnose(
              Diagnostic(
                node: segment,
                message: MacroExpansionErrorMessage(
                  """
                  Bind after opening \(q)\(openingDelimiter)\(q) in SQL string produces invalid \
                  fragment
                  """
                ),
                notes: [
                  Note(
                    node: Syntax(string),
                    position: currentDelimiter.segment.position.advanced(
                      by: currentDelimiter.offset
                    ),
                    message: MacroExpansionNoteMessage("Opening \(q)\(openingDelimiter)\(q)")
                  )
                ]
              )
            )
          }
          continue
        }

        for (offset, byte) in segment.content.syntaxTextBytes.enumerated() {
          if let delimiter = currentDelimiter ?? parenStack.last {
            if byte == delimiters[delimiter.delimiter],
               offset != delimiter.offset + 1,
               segment.content.syntaxTextBytes.indices.contains(offset - 1)
                 ? segment.content.syntaxTextBytes[offset - 1] != delimiters[byte]
                 : true
            {
              if currentDelimiter == nil {
                parenStack.removeLast()
                continue
              } else {
                currentDelimiter = nil
                continue
              }
            }
          }
          if currentDelimiter == nil {
            if delimiters.keys.contains(byte) {
              if byte == UInt8(ascii: "(") {
                parenStack.append((byte, segment, offset))
              } else {
                currentDelimiter = (byte, segment, offset)
              }
            } else {
              let binds = [
                UInt8(ascii: "?"), UInt8(ascii: ":"), UInt8(ascii: "@"), UInt8(ascii: "$")
              ]
              if binds.contains(byte) {
                unexpectedBind = (segment, offset)
              }
            }
          }
        }

        invalidBind = currentDelimiter?.segment == segment
      }
      
      if let currentDelimiter = currentDelimiter ?? parenStack.last,
        let closingDelimiter = delimiters[currentDelimiter.delimiter]
      {
        let openingDelimiter = UnicodeScalar(currentDelimiter.delimiter)
        let closingDelimiter = UnicodeScalar(closingDelimiter)
        let q = openingDelimiter == "'" ? #"""# : "'"
        context.diagnose(
          Diagnostic(
            node: string,
            position: currentDelimiter.segment.position.advanced(by: currentDelimiter.offset),
            message: MacroExpansionWarningMessage(
              """
              Cannot find \(q)\(closingDelimiter)\(q) to match opening \(q)\(openingDelimiter)\(q) \
              in SQL string produces incomplete fragment; did you mean to make this explicit?
              """
            ),
            fixIt: .replace(
              message: MacroExpansionFixItMessage(
                "Use 'SQLQueryExpression.init(_:)' to silence this warning"
              ),
              oldNode: node,
              newNode: FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                  baseName: .identifier("SQLQueryExpression")
                ),
                leftParen: .leftParenToken(),
                arguments: node.arguments,
                rightParen: .rightParenToken()
              )
            )
          )
        )
      }
      if let unexpectedBind {
        context.diagnose(
          Diagnostic(
            node: string,
            position: unexpectedBind.segment.position.advanced(by: unexpectedBind.offset),
            message: MacroExpansionErrorMessage(
              """
              Invalid bind parameter in literal; use interpolation to bind values into SQL
              """
            )
          )
        )
      }
    }
    return "StructuredQueries.SQLQueryExpression(\(argument))"
  }
}
