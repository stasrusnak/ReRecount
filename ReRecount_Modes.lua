local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale( "ReRecount" )
local Epsilon=0.000000000000000001

local revision = tonumber(string.sub("$Revision: 73072 $", 12, -3))
if ReRecount.Version < revision then ReRecount.Version = revision end

--.MainTitle = What you see on the window title 
--.TopNames = Names of the entries for the top data
--.TopAmount = What we call the amount for the top
--.BotNames = Names of the entries for the bottom
--.BotMin = The minimum label for bottom
--.BotAvg = The average label for bottom
--.BotMax = The minimum label for bottom
--.BotAmount = Label for what the amount is on the bottom
local DetailTitles={}
DetailTitles.Attacks={
	TopNames = L["Ability Name"],
	TopCount = L["Count"],
	TopAmount = L["Damage"],
	BotNames = L["Type"],
	BotMin = L["Min"],
	BotAvg = L["Avg"],
	BotMax = L["Max"],
	BotAmount = L["Count"]
}

DetailTitles.Resisted={
	TopNames = L["Ability Name"],
	TopCount = "Count",
	TopAmount = L["Resisted"],
	BotNames = L["Type"],
	BotMin = L["Min"],
	BotAvg = L["Avg"],
	BotMax = L["Max"],
	BotAmount = L["Count"]
}

DetailTitles.Blocked={
	TopNames = L["Ability Name"],
	TopCount = "",
	TopAmount = L["Blocked"],
	BotNames = L["Type"],
	BotMin = L["Min"],
	BotAvg = L["Avg"],
	BotMax = L["Max"],
	BotAmount = L["Count"]
}

DetailTitles.Absorbed={
	TopNames = L["Ability Name"],
	TopCount = "",
	TopAmount = L["Absorbed"],
	BotNames = L["Type"],
	BotMin = L["Min"],
	BotAvg = L["Avg"],
	BotMax = L["Max"],
	BotAmount = L["Count"]
}

