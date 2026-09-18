---
name: api
description: >
  Look up exact World of Warcraft Forever client API signatures - arguments, types,
  nilable flags, return values, events, enums and structures - across all 408 systems,
  269 C_* namespaces, widget methods and every global, generated from the client's own
  Blizzard_APIDocumentation on build 1.60.1.69913. Use when a specific function,
  namespace, event, enum or structure is named and the question is its signature, its
  parameters, its return values, or whether it exists on this build at all. For whether
  you are permitted to call it, or why it returned nil or a secret, use the restrictions
  skill. For how to assemble an addon, use the build skill.
---

# Forever API lookup

The reference lives at `${CLAUDE_PLUGIN_ROOT}/reference/api/`. It is generated from the
client's own documentation, so it is what the client actually ships, not what a wiki says
it ships.

**One symbol, one file, path derivable from the name.** Do not read index files hunting for
something. Compute the path and read it.

## The lookup ladder

Work down it. Stop at the first step that answers.

**1. Namespace known → read the derived path.** Zero searches.

```
C_AuctionHouse.SendBrowseQuery
  → reference/api/namespaces/C_AuctionHouse/SendBrowseQuery.md
```

**2. Bare name → glob for it.**

```
Glob: reference/api/**/GetBuildInfo.md
```

Globals shard by first letter: `reference/api/globals/G/GetBuildInfo.md`.
Events too: `reference/api/events/A/AUCTION_HOUSE_SHOW.md`.
Enums and structures are flat: `reference/api/enums/WorldQuestQuality.md`,
`reference/api/structures/AuctionHouseBrowseQuery.md`.
Widget methods live under the type: `reference/api/widgets/<Type>/<Method>.md`.

**3. Name unknown ("what returns an item key?") → grep the tree.**

```
Grep: "itemKey" in reference/api/namespaces/
```

**4. Still nothing → check the aliases, then the namespace index.**

- `reference/api/ALIASES.md` — the Classic globals people reach for and what replaced
  them. `UnitAura` → `C_UnitAuras.GetAuraDataByIndex`, `QueryAuctionItems` →
  `C_AuctionHouse.SendBrowseQuery`. Forever removed the Classic-era globals wholesale, so
  this is the most common reason a lookup fails.
- `reference/api/namespaces/_index.md` — every namespace with its counts, for "which area
  even owns this".
- `reference/api/INDEX.md` — every symbol with its path. The fallback, not the first move:
  it is large, so grep it rather than reading it.

## What a missing file means

**Exactly one thing: the symbol is not on this client.**

That is an invariant worth trusting, and it cost 5,873 extra files to buy. Every symbol
present in the client's global table gets a page even when Blizzard documents nothing
about it — those pages say so explicitly and carry no invented signature. So you never
have to wonder whether a lookup failed or the function is absent.

If a page is missing, say the symbol does not exist on build 1.60.1.69913, and check
`ALIASES.md` for what replaced it.

## Reading a page

- A **`RESTRICTED — measured`** banner at the top is our own measurement, and it is the
  part no other reference has. It says what the client actually did, with a link to the
  evidence. Always surface it; never paraphrase it away.
- A **`RESTRICTED — Blizzard flag`** banner means the function carries `HasRestrictions` in
  Blizzard's own documentation: gated on a hardware event, or refuses to run from a script.
  274 functions have it.
- **`Present on this client, but not documented by Blizzard`** means exactly that. The
  function is callable; no signature exists to show. Do not invent one — say it is
  undocumented and, if it matters, suggest probing it.
- Types are Blizzard's own vocabulary: `bool`, `cstring`, `luaIndex`, `fileID`,
  `BigUInteger`, `UnitToken`, `ItemInfo`, plus mixins and enums. Nilable is stated per
  argument and per return.

## Is this reference current?

`reference/api/BUILD.md` names the client build it was generated from. Forever is in beta
and moved 69893 → 69913 in one day, so check it before trusting a signature on an
unfamiliar build. If the user's client has moved on, the `regenerate` skill rebuilds the
whole reference from their own client in about two minutes.

## Do not

- Do not answer API questions from memory of Retail. Forever is Retail's API set but not
  identical, and the differences are exactly what someone is asking about.
- Do not read a whole `_index.md` to find one function. That is the failure this layout
  exists to prevent.
- Do not treat "Blizzard documents it" as "you may call it". That is the restrictions
  skill's question, and on this client the answer is often no.
