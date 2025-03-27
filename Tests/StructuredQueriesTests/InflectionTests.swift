import StructuredQueriesSupport
import Testing

@Suite struct InflectionTests {
  @Test func basics() {
    #expect("user".pluralized() == "users")
    #expect("category".pluralized() == "categories")
    #expect("status".pluralized() == "statuses")
    #expect("person".pluralized() == "persons")  // people?
  }
}
