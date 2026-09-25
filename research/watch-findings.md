# Watch findings — inbox

Unverified leads about Forever's addon API, restrictions, tooling and developer workflow,
collected by the daily `wow-forever-addon-watch` scheduled task. **Nothing here is evidence
yet.** This is a queue of things to investigate; `research/findings.md` is the evidence base.

Promotion path: investigate an item → if it can be measured, measure it with ForeverProbe
and write it up in `research/findings.md` §P → if it is a primary source worth keeping,
add it as a numbered section there → then strike it here with a pointer. Delete items that
turn out to be wrong or irrelevant.

Each entry carries the confidence labels from `research/findings.md`: **[PRIMARY]**
fetched and read directly · **[REPORTED]** credible secondary source, fetched ·
**[UNVERIFIED]** surfaced in search, not independently confirmed.

Scope: how to build Forever addons. API surface and signatures, restrictions and their
scope, SavedVariables and the out-of-game channel, tooling and porting, client builds, and
the gotchas that cost other developers time. Not: what any particular addon should do.

---

## Open — to investigate

### W.3a Read `WOW4E_AH_Trader` as porting prior art

**[PRIMARY]** <https://github.com/1nd1v1d/WOW4E_AH_Trader> — README fetched (German).
Declares `Beta-Port für Interface 16001`, v0.2.4-beta, so it targets this client.

Not interesting as an addon; interesting as **a worked example of porting a Retail-API
addon to 16001 by someone outside this repo**. It implements request queueing, throttle
handling, timeout and retry against a modern API — the same defensive shape this plugin
tells people to write. Worth reading for gotchas it hit that the probe has not, and worth
comparing against what `tools/lint_addon.py` says about it now that the linter reads `.toc`
files as well.

Caveat before citing any of it: its own status says several event paths are still
unverified on the real client. Treat as untested code, not as measurement.

*(The other half of the original W.3 — CurseForge carrying a distinct Forever flavour —
is written up in `research/findings.md` §9.)*

### W.10 The SV read failure has a stated mechanism, and Blizzard still has not acknowledged it

**[PRIMARY]** <https://eu.forums.blizzard.com/en/wow/t/forever-beta-160169913-savedvariables-fail-to-load-on-client-startupreload-%E2%80%94-all-addon-settings-reset-on-restart/629888>
(2026-09-19, no staff reply) and
<https://us.forums.blizzard.com/en/wow/t/savedvariables-never-load-in-the-beta-%E2%80%94-all-addon-settings-reset-on-login-69913/2354798>
(CycnusJones, 2026-09-19, no staff reply). Both fetched this run.

The EU thread states a mechanism rather than the symptom: the client "fails to populate
existing SavedVariables into the global environment (`_G`) before `ADDON_LOADED` triggers",
on build 1.60.1.69913 (`_classic_beta_`), and reproduces "on /reload (inconsistently),
logout/relog, and full restart". The US thread: "The file on disk is correct... the data is
all there, valid Lua" and "It's only the read that never happens", tested with marker values
placed in several candidate locations including top-level `WTF\SavedVariables`.

**Why it matters here.** Two things. First, "inconsistently on /reload" is the only outside
report whose shape matches what this repo measured in §P.27 — per-character survives a
`/reload`, account-wide does not, neither survives a logout. Every other report says "never".
If the inconsistency other people see is that same split, §12 can state it as corroborated
rather than repo-only. Second, `_G` not populated before `ADDON_LOADED` is a sharper claim
than "the read never happens", and is separately testable.

Also settled this run, and it is a negative: **Blizzard has still not acknowledged the bug.**
Kaivax's beta known-issues list was fetched at both
<https://us.forums.blizzard.com/en/wow/t/wow-forever-beta-known-issues-september-18/2352687>
and its Arctium mirror <https://arctium.io/blue-posts/779>; it names Lua errors from barber
chairs and the Legacy System and nothing about addons or SavedVariables. A search snippet this
run claimed the known-issues list covers the SavedVariables bug. **It does not** — the third
time a snippet on this topic has invented a claim the fetched page does not make. So the expiry
note on §12's guidance stays: unfixed *and* unacknowledged as of 2026-09-21.

**How to settle it.** Reproduce directly: seed both an account-wide and a per-character SV file,
`/reload`, and see which comes back — ForeverProbe already does this, §P.27 is the run. What is
new to test is the `_G`-before-`ADDON_LOADED` framing: check whether the global is nil at
`ADDON_LOADED` specifically, rather than only at file scope and at logout.

### W.11 Two shipped workaround tools use the same bridge trick, and it is simpler than ours

**[PRIMARY]** <https://github.com/nobewayo/ForeverSVFix> (Simon Ahnfeldt Nielsen, v1.0.0) and its
forum thread <https://eu.forums.blizzard.com/en/wow/t/temporary-workaround-for-the-forever-beta-addon-savedvariables-bug/630188>
(S1MON, 2026-09-20); plus **WTFix** v0.8.8, described at
<https://eu.forums.blizzard.com/en/wow/t/workaround-for-addon-settings-savedvariables-resetting-on-forever-beta/630138>
(Solshine, 2026-09-20/21). All three fetched. No staff reply on either thread.

Both tools do the same thing by different means: **make the SavedVariables file load as addon
code**. ForeverSVFix links `WTF/Account/<account>/SavedVariables/[AddOn].lua` into
`Interface/AddOns/[AddOn]/ForeverSVFixData/[AddOn].lua` and edits the addon's TOC "to load the
SavedVariables before addon initialization", keeping backups in `WTF/ForeverSVFix/backups/`.
WTFix instead writes "a restore `.lua` file containing known-good addon settings" added to the
`.toc` "to load before addon initialization", with "a Windows script that updates the restore
file after logging out" as the outbound half.

**Why it matters here.** This is the out-of-game channel question answered by two independent
people, and it is **a cheaper pattern than the one §12 documents**. Thunderz's workaround
generates Lua into the AddOns folder; these two just point the TOC at the SV file that already
exists, so the inbound channel needs no code generation at all — an external writer edits the
real SV file in place and the next load picks it up. It also implies the loader is fine and only
the restore step is broken, which points the same way as W.10's `_G`-before-`ADDON_LOADED` claim.

Caveats to carry if any of this is written up: ForeverSVFix is validated only on Linux/Wine
("Windows and macOS builds exist but untested in-game"), its author discloses AI assistance in
development, and WTFix is reported to break on EllesmereUI because that addon stores function
references in SavedVariables — which a plain `.toc`-loaded file cannot restore.

