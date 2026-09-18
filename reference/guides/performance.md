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
| `C_Map.GetBestMapForUnit` | 0.61 – 0.64 µs | none measurable |
| `C_CVar.SetCVar`, value changed | 0.79 – 0.82 µs | — |
| `C_CVar.SetCVar`, value unchanged | 0.30 – 0.32 µs | — |

Time is not the interesting column. Everything here is sub-10 µs against a 3.6 ms frame at
274 fps. **The allocation is the interesting column.**

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

## Writing CVars is affordable at frame rate

§P.22 established that driving `Brightness` from `OnUpdate` for four seconds produced no
frame-gap spike. The per-call figure says why: a write with a changed value is under a
microsecond, and a write with the same value is a third of that. One changed write per
frame is about 0.02% of a frame at 274 fps.

A write is a live post-process, not a device restart, so a smooth ease is possible. See
`restrictions/` for what is and is not writable, and note that CVar writes have **not** been
measured in combat.

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

`collectgarbage("count")`, `("stop")`, `("restart")` and `("collect")` all work too. If you
are measuring allocation, **stop the collector first** — a collection inside your measuring
loop reads as a negative delta and reports that the call allocates nothing.

## Two habits this suggests

1. **Anything that reads the game every frame deserves a second look**, and an accumulator
   is usually the whole fix. The cost is rarely the arithmetic; it is the object the API
   hands you.
2. **Measure before optimising, but not with `elapsed`.** The instrument with the resolution
   is `debugprofilestop`, and it has to loop the call enough times to clear the noise.
