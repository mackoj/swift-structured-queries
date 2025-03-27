import StructuredQueriesSupport
import Testing

@Suite struct InflectionTests {
  @Test func basics() {
    #expect("category".pluralized() == "categories")
    #expect("person".pluralized() == "persons")  // people?
    #expect("placebo".pluralized() == "placebos")
    #expect("status".pluralized() == "statuses")
    #expect("user".pluralized() == "users")
    #expect("zoo".pluralized() == "zoos")
  }
}
