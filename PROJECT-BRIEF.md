# Project Brief: Emulator Cheat Code Companion

## The problem
Entering GameShark / Action Replay / Game Genie codes on a phone emulator is
miserable. You find a code on a forum, squint at a 16-character hex string, and
retype it into a tiny text field. Get one character wrong and the game crashes or
the save corrupts — with no error message telling you which.

The tool: search a game, browse codes, one tap to get the code into the emulator
in whatever format it accepts.

## Feasibility spike — DO THIS FIRST

**Nothing gets built until this question is answered.**

iOS sandboxing likely prevents writing into another app's cheat storage. Android
emulators (RetroArch, mGBA) read `.cht` files from shared storage, which is
writable. So the answer determines whether this is an app or a glorified clipboard.

Investigate the target emulator (docs, and source if open source) and report which
is true:

- **(a) Direct injection possible** — a URL scheme, share-sheet handler, document
  import, or writable cheat file on shared storage. Document the exact mechanism
  and format.
- **(b) Clipboard + deep link only** — format the code correctly, copy it, deep
  link into the emulator, user pastes.
- **(c) Neither** — the tool becomes a fast searchable reference with
  copy-to-clipboard, which is still a real improvement over forum-squinting.

Report the finding before writing feature code.

## Design requirements

### Region and revision are first-class
A US GameShark code silently fails or corrupts saves on a EU ROM. Same game, same
title, different memory layout. Most cheat sites bury this in a comment or omit it.

Model `region` and `rom_revision` as required fields on every code. Filter by them
in the UI. Warn on mismatch. This is the correctness feature that would make the
tool trustworthy.

### Offline-first
The code library ships with the app. Emulation happens on planes, trains, and
couches. Nothing should require a network round trip to browse or copy a code.

### Code health
Cheat codes break things — some crash on load, some corrupt saves, some only work
before a certain point in the game. Model a `reliability` field and any known
side effects. A code that corrupts a 40-hour save file is worse than no code.

## Scope boundaries
- **Codes only. No ROMs, no ROM links, no ROM discovery.** Emulators are legal;
  the tool stays entirely on the legal side of that line.
- Source the code library from something with clear reuse terms. Check licensing
  before ingesting any existing database. If terms are unclear, hand-seed a smaller
  library rather than scraping.
- No accounts. No telemetry on what games people play.

## Suggested v1 scope
Feasibility answer → data schema with region/revision → one platform (whichever the
spike says is viable) → 3–4 games fully populated → search and copy flow.

Ship something that works for four games before generalizing to four hundred.
