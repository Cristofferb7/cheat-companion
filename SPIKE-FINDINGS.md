# Feasibility Spike — Delta on iOS

Target: Delta (rileytestut/Delta), iOS. Investigated 2026-08-15 against the `main`
branch (app version `2.0b5`) and current public docs.

## Verdict: (b) — clipboard + deep link only. Direct injection is not possible.

The tool is a fast offline reference that formats, validates, and copies codes,
with an optional one-tap deep link that opens the right game in Delta. The user
performs the final paste inside Delta's own cheat editor.

## Evidence

### 1. No file-import path for cheats (rules out share sheet / document import)

`Delta/Supporting Files/Info.plist` on `main` declares document types for ROMs
(SNES, GBA, GBC, NES, N64, DS, Genesis), controller skins (`.deltaskin`), and
ZIP archives. There is **no cheat document type** and no imported/exported UTI
for cheats. Sharing a cheat file to Delta has nothing to land on.

### 2. The `delta://` URL scheme has exactly one action (rules out URL-based injection)

`Delta/Deep Linking/DeepLink.swift` defines a single `ActionType`:
`game` — i.e. `delta://game/<identifier>` launches a game. There is no cheat
action, no parameters beyond the game identifier.

Usable half of this: `CopyDeepLinkActivity.swift` lets the user copy a game's
deep link from Delta's share sheet. If our app stores that link per game, one
tap can open Delta directly into the game after copying a code. The identifier
is Delta-internal, so the user must supply the link once per game — an
acceptable one-time setup step.

### 3. Cheat storage is a sandboxed Core Data store (rules out file writing)

- Cheats are Core Data entities (`Database/Model/Human/Cheat.swift`,
  `_Cheat.swift`) in Delta's SQLite persistent store — there are no flat `.cht`
  files like RetroArch/mGBA on Android.
- `LSSupportsOpeningDocumentsInPlace` is `false`, so Delta's container is not
  reachable from other iOS apps at all (`UIFileSharingEnabled` only exposes
  Documents to a desktop over USB/Finder).
- Even with hypothetical access, the store is synced by Harmony
  (Dropbox / Google Drive). External writes to a live Core Data store would risk
  corruption and sync conflicts. This path is closed and should stay closed.

### 4. Market risk: Delta 2.0 ships a built-in cheat database ("CheatBase")

`Delta/Database/Cheats/CheatBase.swift` (on `main`, in the 2.0 beta) bundles a
searchable SQLite cheat database matched to the user's ROM (`romID`), with
name, description, code, device, activation, and category per cheat. The
shipping App Store version still documents manual entry only, but when 2.0
ships, "find a code without leaving Delta" is largely solved for Delta users.

What CheatBase does not appear to solve — where a companion still adds value:
- **Region / ROM-revision correctness** (our core design requirement; CheatBase
  matches by romID which helps, but coverage and mismatch warnings are unknown)
- **Reliability / side-effect metadata** (save-corruption warnings)
- **Format validation before entry** (Delta rejects or silently misbehaves on
  malformed codes)
- **Codes that aren't in its database**, and every non-Delta emulator

## Delta's exact cheat formats (what the formatter must produce)

From the DeltaCore wiki — codes must be alphanumeric hex in exactly this shape:

| System | Device | Format |
|---|---|---|
| GB / GBC | GameShark | `XXXXXXXX` |
| GB / GBC | Game Genie | `XXX YYY ZZZ` |
| GBA | GameShark / Action Replay | `XXXXXXXX YYYYYYYY` |
| GBA | Code Breaker | `XXXXXXXX YYYY` |
| NES | Game Genie | `XXXXXX` or `XXXXXXXX` |
| SNES | GameShark / Pro Action Replay | `XXXXXXXX` |
| SNES | Game Genie | `XXXX YYYY` |
| N64 | GameShark / Pro Action Replay | `XXXXXXXX YYYY` |

Notes: some codes are version-specific (confirms `rom_revision` as a required
field); Master Codes usually auto-apply but sometimes must be added manually —
worth modeling as a `requires_master_code` relation.

## Stack recommendation: native iOS (SwiftUI) + bundled SQLite

Reasoning tied to the finding:

- The user's emulator is iOS-only, and the verdict removes any injection
  mechanism that could have argued for Android-first. Single platform → no
  cross-platform framework earns its complexity. React Native/Expo is ruled out
  by its own justification in CLAUDE.md ("only if both paths work" — they don't).
- Everything the product does is native-API-shaped: clipboard (`UIPasteboard`),
  deep links (`UIApplication.open`), offline bundled data, share-sheet intake of
  the user's `delta://` game links.
- Data: bundled SQLite (GRDB) read-only library, generated at build time from
  reviewable flat files (JSON/YAML in git, per the brief's data-correctness
  goal). Offline-first is satisfied by construction.

## Proposed v1 flow (pending direction — no code written)

1. Search game → pick region/revision → browse codes with reliability badges
2. Tap code → validated against the format table above → copied to clipboard
3. If the user has pasted that game's `delta://` link once → auto-open Delta
   into the game; otherwise show "open Delta" + a 10-second how-to
4. User: pause menu → Cheat Codes → `+` → paste name & code

## Open question before feature work

Given CheatBase lands in Delta 2.0, is v1 still the 3–4-game hand-seeded library
(differentiating on region-correctness and reliability metadata), or should the
scope tilt toward being the best *formatter/validator + deep-link launcher*
with a smaller reference library? Both fit finding (b); they prioritize the
data work differently.
