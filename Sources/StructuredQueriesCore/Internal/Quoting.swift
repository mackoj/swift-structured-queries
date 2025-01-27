extension String {
  // TODO: Test
  func quoted(_ delimiter: String = "\"") -> String {
    replacing(delimiter, with: delimiter + delimiter)
  }
}
