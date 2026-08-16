# Data schema — `data/games/*.json`

One JSON file per (game, region) pair. Flat files in git so every data change is
reviewable. The app bundles these files; CheatKit validates every record at load
(and in tests), so a malformed code cannot ship.

## Game file

```jsonc
{
  "schema_version": 1,
  "game": {
    "slug": "pokemon-firered-us",        // stable id, kebab-case
    "title": "Pokémon FireRed",
    "system": "gba",                     // "gb" | "gbc" | "gba" | "nds"
    "region": "US",                      // "US" | "EU" | "JP"
    "revisions": ["v1.0", "v1.1"],       // known ROM revisions for this region
    "revision_note": "v1.0 and v1.1 use different memory addresses — codes are NOT interchangeable.",
    "is_rom_hack": false,                // optional, default false. True for fan hacks
    "based_on": null,                    // optional. Hacks: the official base game
    "warnings": []                       // optional. Game-level warnings shown in the UI,
                                         // e.g. cheat families known to BREAK this hack
  },
  "codes": [ /* Code records, see below */ ]
}
```

## Code record

```jsonc
{
  "id": "firered-rare-candy",           // unique within the file
  "name": "Rare Candy in PC",
  "description": "Withdraw unlimited Rare Candies from PC item storage.",
  "device": "gameshark_v3",             // see device enum
  "code": "82025840 0044",              // exact lines, \n-separated, as verified at source
  "region": "US",                       // REQUIRED on every code (brief: non-negotiable)
  "rom_revision": "v1.0",               // REQUIRED: "v1.0" | "v1.1" | game ID | "unspecified"
  "requires_master_code": true,
  "master_code_id": "firered-master",   // id of the master code record, if required
  "is_master_code": false,
  "activation": null,                   // e.g. "Hold L+R while entering a Poké Mart"
  "reliability": "source_verified",     // see reliability enum
  "side_effects": [                      // [] when none known — never null
    "Disable after use; leaving item cheats on can corrupt the bag."
  ],
  "source_url": "https://…",            // page the code was read from, verbatim
  "last_verified": "2026-08-15"
}
```

## Enums

`device` — determines the required code format (validated by CheatKit):

| device | systems | line format |
|---|---|---|
| `gameshark_gb` | gb, gbc | `XXXXXXXX` (8 hex) |
| `game_genie_gb` | gb, gbc | `XXX-YYY-ZZZ` (stored with dashes) |
| `gameshark_v3` | gba | `XXXXXXXX YYYYYYYY` |
| `action_replay` | gba | `XXXXXXXX YYYYYYYY` |
| `codebreaker` | gba | `XXXXXXXX YYYY` |
| `action_replay_ds` | nds | `XXXXXXXX YYYYYYYY` per line, multi-line |

`reliability`:

- `source_verified` — read verbatim from a source that states it works for the
  given region + revision
- `community_reported` — source exists but working status is anecdotal/mixed
- `unverified` — do not ship; placeholder during curation only

## Rules

1. `region` and `rom_revision` are required on every code. A code whose source
   didn't state the revision is `"unspecified"` — the UI must show that as a
   warning, not hide it.
2. Every code carries `source_url` + `last_verified`. No source, no entry.
3. `side_effects` is `[]` only when the source says nothing — we never invent
   safety claims in either direction.
4. Codes are stored exactly as verified (grouping, line breaks). The app's
   formatter normalizes for display/clipboard but never alters stored data.
5. A `requires_master_code: true` record must reference an existing
   `master_code_id` in the same file.