DetailTitles.DamagedWho={
	TopNames = L["Player/Mob Name"],
	TopCount = "",
	TopAmount = L["Damage"],
	BotNames = L["Attack Name"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Damage"]
}

DetailTitles.DamageTime={
	TopNames = L["Player/Mob Name"],
	TopCount = "",
	TopAmount = L["Time (s)"],
	BotNames = L["Attack Name"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Time (s)"]
}

DetailTitles.Heals={
	TopNames = L["Heal Name"],
	TopCount = L["Count"],
	TopAmount = L["Heal"],
	BotNames = L["Type"],
	BotMin = L["Min"],
	BotAvg = L["Avg"],
	BotMax = L["Max"],
	BotAmount = L["Count"]
}

DetailTitles.HealedWho={
	TopNames = L["Player/Mob Name"],
	TopCount = "",
	TopAmount = L["Healed"],
	BotNames = L["Heal Name"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Healed"]
}

DetailTitles.OverHeals={
	TopNames = L["Heal Name"],
	TopCount = "",
	TopAmount = L["Overheal"],
	BotNames = L["Type"],
	BotMin = L["Min"],
	BotAvg = L["Avg"],
	BotMax = L["Max"],
	BotAmount = L["Count"]
}

DetailTitles.HealTime={
	TopNames = L["Player/Mob Name"],
	TopCount = "",
	TopAmount = L["Time (s)"],
	BotNames = L["Heal Name"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Time (s)"]
}

DetailTitles.ActiveTime={
	TopNames = L["Player/Mob Name"],
	TopCount = "",
	TopAmount = L["Time (s)"],
	BotNames = L["Ability"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Time (s)"]
}


DetailTitles.DOTs={
	TopNames = L["Ability Name"],
	TopCount = "",
	TopAmount = L["DOT Time"],
	BotNames = L["Ticked on"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Duration"]
}

DetailTitles.HOTs={
	TopNames = L["Ability Name"],
	TopCount = "",
	TopAmount = L["HOT Time"],
	BotNames = L["Ticked on"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Duration"]
}

DetailTitles.Interrupts={
	TopNames = L["Interrupted Who"],
	TopCount = "",
	TopAmount = L["Interrupts"],
	BotNames = L["Interrupted"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Count"]
}

DetailTitles.Ressed={
	TopNames = L["Ressed Who"],
	TopCount = "",
	TopAmount = L["Times"],
	BotNames = L["Ability"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Count"]
}


DetailTitles.Dispels={
	TopNames = L["Who"],
	TopCount = "",
	TopAmount = L["Dispels"],
	BotNames = L["Dispelled"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Count"]
}

DetailTitles.CC={
	TopNames = L["Broke"],
	TopCount = "",
	TopAmount = L["Count"],
	BotNames = L["Broke On"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Count"]
}

DetailTitles.Gained={
	TopNames = L["Ability"],
	TopCount = "",
	TopAmount = L["Gained"],
	BotNames = L["From"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Gained"]
}

DetailTitles.GainedFrom={
	TopNames = L["From"],
	TopCount = "",
	TopAmount = L["Gained"],
	BotNames = L["Ability"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Gained"]
}

DetailTitles.Network={
	TopNames = L["Prefix"],
	TopCount = "",
	TopAmount = L["Messages"],
	BotNames = L["Distribution"],
	BotMin = "",
	BotAvg = "",
	BotMax = "",
	BotAmount = L["Messages"]
}

local DataModes={}

function ReRecount:MergedPetDamageDPS(data,fight)
	if not data or not data.Fights or not data.Fights[fight] then return 0,0 end
	local PetAmount=0
	local PetTime=0
	local Time=data.Fights[fight].ActiveTime or 0
	if ReRecount.db.profile.MergePets and data.Pet then
		for v,k in pairs(data.Pet) do
			if ReRecount.db2.combatants[k] and ReRecount.db2.combatants[k].Fights and ReRecount.db2.combatants[k].Fights[fight] then
				if ReRecount.db2.combatants[k].Fights[fight].Damage and ReRecount.db2.combatants[k].Fights[fight].Damage > 0 then -- Ignore pets which didn't do any damage like non-damage totems or idle pets.
					PetAmount=PetAmount + (ReRecount.db2.combatants[k].Fights[fight].Damage or 0)
					PetTime=PetTime + (ReRecount.db2.combatants[k].Fights[fight].ActiveTime or 0)
				end
			end
		end
		if Time<PetTime then
			Time=PetTime
		end
	end
	
	local damage = data.Fights[fight].Damage or 0
	
	if Time == 0 then
		damage = 0
		PetAmount = 0
		Time = Epsilon
	end
	
	return (damage + PetAmount), (damage + PetAmount)/Time
end

function DataModes:DamageReturner(data, num)
	if not data then return 0,0 end

	local damage, dps = ReRecount:MergedPetDamageDPS(data,ReRecount.db.profile.CurDataSet)
	if num==1 then
		return damage, dps
	end

	return damage, {{data.Fights[ReRecount.db.profile.CurDataSet].Attacks,L["'s Hostile Attacks"],DetailTitles.Attacks},{data.Fights[ReRecount.db.profile.CurDataSet].DamagedWho," "..L["Damaged Who"],DetailTitles.DamagedWho},{data.Fights[ReRecount.db.profile.CurDataSet].PartialResist,L["'s Partial Resists"],DetailTitles.Resisted},{data.Fights[ReRecount.db.profile.CurDataSet].TimeDamaging,L["'s Time Spent Attacking"],DetailTitles.DamageTime}}
end

function DataModes:DPSReturner(data, num)
	if not data then return 0 end

	local _, dps = ReRecount:MergedPetDamageDPS(data,ReRecount.db.profile.CurDataSet)

	if num==1 then
		return dps
	end

	return dps, {{data.Fights[ReRecount.db.profile.CurDataSet].Attacks,L["'s Hostile Attacks"],DetailTitles.Attacks},{data.Fights[ReRecount.db.profile.CurDataSet].DamagedWho," "..L["Damaged Who"],DetailTitles.DamagedWho},{data.Fights[ReRecount.db.profile.CurDataSet].PartialResist,L["'s Partial Resists"],DetailTitles.Resisted},{data.Fights[ReRecount.db.profile.CurDataSet].TimeDamaging,L["'s Time Spent Attacking"],DetailTitles.DamageTime}}
end


function DataModes:FriendlyDamageReturner(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].FDamage or 0)
	end

	return (data.Fights[ReRecount.db.profile.CurDataSet].FDamage or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].FAttacks,L["'s Friendly Fire"],DetailTitles.Attacks},{data.Fights[ReRecount.db.profile.CurDataSet].FDamagedWho," "..L["Friendly Fired On"],DetailTitles.DamagedWho}}
end

function DataModes:DamageTakenReturner(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].DamageTaken or 0)
	end

	return (data.Fights[ReRecount.db.profile.CurDataSet].DamageTaken or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].WhoDamaged," "..L["Took Damage From"],DetailTitles.DamagedWho}}
end

function DataModes:HealingReturner(data, num)
	if not data then return 0, 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].Healing or 0), (data.Fights[ReRecount.db.profile.CurDataSet].Healing or 0)/((data.Fights[ReRecount.db.profile.CurDataSet].ActiveTime or 0) + Epsilon)
	end


	return (data.Fights[ReRecount.db.profile.CurDataSet].Healing or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].Heals,L["'s Effective Healing"],DetailTitles.Heals},{data.Fights[ReRecount.db.profile.CurDataSet].HealedWho," "..L["Healed Who"],DetailTitles.HealedWho},{data.Fights[ReRecount.db.profile.CurDataSet].OverHeals,L["'s Overhealing"],DetailTitles.OverHeals},{data.Fights[ReRecount.db.profile.CurDataSet].TimeHealing,L["'s Time Spent Healing"],DetailTitles.HealTime}}
end

function DataModes:HealingTaken(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].HealingTaken or 0)
	end


	return (data.Fights[ReRecount.db.profile.CurDataSet].HealingTaken or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].WhoHealed," "..L["was Healed by"],DetailTitles.HealedWho}}
