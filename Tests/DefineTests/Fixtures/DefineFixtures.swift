import Define

func makeApi() -> DictionaryApi {
  DictionaryApi(usingSession: mockSession)
}
