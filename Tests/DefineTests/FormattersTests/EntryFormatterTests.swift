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

  // MARK: - Edge cases

  func testEntryWithNoMeaningsProducesJustHeader() {
    let entry = Entry(word: "silent", meanings: [], phonetic: nil, phonetics: [])
    let formatter = EntryFormatter()
    let description = formatter.describe(entry)
    XCTAssertTrue(
      description.hasPrefix("Silent"),
      "Output should start with the capitalized word even when meanings is empty: '\(description)'."
    )
    XCTAssertFalse(
      description.contains("("),
      "Output should have no part-of-speech when meanings is empty: '\(description)'.")
  }

  func testEntryWithMultipleMeaningsIncludesAllPartsOfSpeech() {
    let nounMeaning = Entry.Meaning(
      partOfSpeech: "noun",
      definitions: [Entry.Meaning.Definition(definition: "A thing.")])
    let verbMeaning = Entry.Meaning(
      partOfSpeech: "verb",
      definitions: [Entry.Meaning.Definition(definition: "To do something.")])
    let entry = Entry(
      word: "run", meanings: [nounMeaning, verbMeaning], phonetic: nil, phonetics: [])
    let formatter = EntryFormatter()
    let description = formatter.describe(entry)
    XCTAssertTrue(
      description.contains("(noun)"),
      "Output should include the noun meaning: '\(description)'.")
    XCTAssertTrue(
      description.contains("(verb)"),
      "Output should include the verb meaning: '\(description)'.")
  }

  func testMeaningWithNoDefinitionsProducesJustPartOfSpeech() {
    let emptyMeaning = Entry.Meaning(partOfSpeech: "interjection", definitions: [])
    let entry = Entry(word: "hey", meanings: [emptyMeaning], phonetic: nil, phonetics: [])
    let formatter = EntryFormatter()
    let description = formatter.describe(entry)
    XCTAssertTrue(
      description.contains("(interjection)"),
      "Output should include the part of speech: '\(description)'.")
    XCTAssertFalse(
      description.contains("1."),
      "Output should have no numbered definitions when definitions is empty: '\(description)'.")
  }

  func testNoPhoneticsBothFieldsAbsentProducesEmptyBrackets() {
    let entry = Entry(word: "bare", meanings: [], phonetic: nil, phonetics: [])
    let formatter = EntryFormatter(includingPhonetics: true)
    let firstLine = formatter.describe(entry).components(separatedBy: "\n")[0]
    XCTAssertTrue(
      firstLine.contains("[]"),
      "Header should contain empty brackets when no phonetics are available: '\(firstLine)'.")
  }

  func testPhoneticsPresentOnlyInPhoneticField() {
    let entry = Entry(word: "sole", meanings: [], phonetic: "/soʊl/", phonetics: [])
    let formatter = EntryFormatter(includingPhonetics: true)
    let firstLine = formatter.describe(entry).components(separatedBy: "\n")[0]
    XCTAssertTrue(
      firstLine.contains("/soʊl/"),
      "Header should show the phonetic-field value: '\(firstLine)'.")
  }

  func testPhoneticsPresentOnlyInPhoneticsArray() {
    let entry = Entry(
      word: "array",
      meanings: [],
      phonetic: nil,
      phonetics: [Entry.Phonetic(text: "/əˈreɪ/")])
    let formatter = EntryFormatter(includingPhonetics: true)
    let firstLine = formatter.describe(entry).components(separatedBy: "\n")[0]
    XCTAssertTrue(
      firstLine.contains("/əˈreɪ/"),
      "Header should show phonetics from the phonetics array when phonetic field is nil: '\(firstLine)'."
    )
  }

  func testMultipleDistinctPhoneticsAreSortedAndCommaSeparated() {
    let entry = Entry(
      word: "both",
      meanings: [],
      phonetic: "/boʊθ/",
      phonetics: [Entry.Phonetic(text: "/bəʊθ/")])
    let formatter = EntryFormatter(includingPhonetics: true)
    let firstLine = formatter.describe(entry).components(separatedBy: "\n")[0]
    XCTAssertTrue(
      firstLine.contains("/boʊθ/, /bəʊθ/"),
      "Header should list distinct phonetics sorted and comma-separated: '\(firstLine)'.")
  }
}
