local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale( "ReRecount" )

local revision = tonumber(string.sub("$Revision: 79898 $", 12, -3))
if ReRecount.Version < revision then ReRecount.Version = revision end

--Data for ReRecount is tracked within this file
local Tracking={}

local UnitName = UnitName
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local GetTime = GetTime

-- Elsia: This is straight from GUIDRegistryLib-0.1 by ArrowMaster.
local bit_bor	= bit.bor
local bit_band  = bit.band

local COMBATLOG_OBJECT_AFFILIATION_MINE		= COMBATLOG_OBJECT_AFFILIATION_MINE		or 0x00000001
local COMBATLOG_OBJECT_AFFILIATION_PARTY	= COMBATLOG_OBJECT_AFFILIATION_PARTY	or 0x00000002
local COMBATLOG_OBJECT_AFFILIATION_RAID		= COMBATLOG_OBJECT_AFFILIATION_RAID		or 0x00000004
local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER	= COMBATLOG_OBJECT_AFFILIATION_OUTSIDER	or 0x00000008
local COMBATLOG_OBJECT_AFFILIATION_MASK		= COMBATLOG_OBJECT_AFFILIATION_MASK		or 0x0000000F
-- Reaction
local COMBATLOG_OBJECT_REACTION_FRIENDLY	= COMBATLOG_OBJECT_REACTION_FRIENDLY	or 0x00000010
local COMBATLOG_OBJECT_REACTION_NEUTRAL		= COMBATLOG_OBJECT_REACTION_NEUTRAL		or 0x00000020
local COMBATLOG_OBJECT_REACTION_HOSTILE		= COMBATLOG_OBJECT_REACTION_HOSTILE		or 0x00000040
local COMBATLOG_OBJECT_REACTION_MASK		= COMBATLOG_OBJECT_REACTION_MASK		or 0x000000F0
-- Ownership
local COMBATLOG_OBJECT_CONTROL_PLAYER		= COMBATLOG_OBJECT_CONTROL_PLAYER		or 0x00000100
local COMBATLOG_OBJECT_CONTROL_NPC			= COMBATLOG_OBJECT_CONTROL_NPC			or 0x00000200
local COMBATLOG_OBJECT_CONTROL_MASK			= COMBATLOG_OBJECT_CONTROL_MASK			or 0x00000300
-- Unit type
local COMBATLOG_OBJECT_TYPE_PLAYER			= COMBATLOG_OBJECT_TYPE_PLAYER			or 0x00000400
local COMBATLOG_OBJECT_TYPE_NPC				= COMBATLOG_OBJECT_TYPE_NPC				or 0x00000800
local COMBATLOG_OBJECT_TYPE_PET				= COMBATLOG_OBJECT_TYPE_PET				or 0x00001000
local COMBATLOG_OBJECT_TYPE_GUARDIAN		= COMBATLOG_OBJECT_TYPE_GUARDIAN		or 0x00002000
local COMBATLOG_OBJECT_TYPE_OBJECT			= COMBATLOG_OBJECT_TYPE_OBJECT			or 0x00004000
local COMBATLOG_OBJECT_TYPE_MASK			= COMBATLOG_OBJECT_TYPE_MASK			or 0x0000FC00

-- Special cases (non-exclusive)
local COMBATLOG_OBJECT_TARGET				= COMBATLOG_OBJECT_TARGET				or 0x00010000
local COMBATLOG_OBJECT_FOCUS				= COMBATLOG_OBJECT_FOCUS				or 0x00020000
local COMBATLOG_OBJECT_MAINTANK				= COMBATLOG_OBJECT_MAINTANK				or 0x00040000
local COMBATLOG_OBJECT_MAINASSIST			= COMBATLOG_OBJECT_MAINASSIST			or 0x00080000
local COMBATLOG_OBJECT_RAIDTARGET1			= COMBATLOG_OBJECT_RAIDTARGET1			or 0x00100000
local COMBATLOG_OBJECT_RAIDTARGET2			= COMBATLOG_OBJECT_RAIDTARGET2			or 0x00200000
local COMBATLOG_OBJECT_RAIDTARGET3			= COMBATLOG_OBJECT_RAIDTARGET3			or 0x00400000
local COMBATLOG_OBJECT_RAIDTARGET4			= COMBATLOG_OBJECT_RAIDTARGET4			or 0x00800000
local COMBATLOG_OBJECT_RAIDTARGET5			= COMBATLOG_OBJECT_RAIDTARGET5			or 0x01000000
local COMBATLOG_OBJECT_RAIDTARGET6			= COMBATLOG_OBJECT_RAIDTARGET6			or 0x02000000
local COMBATLOG_OBJECT_RAIDTARGET7			= COMBATLOG_OBJECT_RAIDTARGET7			or 0x04000000
local COMBATLOG_OBJECT_RAIDTARGET8			= COMBATLOG_OBJECT_RAIDTARGET8			or 0x08000000
local COMBATLOG_OBJECT_NONE					= COMBATLOG_OBJECT_NONE					or 0x80000000
local COMBATLOG_OBJECT_SPECIAL_MASK			= COMBATLOG_OBJECT_SPECIAL_MASK			or 0xFFFF0000

local LIB_FILTER_RAIDTARGET	= bit_bor(
	COMBATLOG_OBJECT_RAIDTARGET1, COMBATLOG_OBJECT_RAIDTARGET2, COMBATLOG_OBJECT_RAIDTARGET3, COMBATLOG_OBJECT_RAIDTARGET4,
	COMBATLOG_OBJECT_RAIDTARGET5, COMBATLOG_OBJECT_RAIDTARGET6, COMBATLOG_OBJECT_RAIDTARGET7, COMBATLOG_OBJECT_RAIDTARGET8
)
local LIB_FILTER_ME = bit_bor(
	COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PLAYER
)
local LIB_FILTER_MY_PET = bit_bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PET
						)
local LIB_FILTER_PARTY = bit_bor(COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_AFFILIATION_PARTY)
local LIB_FILTER_RAID  = bit_bor(COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_AFFILIATION_RAID)
local LIB_FILTER_GROUP = bit_bor(LIB_FILTER_PARTY, LIB_FILTER_RAID)

local HotTickTimeId={
	[746]=1, -- First Aid (rank 1)
	[1159]=1,
	[3267]=1,
	[3268]=1,
	[7926]=1,
	[7927]=1,
	[23569]=1,
	[24412]=1,
	[10838]=1,
	[10839]=1,
	[23568]=1,
	[24413]=1,
	[18608]=1,
	[18610]=1,
	[23567]=1,
	[23696]=1,
	[24414]=1,
	[27030]=1,
	[27031]=1, -- First Aid (rank 12)
	[33763]=1, -- Lifebloom (rank 1) no other ranks
}

local DotTickTimeId={
	-- Mage Ticks
	[133]=2, -- Fireball (rank 1)
	[143]=2,
	[145]=2,
	[3140]=2,
	[8400]=2,
	[8401]=2,
	[8402]=2,
	[10148]=2,
	[10149]=2,
	[10150]=2,
	[10151]=2,
	[25306]=2,
	[27070]=2,
	[38692]=2, -- Fireball (rank 14)
	[11119]=2, -- Ignite (rank 1)
	[11120]=2,
	[12846]=2,
	[12847]=2,
	[12848]=2, -- Ignite (rank 5)
	[15407]=1, -- Mind Flay (rank 1)
	[17311]=1,
	[17312]=1,
	[17313]=1,
	[17314]=1,
	[18807]=1,
	[25387]=1, -- Mind Flay (rank 7)
	[980]=2, -- Curse of Agony (rank 1)
	[1014]=2,
	[6217]=2,
	[11711]=2,
	[11712]=2,
	[11713]=2,
	[27218]=2, -- Curse of Agony (rank 7)
	[603]=60, -- Curse of Doom (rank 1)
	[30910]=60, -- Curse of Doom (rank 2)
	[689]=1, -- Drain Life (rank 1) Elsia: According to wowhead it's 1. Which makes sense compared to Mind Flay...
	[699]=1,
	[709]=1,
	[7651]=1,
	[11699]=1,
	[11700]=1,
	[27219]=1,
	[27220]=1, -- Drain Life (rank 8)
	[755]=1, -- Health Funnel (rank 1)
	[3698]=1,
	[3699]=1,
	[3700]=1,
	[11693]=1,
	[11694]=1,
	[11695]=1,
	[27259]=1, -- Health Funnel (rank 8)
	[1949]=1, -- Hellfire (rank 1)
	[11683]=1,
	[11684]=1,
	[27213]=1, -- Hellfire (rank 4)
}


local CCId={
	[118]=true, -- Polymorph (rank 1)
	[12824]=true, -- Polymorph (rank 2)
	[12825]=true, -- Polymorph (rank 3)
	[12826]=true, -- Polymorph (rank 4)
	[28272]=true, -- Polymorph (rank 1:pig)
	[28271]=true, -- Polymorph (rank 1:turtle)
	[9484]=true, -- Shackle Undead (rank 1)
	[9485]=true, -- Shackle Undead (rank 2)
	[10955]=true, -- Shackle Undead (rank 3)
	[3355]=true, -- Freezing Trap Effect (rank 1)
	[14308]=true, -- Freezing Trap Effect (rank 2)
	[14309]=true, -- Freezing Trap Effect (rank 3)
	[2637]=true, -- Hibernate (rank 1)
	[18657]=true, -- Hibernate (rank 2)
	[18658]=true, -- Hibernate (rank 3)
	[6770]=true, -- Sap (rank 1)
	[2070]=true, -- Sap (rank 2)
	[11297]=true, -- Sap (rank 3)
	[6358]=true, -- Seduction (succubus)
}
	
--[[local HealBuffId={
	[33778]=true, -- Lifebloom "bloom" heal
	--[379]=true, -- Earthshield "tick" heal
}]]

local LifebloomId = 33763
local LifebloomHealId = 33778
local EarthShieldTickId = 379

local EarthShieldId = {
	[974]=true, -- Earth Shield (rank 1)
	[32593]=true, -- Earth Shield (rank 2)
	[32594]=true, -- Earth Shield (rank 3)
}


	
local PrayerOfMendingCastId = 33076 -- Prayer of Mending (rank 1)
local PrayerOfMendingAuraId = 41635 -- Prayer of Mending (when Aura is applied)
local PrayerOfMendingHealId = 33110 -- Prayer of Mending (when healing)

local RessesId={
	[2008]=true, -- Ancestral Spirit (Rank 1)
	[20609]=true, --Ancestral Spirit (Rank 2)
	[20610]=true, --Ancestral Spirit (Rank 3)
	[20776]=true, --Ancestral Spirit (Rank 4)
	[20777]=true, --Ancestral Spirit (Rank 5)
	[2006]=true, -- Resurrection (Rank 1)
	[2010]=true, -- Resurrection (Rank 2)
	[10880]=true, -- Resurrection (Rank 3)
	[10881]=true, -- Resurrection (Rank 4)
	[20770]=true, -- Resurrection (Rank 5)
	[25435]=true, -- Resurrection (Rank 6)
	[20484]=true, -- Rebirth (Rank 1)
	[20739]=true, -- Rebirth (Rank 2)
	[20742]=true, -- Rebirth (Rank 3)
	[20747]=true, -- Rebirth (Rank 4)
	[20748]=true, -- Rebirth (Rank 5)
	[26994]=true, -- Rebirth (Rank 6)
	[7328]=true, -- Redemption (Rank 1)
	[10322]=true, -- Redemption (Rank 2)
	[10324]=true, -- Redemption (Rank 3)
	[20772]=true, -- Redemption (Rank 4)
	[20773]=true, -- Redemption (Rank 5)
}
	
-- Base Events: SWING � These events relate to melee swings, commonly called �White Damage�. RANGE � These events relate to hunters shooting their bow or a warlock shooting their wand. SPELL � These events relate to spells and abilities. SPELL_CAST � These events relate to spells starting and failing. SPELL_AURA � These events relate to buffs and debuffs. SPELL_PERIODIC � These events relate to HoT, DoTs and similar effects. DAMAGE_SHIELD � These events relate to damage shields, such as Thorns ENCHANT � These events relate to temporary and permanent item buffs. ENVIRONMENTAL � This is any damage done by the world. Fires, Lava, Falling, etc.
-- Suffixes: _DAMAGE � If the event resulted in damage, here it is. _MISSED - If the event resulted in failure, such as missing, resisting or being blocked. _HEAL � If the event resulted in a heal. _ENERGIZE � If the event resulted in a power restoration. _LEECH � If the event transferred health or power. _DRAIN � If the event reduces power, but did not transfer it.
-- Special Events: PARTY_KILL � Fired when you or a party member kills something. UNIT_DIED � Fired when any nearby unit dies. 