**How to settle it.** Reproduce the trick with ForeverProbe: put a known table in a file listed
in the probe's own `.toc` and confirm it is visible at `ADDON_LOADED`. If it is, the bridge
guidance should lead with this shape and keep the generated-Lua pattern as the fallback.

### W.12 Why `loadstring_untainted` is missing has a named cause, and a better way to detect it

**[PRIMARY]** <https://github.com/EllesmereGaming/EllesmereUI/pull/2143> (dfrisone, 2026-09-20),
corroborated by <https://github.com/Nevcairiel/Bartender4/issues/303> (2026-09-18). Both fetched.

The PR names a mechanism this repo did not have: **`Blizzard_EnvironmentCleanup` nils
`loadstring_untainted`, `secretunwrap` and the `SecureMixin` family** — they are not merely
absent from the build, they are removed deliberately, and "Addons are not meant to reach it".
The PR's title is its point: *decide snippet support by running one, not by a scrubbed global*.
Its probe builds a `SecureHandlerAttributeTemplate` frame, `Execute`s a one-line body and reads
the attribute back — "returns `false` on Forever, `42` on retail". And the scope line, the most
valuable sentence in this batch: the probe is **"Skipped in combat, where the SecureHandlers API
raises outright. It stands down for that session."**

Bartender4 #303 corroborates with a probe anyone can run:
`/dump type(loadstring_untainted), type(loadstring)` returns `nil, function`, the error lands at
`Blizzard_RestrictedAddOnEnvironment/RestrictedExecution.lua:79`, and "Shadowed Unit Frames
triggers the same Blizzard error, suggesting this may be a WoW Forever client issue rather than a
Bartender4-specific defect" — i.e. client-wide, not addon-specific.

**Why it matters here.** Three changes. (1) The restriction list should record the cause
(`Blizzard_EnvironmentCleanup`) and not just the symptom: a deliberate scrub is much less likely
to be "fixed in a later beta build" than a missing engine export, and the guidance currently
treats it as a beta bug. (2) The detection advice should change — the plugin reasons from whether
a global exists; this shows absence of a global is the wrong test and a behavioural probe is the
right one, the same lesson §P.25 learned about secret values. (3) **SecureHandlers raising
outright in combat is a fourth restriction behaviour**, distinct from the combat log refusal, the
C_Secrets value gates and protected actions — and it is combat-scoped.

**How to settle it.** Run the PR's probe out of combat and again in combat with ForeverProbe.
Out of combat expect `false`; in combat confirm whether the API raises, and capture the exact
error text for `research/restrictions.yaml`.

**Update 2026-09-25:** the in-combat half is measured in research/findings.md §P.32, and it
corrects this entry: `Execute` raises only on a frame created in combat; on a frame created
before combat it is refused silently.

### W.13 A port diary with five aura and name gotchas, one of them a scope claim

**[PRIMARY]** <https://github.com/Spotnick2/priestly/pull/2> — "Port to WoW: Forever 1.60.1",
fetched. Frames Forever as "Vanilla content on the Retail codebase... The interface version is
`16001`."

Five claimed differences:
1. "Aura access now throws during combat for all group members, not just the player."
2. "`GetAuraDataBySpellName` returns `nil` instead of throwing when restricted by secrecy."
3. "`C_Spell.GetSpellInfo(name)` only resolves spells the player knows; reverse lookups by name fail."
4. "`UnitName` returns only first names for non-player units; full names require `GetUnitName(unit, false)`."
5. "`MouseIsOver` was removed entirely."

Its compat layer (`PriestlyCompat.lua`) wraps every aura read in `pcall` and returns three states
— HAS / NONE / BLOCKED — with GUID-keyed caching, because the aura payload itself throws on field
access or comparison.

**Why it matters here.** Item 1 is a **scope** claim in the direction this repo cares about:
"during combat", widened from the player to all group members. Item 2 says one restriction can
present as a throw *or* as a `nil` — exactly the trap the probe was built to catch, since a black
box returning `nil` still looks like a working call, and it means defensive code cannot rely on
`pcall` alone. Items 3–5 are plain API surface for the reference and for `tools/lint_addon.py`.
The HAS/NONE/BLOCKED shape is a pattern the build guidance should probably teach outright.

**How to settle it.** All five are directly measurable. Item 1 needs a group member and combat;
items 2–5 need nothing but a login.

### W.14 Someone else generated the API reference from the client's own `/api` system — and got our numbers

**[PRIMARY]** <https://github.com/Atraeau/WoW-Addons> — fetched. A Forever addon dev workspace:
several addons, a vendored BlizzThreatPlates, deploy scripts, and generated docs.

The load-bearing line: "The client documents its own API (the `/api` system). [`docs/api/`] is
that surface turned into browsable Markdown — **6,577 functions, 1,802 events, 792 types across
405 namespaces**." The pipeline is an in-game `/apiexport` command that dumps the client's own
introspection data to SavedVariables, then PowerShell converts it into Markdown plus Lua Language
Server definitions. It records "Interface version: 16001 (patch 1.60.1) · Product:
`wow_classic_beta` · Flavor directory: `_classic_beta_` · **TOC suffix: Camelot**".

**Why it matters here.** The function count is **6,577 — exactly this repo's shipped reference
count**, reached independently from the same source by a different route. That is the first
outside corroboration that the reference is complete rather than merely large, and the event,
type and namespace counts are numbers this repo's generator can be checked against. Two further
things: the `/apiexport`-to-SavedVariables route works *because* the SV **write** path is healthy
while only the read is broken (W.10) — the one place the bug does not bite, worth saying in the
guidance. And "TOC suffix: Camelot" is a packaging fact the linter does not know; compare it with
the `AllowLoadGameType: camelot` finding in §10.

**How to settle it.** Diff their `docs/api/` against `reference/api/`: same source, two
generators, so any disagreement is a bug in one of them. Cheap and high value.

### W.15 Flavour, packaging and client detection are solved by third-party tooling — and W.4's gotcha is half out of date

**[PRIMARY]** three repos, all fetched:
<https://github.com/McTalian-WoW-Addons/wow-addon-agent-tools/pull/2>,
<https://github.com/kemayo/wow-dropthecheapestthing/pull/31>,
<https://github.com/sekitoxD/TuffLevels>.

- **Flavour band.** The agent-tools PR defines interface band **16000–16999 → flavour `forever`**,
  ordered ahead of classic_era because "list is first-match and the `1xxxx` band would otherwise
  swallow 16001", with 226 passing tests. Product is "provisionally set to `wow_classic_beta`,
  with a note that this is provisional until Forever gets its own product ID".
