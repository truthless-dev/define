/// The API response given when a word is not in the dictionary.
struct NotFound: Codable, CustomStringConvertible {
  let message: String

  var description: String { message }
}
