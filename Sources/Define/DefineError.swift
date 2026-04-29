import Foundation

public enum DefineError: LocalizedError {
  case invalidInput(String)
  case invalidJSON(String)
  case network(code: Int?)

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