local SPELLSCHOOL_PHYSICAL = 1
local SPELLSCHOOL_HOLY = 2
local SPELLSCHOOL_FIRE = 4
local SPELLSCHOOL_NATURE = 8
local SPELLSCHOOL_FROST = 16
local SPELLSCHOOL_SHADOW = 32
local SPELLSCHOOL_ARCANE = 64

ReRecount.SpellSchoolName = {
	[SPELLSCHOOL_PHYSICAL] = "Physical",
	[SPELLSCHOOL_HOLY] = "Holy",
	[SPELLSCHOOL_FIRE] = "Fire",
	[SPELLSCHOOL_NATURE] = "Nature",
	[SPELLSCHOOL_FROST] = "Frost",
	[SPELLSCHOOL_SHADOW] = "Shadow",
	[SPELLSCHOOL_ARCANE] = "Arcane",
}

local POWERTYPE_MANA = 0
local POWERTYPE_RAGE = 1
local POWERTYPE_FOCUS = 2
local POWERTYPE_ENERGY = 3
local POWERTYPE_HAPPINESS = 4;
local POWERTYPE_RUNES = 5;
local POWERTYPE_RUNIC_POWER = 6;

ReRecount.PowerTypeName = {
	[POWERTYPE_MANA] = "Mana",
	[POWERTYPE_RAGE] = "Rage",
	[POWERTYPE_ENERGY] = "Energy",
	[POWERTYPE_FOCUS] = "Focus",
	[POWERTYPE_HAPPINESS] = "Happiness",
	[POWERTYPE_RUNES] = "Runes",
	[POWERTYPE_RUNIC_POWER] = "Runic Power",	
}

function ReRecount:MatchGUID(nName,nGUID,nFlags)
	if not ReRecount.PlayerName or not ReRecount.PlayerGUID then
		if bit_band(nFlags, LIB_FILTER_ME) == LIB_FILTER_ME then
			ReRecount.PlayerName = nName
			ReRecount.GUID = nGUID
			return
		end
	end

	if bit_band(nFlags,LIB_FILTER_MY_PET) == LIB_FILTER_MY_PET then
		if not ReRecount.PlayerPet or not ReRecount.PlayerPetGUID or nGUID~=ReRecount.PlayerPetGUID then
			--ReRecount:Print("NewPet detected: "..nName.." "..nGUID.."("..(ReRecount.PlayerPetGUID or "nil")..")")
			ReRecount.PlayerPetGUID = nGUID
			if ReRecount.PlayerPet ~= nName then
				ReRecount.PlayerPet = nName
			end
			return
		end
	end
end

function ReRecount:SwingDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,amount, school, resisted, blocked, absorbed, critical, glancing, crushing)
	ReRecount:SpellDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,0, L["Melee"], SPELLSCHOOL_PHYSICAL, amount, school, resisted, blocked, absorbed, critical, glancing, crushing)
end

function ReRecount:SpellDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, amount, school, resisted, blocked, absorbed, critical, glancing, crushing)

	local HitType=L["Hit"]
	if critical then
		HitType=L["Crit"]
	end
	if eventtype == "SPELL_PERIODIC_DAMAGE" then
		HitType=L["Tick"]
		spellName = spellName .." ("..L["DoT"]..")"
	end
	if eventtype == "DAMAGE_SPLIT" then
		HitType=L["Split"]
	end
	if crushing then
		HitType=L["Crushing"]
	end
	if glancing	then
		HitType=L["Glancing"]
	end
--[[	if blocked then
		HitType="Block"
	end
	if absorbed then
		HitType="Absorbed"
	end--]]
	if eventtype == "RANGE_DAMAGE" then spellSchool = school end

	ReRecount:AddDamageData(srcName, dstName, spellName, ReRecount.SpellSchoolName[spellSchool], HitType, amount, resisted, srcGUID, srcFlags, dstGUID, dstFlags, spellId, blocked, absorbed)
end

function ReRecount:EnvironmentalDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,enviromentalType, amount, school, resisted, blocked, absorbed, critical, glancing, crushing)

	local HitType = L["Hit"]
	if critical then
		HitType=L["Crit"]
	end
	if crushing then
		HitType=L["Crushing"]
	end
	if glancing	then
		HitType=L["Glancing"]
	end
	--[[if blocked then
		HitType="Block"
	end
	if absorbed then
		HitType="Absorbed"
	end--]]

	ReRecount:AddDamageData("Environment", dstName, ReRecount:FixCaps(enviromentalType), ReRecount.SpellSchoolName[school], HitType, amount, resisted, srcGUID, 0, dstGUID, dstFlags, spellId, blocked, absorbed)
end

function ReRecount:FixCaps(capsstr)
	if type(capsstr)=="string" then
		return string.upper(string.sub(capsstr,1,1))..string.lower(string.sub(capsstr,2))
	else
		return nil
	end
end

function ReRecount:SwingMissed(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,missType)
	
	ReRecount:AddDamageData(srcName, dstName, L["Melee"], nil, ReRecount:FixCaps(missType),nil,nil, srcGUID, srcFlags, dstGUID, dstFlags, spellId)
end

function ReRecount:SpellMissed(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, missType)

	ReRecount:AddDamageData(srcName, dstName, spellName, nil, ReRecount:FixCaps(missType),nil,nil, srcGUID, srcFlags, dstGUID, dstFlags, spellId)
end

function ReRecount:SpellHeal(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, amount, overheal,critical)

	 if overheal == 1 and not critical then -- Elsia: Heuristic for detection 2.4 format. Fails if overheal is exactly 1 and the heal was not a crit (WotLK).
	    critical = overheal
	    overheal = nil
	end

	local healtype="Hit"
	if critical then
		healtype="Crit"
	end

	if eventtype == "SPELL_PERIODIC_HEAL" then
		healtype=L["Tick"]
		-- Not activated yet: spellName=spellName.." ("..L["HoT"]..")"
	end

	ReRecount:AddHealData(srcName, dstName, spellName, healtype, amount,overheal, srcGUID,srcFlags,dstGUID,dstFlags,spellId)-- Elsia: Overheal missing!!!
end

function ReRecount:SpellEnergize(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, amount, powerType)

	ReRecount:AddGain(dstName, srcName, spellName, amount, ReRecount.PowerTypeName[powerType], dstGUID, dstFlags, srcGUID, srcFlags, spellId)
end

local extraattacks

function ReRecount:SpellExtraAttacks(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, amount)
--[[	source = ReRecount.curr_srcName
	victim = ReRecount.curr_dstName

	local healtype="Hit"

	ReRecount:Print(ReRecount.curr_type.." "..spellName.." "..amount)
	ReRecount:AddDamageData(source, victim, spellName, ReRecount.SpellSchoolName[spellSchool], HitType, amount)--]]

	-- Elsia: Don't have use for extra attacks currently, amount is number of extra attacks it seems from combat log traces.
	
	extraattacks = extraattacks or {}
	if extraattacks[srcName] then
		ReRecount:DPrint("Double proc: "..spellName.." "..extraattacks[srcName].spellName)
	else
		extraattacks[srcName] = {}
		extraattacks[srcName].spellName = spellName
		extraattacks[srcName].amount = amount
		extraattacks[srcName].proctime = GetTime()
	end
end

function ReRecount:SpellInterrupt(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool)

	if not spellName   then
		spellName = "Melee"
	end
	local ability = extraSpellName .. " (" .. spellName .. ")"
	ReRecount:AddInterruptData(srcName, dstName, ability, srcGUID, srcFlags, dstGUID, dstFlags, extraSpellId) -- Elsia: Keep both interrupting spell and interrupted spell
end

function ReRecount:SpellDrainLeech(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, amount, powerType, extraAmount)

-- Currently unused.
end

function ReRecount:SpellAuraBroken(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool)
	if not spellName then
		spellName = "Melee"
	end
	
	local ability
	if extraSpellName then 
	        ability = spellName .. " (" .. extraSpellName .. ")"
	else
		ability = spellName .." (Melee)"
	end

	if CCId[spellId] then
		ReRecount:AddCCBreaker(srcName, dstName, ability, srcGUID, srcFlags, dstGUID, dstFlags, extraSpellId)
	end
end

function ReRecount:SpellAuraDispelledStolen(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool)

	if eventtype == "SPELL_DISPEL_FAILED" then
		return -- Not covering failures.
	end

	if not spellName then
		spellName = "Melee"
	end
	local ability = extraSpellName .. " (" .. spellName .. ")"

	ReRecount:AddDispelData(srcName, dstName, ability, srcGUID, srcFlags, dstGUID, dstFlags, extraSpellId)
end

function ReRecount:SpellAuraAppliedRemoved(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, auraType)
	
	if eventtype == "SPELL_AURA_APPLIED" then
--		if spellName==PrayerOfMending then
		if spellId==PrayerOfMendingAuraId then
			ReRecount.HealBuffs.POM_Gained(dstName)
		end
	elseif eventtype == "SPELL_AURA_REMOVED" then
		if EarthShieldId[spellId] then
			ReRecount:RemoveEarthShieldSource(dstName,dstGUID,dstFlags)
		end
	end
end

function ReRecount:SpellAuraAppliedRemovedDose(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, auraType, amount)
-- Not sure yet how to handle this

end

function ReRecount:SpellResurrect(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool)
			ReRecount:AddRes(srcName, dstName, spellName, srcGUID, srcFlags, dstGUID, dstFlags, spellId)
end

function ReRecount:SpellCastStartSuccess(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool)

	if eventtype == "SPELL_CAST_SUCCESS" then
		
--		if spellName==PrayerOfMending then
		if spellId==PrayerOfMendingCastId then
			ReRecount.HealBuffs.POM_Casted(srcName,dstName,srcGUID,srcFlags)
--		elseif Resses[spellName] and  victim then
		elseif RessesId[spellId] and  dstName then
			ReRecount:AddRes(srcName, dstName, spellName, srcGUID, srcFlags, dstGUID, dstFlags, spellId)
		elseif EarthShieldId[spellId] then
			ReRecount:AddEarthShieldSource(srcName, dstName, srcGUID, srcFlags, dstGUID, dstFlags)
		elseif LifebloomId == spellId then
			ReRecount.HealBuffs.LB_Casted(srcName,dstName,srcGUID,srcFlags)
			--ReRecount:Print("Eek5")
			--local missType = "Hit"
			--ReRecount:Print(spellName.." "..ReRecount.SpellSchoolName[spellSchool].." "..victim)
			--ReRecount:AddDamageData(srcName, dstName, spellName, ReRecount.SpellSchoolName[spellSchool], ReRecount:FixCaps(missType),nil,nil, srcGUID, srcFlags, dstGUID, dstFlags, spellId)
			-- Elsia: Currently disabled adding success casts to damage details. 
		end
		
	elseif eventtype == "SPELL_INSTAKILL" then

		--ReRecount:Print(ReRecount.curr_type .." "..source.." "..victim)
		ReRecount:AddDeathData(srcName, dstName, nil, srcGUID, srcFlags, dstGUID, dstFlags, spellId)
	end
end

-- Note: GetSpellLink(id) gets spell name from ID.
--  GetSpellInfo(id)

function ReRecount:SpellCastFailed(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool, failedType)
-- Not sure yet how to handle this, are these interrupts?
end

function ReRecount:EnchantAppliedRemoved(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellName, itemId, itemName)
-- Not sure yet how to handle this, 
end

function ReRecount:PartyKill(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags)
	--ReRecount:AddDeathData(srcName , dstName, nil, srcGUID, srcFlags, dstGUID, dstFlags, nil)
-- Could be killing blow tracker
end

function ReRecount:UnitDied(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags)
	ReRecount:AddDeathData(nil , dstName, nil, srcGUID, srcFlags, dstGUID, dstFlags, nil)
end

function ReRecount:SpellSummon(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool)
	ReRecount:AddPetCombatant(dstGUID,dstName,dstFlags,srcGUID,srcName,srcFlags)
end

function ReRecount:SpellCreate(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,spellId, spellName, spellSchool)
-- Elsia: We do nothing for these yet.
end

