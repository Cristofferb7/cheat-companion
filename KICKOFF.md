# Kickoff prompt — Cheat Companion

**Fill in the two bracketed fields before running this.** The prompt does nothing
useful without them.

---

```
Read CLAUDE.md and PROJECT-BRIEF.md before doing anything.

Do the feasibility spike from PROJECT-BRIEF.md, and nothing else.

I use [EMULATOR NAME] on [iOS / Android].

Read its documentation, and its source if it is open source, and determine
whether an external app can get cheat codes into it. Look specifically for:
  - a URL scheme
  - a share-sheet or intent handler
  - document / file import
  - a cheat file (.cht or similar) on shared storage that another app can write

Report which is true, with evidence:
  (a) direct injection is possible — document the exact mechanism and the exact
      file/code format it expects
  (b) clipboard + deep link only
  (c) neither — the tool becomes a fast offline reference with copy-to-clipboard

Then recommend a stack, with reasoning tied to the finding.

Do not scaffold an app. Do not write feature code. Do not pick a stack before
the spike is answered.
```

---

## Why this is the whole first session

On iOS, app sandboxing likely blocks writing into another app's cheat storage. On
Android, emulators commonly read cheat files from shared storage, which is
writable.

That difference decides whether you're building an app that injects codes or a
fast reference that formats and copies them. Both are worth building. They are not
the same product, and finding out after you've built the wrong one is expensive.

## After the spike

- Data schema with `region` and `rom_revision` as required fields
- 3–4 games fully populated by hand
- Search and copy/inject flow

Four games working end to end, then generalize.
