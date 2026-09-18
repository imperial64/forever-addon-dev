# Secret values

Some reads return a value your addon is not allowed to look at. The function still exists,
still succeeds, and hands you something that looks ordinary until you touch it.

## The contagion problem

**`tostring()` does not launder a secret.** It returns a *secret string*. The taint
survives conversion, so this pattern — which looks careful — is not:

```lua
local ok, text = pcall(function() return tostring(UnitPower("player")) end)
-- ok == true, and `text` is a secret string
print(text:sub(1, 10))   -- throws HERE, far from the read
```

Worse: a secret string written into SavedVariables takes the **entire flush** with it. One
unguarded read can cost an addon all of its saved data.

### The safe conversion

```lua
local function plain(v)
    if issecretvalue and issecretvalue(v) then return "<SECRET>" end
    local ok, str = pcall(tostring, v)
    if not ok then return "<UNPRINTABLE>" end
    -- tostring() of a secret is itself secret, so re-test after converting.
    if issecretvalue and issecretvalue(str) then return "<SECRET>" end
    local okCut, cut = pcall(string.sub, str, 1, 200)
    return okCut and cut or "<SECRET>"
end
```

Test **before and after** conversion, and contain the indexing, which is the operation that
actually throws.

The client provides the whole family: `issecretvalue`, `issecrettable`,
`hasanysecretvalues`, `scrub`, `scrubsecretvalues`, `canaccesssecrets`, `secretwrap`,
`dropsecretaccess`.

## What is secret, and when

Gates are `C_Secrets` functions you can query directly.

| Category | Out of combat | In combat |
|---|---|---|
| Auras | readable | **secret** (and they *throw*) |
| Cooldowns | readable | **secret** |
| Action cooldowns | readable | **secret** |
| Unit stats | readable | **secret** |
| Threat values | — | **secret** |
| **Unit power** | **secret** | **secret** |
| Unit identity | readable | readable |
| Max health | readable | readable |
| Spell casts | readable | readable |
| Threat state | — | readable |

Two things worth pulling out of that table:

- **`UnitPower` is secret at all times**, including standing still doing nothing. Blizzard's
  published doctrine explicitly promises that class secondary resources "remain fully
  non-secret". On this client they are the one thing that never is.
- **Threat state is readable while threat values are not.** An addon may know *whether* it
  has aggro, not by how much. That kills the numeric threat meter and leaves the "you are
  about to pull" warning working — which does not look accidental.

## Auras throw rather than returning nil

```
GetAuraDataByIndex(): Auras cannot be accessed when secret while tainted by 'YourAddon'
```

Note **"while tainted by"**. The restriction is scoped to the **call stack**, not to the
data — Blizzard's own UI reads those same auras in that same combat. Your addon is refused
because the stack is yours.

**Workaround:** read before the pull and hold the value, or hand a duration object to a
`Cooldown` widget before combat and let it keep ticking. The sanctioned cooldown path is
`C_Spell.GetSpellCooldownDuration(id)` → `LuaDurationObject` →
`Cooldown:SetCooldownFromDurationObject(obj)`, which never requires addon code to read the
number.

## Asking whether you are restricted

Unlike the rest, this one is queryable:

```lua
C_RestrictedActions.IsAddOnRestrictionActive()  -- false out of combat, true in it
C_RestrictedActions.GetAddOnRestrictionState()  -- 0 out of combat, 2 in it
```

Check it before attempting work, rather than inferring your situation from a masked value.

## Evidence

Measured 2026-09-18 on client 1.60.1 build 69913. `research/findings.md` P.2 (contagion),
P.3 and P.10 (out-of-combat gates), P.18 and P.19 (the combat delta and the refusal shapes).