local EventParse =
{
	["SWING_DAMAGE"] = ReRecount.SwingDamage, -- Elsia: Melee swing damage
	["RANGE_DAMAGE"] = ReRecount.SpellDamage, -- Elsia: Ranged and spell damage types
	["SPELL_DAMAGE"] = ReRecount.SpellDamage,
	["SPELL_PERIODIC_DAMAGE"] = ReRecount.SpellDamage,
	["DAMAGE_SHIELD"] = ReRecount.SpellDamage,
	["DAMAGE_SPLIT"] = ReRecount.SpellDamage,
	["ENVIRONMENTAL_DAMAGE"] = ReRecount.EnvironmentalDamage, -- Elsia: Environmental damage
	["SWING_MISSED"] = ReRecount.SwingMissed, -- Elsia: Misses
	["RANGE_MISSED"] = ReRecount.SpellMissed,
	["SPELL_MISSED"] = ReRecount.SpellMissed,
	["SPELL_PERIODIC_MISSED"] = ReRecount.SpellMissed,
	["DAMAGE_SHIELD_MISSED"] = ReRecount.SpellMissed,
	["SPELL_HEAL"] = ReRecount.SpellHeal, -- Elsia: heals
	["SPELL_PERIODIC_HEAL"] = ReRecount.SpellHeal,
	["SPELL_ENERGIZE"] = ReRecount.SpellEnergize, -- Elsia: Energize
	["SPELL_PERIODIC_ENERGIZE"] = ReRecount.SpellEnergize,
	["SPELL_EXTRA_ATTACKS"] = ReRecount.SpellExtraAttacks, -- Elsia: Extra attacks
	["SPELL_INTERRUPT"] = ReRecount.SpellInterrupt, -- Elsia: Interrupts
	["SPELL_DRAIN"] = ReRecount.SpellDrainLeech, -- Elsia: Drains and leeches.
	["SPELL_LEECH"] = ReRecount.SpellDrainLeech,
	["SPELL_PERIODIC_DRAIN"] = ReRecount.SpellDrainLeech,
	["SPELL_PERIODIC_LEECH"] = ReRecount.SpellDrainLeech,
	["SPELL_DISPEL_FAILED"] = ReRecount.SpellAuraDispelledStolen, -- Elsia: Failed dispell
	["SPELL_AURA_DISPELLED"] = ReRecount.SpellAuraDispelledStolen, -- Removed with 2.4.3
	["SPELL_AURA_STOLEN"] = ReRecount.SpellAuraDispelledStolen, -- Removed with 2.4.3
	["SPELL_AURA_APPLIED"] = ReRecount.SpellAuraAppliedRemoved, -- Elsia: Auras
	["SPELL_AURA_REMOVED"] = ReRecount.SpellAuraAppliedRemoved,
	["SPELL_AURA_APPLIED_DOSE"] = ReRecount.SpellAuraAppliedRemovedDose, -- Elsia: Aura doses
	["SPELL_AURA_REMOVED_DOSE"] = ReRecount.SpellAuraAppliedRemovedDose,
	["SPELL_CAST_START"] = ReRecount.SpellCastStartSuccess, -- Elsia: Spell casts
	["SPELL_CAST_SUCCESS"] = ReRecount.SpellCastStartSuccess,
	["SPELL_INSTAKILL"] = ReRecount.SpellCastStartSuccess,
	["SPELL_DURABILITY_DAMAGE"] = ReRecount.SpellCastStartSuccess,
	["SPELL_DURABILITY_DAMAGE_ALL"] = ReRecount.SpellCastStartSuccess,
	["SPELL_CAST_FAILED"] = ReRecount.SpellCastFailed, -- Elsia: Spell aborts/fails
	["ENCHANT_APPLIED"] = ReRecount.EnchantAppliedRemoved, -- Elsia: Enchants
	["ENCHANT_REMOVED"] = ReRecount.EnchantAppliedRemoved,
	["PARTY_KILL"] = ReRecount.PartyKill, -- Elsia: Party killing blow
	["UNIT_DIED"] = ReRecount.UnitDied, -- Elsia: Unit died
	["UNIT_DESTROYED"] = ReRecount.UnitDied,
	["SPELL_SUMMON"] = ReRecount.SpellSummon, -- Elsia: Summons
	["SPELL_CREATE"] = ReRecount.SpellCreate, -- Elsia: Creations
	["SPELL_AURA_BROKEN"] = ReRecount.SpellAuraBroken, -- New with 2.4.3
	["SPELL_AURA_BROKEN_SPELL"] = ReRecount.SpellAuraBroken, -- New with 2.4.3
	["SPELL_AURA_REFRESH"] = ReRecount.SpellAuraAppliedRemoved, -- New with 2.4.3
	["SPELL_DISPEL"] = ReRecount.SpellAuraDispelledStolen, -- Post 2.4.3
	["SPELL_STOLEN"] = ReRecount.SpellAuraDispelledStolen, -- Post 2.4.3
	["SPELL_RESURRECT"] = ReRecount.SpellResurrect, -- Post WotLK
}

