# Test plan: one play session on Forever beta build 1.60.1.70009

**Status: not yet run.** This is a set of instructions, not a result. Nothing here is a finding
until the pasted output and the captures come back and are written up in `research/findings.md` §P.

It settles four open inbox items in one session, with two client launches:

| Item | Question | Instrument |
|---|---|---|
| W.32 | Does 70009 read SavedVariables back after a full exit and a relaunch through Battle.net, account-wide and per-character? | `/fprobe cold seed`, `/fprobe cold`, companions `ForeverProbeSV_First` / `ForeverProbeSV_Late` |
| W.30 | Does `## LoadSavedVariablesFirst: 1` move the restore ahead of file scope, and which file-scope idiom survives with and without it? | same, `Clobber` / `OrInit` columns |
| W.33, W.12 | Do secure snippets run on 70009 out of combat (expect `42`)? Does the SecureHandlers API raise in combat? | `/fprobe snippet` |
| W.34 | A fresh surface dump, build number and date, and the reference version check, on 70009 | `/fprobe`, `/fprobe port`, `/fprobe docs version` |

It also answers whether CLAUDE.md's "both passes in one session" constraint still applies: the
`[Probe]` rows of `/fprobe cold` show whether `ForeverProbeDB` and `ForeverProbeChar` came back.

## What was built for it

- `addons/ForeverProbeSV_First/`: has `## LoadSavedVariablesFirst: 1`.
  `addons/ForeverProbeSV_Late/`: the same without it. They are identical apart from that one
  `.toc` line and the global names in `Init.lua`. `Core.lua` is byte-identical in both, and
  `install-addon.ps1` refuses to install if the two copies differ. Each declares six saved globals:

  | Column | Global | Scope | How it is bound |
  |---|---|---|---|
  | `DB` | `<addon>DB` | account | on `ADDON_LOADED`, `X = X or {}` |
  | `Char` | `<addon>Char` | character | on `ADDON_LOADED` |
  | `Clob` | `<addon>Clobber` | account | file scope, `X = { fresh = true }` unconditionally |
  | `OrIn` | `<addon>OrInit` | account | file scope, `X = X or { fresh = true }` |
  | `cClob` | `<addon>CharClobber` | character | as `Clob` |
  | `cOrIn` | `<addon>CharOrInit` | character | as `OrIn` |

  Each companion inspects all six at `fs-before` (file scope, before `Init.lua` assigns
  anything), `fs-after`, `ADDON_LOADED` (before binding), `PLAYER_LOGIN` and `ENTERING_WORLD`.
  It also keeps the last six loads' observations in its own `DB.observed`.
- `ForeverProbe` gained:
  - `/fprobe cold seed [reload]` and `/fprobe cold [token]`.
  - `/fprobe snippet`.
  - `/fprobe copy`, which shows the transcript of everything the probe printed in a selectable
    box. WoW chat cannot be copied, so this is how output gets pasted back.
  - A buildDate in the surface dump's `build` record.
  - A rebind guard. If 70009 restores `ForeverProbeDB` after the probe's file scope, `db` is
    re-pointed at the restored table and the swap is recorded as `rebind`. Without it, this
    session's surface dump would go into an orphan table and never reach the capture.

## Cell legend for `/fprobe cold`

`C` = the cold token is present. `R` = the reload token is present. `x` = a cold token other than
the one you passed. `f` = the fresh table from the addon's own file scope. `e` = an empty table
(bound by the addon, nothing restored). `-` = the global is nil. A trailing `*` means a different
table from the phase before: the global was replaced, not mutated.

The `directive=` field is whatever `GetAddOnMetadata` returns for `LoadSavedVariablesFirst`. A
`nil` there only means the client does not expose that field to Lua. The phases decide whether the
directive worked; that field does not.

---

## 0. Pre-flight (PowerShell, client closed)

Run from the repo root, `F:\Projects\forever-addon-dev`.

**0.1 Locate the install and confirm the client is not running.**

```powershell
$wow  = @("C:\Program Files (x86)\World of Warcraft","C:\Program Files\World of Warcraft","D:\World of Warcraft","D:\Games\World of Warcraft","E:\World of Warcraft","F:\World of Warcraft","F:\Games\World of Warcraft") | Where-Object { Test-Path $_ } | Select-Object -First 1
$beta = Join-Path $wow "_classic_beta_"; $beta
Get-Process Wow* -ErrorAction SilentlyContinue
```