end

function DataModes:OverhealingReturner(data, num)
	if not data then return 0 end
	local overhealing = data.Fights[ReRecount.db.profile.CurDataSet].Overhealing or 0
	if num==1 then
		local OverhealPercent
		OverhealPercent=(math.floor(1000*overhealing/(overhealing+(data.Fights[ReRecount.db.profile.CurDataSet].Healing or 0)+Epsilon)+0.5)/10).."%"
		return overhealing, OverhealPercent
	end

	return overhealing, {{data.Fights[ReRecount.db.profile.CurDataSet].OverHeals,L["'s Overhealing"],DetailTitles.OverHeals},{data.Fights[ReRecount.db.profile.CurDataSet].Heals,L["'s Effective Healing"],DetailTitles.Heals},{data.Fights[ReRecount.db.profile.CurDataSet].HealedWho," "..L["Healed Who"],DetailTitles.HealedWho}}
end

function DataModes:DeathReturner(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].DeathCount or 0)
	end

	return (data.Fights[ReRecount.db.profile.CurDataSet].DeathCount or 0), {{data.DeathLogs, ReRecount.SetDeathDetails, ReRecount.SetDeathLogDetails}}
end

function DataModes:DOTReturner(data, num)
	if not data then return 0,0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].DOT_Time or 0), (data.Fights[ReRecount.db.profile.CurDataSet].DOT_Time or 0)/((data.Fights[ReRecount.db.profile.CurDataSet].ActiveTime or 0)+Epsilon)
	end

	return (data.Fights[ReRecount.db.profile.CurDataSet].DOT_Time or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].DOTs,L["'s DOT Uptime"],DetailTitles.DOTs}}
end

function DataModes:HOTReturner(data, num)
	if not data then return 0,0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].HOT_Time or 0), (data.Fights[ReRecount.db.profile.CurDataSet].HOT_Time or 0)/((data.Fights[ReRecount.db.profile.CurDataSet].ActiveTime or 0)+ Epsilon)
	end

	return (data.Fights[ReRecount.db.profile.CurDataSet].HOT_Time or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].HOTs,L["'s HOT Uptime"],DetailTitles.HOTs}}
