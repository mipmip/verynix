#!/usr/bin/env bash
set -euo pipefail

# --- Pre-flight checks ---

if ! command -v gum &>/dev/null; then
  echo "error: gum not found. Install with: nix run nixpkgs#gum" >&2
  exit 1
fi

if ! command -v gh &>/dev/null; then
  echo "error: gh not found. Install with: nix run nixpkgs#gh" >&2
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "error: gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

# Dirty working directory check (works for both git and jj-colocated)
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "error: working tree is not clean. Commit or stash changes first." >&2
  exit 1
fi

# --- Read current version ---

current_version=$(grep -oP '^version:\s+\K[0-9]+\.[0-9]+\.[0-9]+' vx.cabal)
if [ -z "$current_version" ]; then
  echo "error: could not read version from vx.cabal" >&2
  exit 1
fi

# --- Check unreleased content ---

unreleased_content=$(sed -n '/^## \[Unreleased\]/,/^## \[/{/^## \[/!p}' CHANGELOG.md | grep -v '^$' || true)
if [ -z "$unreleased_content" ]; then
  echo "error: no content in [Unreleased] section of CHANGELOG.md" >&2
  exit 1
fi

# --- Bump type selection ---

echo "Current version: $current_version"
bump=$(gum choose "major" "minor" "patch")

# --- Compute new version ---

IFS='.' read -r major minor patch <<< "$current_version"

case "$bump" in
  major) new_version="$((major + 1)).0.0" ;;
  minor) new_version="${major}.$((minor + 1)).0" ;;
  patch) new_version="${major}.${minor}.$((patch + 1))" ;;
esac

# --- Check tag doesn't exist ---

if git rev-parse "v${new_version}" &>/dev/null; then
  echo "error: tag v${new_version} already exists." >&2
  exit 1
fi

# --- Confirm ---

if ! gum confirm "Release $current_version → $new_version?"; then
  echo "aborted." >&2
  exit 0
fi

# --- Update vx.cabal ---

sed -i "s/^version:       ${current_version}/version:       ${new_version}/" vx.cabal

# --- Update CHANGELOG.md ---

today=$(date +%Y-%m-%d)
sed -i "s/^## \[Unreleased\]/## [Unreleased]\n\n## [${new_version}] - ${today}/" CHANGELOG.md

# --- Extract release notes ---

release_notes=$(sed -n "/^## \[${new_version}\]/,/^## \[/{/^## \[/!p}" CHANGELOG.md)

# --- Git commit + tag ---

git add vx.cabal CHANGELOG.md
git commit -m "release v${new_version}"
git tag "v${new_version}"

# --- Push + GitHub release ---

git push origin HEAD:main
git push origin "v${new_version}"
gh release create "v${new_version}" --title "v${new_version}" --notes "$release_notes"

echo ""
echo "Released v${new_version}"
