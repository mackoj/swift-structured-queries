extension StringProtocol {
  // TODO: If exposed publicly (via a helper) we should support '[]'.
  func quoted(_ delimiter: String = "\"") -> String {
    delimiter + replacingOccurrences(of: delimiter, with: delimiter + delimiter) + delimiter
  }
}
