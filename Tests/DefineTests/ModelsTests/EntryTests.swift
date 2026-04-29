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

  func testDescriptionHasMultipleLines() {
    let description = entries[0].describe()
    let lines = description.count { $0 == "\n" } + 1
    XCTAssertGreaterThan(
      lines, 2, "Description should show at least three lines; has \(lines): '\(description)'.")
  }

  func testDescriptionIncludesAPartOfSpeech() {
    let description = entries[0].describe()
    let hasAdjective = description.contains("adjective")
    XCTAssertTrue(hasAdjective, "Description '\(description)' does not show parts of speech.")
  }

  func testDescriptionShowsNumberedDefinitions() {
    let description = entries[0].describe()
    let hasOne = description.contains("1.")
    let hasTwo = description.contains("2.")
    XCTAssertTrue(
      hasOne && hasTwo, "Missing numbered definitions in description: '\(description)'.")
  }

  func testDefinitionsAreNumberedStartingAtOne() {
    let description = entries[0].describe()
    let hasZero = description.contains("0.")
    XCTAssertFalse(hasZero, "Definition numbering should start at 1, not 0: '\(description)'.")
  }

  func testDescriptionIsFullyLeftAligned() {
    let description = entries[0].describe()
    let lines = description.components(separatedBy: "\n")
    for (i, line) in lines.enumerated() {
      if let char = line.first, char.isWhitespace {
        XCTFail("Line \(i + 1) of description is indented: '\(line)'.")
      }
    }
  }
}
