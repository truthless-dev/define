import XCTest

@testable import Define

class EntryTests: XCTestCase {
  func testDescriptionBeginsWithTheDefinedWord() {
    let api = DictionaryApi()
    let entries = try! api.decode(entries: entriesData)
    let description = entries[0].describe().trimmingCharacters(in: .whitespacesAndNewlines)
    let startsWithWord = description.hasPrefix("Unctuous")
    XCTAssertTrue(
      startsWithWord, "Description '\(description)' does not start with the word being defined.")
  }
}
