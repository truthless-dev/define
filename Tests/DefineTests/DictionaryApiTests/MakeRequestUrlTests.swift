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
}
