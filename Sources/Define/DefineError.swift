import Foundation

public enum DefineError: LocalizedError {
  case invalidJSON(String)

  public var errorDescription: String? {
    switch self {
    case .invalidJSON(let message):
      message
    }
  }
}
