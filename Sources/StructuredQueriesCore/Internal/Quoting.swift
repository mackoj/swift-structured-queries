extension String {
  func quoted(_ delimiter: String = "\"") -> String {
    let escaped =
      self
      .split(separator: delimiter, omittingEmptySubsequences: false)
      .joined(separator: delimiter)
    return """
      \(delimiter)\(escaped)\(delimiter)
      """
  }
}
