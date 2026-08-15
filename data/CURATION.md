# Curation notes — what's in, what's out, and why

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
