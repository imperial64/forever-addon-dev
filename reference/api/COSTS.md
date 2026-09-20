<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# Costs

What permitted calls cost on client 1.60.1 build 69913, measured with AmbianceCost; DynamicAmbiance.

**Nothing here is a restriction.** Every call on this page is allowed; what is recorded is what it prices. For what the client refuses, see `RESTRICTIONS.md`.

> **These go stale differently from the rest of this reference.** Pinned to build 69913 on one machine. Nothing in this repo re-measures these, so a new build invalidates them silently. Time figures are guidance about proportion; the allocation figures are the ones that constrain a design.

| Field | Value |
|---|---|
| Measured | 2026-09-20 |
| Machine | RTX 5080, 1920x1080, D3D12, gxMaximize=1 (maximized windowed) |
| Combat state | out of combat for every figure here; P.29 measured the CVar write in both states |
| Capture | `research/captures/AmbianceCost_2026-09-18_215313_cost-bench.lua` |

Method: debugprofilestart/debugprofilestop around an adaptively sized loop; loop overhead measured separately and subtracted; each call benched on its own frame. Allocation measured with the collector stopped, so that a collection inside the loop cannot read as a negative delta and report "allocates nothing".

Instrument: AmbianceCost and DynamicAmbiance, addons in a separate repository. Neither is shipped here and /fprobe reproduces none of this; the captures are checked in so the numbers can be re-derived rather than taken on trust.

| Call | Measured | Time (µs/call) | Allocation (bytes/call) |
|---|---|---|---|
| `C_Map.GetBestMapForUnit` | the call | 0.610 – 0.636 | none measurable |
| `C_CVar.SetCVar`, `SetCVar` | value changed | 0.786 – 0.823 | **822** |
|  | value unchanged | 0.304 – 0.316 | — |
|  | numeric argument rather than a preformatted string | — | **827** |
|  | the Lua-side ("%.2f"):format(v) alone, varying v | — | **38** |
| `C_Map.GetPlayerMapPosition` | bare call | 4.38 – 5.71 | **1864** |
|  | plus GetXY() to get two numbers | 4.91 – 7.91 | — |
| `UnitPosition` | UnitPosition("player") | — | none measurable |

An em dash in the allocation column means the figure was not separately measured for that row, not that the call allocates nothing; `none measurable` is the measured zero.

## best-map-for-unit

_Resolving the current map_

Cheap - seven to nine times cheaper than the position read.

**Measured.** 0.610 - 0.636 µs, no measurable allocation (n=5).

Returns a numeric uiMapID. Its cost is not what would make a position poller expensive; player-map-position is. It is still a map-tree lookup rather than a field read, so it does not belong inside a per-frame path even at this price.

**Guidance.** Resolve it on a zone-change event and hold the id, rather than re-asking inside the poll.

_Evidence: §Q.3 in `research/findings.md`._

## cvar-write

_Writing a CVar_

Cheap in time and expensive in garbage, and the two point in opposite directions. Sub-microsecond per call, but ~822 bytes allocated on EVERY write.

**Measured.** value changed: 0.786 - 0.823 µs, 822 bytes; value unchanged: 0.304 - 0.316 µs; numeric argument rather than a preformatted string: 827 bytes; the Lua-side ("%.2f"):format(v) alone, varying v: 38 bytes (n=5).

Measured through C_CVar.SetCVar on Brightness. That a changed value costs more time says the client does real work on change - and that the work is still under a microsecond, about 0.02% of a frame at 274 fps. This is the number under the P.22 conclusion that driving brightness from OnUpdate is a cheap live post-process rather than a device restart; P.22 measured a ceiling (442 writes over four seconds with no frame spike), this is the cost. The allocation is the half P.22 does not cover, and it is the half that constrains a design. Passing a number instead of a preformatted string does NOT avoid it - 827 against 822, the wrong direction and inside the noise either way. The conversion happens inside the call. The Lua-side format string accounts for only 38 of the bytes, so SetCVar itself is responsible for roughly 784. At a realistic ~35 writes/s from OnUpdate that is about 28 KB/s, or ~99 MB/hour, PER CVAR DRIVEN. An author who reads P.22's frame-time conclusion and stops will believe a write is free; it is free in time and it is not free in garbage. Whether a write lands at all in combat is a restriction question and is now answered: it does, measured in both states on 2026-09-20. See P.29 and graphics-cvars-writable in the restriction list. Only Brightness was measured. Whether 822 bytes is constant across CVars, or differs for a CVar the client persists differently, was NOT measured.

**Guidance.** Do not cache a CVar value to avoid the write on time grounds; a redundant write is cheaper in time than most of the work you would do to avoid it. Do think about the write RATE on allocation grounds - driving two CVars every frame is not free, and an epsilon skip or an accumulator is the lever.

_Evidence: §Q.4, §P.29 in `research/findings.md`._

## player-map-position

_Reading player position_

Allocates 1864 bytes on EVERY call. The allocation is the constraint here, not the time.

**Measured.** bare call: 4.38 - 5.71 µs, 1864 bytes; plus GetXY() to get two numbers: 4.91 - 7.91 µs (n=5).

The call returns a position object exposing GetXY() rather than two numbers, and building that object costs 1864 bytes - byte-identical across all five runs, so this is the shape of the object rather than measurement noise. Unpacking it with GetXY() costs time but no further allocation worth recording; the 1864 bytes is the object the call hands back. Polled every frame that is roughly 218 KB/s of garbage at 120 fps and 500 KB/s at 274; on a 10 Hz accumulator it is about 18 KB/s. Nothing refuses this call and the time is negligible against a frame; the garbage is what would show up as a stutter under the collector. A building interior in the open world is NOT the instance case. Called inside the Northshire chapel it returned an ordinary point on the PARENT map, with GetBestMapForUnit unchanged; it did not go nil and the map did not change. Behaviour inside an actual instance was NOT measured - retail returns nil there - and neither was a building that is its own map. If you want world coordinates rather than map coordinates, unit-position below allocates nothing.

**Guidance.** Poll position on an accumulator rather than per frame, and guard for a nil return.

_Evidence: §Q.2 in `research/findings.md`._

## unit-position

_Reading player world position_

Present, returns plain numbers, and allocates nothing - the paired alternative to player-map-position on the axis that matters here.

**Measured.** no measurable allocation (n=1).

Against C_Map.GetPlayerMapPosition's 1864 bytes per call, this removes the garbage problem rather than reducing it. The tradeoff is not cost but coordinate space: UnitPosition returns WORLD coordinates, GetPlayerMapPosition normalized 0-1 MAP coordinates. They answer different questions and one cannot simply be substituted for the other. Read this entry as "worth investigating" rather than "use this instead". Only the allocation was measured. NOT verified on this client: the return-value ORDER, behaviour inside instances, whether it is restricted in combat, and its time cost, which was not separately benched. P.25 has already shown this client gates unit reads on axes retail does not, so retail's behaviour is not a safe default here. The order is worth singling out because there is a live disagreement. This client's own documentation names the returns positionX, positionY, positionZ, mapID - X first - and the generated page above says so. Community documentation for retail has long held that the first two arrive Y then X regardless of those names. Nothing here measured which is true on this build, and getting it backwards produces a position that is wrong in a way that still looks plausible.

**Guidance.** If you need world coordinates, this is the cheap read. If you need a position on a map, you still need player-map-position and its accumulator. Confirm the return ORDER against a known landmark on your own client before relying on it - the documented names and the retail folklore disagree, and neither was measured here.

_Evidence: §Q.8 in `research/findings.md`._
