
ForeverProbeDB = {
["combatLog"] = {
["eventFired"] = 0,
["readerPresent"] = false,
["count"] = 0,
["registered"] = false,
["inCombatCount"] = 0,
["samples"] = {
},
["registrationForbidden"] = "measured 2026-09-18: ADDON_ACTION_FORBIDDEN at load, out of combat",
["subevents"] = {
},
},
["secrecy"] = {
["incombat"] = {
["combatLogRestricted"] = "true",
["chatMessagingLockdown"] = "false",
["addonRestrictionState"] = "2",
["gates"] = {
["ShouldUnitThreatStateBeSecret"] = "false",
["ShouldUnitHealthMaxBeSecret"] = "false",
["ShouldUnitPowerBeSecret"] = "true",
["ShouldAurasBeSecret"] = "true",
["ShouldUnitIdentityBeSecret"] = "false",
["CanCompareUnitTokens"] = "true",
["ShouldActionCooldownBeSecret"] = "true",
["ShouldUnitThreatValuesBeSecret"] = "true",
["ShouldUnitSpellCastBeSecret"] = "false",
["ShouldCooldownsBeSecret"] = "true",
["ShouldUnitStatsBeSecret"] = "true",
["HasSecretRestrictions"] = "true",
},
["addonMessagesRestricted"] = "true",
["gateArgs"] = {
["ShouldUnitThreatStateBeSecret"] = "(\"player\")",
["ShouldUnitHealthMaxBeSecret"] = "(\"player\")",
["ShouldUnitPowerBeSecret"] = "(\"player\")",
["ShouldAurasBeSecret"] = "()",
["ShouldUnitIdentityBeSecret"] = "(\"player\")",
["CanCompareUnitTokens"] = "(\"player\", 1)",
["ShouldActionCooldownBeSecret"] = "(1)",
["ShouldUnitThreatValuesBeSecret"] = "(\"player\", 1)",
["ShouldUnitSpellCastBeSecret"] = "(\"player\", 1)",
["ShouldCooldownsBeSecret"] = "()",
["ShouldUnitStatsBeSecret"] = "()",
["HasSecretRestrictions"] = "()",
},
["addonRestrictionActive"] = "true",
["addonRestrictionActiveArg"] = "(addonName)",
["addonRestrictionStateArg"] = "(addonName)",
["inCombat"] = true,
},
},
["blockLog"] = {
{
["addon"] = "ForeverProbe",
["test"] = "UseAction(slot1)",
["event"] = "ADDON_ACTION_FORBIDDEN",
["func"] = "UseAction()",
},
{
["addon"] = "ForeverProbe",
["test"] = "EditMacro",
["event"] = "ADDON_ACTION_BLOCKED",
["func"] = "EditMacro()",
},
{
["addon"] = "ForeverProbe",
["test"] = "SetOverrideBindingClick",
["event"] = "ADDON_ACTION_BLOCKED",
["func"] = "SetOverrideBindingClick()",
},
},
["bridge"] = {
["loads"] = 1,
},
["actions"] = {
["incombat"] = {
["tests"] = {
["EditMacro"] = {
["ok"] = true,
["allowed"] = false,
["blockEvents"] = {
"ADDON_ACTION_BLOCKED:EditMacro()",
},
},
["SecureBtn:SetAttribute"] = {
["ok"] = true,
["allowed"] = true,
},
["UseAction(slot1)"] = {
["ok"] = true,
["allowed"] = false,
["blockEvents"] = {
"ADDON_ACTION_FORBIDDEN:UseAction()",
},
},
["CastSpellByName"] = {
["ok"] = true,
["allowed"] = true,
},
["SetOverrideBindingClick"] = {
["ok"] = true,
["allowed"] = false,
["blockEvents"] = {
"ADDON_ACTION_BLOCKED:SetOverrideBindingClick()",
},
},
},
["reads"] = {
["spellCooldownStart"] = "nil",
["targetCasting"] = "nil",
["playerAura1"] = "ERR: GetAuraDataByIndex(): Auras cannot be accessed when secret while tainted by 'ForeverProbe'\nLua Taint: ForeverProbe",
["playerPower"] = "<SECRET>",
["targetHealth"] = "<SECRET>",
["combatLogAPI"] = "ABSENT",
["targetAura1"] = "ERR: GetAuraDataByIndex(): Auras cannot be accessed when secret while tainted by 'ForeverProbe'\nLua Taint: ForeverProbe",
},
["inCombat"] = true,
},
},
["registerBlocked"] = {
},
}
