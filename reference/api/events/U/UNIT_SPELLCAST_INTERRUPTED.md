<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UNIT_SPELLCAST_INTERRUPTED

**Payload**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitTarget` | `UnitTokenVariant` | no |  |
| 2 | `castGUID` | `WOWGUID` | no |  |
| 3 | `spellID` | `number` | no |  |
| 4 | `interruptedBy` | `WOWGUID` | no |  |
| 5 | `castBarID` | `UnitCastBarID` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this event | `SecretWhenUnitSpellCastRestricted` | `true` |
| payload `castBarID` | `NeverSecret` | `true` |

System: `Unit`