- **TOC game-type tags.** Same PR: `standard` = Retail only, `mainline` = Retail + Forever; its
  compatibility check greps for `ExcludeLoadGameType: camelot`, and for `AllowLoadGameType: standard`
  without `camelot`.
- **Packaging is already done.** dropthecheapestthing #31: "BigWigsMods/packager already maps
  `16???` to the forever game type", and that port needed **no code changes at all** — only
  `## Interface:` gaining 16001. It confirms on a live client that "dropping and selling work, and
  the merchant hook takes", and that "WOW_PROJECT_ID [is] WOW_PROJECT_MAINLINE, and its API is
  complete for everything this addon touches: `C_Container`, `C_Item` and `C_TransmogCollection`".
- **Detection trap.** TuffLevels: "`select(4, GetBuildInfo())` returns `16001`, so the
  near-universal `>= 100000` test for 'modern client' reads Forever as Classic." Detect via
  `WOW_PROJECT_ID`, build number only as fallback. It also names Classic globals that must be
  replaced (`GetItemInfo`, `GetSpellInfo`, `UnitAura`, `GetTalentInfo`,
  `CombatLogGetCurrentEventInfo`) and one operational limit: **Lua error delivery caps at 100
  errors per session**.

**Why it matters here.** W.4 told people automated TOC updaters silently skip Forever because
16001 < 50504. That is still true of *updaters*, but **packaging is not broken** — BigWigsMods
handles the band already — so the guidance should split the two and stop implying a packaging
problem. The `>= 100000` trap is a lint rule worth writing today: a one-line mistake that
misroutes an addon's entire compat path, and it will be present in almost every port that predates
Forever. The `AllowLoadGameType` greps are ready-made linter checks. The 100-errors-per-session cap
changes how a probe run should be read — a quiet log late in a session may mean the cap, not success.

**How to settle it.** Nothing here needs a client except the error cap, which the probe can test by
deliberately raising 120 errors and counting what arrives.

### W.16 A player reports combo points are secret, which would contradict the published doctrine

**[UNVERIFIED]** <https://us.forums.blizzard.com/en/wow/t/combo-points-are-secret-values/2352853>
— Phosphoros, 2026-09-17, fetched, **no staff reply**. "The addon API considers them a secret
value and prevents addons from tracking them", with combo points "treated like [a debuff] for UI
and addon purposes". No scope given and no test described: this reads as a player's inference from
a broken addon, not a measurement.

**Why it matters here.** Hazzikostas's disarmament post says class secondary resources stay fully
readable, and combo points are the textbook secondary resource. This repo has already measured
`ShouldUnitPowerBeSecret("player")` **true out of combat**, which is that doctrine backwards. A
confirmed combo-point gate would turn that measurement from an anomaly into a pattern — the
published doctrine being wrong about secondary resources generally. A refutation is just as
useful: it would mean the player hit the aura/debuff path, not a power gate.

**How to settle it.** Trivial with ForeverProbe on a rogue or druid: read
`UnitPower("player", Enum.PowerType.ComboPoints)` out of combat and in combat, alongside
`C_Secrets.ShouldUnitPowerBeSecret("player")`.

### W.17 Someone else is building this plugin

**[REPORTED]** <https://github.com/DennysOliveira/wow-addon-dev> — the file fetched was
`plugins/wow-addon-dev/skills/wow-addon-dev/references/secret-values.md`. The path shape is a
Claude Code plugin with a skill and a references directory: the same artefact this repo is.

Worth knowing mostly for what it is **not**. Its secret-values reference is scoped to "WoW 12.0
(Midnight)", interface **120001** — it makes no claim about Forever, 16001 or 1.60.1 anywhere —
and it cites no source for anything: not measured, not datamined, not attributed to Blizzard docs.
Its substance is the disarmament summary already recorded here (arithmetic, comparison, string
ops, boolean logic and table-keying all forbidden on secret values from tainted code; secrets
behave normally in untainted Blizzard code).

**Why it matters here.** Two uses, neither as evidence. As a **gap check**: its taxonomy of
forbidden *operations* on a secret value is a cleaner axis than `restrictions.yaml`, which is
organised by which API is gated rather than by what you may not do with what it returns — worth
stealing. As **positioning**: the nearest comparable plugin is retail-scoped and unsourced, which
is exactly the hole this one fills, and a reminder that measured-with-a-probe and cite-the-source
is the whole differentiator. Do not cite it for any Forever fact.

**How to settle it.** Nothing to measure. Read its skill structure once for ideas and move on.

### W.18 The packaging toolchain already has a Forever target, and its name is `camelot`

**[PRIMARY]** <https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh> — fetched
2026-09-22 and read at source, not taken from a report. The `-g` flag's accepted game types are
`"retail|classic|bcc|wrath|cata|mists|titan|forever"`, with `mainline` aliased to `retail` and
**`camelot` aliased to `forever`**. The script recognises the TOC filename suffixes `-Camelot` and
`_Camelot` as the Forever flavour, and associates the interface pattern **`16???`** with it.

Surfaced by <https://github.com/danielcosta42/guildos/issues/20> (opened 2026-09-18, now **closed**),
a Portuguese-language issue on a third-party addon whose title translates to "Publish on the Forever
flavour: Curse already has it, our TOC and workflows do not". It names CurseForge's Forever flavour
as **`gameVersionTypeId=88568`**, states that "Addons published for the Forever flavor declare
`## Interface: 16001`", and its acceptance criterion is a multi-value TOC, `## Interface: 20506, 16001`
— Anniversary first, Forever second. Its diagnosis of its own breakage: the addon declared only
`20506`, published with `-g bcc`, and pinned a packager version predating Forever support.

Corroborated on the store side: <https://www.curseforge.com/wow/addons/classicui-forever/files>
serves **`Forever`** as a selectable flavour filter alongside `Retail`, with a file labelled
"Forever + 1" uploaded 2026-09-21.

**Why it matters here.** This is the first hard, checkable answer to trigger 4 and it is upstream
of guidance rather than news about it. Three separate things the plugin can now state as fact
instead of describing as unsettled: the flavour keyword is `forever` with `camelot` as its alias;
the TOC suffix is `_Camelot`; the interface pattern the toolchain matches is `16???`, not the single
literal `16001`. It also independently corroborates §P.24's `camelot` codename finding from a
completely different direction — the client called itself Camelot from the inside, and the packaging
ecosystem calls it Camelot from the outside. The `16???` range is the load-bearing detail: guidance
that hardcodes `16001` will be wrong the first time Blizzard bumps the build, and the multi-value
`## Interface: 20506, 16001` idiom is the shape a real cross-flavour TOC takes. A linter rule falls
straight out of this.

