extension String {
  func quoted(_ delimiter: String = "\"") -> String {
    delimiter + replacingOccurrences(of: delimiter, with: delimiter + delimiter) + delimiter
  }
}
