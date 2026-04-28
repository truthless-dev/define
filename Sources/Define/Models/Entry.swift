/// A single dictionary entry returned by the API.
///
/// A successful API request will return a array of these. Decoders
/// should thus receive `[Entry].self` when decoding API responses.
struct Entry: Codable {
  let word: String

  func describe() -> String {
    """
        \(word.capitalized)
    """
  }
}
