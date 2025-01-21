import SwiftSyntax

let moduleName: TokenSyntax = "StructuredQueries"

extension String {
  func qualified() -> String {
    "\(moduleName).\(self)"
  }

  func tableName() -> String {
    lowerCamelCased().pluralized()
  }

  func lowerCamelCased() -> String {
    var prefix = prefix(while: \.isUppercase)
    if prefix.count > 1 { prefix = prefix.dropLast() }
    return prefix.lowercased() + dropFirst(prefix.count)
  }

  func pluralized() -> String {
    let suffix = hasSuffix("s") ? "es" : "s"
    return self + suffix
  }
}
