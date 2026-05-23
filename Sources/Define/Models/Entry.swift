/// A single dictionary entry returned by the API.
///
/// A successful API request will return a array of these. Decoders
/// should thus receive `[Entry].self` when decoding API responses.
struct Entry: Codable {
  let word: String
  let meanings: [Meaning]
  let phonetic: String?
  let phonetics: [Phonetic]

  struct Meaning: Codable {
    let partOfSpeech: String
    let definitions: [Definition]

    struct Definition: Codable {
      let definition: String
    }
  }

  struct Phonetic: Codable {
    let text: String?
  }
}
