import StructuredQueries
import Testing

@Suite struct DisfavoredOverloadTests {
  @Test func basics() {
    let a1 = "a".contains("a")
    #expect(a1 == true)
  }
}