end

function DataModes:InterruptReturner(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].Interrupts or 0)
	end

	return (data.Fights[ReRecount.db.profile.CurDataSet].Interrupts or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].InterruptData,L["'s Interrupts"],DetailTitles.Interrupts}}
end

function DataModes:Ressed(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].Ressed or 0)
	end

	return (data.Fights[ReRecount.db.profile.CurDataSet].Ressed or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].RessedWho,L["'s Resses"],DetailTitles.Ressed}}
end

function DataModes:Dispels(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].Dispels or 0)
	end

	return (data.Fights[ReRecount.db.profile.CurDataSet].Dispels or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].DispelledWho,L["'s Dispels"],DetailTitles.Dispels}}
end

function DataModes:Dispelled(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].Dispelled or 0)
	end

	return (data.Fights[ReRecount.db.profile.CurDataSet].Dispelled or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].WhoDispelled," "..L["was Dispelled by"],DetailTitles.Dispels}}
end

function DataModes:ActiveTime(data, num)
	if not data then return 0 end
	if num==1 then
		return (math.floor((data.Fights[ReRecount.db.profile.CurDataSet].ActiveTime or 0)*100)/100 or 0)
	end

	return (math.floor((data.Fights[ReRecount.db.profile.CurDataSet].ActiveTime or 0)*100)/100 or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].TimeSpent,L["'s Time Spent"],DetailTitles.ActiveTime},{data.Fights[ReRecount.db.profile.CurDataSet].TimeDamaging,L["'s Time Spent Attacking"],DetailTitles.DamageTime},{data.Fights[ReRecount.db.profile.CurDataSet].TimeHealing,L["'s Time Spent Healing"],DetailTitles.HealTime}}
end

function DataModes:PolyBreak(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].CCBreak or 0)
	end
	return (data.Fights[ReRecount.db.profile.CurDataSet].CCBreak or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].CCBroken," "..L["CC Breaking"],DetailTitles.CC}}
end

function DataModes:ManaGained(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].ManaGain or 0)
	end
	return (data.Fights[ReRecount.db.profile.CurDataSet].ManaGain or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].ManaGained,L["'s Mana Gained"],DetailTitles.Gained},{data.Fights[ReRecount.db.profile.CurDataSet].ManaGainedFrom,L["'s Mana Gained From"],DetailTitles.GainedFrom}}
end

function DataModes:EnergyGained(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].EnergyGain or 0)
	end
	return (data.Fights[ReRecount.db.profile.CurDataSet].EnergyGain or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].EnergyGained,L["'s Energy Gained"],DetailTitles.Gained},{data.Fights[ReRecount.db.profile.CurDataSet].EnergyGainedFrom,L["'s Energy Gained From"],DetailTitles.GainedFrom}}
end

function DataModes:RageGained(data, num)
	if not data then return 0 end
	if num==1 then
		return (data.Fights[ReRecount.db.profile.CurDataSet].RageGain or 0)
	end
	return (data.Fights[ReRecount.db.profile.CurDataSet].RageGain or 0), {{data.Fights[ReRecount.db.profile.CurDataSet].RageGained,L["'s Rage Gained"],DetailTitles.Gained},{data.Fights[ReRecount.db.profile.CurDataSet].RageGainedFrom,L["'s Rage Gained From"],DetailTitles.GainedFrom}}
end

--Some code for table management from Ace2
local new, del
do
	local cache = setmetatable({},{__mode='k'})
	function new()
		local t = next(cache)
		if t then
			cache[t] = nil
			return t
		else
			return {}
		end
	end
	
	function del(t)
		for k in pairs(t) do
			t[k] = nil
		end
		cache[t] = true
		return nil
	end
end


local function ReRecountSortFunc(a,b)
	if a[2]>b[2] then
		return true
	end
	return false
end


