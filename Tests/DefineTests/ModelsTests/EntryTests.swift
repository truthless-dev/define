import XCTest

@testable import Define

class EntryTests: XCTestCase {
  let entries = {
    let api = DictionaryApi()
    return try! api.decode(entries: entriesData)
  }()

  func testDescriptionBeginsWithTheDefinedWord() {
    let description = entries[0].describe().trimmingCharacters(in: .whitespacesAndNewlines)
    let startsWithWord = description.hasPrefix("Unctuous")
    XCTAssertTrue(
      startsWithWord, "Description '\(description)' does not start with the word being defined.")
  }
}
