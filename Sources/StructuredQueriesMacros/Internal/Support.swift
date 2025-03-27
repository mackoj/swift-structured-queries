import SwiftSyntax

let moduleName: TokenSyntax = "StructuredQueries"

extension String {
  func trimmingBackticks() -> String {
    var result = self[...]
    if result.first == "`" && result.dropFirst().last == "`" {
      result = result.dropFirst().dropLast()
    }
    return String(result)
  }

  func qualified() -> String {
    "\(moduleName).\(self)"
  }
}
