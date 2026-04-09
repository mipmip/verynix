## version-listing

### Requirements

1. `fetchVersions` MUST call `GET https://search.devbox.sh/v2/pkg?name=<pkg>`
2. `fetchVersions` MUST return `Right [Text]` with a list of version strings on success
3. `fetchVersions` MUST return `Left` with an error message on HTTP failure
4. `parseVersionList` MUST be a pure function (`ByteString -> Either Text [Text]`) for testability
5. `parseVersionList` MUST extract version strings from `releases[].version`
6. On 404, `fetchVersions` MUST return `Left "package '<name>' not found"`

### Test Strategy

- Unit test `parseVersionList` with canned JSON matching the real `/v2/pkg` response structure
- Test cases: valid response with multiple versions, empty releases, malformed JSON, 404 response
