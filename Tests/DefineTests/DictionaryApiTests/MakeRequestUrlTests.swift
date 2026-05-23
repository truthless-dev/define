import XCTest

@testable import Define

class MakeRequestUrlTests: XCTestCase {
  func testEmptyWordIsInvalid() {
    let api = DictionaryApi()
    let url = api.makeRequestUrl(defining: "")
    XCTAssertNil(url, "Empty input should be rejected.")
  }

  func testSingleWordInput() {
    let api = DictionaryApi()
    let url = api.makeRequestUrl(defining: "test")
    XCTAssertNotNil(url, "Input was not URL-encoded.")
  }

  func testMultiWordInput() {
    let api = DictionaryApi()
    let url = api.makeRequestUrl(defining: "test phrase")
    XCTAssertNotNil(url, "Input was not URL-encoded.")
  }

  func testWhitespaceOnlyWordIsInvalid() {
    let api = DictionaryApi()
    let url = api.makeRequestUrl(defining: "   ")
    XCTAssertNil(url, "Whitespace-only input should be rejected.")
  }

  func testTabOnlyWordIsInvalid() {
    let api = DictionaryApi()
    let url = api.makeRequestUrl(defining: "\t")
    XCTAssertNil(url, "Tab-only input should be rejected.")
  }

  func testNewlineOnlyWordIsInvalid() {
    let api = DictionaryApi()
    let url = api.makeRequestUrl(defining: "\n")
    XCTAssertNil(url, "Newline-only input should be rejected.")
  }

  func testUrlContainsRequestedWord() {
    let api = DictionaryApi()
    let word = "serendipity"
    let url = api.makeRequestUrl(defining: word)
    XCTAssertEqual(
      url?.lastPathComponent, word,
      "URL last path component should equal the requested word.")
  }

  func testUrlTrimsSurroundingWhitespace() {
    let api = DictionaryApi()
    let url = api.makeRequestUrl(defining: "  test  ")
    XCTAssertEqual(
      url?.lastPathComponent, "test",
      "URL should use the trimmed word, not the padded input.")
  }
}