**How to settle it.** Nothing needs a client. Pin the packager commit that added `forever` and read
its diff to confirm the suffix and range are not being inferred loosely, then encode both as a lint
rule. One open question the sources do not answer: whether a `_Camelot` TOC and a multi-value
`## Interface` line are equivalent to the client, or whether only one of the two is actually read —
that part **is** measurable with ForeverProbe by shipping both forms and checking which loads
without "Load out of date AddOns".

### W.19 The SavedVariables bug is still unfixed on 2026-09-21, and a second workaround genre has appeared

**[REPORTED]** Two new sources, both fetched 2026-09-22, both later than anything previously recorded
on this bug (the prior ceiling was 2026-09-18).

<https://github.com/kylef000/wow-forever-svshim> — a repo distinct from the already-recorded
`nobewayo/ForeverSVFix`. Its README: the Forever 1.60.x beta client "**saves** addon settings when you
`/reload` or log out, but it **never loads them** again." Its mechanism is a PowerShell watcher that
copies the written SavedVariables files into the addon's own data directory, catalogues them in XML,
and restores at `ADDON_LOADED` before addons apply their own defaults. It ships a self-deprecation
check: when Blizzard fixes the bug, the shim "notices and tells you in chat that it can be removed."

<https://eu.forums.blizzard.com/en/wow/t/addon-wtfix-090-savedvariables-recovery-for-wow-forever/630504>
— posted 2026-09-21 16:41 by Ðevilßelle-defias-brotherhood, addon version 0.9.1, **no staff reply**.
WTFix takes a different approach: save a known-good configuration "as a trusted checkpoint" and
"restore it if those settings later get changed or lost", claimed to hold across "/reload, relogs,
full game restarts, cold starts through Battle.net." A reply from *nokz*: "Good effort, but i for one
would not install any application beyond a normal addon just to bandaid an issue that Blizzard will
fix in the next days anyway."

**Why it matters here.** The value is the **date**, not the mechanism. §12's guidance carries an
expiry conditioned on this bug being fixed, and the plugin should not tell someone to build a
workaround for a bug that shipped a fix three days ago. As of 2026-09-21 the bug is still live,
`forever-bugs#34` is still open with no Blizzard acknowledgement, and a sweep of the US and EU forum
threads this run found **no blue reply in any of them**. So the expiry has not triggered and the
workaround guidance stands. Second, the svshim README is an independent restatement of the exact
asymmetry §P.27 measured — writes land, reads do not — from someone who did not read this repo.
Third, and this is the part worth a second look: svshim restores at `ADDON_LOADED`, which is the
idiom W.6 **refuted**. It is not a contradiction — svshim supplies the data itself from outside the
client rather than expecting the client's loader to have populated it — but that distinction is
precisely the thing the plugin should spell out, because a reader who sees `ADDON_LOADED` in a
working shim and `ADDON_LOADED` in a refuted idiom will draw the wrong conclusion. Treat *nokz*'s
"Blizzard will fix it in the next days" as community sentiment, not information.

**How to settle it.** Re-read `forever-bugs#34` and the two forum threads each run and record the
date the bug is last confirmed live; that date is what the guidance expiry hangs on. The
`ADDON_LOADED` distinction needs no client — it is a documentation fix. WTFix's "cold starts through
Battle.net" claim **is** measurable with ForeverProbe and is the stronger claim of the two, since
§P.27 found nothing survives a logout: either WTFix is doing the same out-of-client reseeding svshim
does, or it is claiming something §P.27 says is impossible.

### W.20 A dev calls them "combat restrictions", second-hand and against an unverified VOD

**[UNVERIFIED]** <https://wowsod.pro/articles/wow-forever-qa-recap-september-17> — fetched
2026-09-22. Byline "WoWSoD Editorial", 2026-09-17, a recap of the Blizzard Developer Q&A already
recorded this week through MMO-Champion's write-up. What is new here is named attribution and
direct quotation where MMO-Champion gave neither. Attributed to **Nora Mills, Lead Software
Engineer**: "We did opt for the modern API approach." And, on why: boss encounters in Forever are
"a lot more simplified compared to Modern," so **the combat restrictions** should not hurt. The
recap links a primary VOD, <https://www.youtube.com/watch?v=Y5zzSMSVhRo>, placing the segment around
59 minutes in.

Read the confidence label literally. The VOD was **not** opened and the timestamp **not** confirmed;
Wowhead, the usual cross-check, is currently returning a hard geoblock rather than a 403, so the
recap could not be corroborated against a second outlet either. wowsod.pro is an unvetted third
party. It is not on the junk list and it does cite and link its primary source, which is more than
most, but that is the whole of its credential.

A companion article on the same site, <https://wowsod.pro/articles/wow-forever-addons-weakauras>,
looks at first read like a precise scope statement — self-buffs and cooldowns fine, enemy cast bars
and combat-log-derived state restricted. **It is not a dev quote.** On fetching, the site marks that
passage as its own editorial interpretation, sitting alongside genuine attributed Mills quotes.
Recorded here only so the next run does not re-discover it and mistake it for sourcing.

**Why it matters here.** One word, and only one word, is why this is an entry at all: a Blizzard
engineer reportedly said "**combat** restrictions". Trigger 2's central open question is combat-only
versus always-on, and this repo's measurements say the published summaries are wrong in both
directions — `UnitHealth("player")` and `ShouldUnitPowerBeSecret("player")` are both gated **out of
combat** (§P.25, and the anomaly behind W.16). A dev framing the whole thing as combat-scoped is
either loose speech in a rationale, or it is the doctrine the client is contradicting. Either way it
is one more instance of the pattern the plugin exists to document: what is said about the
restrictions and what the client does are not the same thing, and the plugin should quote the
measurement, not the press. Do not soften the measured guidance on the strength of this.

**How to settle it.** Watch the VOD from ~58:00 and confirm the quote, the speaker and whether
"combat" was a qualifier or a throwaway — that is the only thing that would move it from
`[UNVERIFIED]`. Worth one attempt with the built-in browser next run. Nothing here is measurable
with ForeverProbe that §P.25 has not already measured.
### W.21 A shipped addon shows the sanctioned way to read auras in combat, and the repo has no entry for it

