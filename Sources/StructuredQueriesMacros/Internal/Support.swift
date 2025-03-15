import SwiftSyntax

let moduleName: TokenSyntax = "StructuredQueries"

extension String {
  func lowerCamelCased() -> String {
    var prefix = prefix(while: \.isUppercase)
    if prefix.count > 1 { prefix = prefix.dropLast() }
    return prefix.lowercased() + dropFirst(prefix.count)
  }

  func pluralized() -> String {
    let suffix = hasSuffix("s") ? "es" : "s"
    return self + suffix
  }

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
