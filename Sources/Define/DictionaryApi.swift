import Foundation

/// Interface to the Free Dictionary API
public struct DictionaryApi {
  private static let v2BaseUrl = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/")!

  public init() {
  }

  /// Generate the endpoint for a given word.
  ///
  /// - Parameters:
  ///   - word: The term to look up in the dictionary.
  ///
  /// - Returns: Nil if the word is only whitespace or otherwise can't be
  /// URL-encoded; the endpoint as a `URL` otherwise.
  func makeRequestUrl(defining word: String) -> URL? {
    let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedWord.isEmpty else {
      return nil
    }
    return Self.v2BaseUrl.appendingPathComponent(trimmedWord)
  }
}
