extension String {
  func quoted(_ delimiter: String = "\"") -> String {
    delimiter + replacing(delimiter, with: delimiter + delimiter) + delimiter
  }
}