Expected: the path to `_classic_beta_` prints, and `Get-Process` prints nothing. If the install is
elsewhere, set `$wow` by hand and pass `-WowRoot $wow` to every script below.

**0.2 No SavedVariables workaround installed.** ForeverSVFix, WTFix and svshim (W.11, W.19)
re-inject saved data from outside the client. Any one of them would make a failed read-back look
like a success.

```powershell
Get-ChildItem "$beta\Interface\AddOns" -Directory | Where-Object Name -match 'SVFix|WTFix|svshim'
Select-String -Path "$beta\Interface\AddOns\*\*.toc" -Pattern 'SavedVariablesLink|SVFixData|ForeverSVFix|WTFix|svshim' | Select-Object Path, LineNumber, Line
Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object TaskName -match 'svshim|WTFix|SVFix'
Get-CimInstance Win32_Process | Where-Object CommandLine -match 'svshim|WTFix|SVFix' | Select-Object ProcessId, CommandLine
```

Expected: all four print nothing.
- If a folder is listed, move it out of `Interface\AddOns`. Disabling it is not enough, because
  ForeverSVFix edits other addons' `.toc` files.
- If a `.toc` line is listed, delete that line, or reinstall that addon from a clean copy. W.31's
  manual `SavedVariablesLink.lua` line is one of these.
- If a task or process is listed, stop it (`Stop-Process -Id <id>`, `Disable-ScheduledTask`).

**0.3 No symbolic links or junctions in WTF or AddOns** (W.31's `mklink` route, ForeverSVFix's
junctions):

```powershell
Get-ChildItem "$beta\WTF\Account", "$beta\Interface\AddOns" -Recurse -Force -Attributes ReparsePoint -ErrorAction SilentlyContinue | Select-Object FullName, LinkType, Target
```

Expected: nothing. Any `SymbolicLink` or `Junction` listed under a `SavedVariables` folder, or
inside an addon folder, must be removed first. Remove the link only (`Remove-Item <path>` on the
link), not the file it points at.

**0.4 Inventory of the probe's existing saved files** (for comparison, and to name the leftovers):

```powershell
Get-ChildItem "$beta\WTF" -Recurse -Force -Filter "ForeverProbe*.lua" | Select-Object FullName, Length, LastWriteTime
```

Expected: the account-scoped `...\Account\<ACCOUNT>\SavedVariables\ForeverProbe.lua`, the
per-character `...\<realm>\<character>\SavedVariables\ForeverProbe.lua`, and two seed files from
2026-09-20 at `WTF\Account\SavedVariables\ForeverProbe.lua` and `WTF\SavedVariables\ForeverProbe.lua`.
There should be no `ForeverProbeSV_*` files yet. **Leave the two seed files where they are.** They
are the W.3 path control: if `/fprobe sv` ever reports `SEEDED FILE READ`, 70009 reads one of those
paths. **Do not run `seed-savedvars.ps1` in either mode.** Seeding overwrites the real
account-scoped `ForeverProbe.lua`. `-Restore` would move the client's own `.bak` over the current
file.

**0.5 Other addons.** On the character screen at step 2.1, disable every addon except the three below.
That keeps `/fprobe blocked` attributable and removes any other SV-touching code.

## 1. Install

**1.1**

```powershell
.\scripts\install-addon.ps1
```

Expected: `ForeverProbe - Lua syntax OK (luajit (5.1))`, then the same for `ForeverProbeSV_First`
and `ForeverProbeSV_Late`, then three `Installed ... -> ...\Interface\AddOns\<name>` lines. An error
saying the two `Core.lua` files differ means the repo copies drifted. Copy
`addons\ForeverProbeSV_First\Core.lua` over the `_Late` one and rerun.

**1.2 The in-combat macro.** Step 4.5 has to run while the character is in combat, so make it one
keypress. Do this in game right after logging in at step 2.1: Esc > Macros > New, name `FPS`, body
`/fprobe snippet`, then drag it to an action bar slot. The macro survives the relaunch.

## 2. Session 1: seed, snippet out of combat, surface dump

**2.1** Launch through Battle.net > WoW Forever beta > Play. On the character screen, open AddOns
and enable `ForeverProbe`, `Forever Probe SV (first)` and `Forever Probe SV (late)`. Tick "Load out
of date AddOns" if they show as out of date. Log in the test character somewhere quiet.

