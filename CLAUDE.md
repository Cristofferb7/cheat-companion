# CLAUDE.md — Emulator Cheat Code Companion

## What this is
A mobile companion app for entering cheat codes into emulators without retyping
16-character hex strings on a phone keyboard.

Read `PROJECT-BRIEF.md` first. **The feasibility spike in that document blocks all
feature work** — do not scaffold an app before it's answered.

## Stack
Not decided until the spike resolves. The answer determines the platform:
- If Android has a writable cheat path and iOS doesn't, this is Android-first
- Cross-platform (React Native / Expo) only if both paths work

Do not pick a stack before the spike. Recommend one with reasoning once it's done.

## Non-negotiable constraints

### Scope
- **Codes only. Never ROMs** — no ROM links, no ROM discovery, no ROM metadata
  that implies where to get one. Emulation is legal; this stays on that side.
- No accounts, no telemetry on what games anyone plays
- Offline-first: browsing and copying a code never requires network

### Data correctness
Region and ROM revision are required fields on every code, not optional metadata.
A US code on a EU ROM fails silently or corrupts saves. Filter and warn on this.

Track `reliability` and known side effects per code. A code that corrupts a
40-hour save is worse than no code at all.

### Licensing
Check reuse terms before ingesting any existing cheat database. If terms are
unclear or restrictive, hand-seed a smaller library instead. Do not scrape.

## Working style
- Spike first, report findings, wait for direction
- Four games working end-to-end beats four hundred games half-modeled
- Show me the data schema before building UI on it