**[PRIMARY]** <https://github.com/cassidymichael/ShamanForever> — fetched 2026-09-22. A real
Forever addon, `## Interface: 16001`, first released **today**, CurseForge project 1706929, built by
the BigWigs packager (which independently exercises W.18's toolchain). Its README carries working
code the author states is "**Verified working on build 69913 in this addon**".

The claim: "Addon code cannot read player auras in combat on this client (every read throws 'Auras
cannot be accessed when secret'). The sanctioned route is the `AuraContainer` intrinsic with
`CustomAuraContainerTemplate` from `Blizzard_AuraContainer`. **Its Lua runs untainted, so it reads
the aura and drives widgets the addon supplies.**" The addon creates
`CreateFrame("AuraContainer", nil, parent, "CustomAuraContainerTemplate")`, calls `SetUnit("player")`
and `AddAuraSlot(key, "HELPFUL", {candidateFilters = {includeSpellIDs = {...}}, initializeFrame = ...})`,
handing in its own icon texture, `Cooldown`, `FontString` and `StatusBar` via `SetIcon`,
`SetDurationCooldown`, `SetApplicationCount` and `SetApplicationBar`.

Its gotcha list is the valuable part and every line is a debugging hour someone already spent:
the intrinsic "does not sit where you expect", so set frame strata explicitly; slot frames "are NOT
laid out by the container", anchor them yourself; `candidateFilters.includeSpellIDs` is **a map, not
a list**; the font must be set *before* `SetApplicationCount` because "Blizzard writes text
immediately"; `minApplications` must be 0 or a single charge renders empty; registered parts must be
descendants of the button; **script handlers on anything under the button never run**, so you cannot
learn when the aura disappears in combat; the count text only prints for two or more applications;
the button and its parts are off limits to addon code in combat; and "**everything readable about
the button is secret, even out of combat**".

**Why it matters here.** This is a gap, not a correction. `research/restrictions.yaml` already has
`aura-secrecy` with the exact refusal string and — crucially — the right explanation: "the
restriction is scoped to the call stack, not the data - Blizzard's own UI reads the same auras in the
same combat." `CustomAuraContainer` is that observation turned into a supported API, and **it appears
nowhere in this repo** — not in `reference/api/`, not in the restrictions data, not in the guides.
The plugin currently tells someone their aura reads will throw and stops there; the shipped answer is
that Blizzard provides an untainted container that reads the aura for you and renders your widgets.
That is the difference between documenting a wall and documenting the door next to it, and it is
probably the single most useful thing to add to the build guidance. The closing gotcha is an
independent third sighting of the out-of-combat gating pattern (`UnitHealth` §P.25, combo points
W.16): a thing the published doctrine implies is combat-only, reported secret out of combat too.

Two honesty flags. The README says "This quick addon was created by AI, with minimal oversight by a
human" — so treat the prose as a hypothesis and the code as the artefact. And the "not subject to the
addon aura restrictions" framing is the author's inference; what is checkable is whether the
container renders live aura state in combat from addon-supplied widgets.

**How to settle it.** Directly measurable and worth doing first. Paste the README's snippet into
ForeverProbe on any character with a trackable buff, enter combat, and record whether the icon,
cooldown and count update while `C_Secrets.ShouldAurasBeSecret()` is true — and separately whether a
direct `C_UnitAuras` read still throws in the same frame. Then test the four sharp gotchas
individually: list-vs-map `includeSpellIDs`, `SetApplicationCount` before/after font, `minApplications`
0 vs 1, and whether an `OnHide` under the button ever fires. If it holds, `CustomAuraContainer` needs
a `reference/api/` entry and `aura-secrecy` needs a "sanctioned alternative" field.

### W.22 An addon rewrites action bars out of combat and guards every read with `issecretvalue`

**[PRIMARY]** <https://github.com/Moose-Ltd/AutoSpellRanks> — fetched 2026-09-22, created
2026-09-20. `## Interface: 16001, 120105` with an explicit note: "16001 = WoW Forever (1.60.x,
`_classic_beta_`). 120105 = Retail 12.1.5, which shares the same API." Credits its API baseline to
`Thunderz96/forever-addon-kit`, already on file.

Two mechanisms worth the plugin's attention. **The swap path**: `ClearCursor` ->
`C_Spell.PickupSpell` -> `PlaceAction` -> `ClearCursor`, run only outside combat, with the scan
deferred to `PLAYER_REGEN_ENABLED` if a fight is in progress. "If `PlaceAction` throws, the addon
prints one line and **disables itself for the session** rather than retrying." **The secrecy
discipline**: "Every value that could be a secret passes through `issecretvalue` before it is
compared. Every `C_*` call is checked for existence first."

**Why it matters here.** It adds no API surface — `issecretvalue`, `C_Spell.PickupSpell` and
`C_Spell.GetSpellSkillLineAbilityRank` are all already in `reference/api/`. What it adds is **usage
in the wild**: a shipped addon confirming that a program may rewrite action-bar contents out of
combat on this client, which is a concrete boundary marker on the protected-action axis, the least
measured of the repo's three systems. The `issecretvalue`-before-every-comparison idiom is the
defensive pattern the build guidance and the linter should both carry, because it is the direct
countermeasure to the class of bug §P.25 found — a value that types as `"number"` and throws on
comparison. A lint rule that flags a comparison against a known-gated read with no `issecretvalue`
guard falls straight out of this. The multi-value `## Interface: 16001, 120105` is a second
independent sighting of the W.18 idiom, and its `_classic_beta_` install path corroborates the
product folder already recorded.

Its Beta note restates the SavedVariables bug in the same terms as W.19 and is not separate evidence.
Its claim that 120105 "shares the same API" as 16001 is an assertion, not a measurement, and the
repo's own captured baseline is the better authority.

**How to settle it.** Measurable with ForeverProbe: call `C_Spell.PickupSpell` then `PlaceAction`
out of combat and confirm the slot changes; repeat in combat and record whether `PlaceAction` throws,
returns false or is silently ignored — that distinction is what the protected-action entry needs and
none of the three outcomes is currently documented.

### W.23 A mature third-party dev-tooling addon added a Forever target, and its architecture is the one this repo is building

**[REPORTED]** <https://github.com/Falkicon/Mechanic> — fetched 2026-09-22, 19 stars, alpha,
active since 2025-12. Its `!Mechanic/CHANGELOG.md` records, at **1.4.5, 2026-09-18**: "Add WoW:
Forever support (**Interface 16001 alongside Retail 120100**), bundled with main addon 1.3.6." Note
the README still says "The addon TOCs currently target interface `120100`", so this is a retail
addon that has added a Forever line, **not** a Forever-native project.