Expected: `FProbe loaded. /fprobe out of combat, then /fprobe combat mid-fight.` About a second
later: `API reference is behind this client - build 69913 -> 70009`, which is expected. If a
"blocked from an action" popup appears, press **Ignore**.

**2.2** `/fprobe port`

Expected: `GetBuildInfo(): version 1.60.1  build 70009  date <date string>  interface 16001`, and
`%d%02d%02d of 1.60.1 = 16001 -> matches the client's own interface number`. **If the build is
not 70009, stop.** This plan is for 70009.

**2.3** `/fprobe docs version`

Expected: `API reference is behind this client - build 69913 -> 70009`, unless a regenerated
reference was installed in the meantime. In that case expect `API reference matches this client`.

**2.4** `/fprobe sv`

This first launch is itself a cold start: 70009 reading files that 69913 wrote on 2026-09-20. The
old per-global lines are the evidence.
- If W.32 holds: `ForeverProbeBind` and `ForeverProbeChar` read `RESTORED last session's token ...`.
- If §P.27 still holds: both read `fresh, N key(s)`.

The load-order line reads `saved-variables-restored-AFTER-addon-lua` if `ForeverProbeDB` was
replaced after file scope.

**2.5** `/fprobe cold`

This is the companions' baseline. No file exists for them yet, so nothing can be restored. Expected
for both `[First]` and `[Late]`:

```
    phase           DB    Char  Clob  OrIn  cClob cOrIn
    fs-before       -     -     -     -     -     -
    fs-after        -     -     f     f     f     f
    ADDON_LOADED    -     -     f     f     f     f
    PLAYER_LOGIN    e     e     f     f     f     f
    ENTERING_WORLD  e     e     f     f     f     f
    cold token first seen: DB@none Char@none ...
```

The `[Probe]` rows and the line `ForeverProbeDB replaced after file scope: true|false` also record
how 70009 treated the probe's existing file at this launch.

**2.6 Reload leg.** Kept apart from the cold-start leg by using a different marker field.

1. `/fprobe cold seed reload`. Expected:
   `COLD-START SEED  leg=reload  token=<R>`, then `companions: First 6/6, Late 6/6`, then
   `probe: ProbeDB ok, ProbeChar ok`. Note `<R>`.
2. `/reload`
3. `/fprobe cold <R>`. Expected: `initialLogin=false reloadingUi=true` on both companions.
   - If the reload restores everything, `R` appears in every column: from `fs-before` for
     `[First]`, and from `ADDON_LOADED` (with `*`) for `[Late]`.
   - The §P.27 pattern on 69913 would be `R` in the per-character columns only.

   Do not seed the cold leg before this step.

**2.7** `/fprobe`: the surface dump and action tests.

Expected:
- The first line is `build 1.60.1 (70009) <date> toc 16001`.
- Then `read/execute/secure/channel N/M present`, and the `EXTERNAL` line.
- Then `global dump: <N> functions, <M> C_ namespaces`. Note N and M. W.34 predicts new `C_Flyout`
  and `C_NameUtil`.
- Then the action tests.

Forbidden-action popups are expected here: press **Ignore** each time.

**2.8** `/fprobe snippet`: out of combat. Expected:

```
SECURE SNIPPET  out of combat  build 70009
  type(loadstring_untainted)=nil  type(loadstring)=function  type(SecureHandlerExecute)=<function|nil>
  Base         create=ok exec=ok via frame:Execute fbok=42 (want 42) blocks=0
  Attr         create=ok exec=ok via frame:Execute fbok=42 (want 42) blocks=0
```

W.33 predicts exactly this. `fbok=nil` or `false` with `exec=ok` means the snippet did not run,
which is the pre-70009 behaviour. `exec=RAISED` prints the error text on the next line.

**2.9** `/fprobe blocked`: the list of every block so far, each attributed to a test.

**2.10 Cold seed. This must be the last command before exiting.**
`/fprobe cold seed`

Expected: `COLD-START SEED  leg=cold  token=<C>`, `companions: First 6/6, Late 6/6`,
`probe: ProbeDB ok, ProbeChar ok`, then `WRITE THE TOKEN DOWN`. **Write `<C>` down.** It looks like
`1790330000-2`. From here until the exit, do not `/reload`.

**2.11** `/fprobe copy`, then Ctrl+C, then Escape. Paste the text into a new file, e.g.
`Desktop\70009-s1.txt`. This is paste-back item 1. Opening the box does not reload anything.

