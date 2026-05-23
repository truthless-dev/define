import XCTest

@testable import Define

class DefineErrorTests: XCTestCase {
  func testNetworkErrorWithCodeDescription() {
    let error = DefineError.network(code: 503)
    XCTAssertTrue(
      error.errorDescription!.contains("503"),
      "errorDescription should include the HTTP status code.")
  }

  func testNetworkErrorWithoutCodeDescription() {
    let error = DefineError.network(code: nil)
    XCTAssertTrue(
      error.errorDescription!.contains("occurred."),
      "errorDescription for a codeless network error should omit the code suffix.")
  }
}
