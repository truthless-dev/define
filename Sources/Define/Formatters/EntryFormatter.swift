/// Produce user-readable views of Entry instances.
struct EntryFormatter {
  let includingPhonetics: Bool

  /// Create an `EntryFormatter`.
  ///
  /// - Parameters:
  ///   - includingPhonetics: Whether to include phonetic pronunciations in formatted output.
  init(includingPhonetics: Bool = false) {
    self.includingPhonetics = includingPhonetics
  }

  /// Format a single entry as a human-readable string.
  ///
  /// - Parameters:
  ///   - entry: The entry to format.
  ///
  /// - Returns: A formatted, multi-line string representation of the entry.
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

  /// Collect, deduplicate, and sort all phonetic notations for an entry into a comma-separated string.
  private func describePhonetics(of entry: Entry) -> String {
    let phoneticsList = Set([entry.phonetic ?? ""] + entry.phonetics.compactMap { $0.text })
    return phoneticsList.filter { !$0.isEmpty }.sorted().joined(separator: ", ")
  }

  /// Format a single meaning as a numbered list of definitions preceded by its part of speech.
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