**2.12** `/quit` (or Menu > Exit Game). The client writes every SavedVariables file on the way out.

## 3. Between sessions (PowerShell)

**3.1** Confirm that the client has fully exited:

```powershell
Get-Process Wow* -ErrorAction SilentlyContinue
```

Expected: nothing. Wait and repeat if it is still there. Battle.net itself may stay open.

**3.2** Collect what session 1 wrote:

```powershell
.\scripts\collect-savedvars.ps1 -Label 70009-s1
```

Expected: `Collected ...` and `-> research\captures\...` for six files: `ForeverProbe`,
`ForeverProbeSV_First` and `ForeverProbeSV_Late`, each account-wide and `_<Character>`. You may also
get the `_SavedVariables` leftover from 0.4. Under the quick look, each of the six should show
`coldToken values <C>` in yellow, and the `ForeverProbe` account file should show
`globalFunctions present`, `snippet present` and `buildDate present`.

**This proves the write side.** If `<C>` is missing from any file here, the flush failed, not the
read. Stop and paste this output back before going further.

## 4. Session 2: relaunch through Battle.net and read

**4.1** Battle.net > Play. Log in the **same character**. Do not `/reload` before 4.2.

**4.2 The result.** `/fprobe cold <C>`

`initialLogin=true reloadingUi=false` on both companions confirms this load is a cold start. What
the rows mean:

| Outcome | `[First]` | `[Late]` | Reading |
|---|---|---|---|
| A. Fixed, and the directive works as Blizzard's own damage meter implies | `C` from `fs-before` in every column. `Clob` and `cClob` turn `f*` at `fs-after` (verdict `@fs-before->lost`), and `OrIn`/`cOrIn` keep `C` | `-` at `fs-before`, `f` at `fs-after`, `C*` at `ADDON_LOADED` in every column | W.32 and W.30 both confirmed. The default is retail's order (restore after file scope) and the directive opts in to before |
| B. Fixed, and the restore always comes first | as A | `C` already at `fs-before`, and `Clob`/`cClob` lost like `[First]` | The directive has no effect, because restore-first is the default |
| C. Fixed for one scope only | `C` only in the account columns, or only in the character columns | same | Partial fix. Name the scope that works |
| D. Not fixed | no `C` anywhere. `DB`/`Char` read `e` from `PLAYER_LOGIN`, and `Clob`/`OrIn` read `f` | same | W.32 is wrong for this install, and §P.27 stands |

`x` in any cell is a token from a different seed: an older run, or a wrong token typed.

The `[Probe]` rows answer the one-session constraint:
- `C` in `DB` and `Char` means both of the probe's files came back.
- `ForeverProbeDB replaced after file scope: true` means the rebind guard fired. That is retail's
  order, and without the guard this session's writes would have been lost.
- `surface dump from before present: true` means session 1's `/fprobe` survived the exit.

If all three hold, CLAUDE.md's one-session constraint no longer applies on 70009.

**4.3** `/fprobe sv`: the older instrument's reading of the same cold start. `ForeverProbeBind`
(account) and `ForeverProbeChar` (character) should read `RESTORED` under outcome A or B.

**4.4** `/fprobe snippet`: out of combat, again. This creates this session's frames; frames made in
session 1 do not survive the relaunch. Expected: `fbok=42` on `Base` and `Attr`, as in 2.8.

**4.5** Pull one mob, something low-level that cannot kill the character. While the character is in
combat, press the `FPS` macro from 1.2 (or type `/fprobe snippet`). Press **Ignore** on any popup.
Expected shape:

```
SECURE SNIPPET  IN COMBAT  build 70009
  ...
  Base reused  create=reused exec=<ok|RAISED> via frame:Execute fbok=<43|42> (want 43) blocks=<n>
    error: <exact text, if raised>
    ADDON_ACTION_BLOCKED:<func>   (one line per block)
  Base fresh   create=<ok|RAISED ...> exec=... fbok=<44|nil> (want 44) blocks=<n>
  Attr reused  ...
  Attr fresh   ...
```

- W.12 predicts `exec=RAISED`, with the error text on the next line.
- `exec=ok` with `fbok=42` on a reused frame means `Execute` returned without running.
- `fbok=43` or `44` means snippets run in combat.
- `combat ended during the run` means the fight ended too early. Pull again and repeat.

Then finish the fight.

**4.6** `/fprobe blocked`: every block with the test that caused it, including any
`snippet:combat:...` entries.

