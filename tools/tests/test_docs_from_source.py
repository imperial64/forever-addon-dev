"""Regression test for the source adapter.

tools/docs_from_source.py is only worth having if what it emits is what the
in-game dumper would have written, byte for byte once the generator has run.
The full-scale proof is a control run against a build whose dump is checked in
(69913: zero differences across 408 systems). This test pins the individual
behaviours that proof depends on, on a fixture small enough to read:

- files load in .toc order and a nameless documentation table is not a system,
  but its tables land in `apiDocs.tables`, keyed and collision-suffixed;
- the projection keeps the dumper's fields, every secrecy and gating key, a
  function's own Namespace and enum values, and nothing else;
- `Enum.X.Y` and `Constants.X.Y` in a kept field resolve to the number the
  client would hold; anything the source cannot resolve is nil and reported;
- Blizzard's renderers are reproduced with their colour escapes and the
  "optional " decoration, and an unresolvable Expr default counts as nil;
- a repeated system name is suffixed and recorded, not dropped;
- the SavedVariables it writes reads back through svlua unchanged.

    python tools/tests/test_docs_from_source.py
"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(REPO / "tools"))

import svlua  # noqa: E402
from docs_from_source import build_api_docs, to_savedvariables  # noqa: E402

TOC = """## Title: Blizzard API Documentation Generated
## LoadOnDemand: 1

