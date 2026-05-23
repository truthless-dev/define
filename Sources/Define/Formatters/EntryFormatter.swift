/// Produce user-readable views of Entry instances.
struct EntryFormatter {
  let includingPhonetics: Bool

  init(includingPhonetics: Bool = false) {
    self.includingPhonetics = includingPhonetics
  }

  func describe(_ entry: Entry) -> String {
    let term = entry.word.capitalized
    let header =
      if includingPhonetics {
        "\(term) [\(describePhonetics(of: entry))]"
      } else {
        term
      }
    let meaningSections =
      entry.meanings
      .map { describeMeaning($0) }
      .joined(separator: "\n")
    return """
      \(header)
      \(meaningSections)

      """
  }

  private func describePhonetics(of entry: Entry) -> String {
    let phoneticsList = Set([entry.phonetic ?? ""] + entry.phonetics.compactMap { $0.text })
    return phoneticsList.filter { !$0.isEmpty }.sorted().joined(separator: ", ")
  }

  private func describeMeaning(_ meaning: Entry.Meaning) -> String {
    let definitionSection =
      meaning.definitions
      .enumerated()
      .map { (i, definition) in "\(i + 1). \(definition.definition)" }
      .joined(separator: "\n")
    return """
      (\(meaning.partOfSpeech))
      \(definitionSection)
      """
  }
}
