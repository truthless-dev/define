import XCTest

@testable import Define

class DecodeTests: XCTestCase {
  func testSuccessfulApiResponse() {
    let api = DictionaryApi()
    do {
      let entries = try api.decode(entries: entriesData)
      XCTAssertGreaterThan(entries.count, 0, "Decoded entry list is empty.")
    } catch {
      XCTFail("Decoding threw error type \(type(of: error)): \(error).")
    }
  }

  func testBadlyFormedEntriesThrowsJSONError() {
    let api = DictionaryApi()
    // The missing ']' here is intentional.
    let malformedJSON = """
      [
      {
          "word": "test"
      }
      """.data(using: .utf8)!
    do {
      let _ = try api.decode(entries: malformedJSON)
    } catch {
      let expectedMessage = error.localizedDescription.contains("format")
      XCTAssertTrue(expectedMessage, "Unexpected error message: \(error.localizedDescription)")
    }
  }

  func testEntriesWithoutWordsThrowsJSONError() {
    let api = DictionaryApi()
    // The missing ']' here is intentional.
    let entriesMissingWords = """
      [
      {
          "phonetic": "test"
      }
      ]
      """.data(using: .utf8)!
    do {
      let _ = try api.decode(entries: entriesMissingWords)
    } catch {
      let expectedMessage = error.localizedDescription.contains("missing")
      XCTAssertTrue(expectedMessage, "Unexpected error message: \(error.localizedDescription)")
    }
  }
  func testNotFoundApiResponse() {
    let api = DictionaryApi()
    do {
      let notFound = try api.decode(notFound: notFoundData)
      XCTAssertTrue(notFound.message.contains("Sorry"))
    } catch {
      XCTFail("Decoding threw error type \(type(of: error)): \(error).")
    }
  }

  func testDecodeEntriesThrowsDefineInvalidJSONError() {
    let api = DictionaryApi()
    let notJSON = "not json at all".data(using: .utf8)!
    do {
      let _ = try api.decode(entries: notJSON)
      XCTFail("Non-JSON data should throw an error.")
    } catch {
      switch error {
      case .invalidJSON:
        break
      default:
        XCTFail("Expected .invalidJSON, got \(error).")
      }
    }
  }

  func testBadlyFormedNotFoundThrowsDefineInvalidJSONError() {
    let api = DictionaryApi()
    let malformedJSON = "{ unclosed".data(using: .utf8)!
    do {
      let _ = try api.decode(notFound: malformedJSON)
      XCTFail("Malformed JSON should throw an error.")
    } catch {
      switch error {
      case .invalidJSON:
        break
      default:
        XCTFail("Expected .invalidJSON, got \(error).")
      }
    }
  }
}