function ReRecount:AddSortedTooltipData(title,data,num)
	local SortedData=ReRecount:GetTable()
	GameTooltip:AddLine(title,1,0.82,0)

	local total=Epsilon
	local i=0
	if data then
		for k,v in pairs(data) do
			if v.amount then
				i=i+1
				if not SortedData[i] then
					SortedData[i]=ReRecount:GetTable()
				end
				SortedData[i][1]=k
				SortedData[i][2]=v.amount
				
				total=total+v.amount
			end		
		end
	end
		
	if num>i then
		num=i
	end

	table.sort(SortedData,ReRecountSortFunc)

	for i=1,num do
		if SortedData[i] then
			GameTooltip:AddDoubleLine(i..". "..SortedData[i][1],SortedData[i][2].." ("..math.floor(100*SortedData[i][2]/total).."%)",1,1,1,1,1,1)
		end
	end

	ReRecount:FreeTableRecurse(SortedData)
end

--The various tooltip functions used for each of the main window data displays
local TooltipFuncs={}
function TooltipFuncs:Damage(name,data)
	if data then
		local SortedData,total
		GameTooltip:ClearLines()
		GameTooltip:AddLine(name)
		ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Damage Abilities"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].Attacks,3)
		GameTooltip:AddLine("")
		ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Attacked"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].DamagedWho,3)
		if ReRecount.db.profile.MergePets and data.Pet --[[and ReRecount.db2.combatants[data.Pet[table.getn(data.Pet)] ].Init]] then
			local petindex = table.getn(data.Pet)
			if data.Pet[petindex] and ReRecount.db2.combatants[data.Pet[petindex]] then
				if ReRecount.db2.combatants[data.Pet[petindex]].Fights[ReRecount.db.profile.CurDataSet] then
					local Damage=ReRecount.db2.combatants[data.Pet[petindex]] and ReRecount.db2.combatants[data.Pet[petindex]].Fights and ReRecount.db2.combatants[data.Pet[petindex]].Fights[ReRecount.db.profile.CurDataSet].Damage or 0 
					Damage=Damage/(Damage+(data.Fights[ReRecount.db.profile.CurDataSet].Damage or 0))
					GameTooltip:AddLine(" ")
					GameTooltip:AddDoubleLine(L["Pet"]..":",data.Pet[petindex].." ("..math.floor(Damage*100+0.5).."%)",nil,nil,nil,1,1,1)
					ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Pet Damage Abilities"],ReRecount.db2.combatants[data.Pet[petindex] ].Fights and ReRecount.db2.combatants[data.Pet[petindex] ].Fights[ReRecount.db.profile.CurDataSet].Attacks,3)
					GameTooltip:AddLine("")
					ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Pet Attacked"],ReRecount.db2.combatants[data.Pet[petindex] ].Fights and ReRecount.db2.combatants[data.Pet[petindex] ].Fights[ReRecount.db.profile.CurDataSet].DamagedWho,3)
				end
			end
		end

		GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
	end
end

function TooltipFuncs:FDamage(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Friendly Attacks"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].FAttacks,3)
	GameTooltip:AddLine("")
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Friendly Fired On"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].FDamagedWho,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:DamageTaken(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Attacked by"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].WhoDamaged,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:Healing(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Heals"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].Heals,3)
	GameTooltip:AddLine("")
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Healed"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].HealedWho,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:HealingTaken(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Healed By"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].WhoHealed,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:Overhealing(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Over Heals"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].OverHeals,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:DOTs(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["DOTs"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].DOTs,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:HOTs(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["HOTs"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].HOTs,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:Interrupts(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Interrupted"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].InterruptData,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:Dispels(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Dispelled"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].DispelledWho,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:Dispelled(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Dispelled By"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].WhoDispelled,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:ActiveTime(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Attacked/Healed"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].TimeSpent,3)
	local Heal,Damage
	Heal=data.Fights[ReRecount.db.profile.CurDataSet].TimeHeal or 0
	Damage=data.Fights[ReRecount.db.profile.CurDataSet].TimeDamage or 0
	local Total=Heal+Damage+Epsilon
	Heal=100*Heal/Total
	Damage=100*Damage/Total
	GameTooltip:AddDoubleLine(L["Time Damaging"]..":",math.floor(Damage+0.5).."%",nil,nil,nil,1,1,1)
	GameTooltip:AddDoubleLine(L["Time Healing"]..":",math.floor(Heal+0.5).."%",nil,nil,nil,1,1,1)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:ManaGained(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Mana Abilities"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].ManaGained,3)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Mana Sources"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].ManaGainedFrom,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:EnergyGained(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Energy Abilities"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].EnergyGained,3)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Energy Sources"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].EnergyGainedFrom,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)