**4.7** `/fprobe copy`, then Ctrl+C, then Escape. Paste into `Desktop\70009-s2.txt`. This is
paste-back item 2.

**4.8** `/quit`. Then in PowerShell:

```powershell
Get-Process Wow* -ErrorAction SilentlyContinue
.\scripts\collect-savedvars.ps1 -Label 70009-s2
```

Expected: the same six files with `70009-s2` in the name. Under outcome A or B, `coldToken values`
still shows `<C>` for the columns that kept it. Under A, the `[First]` `Clobber` files no longer
carry `<C>`: the clobbered fresh table is what was written. The `ForeverProbe` account file shows
`snippet present` and `coldTest present`.

## 5. What to paste back

1. **`70009-s1.txt`**, from step 2.11. It must contain these blocks:
   - `INTERFACE VERSION`, from `/fprobe port`
   - the `API reference ...` line from `/fprobe docs version`
   - `SAVEDVARIABLES`, from `/fprobe sv`
   - two `COLD-START REPORT` blocks: the baseline from 2.5 and the reload leg from 2.6
   - the `build 1.60.1 (70009) ...` line and the `global dump:` line from `/fprobe`
   - `SECURE SNIPPET  out of combat`
   - `BLOCKED / FORBIDDEN`
   - `COLD-START SEED  leg=cold  token=<C>`
2. **`70009-s2.txt`**, from step 4.7. It must contain these blocks:
   - `COLD-START REPORT ... expecting <C>`: the result
   - `SAVEDVARIABLES`
   - `SECURE SNIPPET  out of combat` and `SECURE SNIPPET  IN COMBAT`
   - `BLOCKED / FORBIDDEN`
3. **The console output of both `collect-savedvars.ps1` runs**, from 3.2 and 4.8, including the
   yellow `coldToken values` lines.
4. Anything odd that the probe cannot see, such as an error dialog's full text or a popup you did
   not press Ignore on.

If the copy box fails to open (`copy box could not be built`), the same transcript is in the
captures under `ForeverProbeDB.transcript`. Items 1 and 2 can then be skipped, and the captures
carry the result.

## 6. Capture files produced

`<stamp>` is `yyyy-MM-dd_HHmmss` at collection time. `<Character>` is the WTF folder name, e.g.
`Abla-Imperial`. All files are in `research/captures/`:

| File | What it carries |
|---|---|
| `ForeverProbe_<stamp>_70009-s1.lua` | Surface dump (`globalFunctions`, `namespaces`); `build` with `buildDate` and `surfaceAt`; `port`; `docsVersion`; `savedVars`; `snippet.outOfCombat`; `coldTest` (seeds and the two reports); `rebind`; `blockLog`; `transcript`. **This is the `--surface` input for 70009** |
| `ForeverProbe_<stamp>_70009-s1_<Character>.lua` | `ForeverProbeChar`, with `coldTest` markers |
| `ForeverProbeSV_First_<stamp>_70009-s1.lua`, `..._<Character>.lua` | The First variant's six globals, marker fields, and `DB.observed` (per-load phase records) |
| `ForeverProbeSV_Late_<stamp>_70009-s1.lua`, `..._<Character>.lua` | The same for Late |
| `ForeverProbe_<stamp>_70009-s1_SavedVariables.lua` | The 2026-09-20 seed leftover at `WTF\Account\SavedVariables\`, if it is still there |
| the same six (or seven) with `70009-s2` | Session 2: `coldTest.reports` with the cold-start result, `snippet.outOfCombat` and `snippet.inCombat`, `rebind`, `blockLog`, `transcript`. Under outcome A or B, session 1's surface dump is still in the account file |

The `WTF\SavedVariables\ForeverProbe.lua` seed is outside `WTF\Account` and is never collected. It
does not need to be.

## Known limits of this plan

- **Leaving the game is not the same as killing it.** A `/quit` exit and relaunch is what W.32
  describes. A crash, Alt+F4 or task-manager kill does not flush, and would show as outcome D for
  the wrong reason. Step 3.2 catches that, because the token would be missing on disk.
- **An unfinished fight gives no in-combat result.** The in-combat leg needs the whole
  `/fprobe snippet` to run in combat. The macro exists for that reason, and the command reports it
  when combat ended mid-run.
- **The directive readback proves nothing on its own.** `directive=nil` is expected: most clients
  do not expose non-`X-` `.toc` fields to `GetAddOnMetadata`.
