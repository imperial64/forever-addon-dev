"""Regression test for the generator's handling of the widened capture.

Four things the capture can now carry, each of which the generator must use
when present and ignore when absent, because the checked-in in-game dumps
predate all of them and must still reproduce the shipped tree byte for byte:

- `EnumValue` on enum members and `Value` on constants, rendered as a Value
  column only when there is a value to put in it;
- a function's own `Namespace`, which overrides its system's ("" is global),
  without a --surface stub then duplicating the page it moved to;
- `apiDocs.tables`, the shared tables no system owns, paged at the path their
  name derives, with a collision against a system table skipped and reported;
- the secrecy and gating keys, in their own section, verbatim, and only when
  an entry has one.

And the guard on --surface: a surface dump from another build must not label
anything "present on this client". And a restriction entry's own `build` and
`measured_on`, which override the file's meta on every generated view.

    python tools/tests/test_build_reference.py
"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(REPO / "tools"))

from build_reference import (  # noqa: E402
    ReferenceBuilder, Restrictions, docs_version_lua, restriction_key)


def old_capture() -> dict:
    """The shape the in-game dumper wrote on 2026-09-18: none of the new fields."""
    return {
        "client": {"version": "1.60.1", "build": "69913", "interface": "16001"},
        "counts": {"systems": 2, "stored": 2, "functions": 2, "events": 1, "tables": 2},
        "systems": {
            "Thing": {
                "Name": "Thing", "Namespace": "C_Thing", "Type": "System",
                "Functions": [
                    {"Name": "Get", "Type": "Function", "HasRestrictions": True,
                     "Returns": [{"Name": "id", "Type": "number", "Nilable": False}]},
                    {"Name": "Lockdown", "Type": "Function"},
                ],
                "Events": [{"Name": "ThingChanged", "LiteralName": "THING_CHANGED",
                            "Type": "Event",
                            "Payload": [{"Name": "id", "Type": "number", "Nilable": False}]}],
                "Tables": [
                    {"Name": "ThingKind", "Type": "Enumeration", "NumValues": 2,
                     "Fields": [{"Name": "A", "Type": "ThingKind"},
                                {"Name": "B", "Type": "ThingKind"}]},
                    {"Name": "ThingConstants", "Type": "Constants",
                     "Values": [{"Name": "MAX"}]},
                ],
            },
        },
    }


def new_capture() -> dict:
    """The same build as the widened dumper and the source adapter write it."""
    docs = old_capture()
    thing = docs["systems"]["Thing"]
    get, lockdown = thing["Functions"]
    get["SecretArguments"] = "AllowedWhenUntainted"
    get["Returns"][0]["ConditionalSecret"] = True
    lockdown["Namespace"] = ""
    lockdown["SecretWhenInCombat"] = True
    lockdown["ChecksForbiddenAspects"] = [{"Argument": "self", "Aspect": 2048}]
    thing["Events"][0]["HasRestrictions"] = True
    thing["Events"][0]["Payload"][0]["NeverSecret"] = True
    thing["Tables"][0]["Fields"][0]["EnumValue"] = 0
    thing["Tables"][0]["Fields"][1]["EnumValue"] = 1
    thing["Tables"][1]["Values"] = [{"Name": "MAX", "Type": "number", "Value": 4}]
    docs["systems"]["Other"] = {
        "Name": "Other", "Type": "System",
        "Functions": [{"Name": "Moved", "Type": "Function", "Namespace": "C_Else"}],
    }
    docs["tables"] = {
        "ForbiddenAspect": {"Name": "ForbiddenAspect", "Type": "Enumeration",
                            "Fields": [{"Name": "SetTexture", "Type": "ForbiddenAspect",
                                        "EnumValue": 2048}]},
        # Same name as a system table: must not overwrite it.
        "ThingKind": {"Name": "ThingKind", "Type": "Enumeration",
                      "Fields": [{"Name": "Z", "Type": "ThingKind", "EnumValue": 9}]},
    }
    return docs


def build(out: Path, docs: dict, surface: dict | None = None,
          surface_build: str | None = None) -> ReferenceBuilder:
    builder = ReferenceBuilder(out, docs)
    if surface:
        builder.surface = surface
        builder.surface_build = surface_build
    builder.build()
    builder.write_build_info(Path("capture.lua"))
    return builder


def tree(root: Path) -> dict[str, str]:
    return {p.relative_to(root).as_posix(): p.read_text(encoding="utf-8")
            for p in sorted(root.rglob("*.md"))}


SURFACE = {
    "globals": ["Lockdown", "UndocumentedGlobal"],
    "namespaces": {"C_Thing": ["Get", "Gone"], "C_Else": ["Moved"]},
}


def main() -> int:
    failures: list[str] = []

    def check(label: str, got, want) -> None:
        if got != want:
            failures.append(f"{label}: got {got!r}, want {want!r}")

    def contains(label: str, text: str, needle: str, want: bool = True) -> None:
        if (needle in text) != want:
            failures.append(f"{label}: {'missing' if want else 'unexpected'} {needle!r}")

    check("restriction_key", [k for k in ("SecretArguments", "NeverSecret", "ConstSecretAccessor",
                                          "RequiresFriendList", "ChecksForbiddenAspects",
                                          "IsProtectedFunction", "HasRestrictions",
                                          "MayReturnNothing", "SynchronousEvent",
                                          "RequireNPERestricted", "Name") if restriction_key(k)],
          ["SecretArguments", "NeverSecret", "ConstSecretAccessor", "RequiresFriendList",
           "ChecksForbiddenAspects", "IsProtectedFunction", "HasRestrictions"])

    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)

        # 1. Old capture: none of the new sections, columns or pages.
        build(root / "old", old_capture(), SURFACE, "69913")
        old = tree(root / "old")
        enum_old = old["enums/ThingKind.md"]
        check("old enum header", enum_old.count("| # | Name | Type | Nilable | Default |"), 1)
        contains("old enum", enum_old, "| Value |", False)
        contains("old constants keep their legacy rendering", old["structures/ThingConstants.md"],
                 "| `MAX` | None |")
        contains("old: no secrecy section anywhere", "".join(old.values()),
                 "Secrecy and restriction keys", False)
        check("old: Lockdown stays where its system put it",
              "namespaces/C_Thing/Lockdown.md" in old, True)
        contains("old: matching surface stubs say present", old["globals/U/UndocumentedGlobal.md"],
                 "Present on this client")
        contains("old: matching surface, no warning", old["BUILD.md"], "WARNING", False)
        contains("old: no shared_tables row", old["BUILD.md"], "shared_tables", False)

        # 2. New capture.
        builder = build(root / "new", new_capture(), SURFACE, "69913")
        new = tree(root / "new")
        enum_new = new["enums/ThingKind.md"]
        contains("enum Value column", enum_new, "| # | Name | Value | Type | Nilable | Default |")
        contains("enum value row", enum_new, "| 2 | `B` | 1 | `ThingKind` | no |  |")
        contains("shared table did not overwrite the system's", enum_new, "`Z`", False)
        contains("constant values", new["structures/ThingConstants.md"],
                 "| `MAX` | `number` | `4` |")

        check("function-level \"\" namespace -> global", "globals/L/Lockdown.md" in new, True)
        check("...and not left in the system's namespace",
              "namespaces/C_Thing/Lockdown.md" in new, False)
        contains("global page is documented, not a stub", new["globals/L/Lockdown.md"], "```lua")
        contains("footer says why", new["globals/L/Lockdown.md"],
                 "Global (function-level `Namespace`; the system's is `C_Thing`)")
        check("function-level namespace -> that namespace", "namespaces/C_Else/Moved.md" in new, True)
        contains("namespaced page is documented, not a stub",
                 new["namespaces/C_Else/Moved.md"], "```lua")
        check("namespace-less system did not file it as a global", "globals/M/Moved.md" in new, False)
        check("stubs: only the two genuinely undocumented symbols", builder.stubs, 2)

        get_page = new["namespaces/C_Thing/Get.md"]
        contains("secrecy section", get_page, "**Secrecy and restriction keys**")
        contains("function key verbatim", get_page,
                 '| this function | `SecretArguments` | `"AllowedWhenUntainted"` |')
        contains("return key", get_page, "| return `id` | `ConditionalSecret` | `true` |")
        contains("HasRestrictions keeps its banner", get_page, "RESTRICTED — Blizzard flag")
        contains("...and is not repeated in the table", get_page, "`HasRestrictions` |", False)
        contains("structured value rendered as Lua", new["globals/L/Lockdown.md"],
                 '`{ { Argument = "self", Aspect = 2048 } }`')
        event_page = new["events/T/THING_CHANGED.md"]
        contains("event HasRestrictions in the table", event_page,
                 "| this event | `HasRestrictions` | `true` |")
        contains("payload key", event_page, "| payload `id` | `NeverSecret` | `true` |")

        forbidden = new["enums/ForbiddenAspect.md"]
        contains("shared table paged", forbidden, "| 1 | `SetTexture` | 2048 | `ForbiddenAspect` |")
        contains("shared table owner", forbidden, "System: none")
        check("shared tables counted", builder.shared_tables, 1)
        check("collision reported", len(builder.table_collisions), 1)
        contains("collision in BUILD.md", new["BUILD.md"], "shared table `ThingKind`")
        contains("shared_tables row", new["BUILD.md"], "| shared_tables | 1 |")

        # 3. Determinism: the same capture twice is the same tree.
        build(root / "again", new_capture(), SURFACE, "69913")
        check("deterministic", tree(root / "again") == new, True)

        # 4. A surface from another build never says "present on this client".
        docs = new_capture()
        docs["client"]["build"] = "70009"
        mismatched = build(root / "mismatch", docs, SURFACE, "69913")
        other = tree(root / "mismatch")
        check("mismatch detected", mismatched.surface_mismatch, True)
        contains("no 'present' claim", "".join(other.values()), "Present on this client", False)
        contains("stub says where it was seen", other["namespaces/C_Thing/Gone.md"],
                 "Seen on client build 69913, not documented by Blizzard on build 70009")
        contains("BUILD.md warning", other["BUILD.md"], "**WARNING: the --surface capture is from")
        contains("BUILD.md surface row", other["BUILD.md"], "| surface_build | 69913 |")
        unrecorded = build(root / "unrecorded", new_capture(), SURFACE, None)
        check("a surface that does not record its build is treated as a mismatch",
              unrecorded.surface_mismatch, True)

        # 5. A restriction entry's own build and date beat meta's, everywhere a
        #    build is printed; an entry without them inherits meta's.
        restrictions = Restrictions(None)
        restrictions.meta = {"client": "1.60.1", "build": "69913",
                             "measured_on": "2026-09-20", "interface": 16001,
                             "measured_by": "probe"}
        restrictions.entries = [
            {"id": "old-entry", "symbols": ["C_Thing.Get"], "verdict": "secret",
             "scope": "always", "summary": "Old.", "evidence": ["P.1"]},
            {"id": "new-entry", "symbols": ["C_Else.Moved"], "verdict": "blocked",
             "scope": "in-combat", "summary": "New.", "evidence": ["P.32"],
             "build": "70009", "measured_on": "2026-09-25"},
        ]
        for entry in restrictions.entries:
            for symbol in entry["symbols"]:
                restrictions.by_symbol.setdefault(symbol, []).append(entry)
        docs = new_capture()
        docs["client"]["build"] = "70009"
        per = ReferenceBuilder(root / "per", docs, restrictions)
        per.build()
        per.write_restrictions_page()
        skill = root / "SKILL.md"
        skill.write_text("head\n<!-- BEGIN GENERATED restrictions-table -->\n"
                         "<!-- END GENERATED restrictions-table -->\ntail\n", encoding="utf-8")
        per.update_skill_table(skill)
        pages = tree(root / "per")
        contains("inherited build on the banner", pages["namespaces/C_Thing/Get.md"],
                 "Measured 2026-09-20 on build 69913.")
        contains("own build on the banner", pages["namespaces/C_Else/Moved.md"],
                 "Measured 2026-09-25 on build 70009.")
        contains("...and not meta's", pages["namespaces/C_Else/Moved.md"], "build 69913", False)
        page = pages["RESTRICTIONS.md"]
        contains("RESTRICTIONS.md header admits exceptions", page,
                 "build 69913 (interface 16001) with probe, except where an entry names its own build.")
        contains("RESTRICTIONS.md row", page, "New. _(measured 2026-09-25 on build 70009)_ |")
        contains("RESTRICTIONS.md section", page, "**Measured 2026-09-25 on build 70009**")
        contains("inheriting row carries no note", page, "Old. _(measured", False)
        table = skill.read_text(encoding="utf-8")
        contains("skill row", table, "New. _(measured 2026-09-25 on build 70009)_ |")
        contains("skill footer", table, "build 69913, except where a row names its own build.")
        check("own_build is false when it matches meta",
              restrictions.own_build({"build": "69913", "measured_on": "2026-09-20"}), False)
        restrictions.entries = restrictions.entries[:1]
        plain = ReferenceBuilder(root / "plain", docs, restrictions)
        plain.write_restrictions_page()
        contains("no exception clause when no entry has its own build",
                 (root / "plain" / "RESTRICTIONS.md").read_text(encoding="utf-8"),
                 "except where", False)

    # 6. DocsVersion.lua is written from BUILD.md's rows, date only, no clock.
    lua = docs_version_lua({"version": "1.60.1", "build": "70009", "interface": "16001",
                            "generated": "2026-09-24 22:03:25", "systems": 410,
                            "functions": 6596, "events": 1805, "tables": 797})
    for needle in ('    build     = "70009",', "    interface = 16001,",
                   '    generated = "2026-09-24",', "    functions = 6596,",
                   "GENERATED by tools/build_reference.py"):
        contains("DocsVersion.lua", lua, needle)
    contains("DocsVersion.lua carries no time of day", lua, "22:03", False)

    if failures:
        print("FAIL")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print("ok: enum values, namespace override, shared tables, secrecy keys, surface guard,"
          " per-entry restriction build, old-capture compatibility and determinism")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
