# Backlog — informed by competitive research (2026-08-16)

Research summary: the leading App Store cheat app sits at 1.3★, killed by dead
codes and oversold coverage; users pay specifically to remove ads; no
competitor ships revision warnings, safety flags, or device-type labeling —
the things this app already does. Full notes in the session that produced
this file; sources: Cheat Boy (App Store), PokeCodes, MasterDex, Retrododo,
Delta FAQ.

## High value, not yet built

1. **ROM hack coverage** (Radical Red, Unbound, Rocket Edition…). PokeCodes'
   entire traction is ROM-hack codes — that's what Delta players increasingly
   play. Schema already supports it (a hack is just a game entry whose
   revision names the hack version). Needs careful sourcing per hack.
2. **Copy-bundle flow**: on master-code-dependent cheats, a single guided
   flow: copy master → open Delta → return → copy cheat. Today it's two
   separate copy buttons (already good, could be one guided sequence).
3. **Request-a-code intake**: PokeCodes turns coverage gaps into engagement.
   For a personal app, a simple "note to self" list; for a public app, a
   GitHub issue template link.
4. **Per-game language variants** (EU/JP ROMs) — currently US-only, honest
   but thin for non-US players.

## Done (was in research recommendations)

- Per-system browse chips with visible counts (home screen)
- Category-by-intent grouping (Items / Encounters / Training / Movement)
- "Works on your ROM": revision-mismatched codes fade back + warning text
- Inline safety flags per code (side_effects in data, warning box in UI)
- Offline-first (data bundled), ad-free by nature, device-type labeling,
  master-code pairing via master_code_id
