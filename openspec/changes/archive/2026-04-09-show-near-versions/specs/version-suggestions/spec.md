## version-suggestions

### Requirements

1. `findNeighbors` MUST accept a target version (`Text`) and a list of available versions (`[Text]`)
2. `findNeighbors` MUST return `(Maybe Text, Maybe Text)` — (nearest lower, nearest upper)
3. `findNeighbors` MUST use semver ordering: compare by major, then minor, then patch
4. `parseVersion` MUST split a version string on `.` and parse segments as integers
5. `parseVersion` MUST handle non-numeric segments by treating them as greater than any numeric segment (so `1.0.0-rc1` sorts after `1.0.0`)
6. When the target is below all available versions, the lower neighbor MUST be `Nothing`
7. When the target is above all available versions, the upper neighbor MUST be `Nothing`
8. When the target matches an existing version exactly, neighbors MUST be the immediately adjacent versions (not the matching one)
9. `formatSuggestion` MUST format the error message with package name, requested version, and neighbors

### Test Strategy

- Unit test `findNeighbors` with various version lists and targets
- Test cases: target between versions, target below all, target above all, target matches exactly, single version available, empty list
- Unit test `parseVersion` with standard semver, non-standard versions, single-component versions
- Unit test `formatSuggestion` for both single and double neighbor output
