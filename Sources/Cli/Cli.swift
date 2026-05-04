import ArgumentParser
import Define

@main
struct Define: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: packageName.lowercased(),
    abstract: "Look up a word or phrase in a dictionary",
    discussion: """
      This tool makes requests to the Free Dictionary API at \
      www.dictionaryapi.dev. Thank you to the maintainer of that \
      resource. Please take care not to overwhelm the server with \
      requests.
      """,
    version: packageVersion
  )

  @Argument(help: "The word or phrase to define.")
  var word: String

  @Flag(name: [.short, .long], help: "Whether to include phonetic pronunciations in the output.")
  var phonetics = false

  mutating func run() async throws {
    let api = DictionaryApi()
    let definition = try await api.define(word: word, includingPhonetics: phonetics)
    print(definition)
  }
}
