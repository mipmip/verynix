## api-client

### Requirements

1. `resolveVersion` MUST call `GET https://search.devbox.sh/v2/resolve?name=<pkg>&version=<ver>`
2. `resolveVersion` MUST return `Right NixhubResponse` with `rev` and `attrPath` on success
3. `resolveVersion` MUST return `Left` with an error message on HTTP failure or missing data
4. `resolveVersion` MUST use the current platform's system key to extract the correct entry from the response
5. `parseNixhubResponse` MUST be a pure function (`ByteString -> Text -> Either Text NixhubResponse`) where the `Text` parameter is the current system string
6. `parseNixhubResponse` MUST extract `rev` from `systems.<system>.flake_installable.ref.rev`
7. `parseNixhubResponse` MUST extract `attrPath` from `systems.<system>.flake_installable.attr_path`
8. `parseNixhubResponse` MUST return `Left` when the requested system is not present in the response

### Test Strategy

- Unit test `parseNixhubResponse` with canned JSON matching the real Nixhub response structure
- Test cases: valid response, missing system key, malformed JSON, missing fields
- No network calls in tests
