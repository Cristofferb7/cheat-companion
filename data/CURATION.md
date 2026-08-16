# Curation notes — what's in, what's out, and why

## 2026-08-16, ROM hacks (Radical Red, Unbound)

Hacks get game-level `warnings` (rendered as "Know before you cheat") carrying
what their communities report breaks: Unbound's deliberate anti-cheat item
protections and broken FireRed PC-item codes; RR's level-cap interactions and
dead code families. Omitted on purpose:
- **RR**: One-Hit-KO (reported failing specifically on Delta), Complete
  Pokédex (source's own freeze warning), Mega catch codes (revert after
  capture), the in-game console codes Seviian/Mega/Puzzle (need New Game+).
  The safe in-game `Woyaopp` console cheat is mentioned in the Rare Candy
  description instead of being a code record (it isn't a device code).
- **Unbound**: 'Unlock All Badges' (permanently breaks gym battles), the new
  100% catch rate (resets the ROM after capture + sources conflict on an
  operand), Mega Stone codes (sources conflict on the write address), old
  2-line shiny (locks gender/stats), catch-trainer-Pokémon (reported dead on
  2.1.1.1 with conflicting behavior descriptions).
- Integrity rule change: the "GBA game with GameShark codes must ship a
  master code" check now exempts ROM hacks — RR verifiably needs none.

## 2026-08-16, second batch (LeafGreen, SoulSilver, Red/Blue)

- **LeafGreen**: v1.0 and v1.1 need entirely different master codes — both
  ship (CodeBreaker enabler + AR master for v1.0; combined master+Anti-DMA
  for v1.1) and every code references the right one. Omitted: the MadCatz
  "Gain 5000 Exp" (needs a MadCatz-specific master we don't carry) and a
  walk-through-walls variant whose line breaks couldn't be recovered
  unambiguously.
- **SoulSilver**: primary source is Cheat Happens' US list cross-checked
  against two other sites; note their page header shows HeartGold's game ID
  (site labeling error) — the codes themselves match IPGE sources. Ball-
  pocket code's 2nd/3rd blocks are single-source → `community_reported`.
- **Red/Blue**: one shared code set (no source distinguishes the versions).
  Omitted: the famous Mew encounter code (never seen verbatim on a fetchable
  page, and a conflicting variant circulates) and an "Infinite PP" code whose
  own source labels it contradictorily. Walk Through Walls has two one-digit
  variants in the wild — the two-page-verified one ships, flagged
  `community_reported` with the variant noted.

## 2026-08-16 additions (Yellow, Ruby, HeartGold)

- **Yellow**: money-code middle line has a circulating D0-vs-D3 typo; the
  D3 majority reading from older dedicated databases was used and the
  conflict is noted in the description. Infinite PP and Level-100 are
  single-source → `community_reported`.
- **Ruby**: two device generations mean two master-code sets that must not
  be mixed — both masters ship, and each dependent code references the right
  one. Omitted: the egg-based "Always Shiny" procedure (its own author warns
  it crashes the game), the no-space "Unlimited Masterball in bag" variant
  (formatting suspect, better PC variant exists), the "Unlimited EXP" code
  (a 2026 user reported it misbehaving specifically on Delta), and the v1.1/
  v1.2 SID masters (niche, unclear purpose).
- **HeartGold**: primary source is Cheat Happens' official US list
  (IPKE-AD102382), cross-confirmed line-for-line on a second site. Two US
  game-ID variants exist and are surfaced in the revision note. Omitted: an
  "x99 Rare Candies" code whose block-write header is structurally
  inconsistent, and Japanese (IPKJ) codes which use a different memory base
  and must never be used on US carts. EXP multipliers are single-source →
  `community_reported`.

Research date: 2026-08-15. Codes were gathered from fetched pages only (never
from memory), cross-checked across sources where possible. gamehacking.org was
Cloudflare-blocked for GBC/GBA/DS list pages during research except the two
FireRed pages; where blocked, established cheat sites and archived captures
were used and cross-compared.

## Omitted on purpose

- **Template codes with placeholder digits** (Crystal wild modifier
  `01xx04D2`, Crystal casino coins `01??56D8`, FireRed wild modifier
  `83007CEE YYYY`): not valid hex until filled in, and safe filling needs a
  species/value picker UI. Planned as a v2 feature, not shipped as raw data.
- **Emerald wild Pokémon modifier / teleport codes**: species table and warp
  lines were only found on one or two low-authority pages; encounter cheats
  also carry bad-egg reports. Out until better corroboration.
- **Platinum 995 Rare Candies**: single source, and its block-write zeroes the
  rest of the Medicine pocket. The 900x All Medicine code covers the same need
  without the destruction.

## Judgment calls in the data

- **`requires_master_code` on GBA GameShark v3 codes** is set to true even
  when a source didn't explicitly say so: enabling a master code is harmless,
  missing a needed one silently breaks codes. Where sources conflicted
  (Emerald walk-through-walls) the safe direction was chosen and noted in the
  description.
- **Emerald "Infinite Money"** circulates as a 5-line block that embeds the
  master code; stored here as the 3 money lines + master reference so Delta
  users don't double-enter the master code.
- **FireRed EXP/money master codes** are separate master records because the
  source pairs them with those specific cheats, not with the global (m) code.
- **Reliability**: `source_verified` = verbatim-identical on 2+ independent
  fetched pages (or an official CodeJunkies list / hand-tested-on-Delta page);
  `community_reported` = single source or mixed user reports.
- **Hex case**: normalized to uppercase; grouping and line breaks preserved
  exactly as published.
