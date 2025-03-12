import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct StructuredQueriesPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    ColumnMacro.self,
    RawMacro.self,
    SelectionMacro.self,
    TableMacro.self,
  ]
}
