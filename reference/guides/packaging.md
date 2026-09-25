# Shipping an addon: the `.toc`, the interface number, and detecting this client

Everything on this page comes from two maintained retail addons that added Forever support
in the first days of the beta, plus a reading of Blizzard's own `forever` branch. Sources
and quotes are in `research/findings.md` §9 and §10. Nothing here needed a running client,
which is why it is guidance rather than a measurement.

## The header, and the rule that costs a day

```
## Interface: 16001, 120100, 110200
## Title: My Addon
## Notes: What it does.
## SavedVariables: MyAddonDB
## SavedVariablesPerCharacter: MyAddonCharDB

MyAddon.lua
```

**Directives must be contiguous.** The header ends at the first line that is not a `##`
directive. A blank line in the middle of it means every directive after that point is
silently ignored — one porter put a blank line above `## SavedVariables` and lost all of
their addon's saved data at login, with no error anywhere. The linter reports this as
`toc-header-break`, an error.

Comments and file entries go *below* the header, not inside it.

**`## LoadSavedVariablesFirst: 1` is a real directive on this client.** Measured on build
70009, it moves the SavedVariables restore from `ADDON_LOADED` to before your files run.
That changes which file-scope idiom destroys saved data. Leave it out unless you need saved
values at file scope, and read `guides/savedvariables.md` before adding it
(`research/findings.md` §P.31).

## One `.toc`, every flavour

`## Interface` takes a comma-separated list, so one file covers Forever and both retail
lines at once. RPGLootFeed ships "a single TOC carrying all six interface versions; no
per-flavor TOC splitting is involved". Do not split into `-Mainline.toc` / `-Classic.toc`
for Forever's sake.

## Where 16001 comes from

It is derived, not assigned. `BuildInfo.GetInterfaceVersion` formats `%d%02d%02d`, so
version **1.60.1 → 16001**. It moves when the version triple moves, so an addon that
hardcodes `16001` is hardcoding 1.60.1 rather than "Forever". `/fprobe port` recomputes the
formula against the client's own `GetBuildInfo()` and reports a disagreement.

## The gotcha in your build tooling, not your addon

**16001 is numerically below every live product.** Retail is 120100 and climbing; Classic
Era is 11507; the Anniversary line is 50504. Any tool that compares interface numbers
ordinally — a nightly `.toc` updater, a CI compatibility gate, a "is this addon current"
check — will treat Forever as *older* than whatever it already supports and do nothing.

This is the failure that is worth writing on a sticky note, because it reports success.
RPGLootFeed's nightly updater "skips a beta whose interface is numerically lower than its
live product (50504 > 16001), so the nightly toc-updater reports no updates".

Nothing in this repo can lint that for you: it lives in your CI, not in your addon. Check
it by hand once.

The in-addon version of the same mistake — `select(4, GetBuildInfo()) >= 100000` as a
"modern client" test — *is* linted, as `version-check-trap`. See `guides/pitfalls.md`.

## You cannot detect Forever from Lua

There is **no `WOW_PROJECT_*` constant for Forever**. The client reports
`WOW_PROJECT_MAINLINE`, the same value retail reports, so:

```lua
-- Both of these are wrong on this client.
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then  -- true here AND on retail
if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then   -- false, on a Classic-line client
```

The linter flags `WOW_PROJECT_ID` comparisons as `project-id-detection`.

The client's own game type is **`camelot`**, and Blizzard's modules gate on a `.toc`
directive rather than a runtime test:

```
## AllowLoadGameType: standard, camelot
```

That is a load-time declaration, and Blizzard using it in their own modules does not prove
the client honours it from a third-party addon — that is unmeasured. If you need a runtime
test today, the interface version is the honest one:

```lua
local interface = select(4, GetBuildInfo())
local isForever = interface >= 16000 and interface < 20000
```

which is the bracket another porter settled on for the same reason. It is a bracket, not an
identity: it will also match a future 1.7x build, which is usually what you want.

## Distribution

CurseForge carries a distinct **Forever flavour** with its own download channel, live since
2026-09-18.

**Releasing with the BigWigs packager** (`BigWigsMods/packager@v2`) works for Forever. The
evidence is a reading of its `release.sh` on 2026-09-25 plus one real run: the
dynamic-ambiance-forever addon's v0.3.0 and v0.3.1 releases, the same day. `release.sh` maps
`## Interface: 16???` to game type `forever`. The v0.3.0 run built
`DynamicAmbiance-v0.3.0-forever.zip`, created the GitHub Release, and wrote
`"flavor":"forever","interface":16001` to `release.json`. The v0.3.1 run also uploaded to
CurseForge and Wago, both as game version `1.60.1`. Where the packager can publish a Forever
build:

| Site | Forever | Source |
|---|---|---|
| GitHub Releases | yes | the v0.3.0 and v0.3.1 runs |
| CurseForge | yes, game id `88568` | the v0.3.1 run |
| Wago | yes, type `forever` | the v0.3.1 run |
| WoWInterface | **no**: "No WoWInterface game type match for \"forever\"", and the run fails if `## X-WoWI-ID` is set | `release.sh` |

The workflow, `.pkgmeta` for an addon in a subfolder, `@project-version@`, cutting a
release, and creating the CurseForge and Wago projects are in the `publish` skill
(`skills/publish/SKILL.md`).

## Related

- `guides/getting-started.md` — your first addon, installing it, enabling it
- `guides/pitfalls.md` — the runtime traps, all measured
- `research/findings.md` §9, §10, §11 — the sources, quoted and credited
