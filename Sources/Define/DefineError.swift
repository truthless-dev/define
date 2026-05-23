import Foundation

/// Errors that can occur while looking up a word definition.
public enum DefineError: LocalizedError {
  /// The word or phrase was empty or could not be URL-encoded.
  case invalidInput(String)
  /// The API response body could not be decoded as expected JSON.
  case invalidJSON(String)
  /// A network request failed, optionally with an HTTP status code.
  case network(code: Int?)

  /// A human-readable description of the error.
  public var errorDescription: String? {
    switch self {
    case .invalidInput(let message):
      message
    case .invalidJSON(let message):
      message
    case .network(let code):
      if let code = code {
        "A network error occured. (code \(code))"
      } else {
        "A network error occured."
      }
    }
  }
}
