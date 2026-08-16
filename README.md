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

## Adding a game

1. Create `data/games/<slug>.json` following `data/SCHEMA.md` (copy an
   existing file of the same system as a starting point). Every code needs a
   real `source_url` — codes from memory are how saves get corrupted.
2. Run `swift run checks` — fix anything it flags. It validates hex format,
   master-code references, regions, and sources.
3. Optional cover: add a design block in `App/Resources/render-covers.swift`
   and render it, or drop any portrait image at
   `App/Resources/Assets.xcassets/cover-<slug>.imageset/cover.png`.
   No cover = automatic colored monogram card.
4. Optional accent: add the slug to `Theme.gameColor(for:)`. Without it the
   game inherits its console's color.
5. Rebuild. The game list, search, and favorites pick the new game up
   automatically — there is no game registry to edit.

## Data rules (the short version)

Every code: exact source URL, region, ROM revision, reliability level, and
known side effects. Codes are stored in Delta's canonical format and validated
on every check run — a malformed or unsourced code fails the build. When in
doubt, a code stays out; a code that corrupts a 40-hour save is worse than no
code.
