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

---

## Closed

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
