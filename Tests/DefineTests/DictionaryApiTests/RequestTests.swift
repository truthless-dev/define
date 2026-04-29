import XCTest

@testable import Define

let testEndpoint = URL(string: "https://www.test-endpoint.com/")!
let error = NSError(domain: "test", code: 1)

let mockSession: URLSession = {
  let configuration = URLSessionConfiguration.ephemeral
  configuration.protocolClasses = [MockURLProtocol.self]
  return URLSession(configuration: configuration)
}()

func responseOK(from url: URL = testEndpoint) -> HTTPURLResponse {
  HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func responseNotFound(from url: URL = testEndpoint) -> HTTPURLResponse {
  HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
}

func responseServerError(from url: URL = testEndpoint) -> HTTPURLResponse {
  HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
}

func makeApi() -> DictionaryApi {
  DictionaryApi(usingSession: mockSession)
}

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