It describes itself as an "in-game development hub": frame inspection, console logs, BugGrabber
errors, addon tests, performance metrics and API testing in game, plus a Python desktop dashboard and
a registry of "60 registered commands". The load-bearing sentences are its workflow: "**Queue Lua
snippets or API tests, reload in game, then read the selected profile's saved results**", and "**The
desktop watches SavedVariables on disk. The data reflects the last save/reload, not a live stream
from WoW.**" It also ships "Lua sandbox tests without a running WoW client" and a TOC-structure
validator.

**Why it matters here.** This is the closest prior art yet to this repo's own probe workflow, and
unlike W.17's competing plugin it is a real, used, non-trivial tool. Queue-snippet then reload then
read-SavedVariables-from-disk is exactly ForeverProbe's loop, arrived at independently, which is
reassurance that the architecture is the natural one rather than a workaround peculiar to this
project. Three things worth stealing or at least reading: its command registry as a structural model
for the plugin's skills, its offline Lua sandbox tests (this repo has no way to test probe code
without a client), and its TOC validator against `tools/lint_addon.py`. The sharpest question it
raises is unasked by its own docs: its whole desktop side depends on reading SavedVariables from
disk, and on Forever the client **writes** but does not **read** them (§P.27, W.19) — which is
harmless for a one-way in-game-to-desktop channel and fatal for anything coming back. That asymmetry
is worth stating explicitly in the plugin's probe guidance.

**How to settle it.** Nothing to measure on a client. Read its command-registry and queue
implementation once for design, diff its TOC validator against `tools/lint_addon.py`, and check
whether its Forever TOC actually loads on 16001 or was added untested — its own README's retail
framing suggests nobody has run it on Forever.

### W.24 Two more `16001` sightings that are not evidence of anything

**[REPORTED]** Recorded so a future run does not rediscover them and mistake a TOC declaration for a
measurement.

<https://github.com/gakonst/nanocodex> (Rust, 519 stars, an OpenAI-agent framework with a WoW addon
example) declares 16001 in `examples/wow/addon/Nanocodex/`, and its own `docs/addon.md` disarms it:
"The TOCs cover Mainline, Era, TBC, Mists and the **previously targeted** Classic Beta interface
16001. **These declarations are compatibility targets.** The new side view has **not** been visually
verified in the running client; mocked Lua APIs do not prove actual rendering or protected API
behavior." It also states its panel's "saved position, visibility, minimized state and draft survive
reload through account-wide SavedVariables" — which §P.27 measured as **false on Forever**, account-wide
being precisely the path that does not survive. As an in-game-to-agent bridge it is out of scope by
the product rule; it is logged only as the cleanest available example of a 16001 declaration that
means nothing.

<https://github.com/Zxeon/IssueReporterLockWowForever> (created 2026-09-18) is a genuine Forever
addon but a single-purpose one: it pins the beta feedback UI in place. Its one transferable line:
"This addon works by matching Blizzard's internal `Blizzard_PTRFeedback` implementation (**an
undocumented global name and UI text**), not a public API." Its premise — reapplying a saved position
"on every future login/reload" — is quietly undercut by W.19, since saved positions do not survive a
restart on this client at all.

**Why it matters here.** One rule, worth writing into the watch itself and into the plugin's
sourcing guidance: **a `## Interface: 16001` line is a claim of intent, not a measurement.** Both of
these declare it; neither has verified anything against the client, and one of them asserts
SavedVariables behaviour this repo has measured to be wrong. The corollary for `gh search code`
sweeps is that the TOC hit is the start of the check, never the finding.

**How to settle it.** Nothing to measure. Do not cite either for a Forever fact.

### W.25 The client's own shipped Lua source is on GitHub with a live-updated Forever branch

**[PRIMARY]** <https://github.com/Gethe/wow-ui-source> (branch `forever`) — a git mirror of the
extracted `Interface/AddOns` Lua/XML source for every WoW client flavor, with a dedicated branch
per flavor (`live`, `classic`, `classic_anniversary`, `classic_titan`, `forever`, `ptr`, …) and one
commit per build. The `forever` branch's history: `cf7fa921` "Initial commit" 2026-09-16, then
builds 69876, 69893 (twice), 69913 (2026-09-18), and **69977, committed 2026-09-23T00:37:19Z — a
build number this watch has not seen before.** Diffed 69913→69977 directly: 4 files changed, all
`Blizzard_GlueXML` login/character-select screen plus `version.txt` — **nothing addon-restriction-
relevant in this bump**, recorded as a negative result so a bare build-number sighting isn't
mistaken for a lead next run.

Fetched `Interface/AddOns/Blizzard_EnvironmentCleanup/Mainline/EnvironmentCleanup.lua` from this
branch directly — the file W.12 says nils `loadstring_untainted`/`secretunwrap`. Confirmed: it
does, unconditionally, alongside `SecureMixin`, `CreateFromSecureMixins` and a long list of
store/VAS globals. **Diffed byte-for-byte against retail's `live` branch copy of the same file —
identical.** So the nilling itself is not Forever-specific code; it is retail's own
`Blizzard_EnvironmentCleanup` shipping unmodified. (The reason it only *breaks* on Forever is a
separate, load-order story — see W.27.)

**Why it matters here.** First time this watch has read the actual client source instead of a
third party's report of it. Worth adding as a standing channel: a periodic diff of `forever`
branch HEAD against the previously recorded commit, scoped to
`Blizzard_RestrictedAddOnEnvironment`, `Blizzard_EnvironmentCleanup`,
`Blizzard_APIDocumentationGenerated` and `Blizzard_AuraContainer`, would surface real
API/restriction changes the moment Blizzard ships them, ahead of any third-party report.

**How to settle it.** Nothing further needed for this file; it's a direct read, already the
strongest evidence tier. Adopt the branch-diff habit above for future runs.

### W.26 Blizzard's own generated docs name at least 19 distinct "secret" conditions, not one black box

