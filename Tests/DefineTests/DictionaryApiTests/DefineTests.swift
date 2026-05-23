import XCTest

@testable import Define

class DefineTests: XCTestCase {
  private var api: DictionaryApi?

  override func setUp() {
    api = makeApi()
  }

  override func tearDown() {
    api = nil
  }

  func testEmptyInputThrowsError() async {
    let expect = expectation(description: "Waiting for completion.")

    do {
      let _ = try await api!.define(word: " ")
      XCTFail("Empty input did not throw an error.")
    } catch {
      switch error {
      case .invalidInput(let message):
        let expected = message.hasPrefix("Invalid word")
        XCTAssertTrue(expected, "Unexpected error message '\(message)'.")
      default:
        XCTFail("Unexpected error type \(type(of: error)): \(error).")
      }
    }

    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)
  }

  func testNetworkErrorsAreThrownAsDefineError() async {
    MockURLProtocol.mock(error: error)
    let expect = expectation(description: "Waiting for completion.")

    do {
      let _ = try await api!.define(word: "test")
      XCTFail("Network error did not throw an error.")
    } catch {
      switch error {
      case .network(let code):
        XCTAssertNil(code, "Shouldn't have a code for non-response. Got \(code!).")
      default:
        XCTFail("Unexpected error type \(type(of: error)): \(error).")
      }
    }

    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)
  }

  func testThrowsWhenValidResponseStatusIsNot200Or404() async throws {
    let dataServerError = "Server is down.".data(using: .utf8)!
    let response = responseServerError()
    MockURLProtocol.mock(data: dataServerError, response: response)
    let expect = expectation(description: "Waiting for completion.")

    do {
      let _ = try await api!.define(word: "test")
      XCTFail("Unmanaged server response did not throw an error.")
    } catch {
      switch error {
      case .network(let code):
        let code = try XCTUnwrap(code, ".network should contain error code from valid response.")
        let expected = response.statusCode
        XCTAssertEqual(code, expected, "Expected status code \(expected). Got \(code).")
      default:
        XCTFail("Unexpected error type \(type(of: error)): \(error).")
      }
    }

    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)
  }

  func testNonexistentWordReturnsSorryMessage() async {
    let response = responseNotFound()
    MockURLProtocol.mock(data: notFoundData, response: response)
    let expect = expectation(description: "Waiting for completion.")

    do {
      let result = try await api!.define(word: "test")
      let expected = result.contains("Sorry")
      XCTAssertTrue(expected, "Invalid 404 response: \(result).")
    } catch {
      XCTFail("Unexpected error type \(type(of: error)): \(error).")
    }

    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)
  }

  func testValidWord() async {
    let response = responseOK()
    MockURLProtocol.mock(data: entriesData, response: response)
    let expect = expectation(description: "Waiting for completion.")

    do {
      let result = try await api!.define(word: "test")
      let hasWord = result.contains("Unctuous")
      let hasMultipleDefinitions = result.contains("2.")
      XCTAssertTrue(
        hasWord && hasMultipleDefinitions, "Unexpected result of valid word lookup: '\(result)'")
    } catch {
      XCTFail("Unexpected error type \(type(of: error)): \(error).")
    }

    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)
  }

  func testNoPhoneticsAreShownByDefault() async {
    let response = responseOK()
    MockURLProtocol.mock(data: entriesData, response: response)
    let expect = expectation(description: "Waiting for completion.")

    do {
      let result = try await api!.define(word: "test")
      let hasPhonetics = result.contains("/ˈʌnktʃuəs/")
      XCTAssertFalse(hasPhonetics, "Default display should not show phonetics.")
    } catch {
      XCTFail("Unexpected error type \(type(of: error)): \(error).")
    }

    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)
  }

  func testIncludingPhonetics() async {
    let response = responseOK()
    MockURLProtocol.mock(data: entriesData, response: response)
    let expect = expectation(description: "Waiting for completion.")

    do {
      let result = try await api!.define(word: "test", includingPhonetics: true)
      let hasPhonetics = result.contains("/ˈʌnktʃuəs/")
      XCTAssertTrue(hasPhonetics, "Missing requested phonetics in output '\(result)'.")
    } catch {
      XCTFail("Unexpected error type \(type(of: error)): \(error).")
    }

    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)
  }

  func testValidResponseWithMalformedEntriesJSONThrowsInvalidJSONError() async {
    let badJSON = "not json".data(using: .utf8)!
    let response = responseOK()
    MockURLProtocol.mock(data: badJSON, response: response)
    let expect = expectation(description: "Waiting for completion.")

    do {
      let _ = try await api!.define(word: "test")
      XCTFail("Malformed entries JSON should throw an error.")
    } catch {
      switch error {
      case .invalidJSON:
        break
      default:
        XCTFail("Expected .invalidJSON, got \(error).")
      }
    }

    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)
  }

  func testNotFoundResponseWithMalformedJSONThrowsInvalidJSONError() async {
    let badJSON = "not json".data(using: .utf8)!
    let response = responseNotFound()
    MockURLProtocol.mock(data: badJSON, response: response)
    let expect = expectation(description: "Waiting for completion.")

    do {
      let _ = try await api!.define(word: "test")
      XCTFail("Malformed not-found JSON should throw an error.")
    } catch {
      switch error {
      case .invalidJSON:
        break
      default:
        XCTFail("Expected .invalidJSON, got \(error).")
      }
    }

    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)
  }

  func testMultipleEntriesAllIncluded() async {
    let twoEntriesData = """
      [
        {
          "word": "alpha",
          "phonetics": [],
          "meanings": [
            {
              "partOfSpeech": "noun",
              "definitions": [{"definition": "First letter of the Greek alphabet."}]
            }
          ]
        },
        {
          "word": "beta",
          "phonetics": [],
          "meanings": [
            {
              "partOfSpeech": "noun",
              "definitions": [{"definition": "Second letter of the Greek alphabet."}]
            }
          ]
        }
      ]
      """.data(using: .utf8)!
    let response = responseOK()
    MockURLProtocol.mock(data: twoEntriesData, response: response)
    let expect = expectation(description: "Waiting for completion.")

    do {
      let result = try await api!.define(word: "test")
      let hasFirst = result.contains("Alpha")
      let hasSecond = result.contains("Beta")
      XCTAssertTrue(
        hasFirst && hasSecond,
        "Output should include all entries in the response: '\(result)'.")
    } catch {
      XCTFail("Unexpected error type \(type(of: error)): \(error).")
    }

    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)
  }
}