end

function TooltipFuncs:RageGained(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Rage Abilities"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].RageGained,3)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Rage Sources"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].RageGainedFrom,3)
	GameTooltip:AddLine("<"..L["Click for more Details"]..">",0,0.9,0)

end

function TooltipFuncs:DeathCounts(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	GameTooltip:Hide()
end

function TooltipFuncs:CCBroken(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["CC's Broken"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].CCBroken,3)
end

function TooltipFuncs:Ressed(name,data)
	local SortedData,total
	GameTooltip:ClearLines()
	GameTooltip:AddLine(name)
	ReRecount:AddSortedTooltipData(L["Top 3"].." "..L["Ressed"],data and data.Fights[ReRecount.db.profile.CurDataSet] and data.Fights[ReRecount.db.profile.CurDataSet].RessedWho,3)
end


local MainWindowModes={
{L["Damage Done"],DataModes.DamageReturner,TooltipFuncs.Damage,nil,{"DAMAGE",L["'s DPS"]},nil,"Damage"},
{L["DPS"],DataModes.DPSReturner,TooltipFuncs.Damage,nil,{"DAMAGE","'s DPS"},nil,"Damage"},
{L["Friendly Fire"],DataModes.FriendlyDamageReturner,TooltipFuncs.FDamage},
{L["Damage Taken"],DataModes.DamageTakenReturner,TooltipFuncs.DamageTaken,nil,{"DAMAGETAKEN",L["'s DTPS"]},nil,"DamageTaken"},
{L["Healing Done"],DataModes.HealingReturner,TooltipFuncs.Healing,nil,{"HEALING",L["'s HPS"]},nil,"Healing"},
{L["Healing Taken"],DataModes.HealingTaken,TooltipFuncs.HealingTaken,nil,{"HEALINGTAKEN",L["'s HTPS"]},nil,"HealingTaken"},
{L["Overhealing Done"],DataModes.OverhealingReturner,TooltipFuncs.Overhealing},
{L["Deaths"],DataModes.DeathReturner,TooltipFuncs.DeathCounts},
{L["DOT Uptime"],DataModes.DOTReturner,TooltipFuncs.DOTs,nil,nil,nil,nil},
{L["HOT Uptime"],DataModes.HOTReturner,TooltipFuncs.HOTs,nil,nil,nil,nil},
{L["Dispels"],DataModes.Dispels,TooltipFuncs.Dispels,nil,nil,nil,nil},
{L["Dispelled"],DataModes.Dispelled,TooltipFuncs.Dispelled,nil,nil,nil,nil},
{L["Interrupts"],DataModes.InterruptReturner,TooltipFuncs.Interrupts,nil,nil,nil,nil},
{L["Ressers"],DataModes.Ressed,TooltipFuncs.Ressed,nil,nil,nil,nil},
{L["CC Breakers"],DataModes.PolyBreak,TooltipFuncs.CCBroken,nil,nil,nil,nil},
{L["Activity"],DataModes.ActiveTime,TooltipFuncs.ActiveTime,nil,nil,nil,nil},
{L["Mana Gained"],DataModes.ManaGained,TooltipFuncs.ManaGained},
{L["Energy Gained"],DataModes.EnergyGained,TooltipFuncs.EnergyGained},
{L["Rage Gained"],DataModes.RageGained,TooltipFuncs.RageGained},
}

function ReRecount:AddModeTooltip(lname,modefunc,toolfunc,...)
	tinsert(MainWindowModes,{lname,modefunc,toolfunc,...})
	ReRecount:SetupMainWindow()
end

function ReRecount:SetupMainWindow()
	ReRecount:LoadMainWindowData(MainWindowModes)	
end