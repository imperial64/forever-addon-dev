<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# Costs

What permitted calls cost on client 1.60.1 build 69913, measured with AmbianceCost.

**Nothing here is a restriction.** Every call on this page is allowed; what is recorded is what it prices. For what the client refuses, see `RESTRICTIONS.md`.

> **These go stale differently from the rest of this reference.** Pinned to build 69913 on one machine. Nothing in this repo re-measures these, so a new build invalidates them silently. Time figures are guidance about proportion; the allocation figures are the ones that constrain a design.

| Field | Value |
|---|---|
| Measured | 2026-09-18 |
| Machine | RTX 5080, 1920x1080, D3D12, gxMaximize=1 (maximized windowed) |
| Combat state | out of combat in all runs |
| Capture | `research/captures/AmbianceCost_2026-09-18_215313_cost-bench.lua` |

Method: debugprofilestart/debugprofilestop around an adaptively sized loop; loop overhead measured separately and subtracted; each call benched on its own frame. Allocation measured with the collector stopped, so that a collection inside the loop cannot read as a negative delta and report "allocates nothing".

Instrument: AmbianceCost, an addon in a separate repository. It is not shipped here and /fprobe does not reproduce any of this; the capture is checked in so the numbers can be re-derived rather than taken on trust.

| Call | Measured | Time (µs/call) | Allocation (bytes/call) |
|---|---|---|---|
| `C_Map.GetBestMapForUnit` | the call | 0.610 – 0.636 | none measurable |
| `C_CVar.SetCVar`, `SetCVar` | value changed | 0.786 – 0.823 | — |
|  | value unchanged | 0.304 – 0.316 | — |
| `C_Map.GetPlayerMapPosition` | bare call | 4.38 – 5.71 | **1864** |
|  | plus GetXY() to get two numbers | 4.91 – 7.91 | — |

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

Sub-microsecond, so a CVar write is affordable at frame rate. A changed value costs about 2.6x a no-op write.

**Measured.** value changed: 0.786 - 0.823 µs; value unchanged: 0.304 - 0.316 µs (n=5).

Measured through C_CVar.SetCVar on Brightness. That a changed value costs more says the client does real work on change - and that the work is still under a microsecond, about 0.02% of a frame at 274 fps. This is the number under the P.22 conclusion that driving brightness from OnUpdate is a cheap live post-process rather than a device restart; P.22 measured a ceiling (442 writes over four seconds with no frame spike), this is the cost. Whether a write lands AT ALL in combat is a restriction question and is still unmeasured - see graphics-cvars-writable in the restriction list.

**Guidance.** Do not cache a CVar value to avoid the write; a redundant write is cheaper than most of the work you would do to avoid it.

_Evidence: §Q.4 in `research/findings.md`._

## player-map-position

_Reading player position_

Allocates 1864 bytes on EVERY call. The allocation is the constraint here, not the time.

**Measured.** bare call: 4.38 - 5.71 µs, 1864 bytes; plus GetXY() to get two numbers: 4.91 - 7.91 µs (n=5).

The call returns a position object exposing GetXY() rather than two numbers, and building that object costs 1864 bytes - byte-identical across all five runs, so this is the shape of the object rather than measurement noise. Unpacking it with GetXY() costs time but no further allocation worth recording; the 1864 bytes is the object the call hands back. Polled every frame that is roughly 218 KB/s of garbage at 120 fps and 500 KB/s at 274; on a 10 Hz accumulator it is about 18 KB/s. Nothing refuses this call and the time is negligible against a frame; the garbage is what would show up as a stutter under the collector. Behaviour inside an instance was NOT measured - retail returns nil there.

**Guidance.** Poll position on an accumulator rather than per frame, and guard for a nil return.

_Evidence: §Q.2 in `research/findings.md`._
