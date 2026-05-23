import Foundation

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
