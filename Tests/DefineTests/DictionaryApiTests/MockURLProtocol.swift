import Foundation
import Synchronization

class MockURLProtocol: URLProtocol {
  static let data = Mutex<Data?>(nil)
  static let response = Mutex<URLResponse?>(nil)
  static let error = Mutex<Error?>(nil)

  static func mock(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
    Self.data.withLock { value in value = data }
    Self.response.withLock { value in value = response }
    Self.error.withLock { value in value = error }
  }

  static func reset() {
    Self.mock()
  }

  override class func canInit(with request: URLRequest) -> Bool { true }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    if let error = Self.error.withLock { $0 } {
      client?.urlProtocol(self, didFailWithError: error)
      return
    }
    if let response = Self.response.withLock { $0 } {
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    }
    client?.urlProtocol(self, didLoad: Self.data.withLock { $0 } ?? Data())
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}
