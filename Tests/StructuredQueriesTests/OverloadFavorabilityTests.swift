import StructuredQueries
import Testing

@Suite struct OverloadFavorabilityTests {
  @Test func basics() {
    do {
      let result = 42.signum()
      #expect(result == 1)
    }
    do {
      let result = 4.2.sign
      #expect(result == .plus)
    }
    do {
      let result = "a".contains("a")
      #expect(result == true)
    }
    do {
      let result = "a".uppercased()
      #expect(result == "A")
    }
    do {
      let result = "A".lowercased()
      #expect(result == "a")
    }
    do {
      let result = [1, 2, 3].count
      #expect(result == 3)
    }
  }
}
