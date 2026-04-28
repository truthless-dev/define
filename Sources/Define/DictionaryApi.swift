import Foundation

/// Interface to the Free Dictionary API
public struct DictionaryApi {
  private static let v2BaseUrl = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/")!

  private let session: URLSession
  private let decoder: JSONDecoder

  /// Create an instance of DictionaryApi.
  ///
  /// - Parameters:
  ///   - session: The `URLSession` this instance will use to make API
  ///     requests.
  ///   - decoder: The `JSONDecoder` this instance will use to decode
  ///     API responses.
  public init(
    usingSession session: URLSession = URLSession.shared,
    usingDecoder decoder: JSONDecoder = JSONDecoder()
  ) {
    self.session = session
    self.decoder = decoder
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

  /// Make a GET request to a generic URL.
  ///
  /// - Parameters:
  ///   - url: The URL to which to send the request.
  ///
  /// - Returns: The raw `Data` and the `HTTPURLResponse` that were
  /// received in response if the request was successful; nil otherwise.
  func request(url: URL) async -> (Data, HTTPURLResponse)? {
    guard let (data, response) = try? await session.data(from: url) else {
      return nil
    }
    return (data, response as! HTTPURLResponse)
  }
}