# Start documentation files here
WidgetDocumentation.lua
SharedConstantsDocumentation.lua
ThingDocumentation.lua
ThingAgainDocumentation.lua
"""

THING = """local Thing =
{
	Name = "Thing",
	Type = "System",
	Namespace = "C_Thing",
	Environment = "All",

	Functions =
	{
		{
			Name = "Get",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Prose the dumper never keeps." },

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "flag", Type = "bool", Nilable = false, Default = false },
				{ Name = "limit", Type = "number", Nilable = false, Default = MAX_THINGS },
			},

			Returns =
			{
				{ Name = "ids", Type = "table", InnerType = "number", Nilable = true, ConditionalSecret = true },
			},
		},
		{
			Name = "Lockdown",
			Type = "Function",
			Namespace = "",
			SecretWhenInCombat = true,
			RequiresThing = true,
			MayReturnNothing = true,
			Arguments =
			{
				{ Name = "kind", Type = "ThingKind", Nilable = false, Default = Enum.ThingKind.B },
			},
		},
	},

	Events =
	{
		{
			Name = "ThingChanged",
			Type = "Event",
			LiteralName = "THING_CHANGED",
			SynchronousEvent = true,
			SecretInChatMessagingLockdown = true,
			Payload =
			{
				{ Name = "id", Type = "number", Nilable = false, NeverSecret = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "ThingKind",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "A", Type = "ThingKind", EnumValue = 0 },
				{ Name = "B", Type = "ThingKind", EnumValue = 1 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(Thing);
"""

# Same Name, no namespace: the dumper suffixes the second one.
THING_AGAIN = """-- a comment the reader must skip
local ThingAgain =
{
	Name = "Thing",
	Type = "System",
	Functions = { { Name = "Plain", Type = "Function" } },
	Events = {},
	Tables = {},
};

APIDocumentation:AddDocumentationTable(ThingAgain);
"""

WIDGET = """local WidgetAPI =
{
	Name = "WidgetAPI",
	Type = "ScriptObject",
	Functions =
	{
		{
			Name = "SetThing",
			Type = "Function",
			ChecksForbiddenAspects = { { Argument = "self", Aspect = Enum.ForbiddenAspect.SetTexture } },
			Arguments = { { Name = "value", Type = "number", Nilable = true } },
		},
	},
	Events = {},
	Tables = {},
};

APIDocumentation:AddDocumentationTable(WidgetAPI);
"""

# No Name: filed under APIDocumentation.tables in the client, never a system.
# Loaded BEFORE ThingDocumentation, and still resolvable from it: the client
# defines Enum and Constants before any documentation loads.
SHARED = """local SharedConstants =
{
	Tables =
	{
		{
			Name = "ForbiddenAspect",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1024,
			MaxValue = 2048,
			Fields =
			{
				{ Name = "ChangeParent", Type = "ForbiddenAspect", EnumValue = 1024 },
				{ Name = "SetTexture", Type = "ForbiddenAspect", EnumValue = 2048 },
			},
		},
		{
			Name = "Shared",
			Type = "Constants",
			Values =
			{
				{ Name = "X", Type = "number", Value = NUM_X + 1 },
				{ Name = "Y", Type = "ForbiddenAspect", Value = Enum.ForbiddenAspect.SetTexture },
				{ Name = "Z", Type = "number", Value = Constants.Shared.W * (2 + 1) - Enum.ForbiddenAspectMeta.NumValues },
				{ Name = "W", Type = "number", Value = 5 },
				{ Name = "S", Type = "string", Value = "text" },
			},
		},
		{ Name = "Shared", Type = "Structure", Fields = { { Name = "again", Type = "bool", Nilable = false } } },
	},
};

APIDocumentation:AddDocumentationTable(SharedConstants);
"""


def main() -> int:
    failures: list[str] = []

    def check(label: str, got, want) -> None:
        if got != want:
            failures.append(f"{label}: got {got!r}, want {want!r}")

    with tempfile.TemporaryDirectory() as tmp:
        folder = Path(tmp) / "Blizzard_APIDocumentationGenerated"
        folder.mkdir()
        (folder / "Blizzard_APIDocumentationGenerated.toc").write_text(TOC, encoding="utf-8")
        (folder / "ThingDocumentation.lua").write_text(THING, encoding="utf-8")
        (folder / "ThingAgainDocumentation.lua").write_text(THING_AGAIN, encoding="utf-8")
        (folder / "WidgetDocumentation.lua").write_text(WIDGET, encoding="utf-8")
        (folder / "SharedConstantsDocumentation.lua").write_text(SHARED, encoding="utf-8")

        client = {"version": "1.60.1", "build": "70009", "interface": "16001"}
        docs, warnings = build_api_docs(folder, client, "2026-09-24 22:03:25")

        systems = docs["systems"]
        # 1. Nameless table skipped; collision suffixed and recorded; widget prefixed.
        check("system keys", sorted(systems), ["ScriptObject:WidgetAPI", "Thing", "Thing~2"])
        check("collisions", docs["counts"]["collisions"], ["Thing"])
        check("counts", {k: docs["counts"][k] for k in ("stored", "functions", "events", "tables",
                                                        "sharedTables", "tableCollisions")},
              {"stored": 3, "functions": 4, "events": 1, "tables": 1,
               "sharedTables": 3, "tableCollisions": ["Shared"]})
        # The first-loaded Thing keeps the plain key: .toc order, not file order.
        check("toc order", systems["Thing"].get("Namespace"), "C_Thing")

        # 1b. The nameless table's tables: keyed by Name, a repeat suffixed.
        shared = docs["tables"]
        check("shared table keys", sorted(shared), ["ForbiddenAspect", "Shared", "Shared~2"])
        check("first-loaded shared keeps the plain key", shared["Shared"]["Type"], "Constants")
        check("shared enum keeps EnumValue", shared["ForbiddenAspect"]["Fields"][1],
              {"Name": "SetTexture", "Type": "ForbiddenAspect", "EnumValue": 2048})
        values = {v["Name"]: v for v in shared["Shared"]["Values"]}
        check("constant literal", values["W"], {"Name": "W", "Type": "number", "Value": 5})
        check("constant string", values["S"].get("Value"), "text")
        check("constant Enum reference resolved", values["Y"].get("Value"), 2048)
        check("constant arithmetic over Constants and EnumMeta", values["Z"].get("Value"), 13)
        check("constant over an unknown global is nil", "Value" in values["X"], False)

        # 2. Projection: the dumper's fields, the gating keys, no prose.
        get = systems["Thing"]["Functions"][0]
        check("function keys", sorted(get), ["ArgumentString", "Arguments", "FullName",
                                             "HasRestrictions", "Name", "ReturnString",
                                             "Returns", "SecretArguments", "Type"])
        check("SecretArguments verbatim", get["SecretArguments"], "AllowedWhenUntainted")
        check("secret key on a return", get["Returns"][0].get("ConditionalSecret"), True)
        check("Expr default dropped", "Default" in get["Arguments"][2], False)
        check("false default kept", get["Arguments"][1].get("Default"), False)
        check("enum values are Fields, EnumValue kept",
              systems["Thing"]["Tables"][0]["Fields"][0],
              {"Name": "A", "Type": "ThingKind", "EnumValue": 0})
        check("Predicates/Environment not kept", "Environment" in systems["Thing"], False)
        lockdown = systems["Thing"]["Functions"][1]
        check("function Namespace kept, empty string included", lockdown.get("Namespace"), "")
        check("Requires*/Secret* kept, other flags not",
              sorted(k for k in lockdown if k not in ("Name", "Type", "Namespace", "Arguments",
                                                      "FullName", "ArgumentString", "ReturnString")),
              ["RequiresThing", "SecretWhenInCombat"])
        check("Enum default resolved", lockdown["Arguments"][0].get("Default"), 1)
        event = systems["Thing"]["Events"][0]
        check("event keys", sorted(k for k in event if k not in ("Name", "Type", "LiteralName",
                                                                 "Payload", "FullName")),
              ["SecretInChatMessagingLockdown"])
        check("payload secret key", event["Payload"][0].get("NeverSecret"), True)
        check("structured key, Enum resolved",
              systems["ScriptObject:WidgetAPI"]["Functions"][0].get("ChecksForbiddenAspects"),
              [{"Argument": "self", "Aspect": 2048}])

        # 3. Renderers.
        check("FullName", get["FullName"],
              "C_Thing.Get(|cffffdd55index|r|cff55ddff, |cffffdd55optional flag|r|cff55ddff,"
              " |cffffdd55limit|r|cff55ddff)")
        check("ReturnString", get["ReturnString"], "|cffffdd55optional ids|r|cff55ddff")
        check("widget FullName (no namespace)",
              systems["ScriptObject:WidgetAPI"]["Functions"][0]["FullName"],
              "SetThing(|cffffdd55optional value|r|cff55ddff)")
        check("no-arg ArgumentString", systems["Thing~2"]["Functions"][0]["ArgumentString"], "")
        check("event FullName", systems["Thing"]["Events"][0]["FullName"],
              "Event.Thing.ThingChanged -> |cffffdd55id|r|cff77ff22")
        # Blizzard's GetFullName uses the SYSTEM's namespace even when the
        # function carries its own; a resolved Enum default makes it optional.
        check("FullName ignores the function-level Namespace", lockdown["FullName"],
              "C_Thing.Lockdown(|cffffdd55optional kind|r|cff55ddff)")
        check("warning for the Expr default",
              [w for w in warnings if "MAX_THINGS" in w] != [], True)
        check("warning for the unresolvable constant", [w for w in warnings if "NUM_X" in w] != [], True)
        check("no warning for what resolved", [w for w in warnings if "Aspect" in w or "Constants" in w], [])

        # 4. Round trip through the reader the generator uses.
        text = to_savedvariables(docs)
        back = svlua.parse(text)["ForeverProbeDB"]["apiDocs"]
        check("svlua round trip", back, docs)

    if failures:
        print("FAIL")
        for failure in failures:
            print(f"  - {failure}")
        return 1
    print("ok: load order, shared tables, projection, load-time evaluation, renderers,"
          " collisions and the SavedVariables round trip")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
