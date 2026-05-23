import XCTest

@testable import Define

class EntryFormatterTests: XCTestCase {
  private var entries: [Entry] = []

  override func setUp() {
    let api = DictionaryApi()
    entries = try! api.decode(entries: entriesData)
  }

  override func tearDown() {
    entries = []
  }

  // MARK: - Default formatter (includingPhonetics: false)

  func testDescriptionBeginsWithTheDefinedWordCapitalized() {
    let formatter = EntryFormatter()
    let description = formatter.describe(entries[0]).trimmingCharacters(in: .whitespacesAndNewlines)
    XCTAssertTrue(
      description.hasPrefix("Unctuous"),
      "Description '\(description)' does not start with the word being defined.")
  }

  func testDescriptionHasMultipleLines() {
    let formatter = EntryFormatter()
    let description = formatter.describe(entries[0])
    let actual = description.count { $0 == "\n" } + 1
    let expected = 2
    XCTAssertGreaterThan(
      actual, expected,
      "Description should show more than \(expected) lines; has \(actual): '\(description)'.")
  }

  func testDescriptionIncludesAPartOfSpeech() {
    let formatter = EntryFormatter()
    let description = formatter.describe(entries[0])
    XCTAssertTrue(
      description.contains("adjective"),
      "Description '\(description)' does not show parts of speech.")
  }

  func testDescriptionShowsNumberedDefinitions() {
    let formatter = EntryFormatter()
    let description = formatter.describe(entries[0])
    XCTAssertTrue(
      description.contains("1.") && description.contains("2."),
      "Missing numbered definitions in description: '\(description)'.")
  }

  func testDefinitionsAreNumberedStartingAtOne() {
    let formatter = EntryFormatter()
    let description = formatter.describe(entries[0])
    XCTAssertFalse(
      description.contains("0."),
      "Definition numbering should start at 1, not 0: '\(description)'.")
  }

  func testDescriptionIsFullyLeftAligned() {
    let formatter = EntryFormatter()
    let description = formatter.describe(entries[0])
    let lines = description.components(separatedBy: "\n")
    for (i, line) in lines.enumerated() {
      if let char = line.first, char.isWhitespace {
        XCTFail("Line \(i + 1) of description is indented: '\(line)'.")
      }
    }
  }

  func testNoPhoneticsByDefault() {
    let formatter = EntryFormatter()
    let description = formatter.describe(entries[0])
    XCTAssertFalse(
      description.contains("/ˈʌnktʃuəs/"),
      "Default formatter should not include phonetics in '\(description)'.")
  }

  func testDescriptionEndsWithNewline() {
    let formatter = EntryFormatter()
    let description = formatter.describe(entries[0])
    XCTAssertTrue(
      description.hasSuffix("\n"),
      "describe(_:) output should end with a trailing newline.")
  }

  func testPartOfSpeechIsSurroundedByParentheses() {
    let formatter = EntryFormatter()
    let description = formatter.describe(entries[0])
    XCTAssertTrue(
      description.contains("(adjective)"),
      "Part of speech should be wrapped in parentheses: '\(description)'.")
  }

  // MARK: - includingPhonetics: true

  func testIncludingPhoneticsShowsPhoneticGuide() {
    let formatter = EntryFormatter(includingPhonetics: true)
    let description = formatter.describe(entries[0])
    XCTAssertTrue(
      description.contains("/ˈʌnktʃuəs/"),
      "Phonetics formatter should include phonetics in '\(description)'.")
  }

  func testIncludingPhoneticsHeaderContainsBrackets() {
    let formatter = EntryFormatter(includingPhonetics: true)
    let description = formatter.describe(entries[0])
    let firstLine = description.components(separatedBy: "\n")[0]
    XCTAssertTrue(
      firstLine.contains("[") && firstLine.contains("]"),
      "Phonetics header should contain brackets: '\(firstLine)'.")
  }

  func testIncludingPhoneticsHeaderBeginsWithWord() {
    let formatter = EntryFormatter(includingPhonetics: true)
    let description = formatter.describe(entries[0])
    let firstLine = description.components(separatedBy: "\n")[0]
    XCTAssertTrue(
      firstLine.hasPrefix("Unctuous"),
      "Phonetics header should start with the word: '\(firstLine)'.")
  }

  func testIncludingPhoneticsDeduplicated() {
    // The test fixture has the same phonetic in both `phonetic` and `phonetics[0].text`.
    let formatter = EntryFormatter(includingPhonetics: true)
    let description = formatter.describe(entries[0])
    let firstLine = description.components(separatedBy: "\n")[0]
    let occurrences = firstLine.components(separatedBy: "/ˈʌnktʃuəs/").count - 1
    XCTAssertEqual(
      occurrences, 1,
      "Duplicate phonetic string in header: '\(firstLine)'.")
  }
}