function ReRecount:CheckRetentionFromFlags(nameFlags)

	if ReRecount.db.profile.Filters.Data["Grouped"] and bit_band(nameFlags, COMBATLOG_OBJECT_AFFILIATION_MINE+COMBATLOG_OBJECT_AFFILIATION_PARTY+COMBATLOG_OBJECT_AFFILIATION_RAID)~=0 then
		return true -- Grouped
	elseif ReRecount.db.profile.Filters.Data["Self"] and bit_band(nameFlags, COMBATLOG_OBJECT_AFFILIATION_MINE+COMBATLOG_OBJECT_TYPE_PLAYER)==COMBATLOG_OBJECT_AFFILIATION_MINE+COMBATLOG_OBJECT_TYPE_PLAYER then
		return true -- Self
	elseif ReRecount.db.profile.Filters.Data["Ungrouped"] and bit_band(nameFlags, COMBATLOG_OBJECT_TYPE_PLAYER+COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= COMBATLOG_OBJECT_TYPE_PLAYER+COMBATLOG_OBJECT_REACTION_FRIENDLY then
		return true -- Ungrouped
	elseif ReRecount.db.profile.Filters.Data["Hostile"] and bit_band(nameFlags, COMBATLOG_OBJECT_CONTROL_PLAYER)~=0 then
		return true
	elseif (ReRecount.db.profile.Filters.Data["Trivial"] or ReRecount.db.profile.Filters.Data["Nontrivial"] or ReRecount.db.profile.Filters.Data["Boss"]) and bit_band(nameFlags, COMBATLOG_OBJECT_CONTROL_NPC)~=0 then
		return true
	elseif ReRecount.db.profile.Filters.Data["Pet"] and bit_band(nameFlags, COMBATLOG_OBJECT_TYPE_PET+COMBATLOG_OBJECT_TYPE_GUARDIAN)~=0 then
		if ReRecount.db.profile.Filters.Data["Self"] and bit_band(nameFlags, COMBATLOG_OBJECT_AFFILIATION_MINE)~=0 then
			return true
		elseif ReRecount.db.profile.Filters.Data["Grouped"] and  bit_band(nameFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY+COMBATLOG_OBJECT_AFFILIATION_RAID)~=0 then
			return true
		elseif ReRecount.db.profile.Filters.Data["Ungrouped"] and bit_band(nameFlags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER+COMBATLOG_OBJECT_REACTION_FRIENDLY) == COMBATLOG_OBJECT_AFFILIATION_OUTSIDER+COMBATLOG_OBJECT_REACTION_FRIENDLY then
			return true
		end
	else
		return false
	end
end

local Blizzard_CombatLog_CurrentSettings
function ReRecount:CombatLogEvent(_,timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	if not ReRecount.db.profile.GlobalDataCollect or not ReRecount.CurrentDataCollect then
		return
	end

	if not ReRecount:CheckRetentionFromFlags(srcFlags) and not ReRecount:CheckRetentionFromFlags(dstFlags) then
		return
	end

	--Blizzard_CombatLog_CurrentSettings = _G.Blizzard_CombatLog_CurrentSettings or _G.Blizzard_CombatLog_Filters.filters[_G.Blizzard_CombatLog_Filters.currentFilter]
	--ReRecount.cleventtext = "" --_G.CombatLog_OnEvent(Blizzard_CombatLog_CurrentSettings, timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	
	if srcName == nil then
		srcName = "No One"
	else
		ReRecount:MatchGUID(srcName,srcGUID,srcFlags)
	end
	if dstName == nil then
		dstName = "No One"
	else
		ReRecount:MatchGUID(dstName,dstGUID,dstFlags)
	end

	local parsefunc = EventParse[eventtype]
	
	if parsefunc then
		parsefunc(self, timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	else
		ReRecount:Print("Unknown combat log event type: "..eventtype)
	end

	-- Elsia: Damage block
	-- Elsia: This is if-chain parsing. table lookup has shown to be much faster in experiments, especially because we use function calls here too. Leaving this here for documentation.
--[[	if eventtype == "SWING_DAMAGE" then
		ReRecount:SwingDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "RANGE_DAMAGE" or eventtype == "SPELL_DAMAGE" or eventtype == "SPELL_PERIODIC_DAMAGE" or eventtype == "DAMAGE_SHIELD" or eventtype == "DAMAGE_SPLIT" then
		ReRecount:SpellDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "ENVIRONMENTAL_DAMAGE" then
		ReRecount:EnvironmentalDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SWING_MISSED" then -- Elsia: Missed block
		ReRecount:SwingMissed(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "RANGE_MISSED" or eventtype == "SPELL_MISSED" or eventtype == "SPELL_PERIODIC_MISSED" or eventtype == "DAMAGE_SHIELD_MISSED" then
		ReRecount:SpellMissed(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SPELL_HEAL" or eventtype == "SPELL_PERIODIC_HEAL" then -- Elsia: Heals
		ReRecount:SpellHeal(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SPELL_ENERGIZE" or eventtype == "SPELL_PERIODIC_ENERGIZE" then -- Elsia: Power gains
		ReRecount:SpellEnergize(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SPELL_EXTRA_ATTACKS" then
		ReRecount:SpellExtraAttacks(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SPELL_INTERRUPT" then
		ReRecount:SpellInterrupt(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SPELL_DRAIN" or eventtype == "SPELL_LEECH" or eventtype == "SPELL_PERIODIC_DRAIN" or eventtype == "SPELL_PERIODIC_LEECH" then -- Elsia: Drains & Leeches
		ReRecount:SpellDrainLeech(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SPELL_DISPEL_FAILED" or eventtype == "SPELL_AURA_DISPELLED" or eventtype == "SPELL_AURA_STOLEN" then -- Elsia: Failed dispell
		ReRecount:SpellAuraDispelledStolen(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SPELL_AURA_APPLIED" or eventtype == "SPELL_AURA_REMOVED" then
		ReRecount:SpellAuraAppliedRemoved(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SPELL_AURA_APPLIED_DOSE" or eventtype == "SPELL_AURA_REMOVED_DOSE" then
		ReRecount:SpellAuraAppliedRemovedDose(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SPELL_CAST_START" or eventtype == "SPELL_CAST_SUCCESS" or eventtype == "SPELL_INSTAKILL" or eventtype == "SPELL_DURABILITY_DAMAGE" or eventtype == "SPELL_DURABILITY_DAMAGE_ALL" then
		ReRecount:SpellCastStartSuccess(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SPELL_CAST_FAILED" then -- Elsia: Spell aborts/fails
		ReRecount:SpellCastFailed(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "ENCHANT_APPLIED" or eventtype == "ENCHANT_REMOVED" then 
		ReRecount:EnchantAppliedRemoved(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "PARTY_KILL" then
		ReRecount:PartyKill(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags)
	elseif eventtype == "UNIT_DIED" or eventtype == "UNIT_DESTROYED" then
		ReRecount:UnitDied(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags)
	elseif eventtype == "SPELL_SUMMON" then
		ReRecount:SpellSummon(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	elseif eventtype == "SPELL_CREATE" then
		ReRecount:SpellCreate(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags,...)
	else
		ReRecount:Print("Unknown combat log event type: "..eventtype)
	end]]
end

function ReRecount:SetActive(who)
	if not who then return end

	who.LastActive=ReRecount.CurTime
end

function ReRecount:AddTimeEvent(who, onWho, ability, friendly)

	if not who then return end

	local Time=GetTime()
	who.LastAbility = who.LastAbility or 0
	local Adding=Time-who.LastAbility
	
	who.LastAbility=Time
	
	if Adding>3.5 then
		Adding=3.5
	end

	Adding=math.floor(100*Adding+0.5)/100

	ReRecount:AddOwnerPetLazySyncAmount(who,"ActiveTime", Adding)
	--ReRecount:AddSyncAmount(who,"ActiveTime", Adding)
	

	ReRecount:AddAmount(who,"ActiveTime",Adding)
	ReRecount:AddTableDataSum(who,"TimeSpent",onWho,ability,Adding)

	if friendly then
		ReRecount:AddAmount(who,"TimeHeal",Adding)
		ReRecount:AddTableDataSum(who,"TimeHealing",onWho,ability,Adding)
	else
		ReRecount:AddAmount(who,"TimeDamage",Adding)
		ReRecount:AddTableDataSum(who,"TimeDamaging",onWho,ability,Adding)
	end
end


--Only care about event tracking for those we want to track deaths for
function ReRecount:AddCurrentEvent(who, eventType, incoming, number, event)
	if not who then return end
	if ReRecount.db.profile.Filters.TrackDeaths[who.type] then
		who.LastEvents = who.LastEvents or {}
		who.LastEventTimes = who.LastEventTimes or {}
		who.LastEventType = who.LastEventType or {}
		who.LastEventIncoming = who.LastEventIncoming or {}
		who.NextEventNum = who.NextEventNum or 1
		who.LastEventTimes[who.NextEventNum]=GetTime()
		who.LastEventType[who.NextEventNum]=eventType
		who.LastEventIncoming[who.NextEventNum]=incoming
		who.LastEvents[who.NextEventNum]=event --(eventType or "").." "..(abiliy or "").." "..(number or "")

		if (not who.unit) or (UnitName(who.unit)~=who.Name) and who.UnitLockout<ReRecount.UnitLockout then
			who.unit=ReRecount:FindUnit(who.Name)
			who.UnitLockout=ReRecount.CurTime
		end
		
		if who.unit then
			if UnitHealthMax(who.unit)~=100 then
				who.LastEventHealth = who.LastEventHealth or {}
				who.LastEventHealth[who.NextEventNum]=UnitHealth(who.unit).." ("..math.floor(100*UnitHealth(who.unit)/UnitHealthMax(who.unit)).."%)"
				if number then
					who.LastEventNum = who.LastEventNum or {}
					who.LastEventNum[who.NextEventNum]=100*number/UnitHealthMax(who.unit)
				elseif who.LastEventNum then
					who.LastEventNum[who.NextEventNum]=nil
				end
			else
				who.LastEventHealth = who.LastEventHealth or {}
				who.LastEventHealth[who.NextEventNum]=UnitHealth(who.unit).."%"
				if who.LastEventNum then
					who.LastEventNum[who.NextEventNum]=nil
				end
			end
			who.LastEventHealthNum = who.LastEventHealthNum or {}
			who.LastEventHealthNum[who.NextEventNum]=100*UnitHealth(who.unit)/UnitHealthMax(who.unit)
		else
			who.LastEventHealth = who.LastEventHealth or {}
			who.LastEventHealthNum = who.LastEventHealthNum or {}
			who.LastEventHealth[who.NextEventNum]="???"
			who.LastEventHealthNum[who.NextEventNum]=0
			if who.LastEventNum then
				who.LastEventNum[who.NextEventNum]=nil
			end
		end		
		
		who.NextEventNum=who.NextEventNum+1

		if who.NextEventNum>ReRecount.db.profile.MessagesTracked then
			who.NextEventNum=who.NextEventNum-ReRecount.db.profile.MessagesTracked
		end
	end
end

--Functions for adding data 

function ReRecount:AddAmount(who,datatype,amount)
	if not who then return end
	if not ReRecount.db.profile.Filters.Data[who.type] or not ReRecount.db.profile.GlobalDataCollect or not ReRecount.CurrentDataCollect then
		return
	end

	ReRecount.NewData = true -- Inform MainWindow that we got new data stored.

	--We add the data to both overall & current fight data
	who.Fights = who.Fights or {}
	who.Fights.OverallData = who.Fights.OverallData or {}
	who.Fights.OverallData[datatype] = who.Fights.OverallData[datatype] or 0
	who.Fights.OverallData[datatype]=who.Fights.OverallData[datatype]+amount
	who.Fights.CurrentFightData = who.Fights.CurrentFightData or {}
	who.Fights.CurrentFightData[datatype] = who.Fights.CurrentFightData[datatype] or 0
	who.Fights.CurrentFightData[datatype]=who.Fights.CurrentFightData[datatype]+amount

	--Now add the time data
--	if who.TimeWindows[datatype] then
	who.TimeWindows = who.TimeWindows or {}
	who.TimeWindows[datatype] = who.TimeWindows[datatype] or {}
	who.TimeWindows[datatype][ReRecount.TimeStep] = who.TimeWindows[datatype][ReRecount.TimeStep] or 0
	who.TimeWindows[datatype][ReRecount.TimeStep]=who.TimeWindows[datatype][ReRecount.TimeStep]+amount

	who.TimeLast = who.TimeLast or {}
	who.TimeLast[datatype]=ReRecount.CurTime
	who.TimeLast["OVERALL"]=ReRecount.CurTime
--	end
end

--Meant for like elemental data and this type isn't expected to be initialized 
function ReRecount:AddAmount2(who,datatype,secondary,amount)
	if not who then return end
	if not ReRecount.db.profile.Filters.Data[who.type]  or not ReRecount.db.profile.GlobalDataCollect or not ReRecount.CurrentDataCollect then
		return
	end
	if not secondary then
		ReRecount:DPrint("Empty secondary: "..datatype)
		return
	end
	
	--We add the data to both overall & current fight data
	who.Fights = who.Fights or {}
	who.Fights.OverallData = who.Fights.OverallData or {}
	who.Fights.OverallData[datatype] = who.Fights.OverallData[datatype] or {}
	who.Fights.OverallData[datatype][secondary]=(who.Fights.OverallData[datatype][secondary] or 0)+amount
	who.Fights.CurrentFightData = who.Fights.CurrentFightData or {}
	who.Fights.CurrentFightData[datatype] = who.Fights.CurrentFightData[datatype] or {}
	who.Fights.CurrentFightData[datatype][secondary]=(who.Fights.CurrentFightData[datatype][secondary] or 0)+amount
end

--Two Different Types of table functions
--First type tracks min/max & count while the other only counts the total sum in the count column
function ReRecount:AddTableDataStats(who,datatype,secondary,detailtype,amount)
	if not who then return end
	if not ReRecount.db.profile.Filters.Data[who.type] or not ReRecount.db.profile.GlobalDataCollect or not ReRecount.CurrentDataCollect then
		return
	end

	who.Fights = who.Fights or {}
	who.Fights.OverallData = who.Fights.OverallData or {}
	who.Fights.OverallData[datatype] = who.Fights.OverallData[datatype] or {}
	local CurTable=who.Fights.OverallData[datatype][secondary]

	if type(CurTable)~="table" then
		who.Fights.OverallData[datatype][secondary]=ReRecount:GetTable()
		CurTable=who.Fights.OverallData[datatype][secondary]
		CurTable.count=0
		CurTable.amount=0
		CurTable.Details=ReRecount:GetTable()
	end	

	CurTable.count=CurTable.count+1
	CurTable.amount=CurTable.amount+amount

	if type(CurTable.Details[detailtype])~="table" then
		CurTable.Details[detailtype]=ReRecount:GetTable()
		CurTable.Details[detailtype].count=0
		CurTable.Details[detailtype].amount=0
	end
	local Details=CurTable.Details[detailtype]

	Details.count=Details.count+1
	Details.amount=Details.amount+amount

	if Details.max then
		if amount>Details.max then
			Details.max=amount
		elseif amount<Details.min then
			Details.min=amount
		end
	else--If no max has been set time to initialize
		Details.max=amount
		Details.min=amount
	end
	
	--[[if type(who.Fights.CurrentFightData[datatype])~="table" then
		who.Fights.CurrentFightData[datatype]=ReRecount:GetTable()
	end]]
	who.Fights.CurrentFightData = who.Fights.CurrentFightData or {}
	who.Fights.CurrentFightData[datatype] = who.Fights.CurrentFightData[datatype] or {}
	CurTable=who.Fights.CurrentFightData[datatype][secondary]
	--Now for the current fight data
	if type(CurTable)~="table" then
		who.Fights.CurrentFightData[datatype][secondary]=ReRecount:GetTable()
		CurTable=who.Fights.CurrentFightData[datatype][secondary]
		CurTable.count=0
		CurTable.amount=0
		CurTable.Details=ReRecount:GetTable()
	end

	

	CurTable.count=CurTable.count+1
	CurTable.amount=CurTable.amount+amount

	if type(CurTable.Details[detailtype])~="table" then
		CurTable.Details[detailtype]=ReRecount:GetTable()
		CurTable.Details[detailtype].count=0
		CurTable.Details[detailtype].amount=0
	end
	Details=CurTable.Details[detailtype]

	Details.count=Details.count+1
	Details.amount=Details.amount+amount

	if Details.max then
		if amount>Details.max then
			Details.max=amount
		elseif amount<Details.min then
			Details.min=amount
		end
	else--If no max has been set time to initialize
		Details.max=amount
		Details.min=amount
	end
end
local first=false
function ReRecount:CorrectTableData(who,datatype,secondary,amount)
	if not who then return end
	if not ReRecount.db.profile.Filters.Data[who.type]   or ReRecount.db.profile.GlobalDataCollect == false  or not ReRecount.CurrentDataCollect then
		return
	end

	who.Fights = who.Fights or {}
	who.Fights.OverallData = who.Fights.OverallData or {}
	who.Fights.OverallData[datatype] = who.Fights.OverallData[datatype] or {}
	local CurTable=who.Fights.OverallData[datatype][secondary]

	if type(CurTable)~="table" then
		who.Fights.OverallData[datatype][secondary]=ReRecount:GetTable()
		CurTable=who.Fights.OverallData[datatype][secondary]
		CurTable.count=0
		CurTable.amount=0
		CurTable.Details=ReRecount:GetTable()
	end	
--[[	if not CurTable.count and not first then
		ReRecount:Print(datatype,secondary,amount)
		ReRecount:Print(debugstack())
	end]]
	if CurTable.count then
		CurTable.count=CurTable.count-1
	end
	CurTable.amount=CurTable.amount-amount

	who.Fights.CurrentFightData = who.Fights.CurrentFightData or {}
	who.Fights.CurrentFightData[datatype] = who.Fights.CurrentFightData[datatype] or {}
	CurTable=who.Fights.CurrentFightData[datatype][secondary]
	--Now for the current fight data
	if type(CurTable)~="table" then
		who.Fights.CurrentFightData[datatype][secondary]=ReRecount:GetTable()
		CurTable=who.Fights.CurrentFightData[datatype][secondary]
		CurTable.count=0
		CurTable.amount=0
		CurTable.Details=ReRecount:GetTable()
	end

	
	if CurTable.count then
		CurTable.count=CurTable.count-1
	end
	CurTable.amount=CurTable.amount-amount
end



function ReRecount:AddTableDataStatsNoAmount(who,datatype,secondary,detailtype)
	if not who then return end
	if not ReRecount.db.profile.Filters.Data[who.type] or not ReRecount.db.profile.GlobalDataCollect or not ReRecount.CurrentDataCollect then
		return
	end

	who.Fights = who.Fights or {}
	who.Fights.OverallData = who.Fights.OverallData or {}
	who.Fights.OverallData[datatype] = who.Fights.OverallData[datatype] or {}
	local CurTable=who.Fights.OverallData[datatype][secondary]

	if type(CurTable)~="table" then
		who.Fights.OverallData[datatype][secondary]=ReRecount:GetTable()
		CurTable=who.Fights.OverallData[datatype][secondary]
		CurTable.count=0
		CurTable.amount=0
		CurTable.Details=ReRecount:GetTable()
	end


	
	CurTable.count=CurTable.count+1

	if type(CurTable.Details[detailtype])~="table" then
		CurTable.Details[detailtype]=ReRecount:GetTable()
		CurTable.Details[detailtype].count=0
		CurTable.Details[detailtype].amount=0
	end
	local Details=CurTable.Details[detailtype]

	Details.count=Details.count+1

	--Now for the current fight data
	--[[if type(who.Fights.CurrentFightData[datatype])~="table" then
		who.Fights.CurrentFightData[datatype]=ReRecount:GetTable()
	end]]
	who.Fights.CurrentFightData = who.Fights.CurrentFightData or {}
	who.Fights.CurrentFightData[datatype] = who.Fights.CurrentFightData[datatype] or {}
	CurTable=who.Fights.CurrentFightData[datatype][secondary]
	if type(CurTable)~="table" then
		who.Fights.CurrentFightData[datatype][secondary]=ReRecount:GetTable()
		CurTable=who.Fights.CurrentFightData[datatype][secondary]
		CurTable.count=0
		CurTable.amount=0
		CurTable.Details=ReRecount:GetTable()
	end



	CurTable.count=CurTable.count+1

	if type(CurTable.Details[detailtype])~="table" then
		CurTable.Details[detailtype]=ReRecount:GetTable()
		CurTable.Details[detailtype].count=0
		CurTable.Details[detailtype].amount=0
	end
	Details=CurTable.Details[detailtype]

	Details.count=Details.count+1
end

function ReRecount:AddTableDataSum(who,datatype,secondary,detailtype,amount)
	if not who then return end
	if (not ReRecount.db.profile.Filters.Data[who.type]) or not ReRecount.db.profile.GlobalDataCollect  or not ReRecount.CurrentDataCollect then
		--Have to make sure this won't be used by something that needs to have data recorded for it
		
		if ReRecount.db2.combatants[secondary] then
			if not ReRecount.db.profile.Filters.Data[ReRecount.db2.combatants[secondary].type] or ReRecount.db.profile.GlobalDataCollect == false then
				return
			end
		else		
			return
		end
	end

	who.Fights = who.Fights or {}
	who.Fights.OverallData = who.Fights.OverallData or {}
	who.Fights.OverallData[datatype] = who.Fights.OverallData[datatype] or {}
	
	local CurTable=who.Fights.OverallData[datatype][secondary]
	if type(CurTable)~="table" then
		who.Fights.OverallData[datatype][secondary]=ReRecount:GetTable()
		CurTable=who.Fights.OverallData[datatype][secondary]
		CurTable.amount=0
		CurTable.Details=ReRecount:GetTable()
	end

	CurTable.amount=(CurTable.amount or 0)+amount

	if detailtype == nil then
		ReRecount:DPrint("DEBUG at: ".. (who or "nil").." "..(datatype or "nil").." ".. (secondary or "nil"))
	end

	if type(CurTable.Details[detailtype])~="table" then
		CurTable.Details[detailtype]=ReRecount:GetTable()
		CurTable.Details[detailtype].count=0
	end

	local Details=CurTable.Details[detailtype]
	Details.count=Details.count+amount

	--Now for the current fight data
	--[[if type(who.Fights.CurrentFightData[datatype])~="table" then
		who.Fights.CurrentFightData[datatype]=ReRecount:GetTable()
	end]]
	who.Fights.CurrentFightData = who.Fights.CurrentFightData or {}
	who.Fights.CurrentFightData[datatype] = who.Fights.CurrentFightData[datatype] or {}
	CurTable=who.Fights.CurrentFightData[datatype][secondary]

	if type(CurTable)~="table" then
		who.Fights.CurrentFightData[datatype][secondary]=ReRecount:GetTable()
		CurTable=who.Fights.CurrentFightData[datatype][secondary]
		CurTable.amount=0
		CurTable.Details=ReRecount:GetTable()
	end

	CurTable.amount=(CurTable.amount or 0)+amount

	if type(CurTable.Details[detailtype])~="table" then
		CurTable.Details[detailtype]=ReRecount:GetTable()
		CurTable.Details[detailtype].count=0
	end

	Details=CurTable.Details[detailtype]

	Details.count=Details.count+amount
end

-- Elsia: Borrowed shamelessly from Threat-2.0
function ReRecount:NPCID(guid)
	return tonumber(guid:sub(-12,-7),16)
end

function ReRecount:DetectPet(name, nGUID, nFlags)
	local isspecial=false
	local ownerID
	local owner
	local petName
	
	petName, owner = name:match("(.-) <(.*)>")
	
	if not petName then
		petName = name
	else
		name = petName
	end
	
	if nFlags and bit_band(nFlags, COMBATLOG_OBJECT_TYPE_PET+COMBATLOG_OBJECT_TYPE_GUARDIAN)~=0 then
		if bit_band(nFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~=0 then
			isspecial=true
			name = name.." <"..ReRecount.PlayerName..">"
			owner = ReRecount.PlayerName -- Elsia: Fix up so that owner properly gets set
			ownerID = ReRecount.PlayerGUID
			if bit_band(nFlags, COMBATLOG_OBJECT_TYPE_PET) ~=0 then
				ReRecount.PlayerPetGUID = nGUID
			else -- Guardians
				ReRecount.LatestGuardian = ReRecount.LatestGuardian + 1
				ReRecount.GuardiansGUIDs[ReRecount.LatestGuardian]=nGUID
				if ReRecount.LatestGuardian > 6 then -- Elsia: Max guardians set to 5 for now
					ReRecount.LatestGuardian = 0
				end
--[[				if ReRecount.NPCID then
					local npcid = ReRecount:NPCID(nGUID) -- Elsia: 15438 and 15352 are mobids of shaman's greater elementals
					if (npcid == 15438 or npcid == 15352) and (not ReRecount.db2.combatants[name] or ReRecount.db2.combatants[name].GUID ~= nGUID) then -- Elsia: Only Sync new elementals
						ReRecount:AnnouncePetGUID(owner,petName,nGUID)
					end
				end]]
			end
		elseif bit_band(nFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY+COMBATLOG_OBJECT_AFFILIATION_RAID)~=0 then
--[[				if bit_band(nFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) ~=0 and ReRecount.NPCID then
			local npcid = ReRecount:NPCID(nGUID)
				if npcid == 15438 or npcid == 15352 then
					local elemname = ReRecount:ActiveElementalName(nGUID)
					if elemname then
						owner = elemname:match("<(.-)>")
						if ReRecount.db2.combatants[owner] then
							ownerID = ReRecount.db2.combatants[owner].GUID
						end
						return elemname, owner, ownerID, isspecial
					end
				end
			end]]
			if nFlags and bit_band(nFlags, COMBATLOG_OBJECT_TYPE_PET)~=0 then
				owner, ownerID = ReRecount:FindOwnerPetFromGUID(name,nGUID)
			
				if owner == nil then
					owner,ownerID=ReRecount.Pets:IsUniquePet(name,nGUID,nFlags)
				end
				if owner then
					name=name.." <"..owner..">"
				else
					--ReRecount:Print("NoOwner")
				end
			elseif nFlags and bit_band(nFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN)~=0 then
				owner = ReRecount:GetGuardianOwnerByGUID(nGUID)
				ownerID = owner and ReRecount.db2.combatants[owner] and ReRecount.db2.combatants[owner].GUID
				if owner then name = name.." <"..owner..">" end
				--ReRecount:DPrint("Party guardian: "..name.." "..(nGUID or "nil").." "..(owner or "nil").." "..(ownerID or "nil"))
			end
		end
	end
	return name, owner, ownerID, isspecial
end

function ReRecount:RemoveEarthShieldSource(victim, dstGUID, dstFlags)

	local SpecialEvent=false
	local owner, ownerID
	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)
	local victimData=ReRecount.db2.combatants[victim]
	if victimData then

		victimData.EarthShieldSource = nil
		victimData.EarthShieldSourceGUID = nil
		victimData.EarthShieldSourceFlags = nil
	end
end

--[[function ReRecount:AddLifebloomSource(source, victim, srcGUID, srcFlags, dstGUID, dstFlags)
	source, owner, ownerID, SpecialEvent = ReRecount:DetectPet(source, srcGUID, srcFlags)

	if not ReRecount.db2.combatants[source] then
		ReRecount:AddCombatant(source,owner,srcGUID,srcFlags, ownerID)
	end
		
	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)

	if not ReRecount.db2.combatants[victim] then
		ReRecount:AddCombatant(victim,owner,dstGUID,dstFlags, ownerID)
	end

	if source == victim then
		--ReRecount:Print("self-shields: "..source)
		return -- Elsia: No need to store anything for self-blooming.
	end
	
	local victimData=ReRecount.db2.combatants[victim]

	--ReRecount:Print("shields: "..victim.." by "..source)
	victimData.EarthShieldSource = source
	victimData.EarthShieldSourceGUID = srcGUID
	victimData.EarthShieldSourceFlags = srcFlags

	ReRecount:CheckRetention(source)
	ReRecount:CheckRetention(victim)
end]]


function ReRecount:AddEarthShieldSource(source, victim, srcGUID, srcFlags, dstGUID, dstFlags)
	local SpecialEvent=false
	local owner, ownerID
	source, owner, ownerID, SpecialEvent = ReRecount:DetectPet(source, srcGUID, srcFlags)

	if not ReRecount.db2.combatants[source] then
		ReRecount:AddCombatant(source,owner,srcGUID,srcFlags, ownerID)
	end
		
	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)

	if not ReRecount.db2.combatants[victim] then
		ReRecount:AddCombatant(victim,owner,dstGUID,dstFlags, ownerID)
	end

	if source == victim then
		--ReRecount:Print("self-shields: "..source)
		return -- Elsia: No need to store anything for self-shielding.
	end
	
	local victimData=ReRecount.db2.combatants[victim]

	--ReRecount:Print("shields: "..victim.." by "..source)
	victimData.EarthShieldSource = source
	victimData.EarthShieldSourceGUID = srcGUID
	victimData.EarthShieldSourceFlags = srcFlags

	ReRecount:CheckRetention(source)
	ReRecount:CheckRetention(victim)
end

function ReRecount:AddDamageData(source, victim, ability, element, hittype, damage, resist, srcGUID, srcFlags, dstGUID, dstFlags, spellId, blocked, absorbed)
	--See if both the source & victim are in the tables
	local SpecialEvent=false
	local owner, ownerID

	--ReRecount:Print((source or "nil") .." "..(victim or "nil").." "..(ability or "nil").." "..(element or "nil"))
	
	source, owner, ownerID, SpecialEvent = ReRecount:DetectPet(source, srcGUID, srcFlags)

	if not ReRecount.db2.combatants[source] then
		ReRecount:AddCombatant(source,owner,srcGUID,srcFlags, ownerID)
	end
		
	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)

	if not ReRecount.db2.combatants[victim] then
		ReRecount:AddCombatant(victim,owner,dstGUID,dstFlags, ownerID)
	end

	if not ReRecount:TestRetention(source) and not ReRecount:TestRetention(victim) then
		ReRecount:CheckRetention(source)
		ReRecount:CheckRetention(victim)
		return
	end
	
	local sourceData=ReRecount.db2.combatants[source]
	local victimData=ReRecount.db2.combatants[victim]

	if not sourceData then
		ReRecount:DPrint("Missing source: "..source)
		return
	end
	
	if not victimData then
		ReRecount:DPrint("Missing target: "..victim)
		return
	end

	ReRecount:SetActive(sourceData)
	ReRecount:SetActive(victimData)

	if extraattacks and extraattacks[source] then
		if extraattacks[source].proctime < GetTime()-5 then -- This is an outdated proc of which we never saw damage contributions. Timeout at 5 seconds
			extraattacks[source] = nil
		else
			ability = ability .. " ("..extraattacks[source].spellName..")"
			extraattacks[source].amount = extraattacks[source].amount - 1
			if extraattacks[source].amount == 0 then
				extraattacks[source] = nil
			end
		end
	end
	
	--Need to add events for potential deaths
	local DPass=damage
	if DPass==0 then
		DPass=nil
	end
	ReRecount.cleventtext = source.." "..ability.." "..victim.." "..hittype
	if damage then
		ReRecount.cleventtext = ReRecount.cleventtext.." -"..damage
	end
	if resist and resist > 0 then
		ReRecount.cleventtext = ReRecount.cleventtext .." ("..resist.." resisted)"
	end
	if element then
		ReRecount.cleventtext = ReRecount.cleventtext.." ("..element..")"
	end
	ReRecount:AddCurrentEvent(sourceData, "DAMAGE", false, nil,ReRecount.cleventtext)
	ReRecount:AddCurrentEvent(victimData, "DAMAGE", true, DPass, ReRecount.cleventtext)

	--Is this friendly fire?
	local FriendlyFire=(sourceData.isFriend==victimData.isFriend) and (sourceData.isPlayer and victimData.isPlayer) -- We only care for friendly fire between players now
	
	--Before any further processing need to check if we are going to be placed in combat or in combat 
	if not ReRecount.InCombat and ReRecount.db.profile.RecordCombatOnly then
		if (not FriendlyFire) and (sourceData.inGroup or victimData.inGroup) then
			ReRecount:PutInCombat()
		else
			ReRecount:CheckRetention(source)
			ReRecount:CheckRetention(victim)
			return
		end
	end

	--Fight tracking purposes to speed up leaving combat
	sourceData.LastFightIn=ReRecount.db2.FightNum
	victimData.LastFightIn=ReRecount.db2.FightNum

	--Need to set the source as active
	ReRecount:AddTimeEvent(sourceData,victim,ability,false)
	

	--Stats for keeping track of DOT Uptime
	if hittype=="Tick" then
		--3 is default time since most abilities have 3 seconds inbetween ticks
		local time=3
--[[		if TickTime[ability] then
			time=TickTime[ability]
		end--]]
		if DotTickTimeId[spellId] then
			time=DotTickTimeId[spellId]
		end
		ReRecount:AddAmount(sourceData,"DOT_Time",time)
		ReRecount:AddTableDataSum(sourceData,"DOTs",ability,victim,time)
	end

	--Melee is always considered Melee since its handled differently from specials keep it seperate
	if ability=="Melee" then
		element="Melee"
	end

	if damage then
		--Victim always cares
		ReRecount:AddAmount(victimData,"DamageTaken",damage)		
		ReRecount:AddTableDataSum(victimData,"WhoDamaged",source,ability,damage)	

		--Sync Data
		ReRecount:AddOwnerPetLazySyncAmount(victimData,"DamageTaken", damage)
		--ReRecount:AddSyncAmount(victimData, "DamageTaken", damage)

		ReRecount:AddAmount2(victimData,"ElementTaken",element,damage)
		
		if resist then -- Elsia: Fixed bug, source has to "take" resists, blocks and absorbs.
			if hittype=="Crit" then
				resist=resist*2
			end
			ReRecount:AddAmount2(victimData,"ElementTakenResist",element,resist)
		end
		
		if blocked or hittype=="Block" then
			ReRecount:AddAmount2(victimData,"ElementTakenBlock",element,blocked)
		end
		
		if absorbed then
			ReRecount:AddAmount2(victimData,"ElementTakenAbsorb",element,absorbed)
		end
	end

	if damage then
		--Record the element type
		sourceData.AbilityType = sourceData.AbilityType or {}
		sourceData.AbilityType[ability]=element
			
		--Alright now if there was a friendly damage done or not decides where this data goes for the source
		if not FriendlyFire then
			ReRecount:AddOwnerPetLazySyncAmount(sourceData,"Damage", damage)
			--ReRecount:AddSyncAmount(sourceData, "Damage", damage)
			ReRecount:AddAmount(sourceData,"Damage",damage)	
			ReRecount:AddTableDataStats(sourceData,"Attacks",ability,hittype,damage)
			ReRecount:AddAmount2(sourceData,"ElementDone",element,damage)
		else
			--ReRecount:AddOwnerPetLazySyncAmount(sourceData,"FDamage", damage) -- We don't currently sync friendly damage
			--ReRecount:AddSyncAmount(sourceData, "FDamage", damage)
			ReRecount:AddAmount(sourceData,"FDamage",damage)
			ReRecount:AddTableDataStats(sourceData,"FAttacks",ability,hittype,damage)
			ReRecount:AddTableDataSum(sourceData,"FDamagedWho",victim,ability,damage)
		end

		-- Elsia: Moved this out because we want this recorded regardless whether it was friendly damage or not
		-- Elsia: Also removed bug, victims resist/block/absorb!
		if resist then
			ReRecount:AddAmount2(sourceData,"ElementDoneResist",element,resist)
			if resist<(damage/2.5) then
				--25% Resist
				ReRecount:AddTableDataStats(victimData,"PartialResist",ability,"25% Resist",resist)
			elseif resist<(1.25*damage) then
				--50% Resist
				ReRecount:AddTableDataStats(victimData,"PartialResist",ability,"50% Resist",resist)
			else
				--75% Resist
				ReRecount:AddTableDataStats(victimData,"PartialResist",ability,"75% Resist",resist)
			end
		else
			ReRecount:AddTableDataStats(victimData,"PartialResist",ability,"No Resist",0)
		end

		if blocked then
			ReRecount:AddAmount2(sourceData,"ElementDoneBlock",element,blocked)
			ReRecount:AddTableDataStats(victimData,"PartialBlock",ability,"Blocked",blocked)
		else
			ReRecount:AddTableDataStats(victimData,"PartialBlock",ability,"No Block",0)
		end
			
		if absorbed then
			ReRecount:AddAmount2(sourceData,"ElementDoneAbsorb",element,absorbed)
			ReRecount:AddTableDataStats(victimData,"PartialAbsorb",ability,"Absorbed",absorbed)
		else
			ReRecount:AddTableDataStats(victimData,"PartialAbsorb",ability,"No Absorb",0)
		end
			
		ReRecount:AddTableDataSum(sourceData,"DamagedWho",victim,ability,damage)	

		--Needs to be here for tracking so we don't add Friendly Damage as well
		if Tracking["DAMAGE"] then
			if Tracking["DAMAGE"][source] then
				for _, v in pairs(Tracking["DAMAGE"][source]) do
					v.func(v.pass,damage)
				end
			end

			if sourceData.inGroup and Tracking["DAMAGE"]["!RAID"] then
				for _, v in pairs(Tracking["DAMAGE"]["!RAID"]) do
					v.func(v.pass,damage)
				end
			end
		end
		
		
		--For identifying who killed when no message is triggered
		victimData.LastAttackedBy=source
		

		--Tracking for passing data to other functions	
		if Tracking["DAMAGETAKEN"] then 
			if Tracking["DAMAGETAKEN"][victim] then
				for _, v in pairs(Tracking["DAMAGETAKEN"][victim]) do
					v.func(v.pass,damage)
				end
			end

			if victimData.inGroup and Tracking["DAMAGETAKEN"]["!RAID"] then
				for _, v in pairs(Tracking["DAMAGETAKEN"]["!RAID"]) do
					v.func(v.pass,damage)
				end
			end
		end
	else
		ReRecount:AddTableDataStatsNoAmount(sourceData,"Attacks",ability,hittype)
	end


	if sourceData.inGroup and not victimData.isFriend then
		if not victimData.level then
			--ReRecount:Print(victimData.Name.." lacks level, please report") -- This happens for freezing traps intriguingly enough
			victimData.level = 1
		end
		if (victimData.level==-1) or ((ReRecount.FightingLevel~=-1) and (victimData.level>ReRecount.FightingLevel)) then
			ReRecount.FightingWho=victim
			ReRecount.FightingLevel=victimData.level
		end
	elseif victimData.inGroup and not sourceData.isFriend then
		if not sourceData.level then
			--ReRecount:Print(sourceData.Name.." lacks level, please report")
			sourceData.level = 1
		end
		if (sourceData.level==-1) or ((ReRecount.FightingLevel~=-1) and (sourceData.level>ReRecount.FightingLevel)) then
			ReRecount.FightingWho=source
			ReRecount.FightingLevel=sourceData.level
		end
	end

	--Alright if we have an element type for this ability add its hit type data
	element=sourceData.AbilityType and sourceData.AbilityType[ability] or element

	if element then
		ReRecount:AddTableDataSum(sourceData,"ElementHitsDone",element,hittype,1)
		ReRecount:AddTableDataSum(victimData,"ElementHitsTaken",element,hittype,1)
	end	

	ReRecount:CheckRetention(source)
	ReRecount:CheckRetention(victim)
end

function ReRecount:AddHealData(source, victim, ability, healtype, amount, overheal,srcGUID,srcFlags,dstGUID,dstFlags,spellId)
	--First lets figure if there was overhealing
	--Get the tables	
	local SpecialEvent=false
	local owner, ownerID
	local sourceowner
	local sourceownerID
	

	source, sourceowner, sourceownerID, SpecialEvent = ReRecount:DetectPet(source, srcGUID, srcFlags)

	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)

	if not ReRecount.db2.combatants[victim] then
		ReRecount:AddCombatant(victim,owner,dstGUID,dstFlags, ownerID) -- Elsia: Bug, owner was missing here
	end
	local victimData=ReRecount.db2.combatants[victim]

	--Might need to change who the source is here
	local oldSource=nil
	local oldsrcGUID=nil
	local oldsrcFlags=nil
	local oldowner=nil
	local oldownerID=nil
	local SpecialEvent=false
	if (source==victim) and EarthShieldTickId == spellId  then -- Elsia: source should always be victim for this spellId btw.
		source = victimData.EarthShieldSource or source
		srcGUID = victimData.EarthShieldSourceGUID or srcGUID
		srcFlags = victimData.EarthShieldSourceFlags or srcFlags
		--ReRecount:Print("Earthshieldtick! "..spellId.." "..source.." "..victim)
		if victimData.EarthShieldSource then
			owner = nil
			ownerID = nil
		end
	elseif (source==victim) and LifebloomHealId == spellId then -- Elsia: source should always be victim for this spellId btw.
		local tempsource, tempsourceId, tempsourceFlags = ReRecount.HealBuffs.LB_Healed(source)
		if tempsource then
			source = tempsource
			srcGUID = tempsourceId
			srcFlags = tempsourceFlags
			owner = nil
			ownerID = nil
		end
	end
--[[	(source==victim) and source~=ReRecount.PlayerName and HealBuffId[spellId]  then
		if ReRecount.HealBuffs:IsMyHealBuff(victimData,ability) then
			oldSource=source
			oldsrcGUID=srcGUID
			oldsrcFlags=srcFlags
			oldowner=owner
			oldownerID=ownerID
			source=ReRecount.PlayerName
			srcGUID=ReRecount.PlayerGUID
			owner = nil
			ownerID = nil
			SpecialEvent=true
		end
	end]]

	if spellId==PrayerOfMendingHealId then
		local tempsource, tempsourceId, tempsourceFlags = ReRecount.HealBuffs.POM_Healed(source)
		if tempsource then
			source = tempsource
			srcGUID = tempsourceId
			srcFlags = tempsourceFlags
			owner = nil
			ownerID = nil
		end
	end

	if not ReRecount.db2.combatants[source] or not ReRecount.db2.combatants[source] then
		ReRecount:AddCombatant(source,sourceowner,srcGUID,srcFlags,sourceownerID)
	end

	local sourceData=ReRecount.db2.combatants[source]

	if not ReRecount:TestRetention(source) and not ReRecount:TestRetention(victim) then
		ReRecount:CheckRetention(source)
		ReRecount:CheckRetention(victim)
		return
	end

	if not sourceData then
		ReRecount:DPrint("Missing source: "..source)
		return
	end
	
	if not victimData then
		ReRecount:DPrint("Missing target: "..victim)
		return
	end

	ReRecount:SetActive(sourceData)
	ReRecount:SetActive(victimData)

	--Need to add events for potential deaths
	ReRecount.cleventtext = source.." "..ability.." "..victim
	if healtype then
		ReRecount.cleventtext = ReRecount.cleventtext.." "..healtype
	end
	if amount then
		ReRecount.cleventtext = ReRecount.cleventtext.." +"..amount
	end
	
	if overheal and overheal ~= 0 then 
		ReRecount.cleventtext = ReRecount.cleventtext .." ("..overheal.." overheal)"
	end
	ReRecount:AddCurrentEvent(victimData, "HEAL", true, amount,ReRecount.cleventtext)
	if source~=victim then
		ReRecount:AddCurrentEvent(sourceData, "HEAL", false, nil,ReRecount.cleventtext)
	end

	--Before any further processing need to check if we are in combat 
	if not ReRecount.InCombat and ReRecount.db.profile.RecordCombatOnly then
		return
	end

	--Fight tracking purposes to speed up leaving combat
	
	--if not sourceData then ReRecount:DPrint("Source-less heal: "..(ability or "nil")..(source or "nil").." "..(victim or "nil").." Please report!") end
	
	if source and sourceData then sourceData.LastFightIn=ReRecount.db2.FightNum end
	victimData.LastFightIn=ReRecount.db2.FightNum

	local VictimUnit=victimData.unit

	if (not VictimUnit or victim~=UnitName(VictimUnit)) and (victimData.UnitLockout>ReRecount.UnitLockout) then
		victimData.UnitLockout=ReRecount.CurTime
		VictimUnit=ReRecount:FindUnit(victim)
		victimData.unit=VictimUnit
	end


	

	if VictimUnit and UnitHealthMax(VictimUnit)~=100 and overheal==nil then
		local HealthMissing = UnitHealthMax(VictimUnit)-UnitHealth(VictimUnit)
		if HealthMissing<amount then
			overheal=amount-HealthMissing
			amount=HealthMissing --Adjust healing considered to the correct number
		else
			overheal=0
		end
	elseif overheal == nil then
		overheal=0
	end
	ReRecount:AddOwnerPetLazySyncAmount(sourceData,"Healing", amount)
	ReRecount:AddOwnerPetLazySyncAmount(victimData,"HealingTaken", amount)
	ReRecount:AddOwnerPetLazySyncAmount(sourceData,"Overhealing", overheal)
	--ReRecount:AddSyncAmount(sourceData,"Healing", amount)
	--ReRecount:AddSyncAmount(victimData,"HealingTaken", amount)
	--ReRecount:AddSyncAmount(sourceData,"Overhealing", overheal)

--[[	if oldSource then
		if not ReRecount.db2.combatants[oldSource] then
			ReRecount:AddCombatant(oldSource,oldowner,oldsrcGUID,oldsrcFlags,oldownerID)
		end
		local old=ReRecount.db2.combatants[oldSource]
		ReRecount:AddSyncAmount(old,"Healing", amount)
		ReRecount:AddSyncAmount(old,"Overhealing", overheal)
		--ReRecount:SendHealCorrection(old.Name,amount,overheal,ability) -- Elsia: Old sync also sync'd details
		ReRecount:SendHealCorrection(old.Name,amount,overheal) -- Elsia: Old sync also sync'd details
	end]] -- Elsia: Healing correction should now be obsolete

	--Tracking for passing data to other functions
	if Tracking["HEALING"] then
		if Tracking["HEALING"][source] then
			for _, v in pairs(Tracking["HEALING"][source]) do
				v.func(v.pass,amount)
			end
		end

		if sourceData and sourceData.inGroup and Tracking["HEALING"]["!RAID"] then
			for _, v in pairs(Tracking["HEALING"]["!RAID"]) do
				v.func(v.pass,amount)
			end
		end
	end

	if Tracking["HEALINGTAKEN"] then
		if Tracking["HEALINGTAKEN"][victim] then
			for _, v in pairs(Tracking["HEALINGTAKEN"][victim]) do
				v.func(v.pass,amount)
			end
		end

		if victimData.inGroup and Tracking["HEALINGTAKEN"]["!RAID"] then
			for _, v in pairs(Tracking["HEALINGTAKEN"]["!RAID"]) do
				v.func(v.pass,amount)
			end
		end
	end

	

	--Need to set the source as active
	ReRecount:AddTimeEvent(sourceData,victim,ability,true)

	--Stats for keeping track of HOT Uptime
	if healtype=="Tick" then
		--3 is default time since most abilities have 3 seconds inbetween ticks
		local time=3
		if HotTickTimeId[spellId] then
			time=HotTickTimeId[spellId]
		end
		ReRecount:AddAmount(sourceData,"HOT_Time",time)
		ReRecount:AddTableDataSum(sourceData,"HOTs",ability,victim,time)
	end

	--No reason to add information if everything was overhealing
	if amount>0 then
		ReRecount:AddAmount(sourceData,"Healing",amount)
		ReRecount:AddAmount(victimData,"HealingTaken",amount)

		ReRecount:AddTableDataStats(sourceData,"Heals",ability,healtype,amount)
		ReRecount:AddTableDataSum(sourceData,"HealedWho",victim,ability,amount)
		ReRecount:AddTableDataSum(victimData,"WhoHealed",source,ability,amount)
	end

	--Now if there was overhealing lets add that data in
	if overheal>0 then
		ReRecount:AddAmount(sourceData,"Overhealing",overheal)
		ReRecount:AddTableDataStats(sourceData,"OverHeals",ability,healtype,overheal)
	end

	ReRecount:CheckRetention(source)
	ReRecount:CheckRetention(victim)
end

function ReRecount:AddInterruptData(source, victim, ability, srcGUID,srcFlags, dstGUID,dstFlags, spellId)
	--Get the tables	
	local SpecialEvent=false
	local owner
	local ownerID

	source, owner, ownerID, SpecialEvent = ReRecount:DetectPet(source, srcGUID, srcFlags)

	if not ReRecount.db2.combatants[source] or not ReRecount.db2.combatants[source] then
		ReRecount:AddCombatant(source,owner,srcGUID,srcFlags, ownerID)
	end -- Elsia: Until here is if pets interupts anybody.

	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)

	if not ReRecount.db2.combatants[victim] then
		ReRecount:AddCombatant(victim, owner,dstGUID,dstFlags, ownerID) -- Elsia: Bug, owner missing here
	end

	if not ReRecount:TestRetention(source) and not ReRecount:TestRetention(victim) then
		ReRecount:CheckRetention(source)
		ReRecount:CheckRetention(victim)
		return
	end
	
	local sourceData=ReRecount.db2.combatants[source]
	local victimData=ReRecount.db2.combatants[victim]

	if not sourceData then
		ReRecount:DPrint("Missing source: "..source)
		return
	end
	
	if not victimData then
		ReRecount:DPrint("Missing target: "..victim)
		return
	end
	
	ReRecount:SetActive(sourceData)
	ReRecount:SetActive(victimData)

	--Need to add events for potential deaths	
	ReRecount.cleventtext = source.." interrupts "..victim.." "..ability
	ReRecount:AddCurrentEvent(victimData,"MISC", true,nil,ReRecount.cleventtext)
	ReRecount:AddCurrentEvent(sourceData,"MISC", false,nil,ReRecount.cleventtext)

	--Friendly fire interrupt? (Duels)
	local FriendlyFire=(sourceData.isFriend==victimData.isFriend) and (sourceData.isPlayer and victimData.isPlayer) -- We only care for friendly fire between players now
	--local FriendlyFire=sourceData.isFriend==victimData.isFriend

	--Before any further processing need to check if we are going to be placed in combat or in combat 
	if not ReRecount.InCombat and ReRecount.db.profile.RecordCombatOnly then
		if (not FriendlyFire) and (sourceData.inGroup or victimData.inGroup) then
			ReRecount:PutInCombat()
		else
			ReRecount:CheckRetention(source)
			ReRecount:CheckRetention(victim)
			return
		end
	end

	--Fight tracking purposes to speed up leaving combat
	sourceData.LastFightIn=ReRecount.db2.FightNum
	victimData.LastFightIn=ReRecount.db2.FightNum

	ReRecount:AddAmount(sourceData,"Interrupts",1)
	ReRecount:AddTableDataSum(sourceData,"InterruptData",victim,ability,1)
	ReRecount:CheckRetention(source)
	ReRecount:CheckRetention(victim)
end

function ReRecount:AddDispelData(source, victim, ability,srcGUID,srcFlags,dstGUID,dstFlags,spellId)
	--Get the tables	
	local SpecialEvent=false
	local owner
	local ownerID
	
	source, owner, ownerID, SpecialEvent = ReRecount:DetectPet(source, srcGUID, srcFlags)

	if not ReRecount.db2.combatants[source] or not ReRecount.db2.combatants[source] then
		ReRecount:AddCombatant(source,owner,srcGUID,srcFlags, ownerID)
	end -- Elsia: Until here is if pets dispelled anybody.

	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)

	if not ReRecount.db2.combatants[victim] then
		ReRecount:AddCombatant(victim,owner,dstGUID,dstFlags, ownerID) -- Elsia: Bug owner missing
	end

	if not ReRecount:TestRetention(source) and not ReRecount:TestRetention(victim) then
		ReRecount:CheckRetention(source)
		ReRecount:CheckRetention(victim)
		return
	end
	
	local victimData=ReRecount.db2.combatants[victim]
	local sourceData=ReRecount.db2.combatants[source]

	if not sourceData then
		ReRecount:DPrint("Missing source: "..source)
		return
	end
	
	if not victimData then
		ReRecount:DPrint("Missing target: "..victim)
		return
	end
	
	ReRecount:SetActive(sourceData)
	ReRecount:SetActive(victimData)
	
	local FriendlyFire=(sourceData.isFriend==victimData.isFriend) and (sourceData.isPlayer and victimData.isPlayer) -- We only care for friendly fire between players now
	--local FriendlyFire=sourceData.isFriend==victimData.isFriend

	--Before any further processing need to check if we are going to be placed in combat or in combat 
	if not ReRecount.InCombat and ReRecount.db.profile.RecordCombatOnly then
		if (not FriendlyFire) and (sourceData.inGroup or victimData.inGroup) then
			ReRecount:PutInCombat()
		else
			ReRecount:CheckRetention(source)
			ReRecount:CheckRetention(victim)
			return
		end
	end

	--Fight tracking purposes to speed up leaving combat
	sourceData.LastFightIn=ReRecount.db2.FightNum
	victimData.LastFightIn=ReRecount.db2.FightNum

	--Need to add events for potential deaths	
	ReRecount.cleventtext = source.." dispels "..victim.." "..ability
	ReRecount:AddCurrentEvent(victimData, "MISC", true,nil,ReRecount.cleventtext)
	ReRecount:AddCurrentEvent(sourceData, "MISC", false,nil,ReRecount.cleventtext)

	--if FriendlyFire then
		ReRecount:AddAmount(sourceData,"Dispels",1)
		ReRecount:AddTableDataSum(sourceData,"DispelledWho",victim,ability,1)
		ReRecount:AddAmount(victimData,"Dispelled",1)
		ReRecount:AddTableDataSum(victimData,"WhoDispelled",source,ability,1)
	--end
	ReRecount:CheckRetention(source)
	ReRecount:CheckRetention(victim)
end

local deathargs={}

function ReRecount:AddDeathData(source, victim, skill,srcGUID,srcFlags,dstGUID,dstFlags,spellId)
	--Before any further processing need to check if we are in combat 
	local SpecialEvent=false
	local owner
	local ownerID
	
	if not ReRecount.InCombat and ReRecount.db.profile.RecordCombatOnly then
		--ReRecount:Print("Death out of combat, not recorded")
		return
	end

	if source and type(source) == "string" then -- Elsia: Fix bug when death doesn't have a killer
	
		source, owner, ownerID, SpecialEvent = ReRecount:DetectPet(source, srcGUID, srcFlags)

		if not ReRecount.db2.combatants[source] or not ReRecount.db2.combatants[source] then
			ReRecount:AddCombatant(source,owner,srcGUID,srcFlags, ownerID)
		end -- Elsia: Until here is if pets heal anybody.
	end
		
	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)

	--Get the tables	
	if not ReRecount.db2.combatants[victim] then
		ReRecount:AddCombatant(victim, owner,dstGUID,dstFlags, ownerID) -- Elsia: Bug owner missing
	end

	local victimData=ReRecount.db2.combatants[victim]
	local sourceData

	if not victimData then return end
	
	--Fight tracking purposes to speed up leaving combat
	victimData.LastFightIn=ReRecount.db2.FightNum

	--Need to add events for potential deaths	
	if source and source~=victim then -- Elsia: May be worth removing the source~=victim check
		if not ReRecount.db2.combatants[source] or not ReRecount.db2.combatants[source] then
			ReRecount:AddCombatant(source,owner,srcGUID,srcFlags, ownerID) -- Elsia: Potential owner bug here
		end
		sourceData=ReRecount.db2.combatants[source]
		sourceData.LastFightIn=ReRecount.db2.FightNum
		ReRecount:AddCurrentEvent(sourceData, "MISC", false)
	end	
	
	ReRecount.cleventtext = victim.." dies."
	ReRecount:AddCurrentEvent(victimData, "MISC", true,nil,ReRecount.cleventtext)

	--This saves who/what killed the victim
	if source then
		victimData.LastKilledBy=source
		victimData.LastKilledAt=GetTime()
	elseif skill then
		victimData.LastKilledBy=skill
		victimData.LastKilledAt=GetTime()
	else
		--The case where we actually add a deathcount
		ReRecount:AddAmount(victimData,"DeathCount",1)
	end

	--We delay the saving of the event logs just in case more messages come later
	if ReRecount.db.profile.Filters.TrackDeaths[victimData.type] then
		--ReRecount:ScheduleTimer(ReRecount.HandleDeath,2,ReRecount,victim,GetTime(),dstGUID,dstFlags)
		deathargs[1]=victim
		deathargs[2]=GetTime()
		deathargs[3]=dstGUID
		deathargs[4]=dstFlags
		ReRecount:ScheduleTimer("HandleDeath",2,deathargs)
	else
			ReRecount:CheckRetention(victim)
	end
	ReRecount:CheckRetention(source)
end

function ReRecount:HandleDeath(arg)
	local SpecialEvent=false
	local owner
	local ownerID

	local victim,DeathTime,dstGUID,dstFlags = unpack(arg)
	
	
	
--[[	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)

	if not ReRecount.db2.combatants[victim].Init then
		ReRecount:AddCombatant(victim,owner,dstGUID,dstFlags, ownerID)
	end]]
	
	if not ReRecount.db2.combatants[victim] then
		return
	end

	local who=ReRecount.db2.combatants[victim]

	
	local num=ReRecount.db.profile.MessagesTracked
	local DeathLog=ReRecount:GetTable()

	DeathLog.DeathAt=ReRecount.CurTime
	DeathLog.Messages=ReRecount:GetTable()
	DeathLog.MessageTimes=ReRecount:GetTable()
	DeathLog.MessageType=ReRecount:GetTable()
	DeathLog.MessageIncoming=ReRecount:GetTable()
	DeathLog.Health=ReRecount:GetTable()
	DeathLog.HealthNum=ReRecount:GetTable()
	DeathLog.EventNum=ReRecount:GetTable()

	if who.LastKilledBy and math.abs(who.LastKilledAt-DeathTime)<2 then
		DeathLog.KilledBy=who.LastKilledBy
	elseif who.LastAttackedBy then
		DeathLog.KilledBy=who.LastAttackedBy
		who.LastAttackedBy=nil
	end
			
	local offset
	for i=1,num do
		offset=math.fmod(who.NextEventNum+i+num-2,num)+1
		if who.LastEvents[offset] and (who.LastEventTimes[offset]-DeathTime)>-15 then
			DeathLog.MessageTimes[#DeathLog.MessageTimes+1]=who.LastEventTimes[offset]-DeathTime
			DeathLog.Messages[#DeathLog.Messages+1]=who.LastEvents[offset] or ""
			DeathLog.MessageType[#DeathLog.MessageType+1]=who.LastEventType[offset] or "MISC"
			DeathLog.MessageIncoming[#DeathLog.MessageIncoming+1]=who.LastEventIncoming[offset] or false
			DeathLog.Health[#DeathLog.Health+1]=who.LastEventHealth[offset] or 0
			DeathLog.HealthNum[#DeathLog.HealthNum+1]=who.LastEventHealthNum[offset] or 0
			DeathLog.EventNum[#DeathLog.HealthNum]=who.LastEventNum and who.LastEventNum[offset] or 0
		end
	end

	who.DeathLogs = who.DeathLogs or {}
	tinsert(who.DeathLogs,1,DeathLog)
	--who.DeathLogs[#who.DeathLogs+1]=DeathLog
	ReRecount:CheckRetention(victim)
end

function ReRecount:AddMiscData(source, victim,srcGUID,srcFlags,dstGUID,dstFlags)
	if not ReRecount.InCombat and ReRecount.db.profile.RecordCombatOnly then
		return
	end

	local SpecialEvent=false
	local owner
	local ownerID

	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)

	--Get the tables
	if not ReRecount.db2.combatants[victim].Init then
		--If the victim doesn't exist we don't care
		return
	end

	source, owner, ownerID, SpecialEvent = ReRecount:DetectPet(source, srcGUID, srcFlags)
	
	if not ReRecount.db2.combatants[source] or not ReRecount.db2.combatants[source] then
		ReRecount:AddCombatant(source,owner,srcGUID,srcFlags,ownerID)
	end

	local sourceData=ReRecount.db2.combatants[source]
	local victimData=ReRecount.db2.combatants[victim]

	--Need to add events for potential deaths
	ReRecount.cleventtext = source.." misc "..victim
	ReRecount:AddCurrentEvent(sourceData, "MISC", false,nil,ReRecount.cleventtext)
	ReRecount:AddCurrentEvent(victimData, "MISC", true,nil,ReRecount.cleventtext)
	ReRecount:CheckRetention(source)
	ReRecount:CheckRetention(victim)
end

function ReRecount:AddMiscVictimData(victim)
	if not ReRecount.InCombat and ReRecount.db.profile.RecordCombatOnly then
		return
	end

	--Get the tables
	if not ReRecount.db2.combatants[victim] then
		--Lets not add events for someone who doesn't exist
		return
	end

	local victimData=ReRecount.db2.combatants[victim]

	--Need to add events for potential deaths
	ReRecount.cleventtext = victim.." misc."
	ReRecount:AddCurrentEvent(victimData, "MISC", true,nil,ReRecount.cleventtext)
	ReRecount:CheckRetention(victim)
end

function ReRecount:AddCCBreaker(source, victim, ability,srcGUID,srcFlags,dstGUID,dstFlags)
	--Get the tables
	local SpecialEvent=false
	local owner
	local ownerID

	source, owner, ownerID, SpecialEvent = ReRecount:DetectPet(source, srcGUID, srcFlags)

	if not ReRecount.db2.combatants[source] or not ReRecount.db2.combatants[source] then
		ReRecount:AddCombatant(source,owner,srcGUID,srcFlags, ownerID)
	end -- Elsia: Until here is if pets heal anybody.

	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)

	if not ReRecount.db2.combatants[victim] then
		ReRecount:AddCombatant(victim,owner,dstGUID,dstFlags, ownerID)
	end

	local sourceData=ReRecount.db2.combatants[source]
	local victimData=ReRecount.db2.combatants[victim]

	ReRecount:SetActive(sourceData)
	ReRecount:SetActive(victimData)

	--Is this friendly fire?
	local FriendlyFire=(sourceData.isFriend==victimData.isFriend) and (sourceData.isPlayer and victimData.isPlayer) -- We only care for friendly fire between players now
	--local FriendlyFire=sourceData.isFriend==victimData.isFriend
	
	--Before any further processing need to check if we are going to be placed in combat or in combat 
	if not ReRecount.InCombat and ReRecount.db.profile.RecordCombatOnly then
		if (not FriendlyFire) and (sourceData.inGroup or victimData.inGroup) then
			ReRecount:PutInCombat()
		else
			ReRecount:CheckRetention(source)
			ReRecount:CheckRetention(victim)
			return
		end
	end

	--Fight tracking purposes to speed up leaving combat
	sourceData.LastFightIn=ReRecount.db2.FightNum
	victimData.LastFightIn=ReRecount.db2.FightNum
	
	if not FriendlyFire then
		ReRecount:AddAmount(sourceData,"CCBreak",1)
		ReRecount:AddTableDataSum(sourceData,"CCBroken",ability,victim,1)
	end
	ReRecount:CheckRetention(source)
	ReRecount:CheckRetention(victim)
end


function ReRecount:AddGain(source, victim, ability, amount, attribute,srcGUID,srcFlags,dstGUID,dstFlags,spellId)
	--Get the tables
	
	local SpecialEvent=false
	local owner
	local ownerID

	source, owner, ownerID, SpecialEvent = ReRecount:DetectPet(source, srcGUID, srcFlags)

	if not ReRecount.db2.combatants[source] or not ReRecount.db2.combatants[source] then
		ReRecount:AddCombatant(source,owner,srcGUID,srcFlags,ownerID)
	end -- Elsia: Until here is if pets heal anybody.

	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)
	if not ReRecount.db2.combatants[victim] then
		ReRecount:AddCombatant(victim,owner,dstGUID,dstFlags,ownerID)
	end -- Elsia: Until here is if pets heal anybody.

	local sourceData=ReRecount.db2.combatants[source]

	ReRecount:SetActive(sourceData)

	local DataAmount, DataTable, DataTable2

	if attribute=="Mana" then
		DataAmount="ManaGain"
		DataTable="ManaGained"
		DataTable2="ManaGainedFrom"
	elseif attribute=="Energy" or attribute=="Focus" then -- Elsia: Focus for pet.
		DataAmount="EnergyGain"
		DataTable="EnergyGained"
		DataTable2="EnergyGainedFrom"
	elseif attribute=="Rage" then
		DataAmount="RageGain"
		DataTable="RageGained"
		DataTable2="RageGainedFrom"
	else
		ReRecount:CheckRetention(source)
		ReRecount:CheckRetention(victim)
		return
	end

	ReRecount:AddAmount(sourceData,DataAmount,amount)
	ReRecount:AddTableDataSum(sourceData,DataTable,ability,victim,amount)
	ReRecount:AddTableDataSum(sourceData,DataTable2,victim,ability,amount)
	ReRecount:CheckRetention(source)
	ReRecount:CheckRetention(victim)
end

function ReRecount:AddRes(source, victim, ability,srcGUID,srcFlags, dstGUID,dstFlags,spellId)
	--Get the tables

	if not ReRecount.db2.combatants[source] or not ReRecount.db2.combatants[source] then
		ReRecount:AddCombatant(source, nil, srcGUID,srcFlags)
	end

	
	local sourceData=ReRecount.db2.combatants[source]

	ReRecount:SetActive(sourceData)

	local SpecialEvent=false
	local owner
	local ownerID

	victim, owner, ownerID, SpecialEvent = ReRecount:DetectPet(victim, dstGUID, dstFlags)

	ReRecount:AddAmount(sourceData,"Ressed",1)
	ReRecount:AddTableDataSum(sourceData,"RessedWho",victim,ability,1)
	ReRecount:CheckRetention(source)
	ReRecount:CheckRetention(victim)
end

--Potential Tracking
--"DAMAGE"
--"DAMAGETAKEN"
--"HEALING"
--"HEALINGTAKEN"

--function ReRecount:FPSUpdate(pass)
--end

function ReRecount:RegisterTracking(id, who, stat, func, pass)
	--Special trackers handled first
	
	local idtoken
	
	if stat=="FPS" then
		idtoken=ReRecount:ScheduleRepeatingTimer(function() func(pass,GetFramerate()*0.1) end,0.1) -- id.."_TRACKER",
		--return -- Elsia: Removed this so we store tokens
	elseif stat=="LAG" then
		idtoken=ReRecount:ScheduleRepeatingTimer(function() local _, _, lag = GetNetStats(); func(pass,lag*0.1) end,0.1)
	elseif stat=="UP_TRAFFIC" then
		idtoken=ReRecount:ScheduleRepeatingTimer(function() local _, up  = GetNetStats(); func(pass,1024*up*0.1) end,0.1)
	elseif stat=="DOWN_TRAFFIC" then
		idtoken=ReRecount:ScheduleRepeatingTimer(function() local down  = GetNetStats(); func(pass,1024*down*0.1) end,0.1)
	elseif stat=="AVAILABLE_BANDWIDTH" then
		idtoken=ReRecount:ScheduleRepeatingTimer(function() func(pass,ChatThrottleLib:UpdateAvail()*0.1) end,0.1)
	end
	
	if type(Tracking[stat])~="table" then
		Tracking[stat]=ReRecount:GetTable()
	end

	if type(Tracking[stat][who])~="table" then
		Tracking[stat][who]=ReRecount:GetTable()
	end

	if type(Tracking[stat][who][id])~="table" then
		Tracking[stat][who][id]=ReRecount:GetTable()
	end

	Tracking[stat][who][id].func=func
	Tracking[stat][who][id].pass=pass
	Tracking[stat][who][id].token=idtoken
end	

function ReRecount:UnregisterTracking(id, who, stat)
	if stat=="FPS" or stat=="LAG" or stat=="UP_TRAFFIC" or stat=="DOWN_TRAFFIC" or stat=="AVAILABLE_BANDWIDTH" then
		ReRecount:CancelTimer(Tracking[stat][who][id].token) -- Was id.."_TRACKER"
		return
	end

	if type(Tracking[stat])~="table" or type(Tracking[stat][who])~="table"  then
		return
	end

	Tracking[stat][who][id]=nil
end


