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

  func decode(entries data: Data) throws(DefineError) -> [Entry] {
    do {
      return try decoder.decode([Entry].self, from: data)
    } catch {
      throw .invalidJSON("\(error.localizedDescription)")
    }
  }

  func decode(notFound data: Data) throws(DefineError) -> NotFound {
    do {
      return try decoder.decode(NotFound.self, from: data)
    } catch {
      throw .invalidJSON("\(error.localizedDescription)")
    }
  }

  /// Look up the definition of a word or phrase.
  ///
  /// Main entrypoint that clients use to interact with the API. This
  /// makes an HTTP GET request to the API and provides the result in a
  /// human-readable format.
  ///
  /// - Parameters:
  ///   - word: The word (or phrase) to look up.
  ///
  /// - Returns: A textual, user-friendly representation of the lookup's
  ///   result.
  ///
  /// - Throws: `DefineError` if the input is invalid, the JSON of the
  ///   response body cannot be parsed, or there was a network issue.
  public func define(word: String, includingPhonetics phonetics: Bool = false)
    async throws(DefineError) -> String
  {
    guard let url = makeRequestUrl(defining: word) else {
      throw .invalidInput("Invalid word or phrase '\(word)'.")
    }
    guard let (data, response) = await request(url: url) else {
      throw .network(code: nil)
    }
    switch response.statusCode {
    case 200:
      let entries = try decode(entries: data)
      return
        entries
        .map { $0.describe(includingPhonetics: phonetics) }
        .joined(separator: "\n")
    case 404:
      let notFound = try decode(notFound: data)
      return String(describing: notFound)
    default:
      throw .network(code: response.statusCode)
    }
  }
}
