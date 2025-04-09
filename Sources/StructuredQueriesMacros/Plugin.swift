import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct StructuredQueriesPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    BindMacro.self,
    ColumnMacro.self,
    SelectionMacro.self,
    SQLMacro.self,
    TableMacro.self,
  ]
}
