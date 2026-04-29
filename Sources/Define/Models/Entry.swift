/// A single dictionary entry returned by the API.
///
/// A successful API request will return a array of these. Decoders
/// should thus receive `[Entry].self` when decoding API responses.
struct Entry: Codable {
  let word: String
  let meanings: [Meaning]

  struct Meaning: Codable {
    let partOfSpeech: String
    let definitions: [Definition]

    struct Definition: Codable, CustomStringConvertible {
      let definition: String

      var description: String { definition }
    }

    /// Generate a user-friendly string describing the Meaning.
    func describe() -> String {
      let definitionSection =
        definitions
        .enumerated()
        .map { (i, definition) in
          "\(i + 1). \(definition)"
        }
        .joined(separator: "\n")
      return """
        (\(partOfSpeech))
        \(definitionSection)
        """
    }
  }

  /// Generate a user-friendly description of the Entry.
  func describe() -> String {
    let meaningSections =
      meanings
      .map { $0.describe() }
      .joined(separator: "\n")
    return """
      \(word.capitalized)
      \(meaningSections)

      """
  }
}
