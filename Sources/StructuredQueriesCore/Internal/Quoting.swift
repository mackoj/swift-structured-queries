extension String {
  func quoted() -> String {
    let escaped =
      self
      .split(separator: #"""#, omittingEmptySubsequences: false)
      .joined(separator: #""""#)
    return """
      "\(escaped)"
      """
  }
}
