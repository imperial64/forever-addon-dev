# What things cost on this client

Measured, like everything else here, rather than assumed. The numbers come from a
microbenchmark run on the beta client — `debugprofilestart` / `debugprofilestop` around an
adaptively sized loop, loop overhead subtracted, five runs across graphics presets and
frame-rate caps.

This page is the prose version. The data itself lives in `research/costs.yaml`, which is
where a new measurement goes; `reference/api/COSTS.md` and the `COST` banners on individual
API pages are generated from it, and `research/findings.md` §Q is the measurement record
behind it. Costs are deliberately kept out of the restriction list: nothing on this page is
refused, and these numbers go stale in a way the restriction data does not.

**These are dated in a way the rest of this reference is not.** The API pages regenerate
from your own client; these numbers do not. Treat them as an order of magnitude that held
on one machine at build 69913, and re-measure before building anything that depends on the
exact figure.

## The short version

| Call | Time per call | Allocation per call |
|---|---|---|
| `C_Map.GetPlayerMapPosition` | 4.4 – 5.7 µs | **1864 bytes** |
| …including `GetXY()` to get two numbers | 4.9 – 7.9 µs | as above |
| `UnitPosition` | not benched | **none** |
| `C_Map.GetBestMapForUnit` | 0.61 – 0.64 µs | none measurable |
| `C_CVar.SetCVar`, value changed | 0.79 – 0.82 µs | **~822 bytes** |
| `C_CVar.SetCVar`, value unchanged | 0.30 – 0.32 µs | not separately measured |

Time is not the interesting column. Everything here is sub-10 µs against a 3.6 ms frame at
274 fps. **The allocation is the interesting column**, and it is the one that catches people
out, because the two do not correlate: a CVar write is one of the cheapest calls here in
time and one of the more expensive in garbage.

One thing to know before you trust any of these: this client runs the **plain Lua 5.1
interpreter, not LuaJIT**. That is what makes `collectgarbage("stop")` a valid guard, and
it is why these byte figures mean anything. Measured — `_VERSION` is `Lua 5.1`, and `jit`,
`ffi`, `table.new` and `string.buffer` are all absent. (`_VERSION` alone would not settle
it: LuaJIT also reports `Lua 5.1`. Neither would `bit`, which both ship.)

## Reading player position is a garbage problem, not a time problem

`C_Map.GetPlayerMapPosition` returns a position object exposing `GetXY()`, and building it
costs 1864 bytes — identical in all five runs, so this is the shape of the object, not
measurement noise.

| Poll rate | Garbage |
|---|---|
| every frame at 120 fps | ~218 KB/s |
| every frame at 274 fps | ~500 KB/s |
| 10 Hz on an accumulator | ~18 KB/s |

So poll on an accumulator:

```lua
local ACCUM, POLL = 0, 0.1   -- seconds
frame:SetScript("OnUpdate", function(_, elapsed)
    ACCUM = ACCUM + elapsed
    if ACCUM < POLL then return end
    ACCUM = 0
    local pos = C_Map.GetPlayerMapPosition(uiMapID, "player")
    if not pos then return end          -- nil inside instances on retail; not measured here
    local x, y = pos:GetXY()
    -- ...
end)
```

`C_Map.GetBestMapForUnit` is cheap enough not to matter, but it is still a map-tree lookup:
put it behind a zone-change event rather than inside the poll.

Two things worth knowing about that call before you build on it:

- **Walking indoors does not break it.** Inside a building in the open world it returns an
  ordinary point on the parent map, with the uiMapID unchanged. The retail caveat about
  instances is a different case and is still unmeasured here.
- **`UnitPosition` allocates nothing**, so if what you actually want is *world* coordinates
  rather than a normalized position on a map, the garbage problem above disappears. It is
  not a drop-in substitute: different coordinate space, and its instance behaviour and
  combat availability are unmeasured here. Its **return order is also unsettled** — the
  client documents `positionX, positionY, positionZ, mapID`, while retail's community
  documentation has long said the first two arrive *Y then X* regardless of those names.
  Nothing here measured which holds. Check it against a known landmark before you trust it;
  getting it backwards gives you a position that is wrong and still looks plausible.

## Writing CVars is cheap in time and expensive in garbage

§P.22 established that driving `Brightness` from `OnUpdate` for four seconds produced no
frame-gap spike, and a later run drove **both** `Brightness` and `Contrast` every frame at
290 fps — 581 writes a second — with a worst frame gap of 9 ms. The per-call figure says
why: a write with a changed value is under a microsecond, and a write with the same value is
a third of that. One changed write per frame is about 0.02% of a frame at 274 fps.

A write is a live post-process, not a device restart, so a smooth ease is possible. **And
CVar writes are permitted in combat** — measured in both states one pull apart, with no
`ADDON_ACTION_BLOCKED` or `ADDON_ACTION_FORBIDDEN` captured in either. That was an open
caveat in an earlier version of this page. Only `Brightness` and `Contrast` were tested, and
only in open-world combat; see `restrictions/` for what is and is not writable.

**The cost that does constrain you is allocation.** Every write allocates about 822 bytes:

```
C_CVar.SetCVar(name, "50.00")   -- 822 bytes
C_CVar.SetCVar(name, 50.0)      -- 827 bytes  (a number does not help)
("%.2f"):format(v)              --  38 bytes  (so the call itself is ~784)
```

Passing a number instead of a preformatted string does not avoid it — the conversion happens
inside the call. At a realistic ~35 writes/s from `OnUpdate` that is roughly 28 KB/s, or
~99 MB/hour, **per CVar you drive**. Driving two is twice that.

So the lever is the write *rate*, not the write. An epsilon skip — don't write unless the
value actually moved by something visible — or an accumulator costs you nothing in smoothness
and takes the garbage with it. Measured on `Brightness` only; treat 822 as an order of
magnitude for a CVar write rather than a constant.

## Do not profile with `OnUpdate` elapsed

The `elapsed` argument this client hands an `OnUpdate` script is **quantised to 1 ms**.
Accumulating it to time your own work gives you noise that looks like data for anything
under about a millisecond — which is most of what an addon does.

Easing on `elapsed` is unaffected: 1 ms is far below the time constants in any animation
you would write.

For actual measurement, the primitives are present and working:

```lua
debugprofilestart()
-- the thing you are timing, looped enough times to clear the quantisation
local ms = debugprofilestop()   -- microsecond resolution
```

`collectgarbage("count")`, `("stop")`, `("restart")` and `("collect")` all work too, and
behave as Lua 5.1 documents. If you are measuring allocation, **stop the collector first** —
a collection inside your measuring loop reads as a negative delta and reports that the call
allocates nothing.

One more trap in the same place: **formatting the same value repeatedly measures nothing**,
because Lua interns the result and the second call onwards allocates zero. Vary the input,
or you will conclude that string formatting is free. That hid the 38-byte figure above the
first time it was measured.

## Two habits this suggests

1. **Anything that reads the game every frame deserves a second look**, and an accumulator
   is usually the whole fix. The cost is rarely the arithmetic; it is the object the API
   hands you.
2. **Measure before optimising, but not with `elapsed`.** The instrument with the resolution
   is `debugprofilestop`, and it has to loop the call enough times to clear the noise.
