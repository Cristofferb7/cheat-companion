# Cheat Companion

iOS companion app for [Delta](https://github.com/rileytestut/Delta): browse
curated, source-verified cheat codes for your games, copy them in the exact
format Delta expects, and jump straight into the game to paste them.

Why it exists, and why it works this way: see `PROJECT-BRIEF.md` and
`SPIKE-FINDINGS.md` (short version: iOS sandboxing makes direct injection into
Delta impossible, so the flow is validate → copy → deep-link → paste).

## Layout

- `data/games/*.json` — the curated code library. Flat files, reviewed in git.
  Schema and rules: `data/SCHEMA.md`. Curation decisions: `data/CURATION.md`.
- `Sources/CheatKit` — Swift package: models, per-device format
  validator/formatter, data integrity checks.
- `Sources/checks` — check runner that works without Xcode: `swift run checks`
- `Tests/CheatKitTests` — XCTest mirror of the checks (needs Xcode)
- `App/` — SwiftUI app sources + xcodegen spec

## Building the app

Requires full Xcode (not just Command Line Tools) and xcodegen:

```
brew install xcodegen
xcodegen generate --spec App/project.yml
open CheatCompanion.xcodeproj
```

Data changes need no Xcode: edit the JSON, run `swift run checks`, commit.

## Data rules (the short version)

Every code: exact source URL, region, ROM revision, reliability level, and
known side effects. Codes are stored in Delta's canonical format and validated
on every check run — a malformed or unsourced code fails the build. When in
doubt, a code stays out; a code that corrupts a 40-hour save is worse than no
code.