**[PRIMARY]** <https://raw.githubusercontent.com/Gethe/wow-ui-source/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SecretPredicatesDocumentation.lua>
— fetched directly, 166 lines, part of the same client `/api` self-documentation system W.14 used
for the function-count reference. It enumerates 30 named "Predicates" as `Precondition` or
`Secret` type, each with a plain-English scope sentence in Blizzard's own words. Secret-type
predicates include `SecretWhenInCombat` ("combat addon restrictions are in effect");
`SecretWhenAurasRestricted` / `SecretWhenUnitAuraRestricted` ("combat, encounter, challenge mode,
or PvP match addon restrictions are in effect" — the aura one adds "Individual spells may be
flagged as never or always secret, which takes priority over restrictions");
`SecretWhenCooldownsRestricted` (same four-condition list); `SecretInActivePvPMatch`;
`SecretInChatMessagingLockdown` ("...and when the player is on a communication-restricted map such
as a dungeon or raid"); `SecretOnRestrictedMaps` ("an addon-restricted map such as a dungeon or
raid"); and per-axis unit predicates — `SecretWhenUnitComparisonRestricted`,
`SecretWhenUnitHealthMaxRestricted`, `SecretWhenUnitIdentityRestricted`,
`SecretWhenUnitNameIdentityRestricted`, `SecretWhenUnitPossessionRestricted`,
`SecretWhenUnitPowerMaxRestricted`, `SecretWhenUnitPowerRestricted`,
`SecretWhenUnitStatsRestricted`, `SecretWhenUnitThreatStateRestricted`,
`SecretWhenUnitThreatValuesRestricted`, `SecretWhenTotemSlotSecret`,
`SecretWhenUnitSpellCastRestricted`, `SecretWhenLossOfControlInfoRestricted`,
`SecretWhenAnchoringSecret`. Precondition-type gates carry their own documented `FailureMode`:
`RequiresNonSecretAura` ("does not raise a blocked action error — instead, protected APIs will
return no values") versus `RequiresUnitAuraAccess` (`FailureMode = "Error"`). Diffed against the
`live` (retail) branch copy: identical but for one blank line — shared infrastructure, not
something Forever narrowed or widened.

**Why it matters here.** Close to the "Blizzard restriction list or allow-list" the trigger calls
the single most valuable possible find, and finer-grained than the repo's three-system model in
two ways. First, secrecy has at least five independent triggering conditions — combat, encounter,
challenge mode, PvP match, and simply "on an addon-restricted map" — so "combat-only vs
always-on" is the wrong binary; a value can be secret on a restricted map with no combat
happening. Second, two failure modes (silent no-return/no-error vs documented `Error`) are a
declared design distinction, not an inconsistency — this directly explains W.13's item 2 (`
GetAuraDataBySpellName` returning `nil` instead of throwing) as two different named predicates.
It also gives exact per-axis names (health max, power, power max, stats, threat state, threat
values, totem slot, spell cast, loss-of-control, unit/name identity, unit possession) that
`research/restrictions.yaml` can be checked against function by function.

**How to settle it.** Nothing to test experimentally — this is Blizzard's own documentation,
already ground truth. The useful next step is mechanical: map `restrictions.yaml`'s existing
entries (`unit-health-secrecy`, `aura-secrecy`, the unmeasured C_Secrets gates for
UnitSpellCast/UnitThreatState/UnitThreatValues) onto which of these 19 Secret-type predicates each
one is, and check whether the "restricted map" and "PvP match" conditions are measured anywhere —
they are not, per the current `findings.md`.

### W.28 A live bag-addon port shows Forever's bank is asymmetric, and hints at unreleased C_Bank functions

**[REPORTED]** <https://github.com/Cidan/BetterBags/pull/1092> (Cidan, fetched via `gh pr view`,
not yet merged). Adds Forever/"Camelot" support to BetterBags, a mature bag addon, describing a
process of auditing "the forever UI source" — the same mirror this run found independently (W.25).
Two measured-not-inferred differences: **bank tab count is 9+9 on Camelot versus 6+5 on live
retail** (probed via `Enum.BagIndex` rather than hard-coded, "byte-identical" on retail); and
**Camelot has no Account/Warband bank at all**, despite `Enum.BagIndex` still declaring
`AccountBankTab_N` members — gated behind a new `addon.hasWarbank = addon.isRetail and not
addon.isForever` predicate that empties every warbank-driven table, menu option and interaction.
One line flags unfinished work: "the three net-new `C_Bank` functions (not needed [yet])" —
implying `C_Bank` gained functions on this client not yet in the addon's own compat layer, and (per
a name search) not obviously named in `reference/api/` either.

**Why it matters here.** Two things. First, an enum member existing (`AccountBankTab_N`) is not
evidence the feature works — the same "declared but inert" trap W.24 flagged for `## Interface:
16001` lines, now shown on the API-surface axis instead of the TOC axis. Second, "three net-new
C_Bank functions" is a dangling, checkable thread for trigger 1: unreported API surface if true.

**How to settle it.** Two things, both needing only a login, not a raid: diff `C_Bank`'s function
list against the captured baseline to see if it already has whatever the PR is alluding to, and
open the bank UI once to confirm tab count and the absent Warbank. The PR is unmerged and marked
`[REPORTED]` rather than `[PRIMARY]` accordingly.

---

### W.29 The curated aura-category flags that `AuraContainer` filtering depends on appear empty on Forever

**[REPORTED]** <https://github.com/ClassicWoWCommunity/forever-bugs/issues/99> (opened 2026-09-23,
OPEN, no comments, no Blizzard reply; fetched via `gh api`). Reporter gives `/dump` repro steps:
"`C_UnitAuras.AuraIsBigDefensive(642)` -> divine shield, false", "`C_UnitAuras.AuraIsBigDefensive(871)`
-> shield wall, false", "`C_Spell.IsSpellImportant(1719)` -> recklessness, false", while
"`C_Spell.IsSpellCrowdControl(118)` -> Polymorph -> true (mechanism works)". Load-bearing sentence:
"player spells are missing curated category flags for `AuraContainer` filtering in Forever." Links
the consumer in the client's own source,
`Blizzard_NamePlates/Blizzard_NamePlateAuras.lua#L196` at build 69977 (`c6e8998318`).

**Why it matters here.** W.21 made `CustomAuraContainer` the sanctioned in-combat door beside the
aura-secrecy wall. If the category predicates that door filters on return false for the obvious
cases, the door exists but its filters are empty on this client: guidance recommending
`AuraIsBigDefensive` / `IsSpellImportant`-based filtering would silently show nothing. The API
*surface* is intact (`AuraIsBigDefensive` is in `reference/api/`); the *data* behind it is not. A
restrictions-adjacent gotcha of a new kind: a present function whose Forever return is
uncurated, not secret.

**How to settle it.** One login, no combat: `/fprobe` or `/dump` the four calls above, plus a
handful more (Ice Block 45438, Evasion 5277, Blessing of Protection 1022). If all "big defensive"
and "important" checks are false while CC checks are true, record it in the aura section as a
data gap with an expiry, like the SV bug.

---

## Closed

Struck 2026-09-25. Settled by one play session on build 1.60.1.70009 and a regeneration of
the reference from the 70009 source.

| Was | Written up | Measured outcome |
|---|---|---|
| **W.27** `loadstring_untainted` missing has a one-line root cause: a `## Dep:` line missing `camelot` | §P.32 | **Confirmed the fix shipped in 70009** (the TOC line W.33 diffed). Behaviour measured directly: secure snippets run out of combat, and `type(loadstring_untainted)` is still `nil` |
| **W.30** `## LoadSavedVariablesFirst: 1` is a real directive and changes SV timing | §P.31 | **Confirmed.** With the directive, saved globals hold last session's data before file scope runs; without it (the default) the client replaces the file-scope table at `ADDON_LOADED`. The linter accepts the directive and per-file `[AllowLoadGameType camelot]` suffixes |
| **W.31** the SV symlink workaround, confirmed on native Windows | §P.30, §P.33 | **Moot on 70009**: the standard read-back path works on its own, so the workaround is now something to remove — leftover `.toc` link lines and stale links (`reference/guides/savedvariables.md`). The symlink-vs-hard-link claim itself was **not measured** here |
| **W.32** the SavedVariables read-back bug is reported fixed in build 70009 | §P.30 | **Confirmed.** Account-wide and per-character SV both come back, across a full exit and relaunch through Battle.net and across `/reload` |
| **W.33** secure snippets work again on 70009, the `EnvironmentCleanup` TOC fix shipped | §P.32 | **Confirmed out of combat** (`Execute` sets an attribute to 42 and reads it back). In combat, `Execute` on a frame made before combat is **refused silently** (`ADDON_ACTION_BLOCKED SecureHandlersUpdateFrame:SetAttribute()`), and on a frame made in combat it **raises** ("Header frame must be explicitly protected"). The linter now flags `loadstring_untainted` existence checks as a false-negative feature test |
| **W.34** build 70009 changes the API surface: new namespaces, a renumbered `ForbiddenAspect` enum, a lost namespace | §P.34; `reference/api/BUILD.md` | **Confirmed and regenerated.** `reference/api/` rebuilt from the 70009 source (`research/captures/SourceDocs_70009_bd2470a.lua`, via `tools/docs_from_source.py`) with the fresh 70009 surface dump: 6,577 → 6,596 functions, 21 added, 2 removed, no renames. Every listed change confirmed: `C_Flyout` (6), `C_NameUtil`, the `C_GameRules` preset swap (the two `Select*ExperiencePreset` functions are absent from the 70009 client too), `C_LocaleContext` → `widgets/LuaLocaleContextAPI/`, the secrecy moves. The `ForbiddenAspect` renumbering is visible in `reference/api/enums/ForbiddenAspect.md`, and the linter flags hardcoded aspect numbers above 1024. The porting checks reproduce except the character-name split (§P.34) |

---

Struck 2026-09-20. Each was fetched, written up in `research/findings.md` with credit, and
then — for everything measurable — **measured on a live client the same day** (§P.23 to
§P.26). The middle column is where the source material lives; the right-hand column is what
the client actually said.

| Was | Written up | Measured outcome |
|---|---|---|
| **W.1** read-back may only be broken on the account-scoped path | §12 expl. B | **Half right, and the half it got right is small.** The exotic WTF paths it named are neither read nor written — seeded before a cold start, untouched after. But the axis was real: per-character saved variables survive a `/reload` while account-wide ones do not. Neither survives a logout (§P.27) |
| **W.2** the bug is unfixed and tracked | §12 | Confirmed as context; `forever-bugs#34` cited, guidance now carries an expiry |
| **W.3** third-party Forever addons as prior art | §9 / W.3a | CurseForge flavour written up; the `WOW4E_AH_Trader` read stays open above |
| **W.4** `.toc`, interface derivation, packaging gotcha | §9 | **Confirmed.** `interfaceFormulaHolds` true: `%d%02d%02d` of 1.60.1 = 16001 on the client (§P.24) |
| **W.5** a port diary with four client differences | §11 | **Split.** Item 3 (`GetCurrentRegionName()` empty) and item 4 (`GetNamePlateForUnit` raises on target-of-target, with an explicit refusal message) **confirmed**. Item 2 (saved variables load before addon Lua) **refuted** — everything is nil at file scope. Item 5 (realm identity) not reproduced; item 1 needed no client and is a lint rule (§P.23, §P.24) |
| **W.6** the bug may be partly addon-side | §12 expl. C | **Refuted.** The prescribed `ADDON_LOADED` binding recovers nothing, because nothing is restored under any of four idioms (§P.23) |
| **W.7** game type `camelot`, no `WOW_PROJECT_*` | §10 | **Confirmed.** Exactly three constants, `WOW_PROJECT_ID` = 1 = `WOW_PROJECT_MAINLINE`. And `CamelotBankPanelItemButtonMixin` is in `_G`, which is the codename from inside the running client (§P.24) |
| **W.8** the Secret surface is countable from the documentation | §13 | **Confirmed in substance, better than reported.** 5,145 of 29,416 entries, across **38 distinct keys** — a taxonomy, not a boolean. The reported 4,025 does not reproduce exactly (§P.26) |
| **W.9** a claim that health is secret always | §14 | **Confirmed, and it corrected us.** `UnitHealth("player")` is secret out of combat, `type()` reports `"number"`, and comparison, arithmetic and equality all throw. `research/restrictions.yaml` gained a `unit-health-secrecy` entry and lost a wrong `UnitPowerMax` claim (§P.25) |

Two lessons worth keeping.

**W.9**: the least credible source in the batch — an unbylined site — was right about a
specific, testable thing this repo had wrong. Its credibility decided how it was labelled,
not whether it was tested.

**W.1**: a lead can be right about the shape of a thing and wrong about every particular.
The folders it named do nothing, but "the client reads some saved variables and not
others" was correct — the split is account-wide versus per-character. Testing the shape
rather than the detail is what found it.

**And a lesson about this repo's own process.** §P.27 was written twice and wrong the
first time, because the first run measured across `/reload`s and the conclusion was stated
as though it covered logging out. The fix was not a better source, it was one more run
under the other condition. When a result arrives that changes guidance, the question to
ask before writing it up is which conditions it was actually taken under.
