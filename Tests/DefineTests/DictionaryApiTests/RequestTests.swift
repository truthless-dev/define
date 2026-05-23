import XCTest

@testable import Define

class RequestTests: XCTestCase {
  var api: DictionaryApi?

  override func setUp() {
    api = makeApi()
  }

  override func tearDown() {
    api = nil
  }

  func testSuccessfulResponse() async throws {
    let response = responseOK()
    MockURLProtocol.mock(data: Data(), response: response)
    let expect = expectation(description: "Waiting for completion.")

    let result = await api!.request(url: testEndpoint)
    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)

    let (_, actualResponse) = try XCTUnwrap(result)
    XCTAssertEqual(actualResponse.statusCode, 200, "Status code was \(actualResponse.statusCode).")
  }

  func testFailingResponse() async {
    let response = responseOK()
    MockURLProtocol.mock(data: Data(), response: response, error: error)
    let expect = expectation(description: "Waiting for completion.")

    let result = await api!.request(url: testEndpoint)
    expect.fulfill()
    await fulfillment(of: [expect], timeout: 1.0)

    XCTAssertNil(result, "Got a value despite the error: \(result!).")
  }
}
