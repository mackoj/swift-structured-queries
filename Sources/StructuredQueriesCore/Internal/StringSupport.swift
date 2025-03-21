extension StringProtocol {
  // TODO: If exposed publicly (via a helper) we should support '[]'.
  func quoted(_ delimiter: String = "\"") -> String {
    delimiter + replacingOccurrences(of: delimiter, with: delimiter + delimiter) + delimiter
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
