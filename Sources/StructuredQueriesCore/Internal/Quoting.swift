extension String {
  func quoted(_ delimiter: String = "\"") -> String {
    // TODO: fix escaping, write tests
    let escaped =
      self
      .split(separator: delimiter, omittingEmptySubsequences: false)
      .joined(separator: delimiter)
    return """
      \(delimiter)\(escaped)\(delimiter)
      """
  }
}
