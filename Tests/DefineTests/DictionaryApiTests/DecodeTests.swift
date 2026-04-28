import XCTest

@testable import Define

let entriesData = """
  [
      {
          "word": "unctuous",
          "phonetic": "/ˈʌnktʃuəs/",
          "phonetics": [
              {
                  "text": "/ˈʌnktʃuəs/",
                  "audio": "https://api.dictionaryapi.dev/media/pronunciations/en/unctuous-uk.mp3",
                  "sourceUrl": "https://commons.wikimedia.org/w/index.php?curid=88943188",
                  "license": {
                      "name": "BY-SA 4.0",
                      "url": "https://creativecommons.org/licenses/by-sa/4.0"
                  }
              }
          ],
          "meanings": [
              {
                  "partOfSpeech": "adjective",
                  "definitions": [
                      {
                          "definition": "(of a liquid or substance) Oily or greasy.",
                          "synonyms": [],
                          "antonyms": []
                      },
                      {
                          "definition": "(of a wine, coffee, sauce, gravy etc.) Rich, lush, intense, with layers of concentrated, soft, velvety flavor.",
                          "synonyms": [],
                          "antonyms": []
                      },
                      {
                          "definition": "(by extension, of a person) Profusely polite, especially unpleasantly so and insincerely earnest.",
                          "synonyms": [],
                          "antonyms": []
                      }
                  ],
                  "synonyms": [
                      "oleaginous",
                      "saponaceous",
                      "slimy",
                      "savorous",
                      "creepy",
                      "effusive",
                      "groveling",
                      "oleaginous",
                      "slimy",
                      "sycophantic"
                  ],
                  "antonyms": []
              }
          ],
          "license": {
              "name": "CC BY-SA 3.0",
              "url": "https://creativecommons.org/licenses/by-sa/3.0"
          },
          "sourceUrls": [
              "https://en.wiktionary.org/wiki/unctuous"
          ]
      }
  ]
  """.data(using: .utf8)!

let notFoundData = """
  {
      "title": "No Definitions Found",
      "message": "Sorry pal, we couldn't find definitions for the word you were looking for.",
      "resolution": "You can try the search again at later time or head to the web instead."
  }
  """.data(using: .utf8)!

class DecodeTests: XCTestCase {
  func testSuccessfulApiResponse() {
    let api = DictionaryApi()
    do {
      let entries = try api.decode(entries: entriesData)
      XCTAssertGreaterThan(entries.count, 0, "Decoded entry list is empty.")
    } catch {
      XCTFail("Decoding threw error type \(type(of: error)): \(error).")
    }
  }

  func testBadlyFormedEntriesThrowsJSONError() {
    let api = DictionaryApi()
    // The missing ']' here is intentional.
    let malformedJSON = """
      [
      {
          "word": "test"
      }
      """.data(using: .utf8)!
    do {
      let _ = try api.decode(entries: malformedJSON)
    } catch {
      let expectedMessage = error.localizedDescription.contains("format")
      XCTAssertTrue(expectedMessage, "Unexpected error message: \(error.localizedDescription)")
    }
  }

  func testEntriesWithoutWordsThrowsJSONError() {
    let api = DictionaryApi()
    // The missing ']' here is intentional.
    let entriesMissingWords = """
      [
      {
          "phonetic": "test"
      }
      ]
      """.data(using: .utf8)!
    do {
      let _ = try api.decode(entries: entriesMissingWords)
    } catch {
      let expectedMessage = error.localizedDescription.contains("missing")
      XCTAssertTrue(expectedMessage, "Unexpected error message: \(error.localizedDescription)")
    }
  }
  func testNotFoundApiResponse() {
    let api = DictionaryApi()
    do {
      let notFound = try api.decode(notFound: notFoundData)
      XCTAssertTrue(notFound.message.contains("Sorry"))
    } catch {
      XCTFail("Decoding threw error type \(type(of: error)): \(error).")
    }
  }
}
