LibStub:GetLibrary("AceComm-3.0"):Embed(ReRecount)
LibStub:GetLibrary("AceSerializer-3.0"):Embed(ReRecount)

local revision = tonumber(string.sub("$Revision: 75264 $", 12, -3))
if ReRecount.Version < revision then ReRecount.Version = revision end

ReRecount.MinimumV=70425 -- Because !BugGrabber sucks!
local MinimumV = ReRecount.MinimumV

-- Elsia: This is straight from GUIDRegistryLib-0.1 by ArrowMaster.

local COMBATLOG_OBJECT_AFFILIATION_MINE		= COMBATLOG_OBJECT_AFFILIATION_MINE		or 0x00000001
local COMBATLOG_OBJECT_AFFILIATION_PARTY	= COMBATLOG_OBJECT_AFFILIATION_PARTY	or 0x00000002
local COMBATLOG_OBJECT_AFFILIATION_RAID		= COMBATLOG_OBJECT_AFFILIATION_RAID		or 0x00000004
local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER	= COMBATLOG_OBJECT_AFFILIATION_OUTSIDER	or 0x00000008
-- Reaction
local COMBATLOG_OBJECT_REACTION_FRIENDLY	= COMBATLOG_OBJECT_REACTION_FRIENDLY	or 0x00000010
-- Ownership
local COMBATLOG_OBJECT_CONTROL_PLAYER		= COMBATLOG_OBJECT_CONTROL_PLAYER		or 0x00000100
-- Unit type
local COMBATLOG_OBJECT_TYPE_PLAYER			= COMBATLOG_OBJECT_TYPE_PLAYER			or 0x00000400
local COMBATLOG_OBJECT_TYPE_GUARDIAN		= COMBATLOG_OBJECT_TYPE_GUARDIAN		or 0x00002000

-- Setting up some useful flag combos to bootstrap synced combatants that need to be added.
local PARTY_GUARDIAN_FLAGS = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_REACTION_FRIENDLY + COMBATLOG_OBJECT_CONTROL_PLAYER + COMBATLOG_OBJECT_TYPE_GUARDIAN
local PARTY_PET_FLAGS = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_REACTION_FRIENDLY + COMBATLOG_OBJECT_CONTROL_PLAYER + COMBATLOG_OBJECT_TYPE_PET
local PARTY_GUARDIAN_OWNER_FLAGS = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_REACTION_FRIENDLY + COMBATLOG_OBJECT_CONTROL_PLAYER + COMBATLOG_OBJECT_TYPE_PLAYER


-- Elsia: Generic Sync code here

function ReRecount:CheckVisible()

	local _ , instanceType = IsInInstance()
	
	if instanceType == "pvp" then return end

	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers(), 1 do 
			local unitid = "raid"..i
			if not UnitIsVisible(unitid) and UnitExists(unitid) then
				local name = UnitName(unitid)
				local combatant = ReRecount.db2.combatants[name]
			
				if not combatant then
					ReRecount:AddCombatant(name,nil,UnitGUID(unitid),COMBATLOG_OBJECT_AFFILIATION_RAID+COMBATLOG_OBJECT_TYPE_PLAYER+COMBATLOG_OBJECT_REACTION_FRIENDLY,nil)
					combatant = ReRecount.db2.combatants[name]
				end
			
				ReRecount.db2.combatants[name].lazysync = true
				ReRecount.lazysync = ReRecount.lazysync or ReRecount:CheckRetention(name)
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers(), 1 do 
			local unitid = "party"..i
			if not UnitIsVisible(unitid) and UnitExists(unitid) then
				local name = UnitName(unitid)
				local combatant = ReRecount.db2.combatants[name]
			
				if not combatant then
					ReRecount:AddCombatant(name,nil,UnitGUID(unitid),COMBATLOG_OBJECT_AFFILIATION_PARTY+COMBATLOG_OBJECT_TYPE_PLAYER+COMBATLOG_OBJECT_REACTION_FRIENDLY,nil)
					combatant = ReRecount.db2.combatants[name]
				end
			
				ReRecount.db2.combatants[name].lazysync = true
				ReRecount.lazysync = ReRecount.lazysync or ReRecount:CheckRetention(name)
			end
		end
	end
end

function ReRecount:SendSelf(target)
	-- Prepare self
	local myname = ReRecount.PlayerName
	local combatant = ReRecount.db2.combatants[myname]
	
	if not combatant then
		return
	end
	
	local serialdata
	local damage = ReRecount:GetLazySyncAmount(myname,myname,"Damage") or 0
	local damagetaken = ReRecount:GetLazySyncAmount(myname,myname,"DamageTaken") or 0
	local healing = ReRecount:GetLazySyncAmount(myname,myname,"Healing") or 0
	local healingtaken = ReRecount:GetLazySyncAmount(myname,myname,"HealingTaken") or 0
	local overhealing = ReRecount:GetLazySyncAmount(myname,myname,"Overhealing") or 0
	local activetime = ReRecount:GetLazySyncAmount(myname,myname,"ActiveTime") or 0
	serialdata = ReRecount:Serialize("PS",myname,myname,damage,damagetaken,healing,overhealing,healingtaken,activetime)
	
	-- Prepare Pets
	local data=combatant	
	local serialpetdata = {}
	
	if data.Pet then
		for i=1,#data.Pet do
			local petname = data.Pet[i]
			if ReRecount:GetLazySyncTouched(myname,petname) then
				local damage = ReRecount:GetLazySyncAmount(myname,petname,"Damage") or 0
				local damagetaken = ReRecount:GetLazySyncAmount(myname,petname,"DamageTaken") or 0
				local healing = ReRecount:GetLazySyncAmount(myname,petname,"Healing") or 0
				local healingtaken = ReRecount:GetLazySyncAmount(myname,petname,"HealingTaken") or 0
				local overhealing = ReRecount:GetLazySyncAmount(myname,petname,"Overhealing") or 0
				local activetime = ReRecount:GetLazySyncAmount(myname,petname,"ActiveTime") or 0
				if  damage + damagetaken + healing + overhealing + healingtaken ~= 0 then
					tinsert(serialpetdata, ReRecount:Serialize("PS",myname,petname,damage,damagetaken,healing,overhealing,healingtaken,activetime))
					ReRecount:ClearLazySyncTouched(myname, petname)
				end
			end
		end
	end

	-- Sync self
	ReRecount:SendCommMessage("ReRecount",serialdata,"WHISPER",target)
	-- Sync pets
	for i=1,#serialpetdata do
		ReRecount:SendCommMessage("ReRecount",serialpetdata[i],"WHISPER",target) 
	end
end

function ReRecount:BroadcastLazySync()

	if not ReRecount.lazysync and not ReRecount.Debug then return end -- Elsia: Nothing to lazy sync

	local _ , instanceType = IsInInstance()
	
	if instanceType == "pvp" then return end
	
	ReRecount.lazysync = false
	
	local validdata
	-- Prepare self
	local myname = ReRecount.PlayerName
	local combatant = ReRecount.db2.combatants[myname]
	
	if not combatant then
		return
	end
	--local myrecord = combatant.Sync
	local serialdata
	if ReRecount:GetLazySyncTouched(myname,myname) then
		local damage = ReRecount:GetLazySyncAmount(myname,myname,"Damage") or 0
		local damagetaken = ReRecount:GetLazySyncAmount(myname,myname,"DamageTaken") or 0
		local healing = ReRecount:GetLazySyncAmount(myname,myname,"Healing") or 0
		local healingtaken = ReRecount:GetLazySyncAmount(myname,myname,"HealingTaken") or 0
		local overhealing = ReRecount:GetLazySyncAmount(myname,myname,"Overhealing") or 0
		local activetime = ReRecount:GetLazySyncAmount(myname,myname,"ActiveTime") or 0
		if  damage + damagetaken + healing + overhealing + healingtaken ~= 0 then
			serialdata = ReRecount:Serialize("PU",myname,myname,damage,damagetaken,healing,overhealing,healingtaken,activetime)
			validdata = true
			ReRecount:ClearLazySyncTouched(myname, myname)
		end
	end
	
	-- Prepare Pets
	local data=combatant	
	local serialpetdata = {}
	
	if data and data.Pet then
		for i=1,#data.Pet do
			--local petrecord = ReRecount.db2.combatants[data.Pet[i]] and ReRecount.db2.combatants[data.Pet[i]].Sync
			local petname = data.Pet[i]
			if ReRecount:GetLazySyncTouched(myname,petname) then
				local damage = ReRecount:GetLazySyncAmount(myname,petname,"Damage") or 0
				local damagetaken = ReRecount:GetLazySyncAmount(myname,petname,"DamageTaken") or 0
				local healing = ReRecount:GetLazySyncAmount(myname,petname,"Healing") or 0
				local healingtaken = ReRecount:GetLazySyncAmount(myname,petname,"HealingTaken") or 0
				local overhealing = ReRecount:GetLazySyncAmount(myname,petname,"Overhealing") or 0
				local activetime = ReRecount:GetLazySyncAmount(myname,petname,"ActiveTime") or 0
				if  damage + damagetaken + healing + overhealing + healingtaken ~= 0 then
					tinsert(serialpetdata, ReRecount:Serialize("PU",myname,petname,damage,damagetaken,healing,overhealing,healingtaken,activetime))
					validdata = true
					ReRecount:ClearLazySyncTouched(myname, petname)
				end
			end
		end
	end

	-- Prepare bosses
	local serialbossdata = {}
	
	local plevel = ReRecount.db2.combatants[ReRecount.PlayerName].level
	
	if not plevel then
		plevel = UnitLevel("player")
	end
	
	
	for k,v in pairs(ReRecount.db2.combatants) do
		if v.type == "Boss" or (v.level and v.level > plevel+2) then
			--ReRecount:Print("Boss: "..k)
			--local myrecord = v.Sync
			if ReRecount:GetLazySyncTouched(myname,k) then
				local damage = ReRecount:GetLazySyncAmount(myname,k,"Damage") or 0
				local damagetaken = ReRecount:GetLazySyncAmount(myname,k,"DamageTaken") or 0
				local healing = ReRecount:GetLazySyncAmount(myname,k,"Healing") or 0
				local healingtaken = ReRecount:GetLazySyncAmount(myname,k,"HealingTaken") or 0
				local overhealing = ReRecount:GetLazySyncAmount(myname,k,"Overhealing") or 0
				local activetime = ReRecount:GetLazySyncAmount(myname,k,"ActiveTime") or 0
				if  damage + damagetaken + healing + overhealing + healingtaken ~= 0 then
					tinsert(serialbossdata, ReRecount:Serialize("PU",myname,k,damage,damagetaken,healing,overhealing,healingtaken,activetime))
				end
				validdata = true
				ReRecount:ClearLazySyncTouched(myname, k)
			end
		end
	end

	if not validdata then
		return
	end
	
	-- This is for testing. It'll whisper the player so you see syncs yourself.
	if ReRecount.Debug then
		local name = ReRecount.PlayerName
		local combatant = ReRecount.db2.combatants[name]
		if combatant and combatant.lazysync or ReRecount.Debug then
			-- Sync self
			if serialdata then
				ReRecount:SendCommMessage("ReRecount",serialdata,"WHISPER",name) 
			end

			-- Sync pets
			for i=1,#serialpetdata do
				--ReRecount:Print("Pet"..i..": "..serialpetdata[i])
				ReRecount:SendCommMessage("ReRecount",serialpetdata[i],"WHISPER",name) 
			end
		
			-- Sync bosses
			for i=1,#serialbossdata do
				--ReRecount:Print("Boss"..i..": "..serialbossdata[i])
				ReRecount:SendCommMessage("ReRecount",serialbossdata[i],"WHISPER",name)
			end
			
			-- Done syncing, thank you very much.
			
			combatant.lazysync = nil				
		end
	end

	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers(), 1 do --GetNumRaidMembers()
			if UnitExists("raid"..i) then
				local name, realm = UnitName("raid"..i)
				
				if ReRecount.VerNum and ReRecount.VerNum[name] and not realm then -- Elsia: Only sync if we have a valid version, and on same realm
				
					local combatant = ReRecount.db2.combatants[name]
					if combatant and combatant.lazysync and name~= ReRecount.PlayerName and UnitIsConnected(name) then -- We don't sync with self
						-- Sync self
						if serialdata then
							ReRecount:SendCommMessage("ReRecount",serialdata,"WHISPER",name)
						end

						-- Sync pets
						for i=1,#serialpetdata do
							ReRecount:SendCommMessage("ReRecount",serialpetdata[i],"WHISPER",name) 
						end
					
						-- Sync bosses
						for i=1,#serialbossdata do
							ReRecount:SendCommMessage("ReRecount",serialbossdata[i],"WHISPER",name)
						end
						combatant.lazysync = nil				
					end
				end
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers(), 1 do 
			if UnitExists("party"..i) then
				local name, realm = UnitName("party"..i)
				if ReRecount.VerNum and ReRecount.VerNum[name] and not realm then -- Elsia: Only sync if we have a valid version, and on same realm
					local combatant = ReRecount.db2.combatants[name]
					if combatant and combatant.lazysync and name~= ReRecount.PlayerName and UnitIsConnected(name) then -- We don't sync with self
						-- Sync self
						if serialdata then
							ReRecount:SendCommMessage("ReRecount",serialdata,"WHISPER",name) 
						end

						-- Sync pets
						for i=1,#serialpetdata do
							--ReRecount:Print("Pet"..i..": "..serialpetdata[i])
							ReRecount:SendCommMessage("ReRecount",serialpetdata[i],"WHISPER",name) 
						end
					
						-- Sync bosses
						for i=1,#serialbossdata do
							--ReRecount:Print("Boss"..i..": "..serialbossdata[i])
							ReRecount:SendCommMessage("ReRecount",serialbossdata[i],"WHISPER",name)
						end
						combatant.lazysync = nil				
					end
				end
			end
		end
	end
end

local SyncTypes =
{
	["Damage"]=true,
	["DamageTaken"]=true,
	["Healing"]=true,
	["Overhealing"]=true,
	["HealingTaken"]=true,
	["ActiveTime"]=true
}

local syncin = {}

function ReRecount:OnCommReceive(prefix, Msgs, distribution, target)
	if distribution == "WHISPER" then
		local worked, cmd, owner, name
		worked, cmd,owner,name,syncin["Damage"],syncin["DamageTaken"],syncin["Healing"],syncin["OverHealing"],syncin["HealingTaken"],syncin["ActiveTime"] = ReRecount:Deserialize(Msgs)
		if worked == true then
			if cmd == "PU" then -- Player Update
				ReRecount:DPrint(cmd .." "..owner.." "..name.." "..(syncin["Damage"] or "nil").." "..(syncin["DamageTaken"] or "nil").." "..(syncin["Healing"] or "nil").." "..(syncin["OverHealing"] or "nil").." "..(syncin["HealingTaken"] or "nil").." "..(syncin["ActiveTime"] or "nil"))
				if type(name)~="number" and (not ReRecount.VerNum[owner] or ReRecount.VerNum[owner]>=MinimumV) then
					local combatant = ReRecount.db2.combatants[name]
					if not combatant then
						local nameFlags
						local petowner = name:match("<(.-)>")
						if owner == name or not petowner then -- Three possibilities: owner == name is self, owner == petowner is pet, else boss
							nameFlags = PARTY_GUARDIAN_OWNER_FLAGS
						else
							nameFlags = PARTY_PET_FLAGS
						end
						ReRecount:AddCombatant(name,petowner and owner,nil,nameFlags,nil)
						combatant = ReRecount.db2.combatants[name]
					end
					
					if ReRecount:CheckRetention(name) then
						local who = combatant

						for k,_ in pairs(SyncTypes) do
							local localamount = ReRecount:GetLazySyncAmount(owner, name, k)
							local syncamount = syncin[k]
							if syncamount and localamount and syncamount > localamount then
							
								if localamount*0.8 < syncamount and syncamount > 20000 then
									ReRecount:DPrint("Sync anomaly: "..localamount.." "..syncamount)
								else
									ReRecount:DPrint("Sync "..k.." for: "..syncamount-localamount)
								end
								
								ReRecount:AddAmount(who,k,syncamount-localamount)
								ReRecount:AddLazySyncAmount(owner,name,k,syncamount-localamount)
							elseif syncamount and localamount and syncamount == localamount then
								--ReRecount:DPrint("clean: "..localamount.."=="..syncamount)
							end
						end
					end
				end
			elseif cmd == "PS" then -- Player data set (when first meeting up)
				ReRecount:DPrint(cmd .." "..owner.." "..name.." "..(syncin["Damage"] or "nil").." "..(syncin["DamageTaken"] or "nil").." "..(syncin["Healing"] or "nil").." "..(syncin["OverHealing"] or "nil").." "..(syncin["HealingTaken"] or "nil").." "..(syncin["ActiveTime"] or "nil"))
				if type(name)~="number" and (not ReRecount.VerNum[owner] or ReRecount.VerNum[owner]>=MinimumV) then
					local combatant = ReRecount.db2.combatants[name]
					if not combatant then
						local nameFlags
						local petowner = name:match("<(.-)>")
						if owner == name or not petowner then
							nameFlags = PARTY_GUARDIAN_OWNER_FLAGS
						else
							nameFlags = PARTY_PET_FLAGS
						end
						ReRecount:DPrint("Creating combatant from PS: "..name.." "..(petowner or  "nil"))
						ReRecount:AddCombatant(name,petowner and owner,nil,nameFlags,nil) -- This could be bad.
						combatant = ReRecount.db2.combatants[name]
					end
					
					if ReRecount:CheckRetention(name) then
						local who = combatant
				
						ReRecount:DPrint("PS with retention: "..name)
						for k,_ in pairs(SyncTypes) do
							local syncamount = syncin[k]
							if syncamount  then -- This could be bad.
								ReRecount:DPrint("PS setting: "..k)
								ReRecount:SetLazySyncAmount(owner,name,k,syncamount)
							else
								ReRecount:DPrint("PS NOT setting: "..k)
							end
						end
					else
						ReRecount:DPrint("PS WITHOUT retention: "..name)
					end
				end
			elseif cmd == "VS" then -- Version Whisper
				-- owner == originator, damage == version string :D
				--local owner = name
				local version = name
				if type(version)~="number" then
					ReRecount.VerNum[owner]=tonumber(string.match(version,"Revision: (%d+)")) -- Elsia: Old format
				else
					ReRecount.VerNum[owner] =version
				end
				if not ReRecount.VerNum[owner] or ReRecount.VerNum[owner]<MinimumV then
					ReRecount.VerTable[owner]="|cffff2020Incompatible|r "..version
				else
					ReRecount.VerTable[owner]=version
				end
			end
		end
	elseif distribution == "RAID" then
		local worked, cmd, owner, pet, petGUID
		worked, cmd, owner, pet, petGUID = ReRecount:Deserialize(Msgs)
		if worked == true then
			if cmd == "RS" then -- Reset broadcast
				local name = owner
				local combatant = ReRecount.db2.combatants[name]
				if not combatant then
					ReRecount:AddCombatant(name,nil,nil,COMBATLOG_OBJECT_AFFILIATION_RAID+COMBATLOG_OBJECT_TYPE_PLAYER+COMBATLOG_OBJECT_REACTION_FRIENDLY,nil)
					combatant = ReRecount.db2.combatants[name]
				end
				if ReRecount:CheckRetention(name) then
					ReRecount:DPrint("Received RS and retaining: "..name)
					ReRecount:ResetLazySyncData(name)
				else
					ReRecount:DPrint("Received RS and NOT retaining: "..name)
				end
			elseif cmd == "VS" or cmd == "VQ" then -- Version Broadcast
				-- owner == originator, pet == version string :D
				local version = pet
				--ReRecount:Print(cmd.." "..owner.." "..version)
				ReRecount.VerTable=ReRecount.VerTable or {} -- Elsia: This really shouldn't happen but it does!
				ReRecount.VerNum=ReRecount.VerNum or {}
				if type(version)~="number" then
					ReRecount.VerNum[owner]=tonumber(string.match(version,"Revision: (%d+)")) -- Elsia: Old format
				else
					ReRecount.VerNum[owner] =version
				end
				if not ReRecount.VerNum[owner] or ReRecount.VerNum[owner]<MinimumV then
					ReRecount.VerTable[owner]="|cffff2020Incompatible|r "..version
				else
					ReRecount.VerTable[owner]=version
				end
				if cmd == "VQ" then
					ReRecount:SendVersion(owner) -- Return own version if requested.
				end
			end
		end
	end
end

function ReRecount:ConfigComm()
	ReRecount.VerTable={}
	ReRecount.VerNum={}

	ReRecount:RegisterComm("ReRecount", "OnCommReceive")	
	ReRecount:RequestVersion()
	
	if ReRecount.Debug and GetNumPartyMembers() == 0 and GetNumRaidMembers() ==0 then
		local owner = ReRecount.PlayerName or UnitName("player")
		local version = ReRecount.Version 
		ReRecount.VerTable=ReRecount.VerTable or {} -- Elsia: This really shouldn't happen but it does!
		ReRecount.VerNum=ReRecount.VerNum or {}
		if type(version)~="number" then
			ReRecount.VerNum[owner]=tonumber(string.match(version,"Revision: (%d+)")) -- Elsia: Old format
		else
			ReRecount.VerNum[owner] =version
		end
		if not ReRecount.VerNum[owner] or ReRecount.VerNum[owner]<MinimumV then
			ReRecount.VerTable[owner]="|cffff2020Incompatible|r "..version
		else
			ReRecount.VerTable[owner]=version
		end
	end
end

function ReRecount:DeleteVersion(name)
	if ReRecount.VerTable and ReRecount.VerTable[name] then
		ReRecount.VerTable[name] = nil
	end
	if ReRecount.VerNum and ReRecount.VerNum[name] then
		ReRecount.VerNum[name] = nil
	end
end

function ReRecount:FreeComm()
	ReRecount:UnregisterComm("ReRecount")
end

function ReRecount:FlagSync()
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers(), 1 do 
			if UnitExists("raid"..i) then
				ReRecount.db2.combatants[UnitName("raid"..i)].lazysync = true
				ReRecount.lazysync = true
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers(), 1 do 
			if UnitExists("party"..i) then
				ReRecount.db2.combatants[UnitName("party"..i)].lazysync = true
				ReRecount.lazysync = true
			end
		end
	end
end

function ReRecount:SendReset()
	ReRecount:SendCommMessage("ReRecount",ReRecount:Serialize("RS",ReRecount.PlayerName),"RAID")
	ReRecount:ResetLazySyncData(ReRecount.PlayerName)
end

function ReRecount:ResetLazySyncData(name)
	if not ReRecount.VerNum then return end
	
	if ReRecount.VerNum[name] and ReRecount.VerNum[name] >= ReRecount.MinimumV and ReRecount.MySyncPartners and ReRecount.MySyncPartners[name] then
		for k, v in pairs(ReRecount.MySyncPartners[name]) do
			for k2, _ in pairs(v) do
				v[k2] = 0
			end
		end
	end
end

function ReRecount:SendVersion(target)
	if target then
		local _, realm = UnitName(target)
		if UnitIsConnected(target) and not realm then
			ReRecount:SendCommMessage("ReRecount",ReRecount:Serialize("VS",ReRecount.PlayerName,ReRecount.Version),"WHISPER",target)
			ReRecount:SendSelf(target)
		end
	else
		ReRecount:SendCommMessage("ReRecount",ReRecount:Serialize("VS",ReRecount.PlayerName,ReRecount.Version),"RAID")
	end
end

function ReRecount:RequestVersion()
	ReRecount:SendCommMessage("ReRecount",ReRecount:Serialize("VQ",ReRecount.PlayerName,ReRecount.Version),"RAID")
end

--[[function ReRecount:SetSyncAmount(who, type, amount)
	who.Sync = who.Sync or {}
	who.Sync.LastChanged=GetTime()
	who.Sync[type]=amount
end]]

function ReRecount:SetLazySyncAmount(name, target, type, amount)
	if not ReRecount.VerNum then return end
	
	if ReRecount.VerNum[name] and ReRecount.VerNum[name] >= ReRecount.MinimumV then
		ReRecount.MySyncPartners = ReRecount.MySyncPartners or {}
		ReRecount.MySyncPartners[name] = ReRecount.MySyncPartners[name] or {}
		ReRecount.MySyncPartners[name][target] = ReRecount.MySyncPartners[name][target] or {}
		ReRecount.MySyncPartners[name][target][type] = amount
	end
end

function ReRecount:GetLazySyncAmount(name, target, type)
	if ReRecount.VerNum and ReRecount.MySyncPartners and ReRecount.VerNum[name] and ReRecount.VerNum[name] >= MinimumV then
--		ReRecount:DPrint(ReRecount.MySyncPartners and ReRecount.MySyncPartners[name] and ReRecount.MySyncPartners[name][target] and ReRecount.MySyncPartners[name][target][type] or "nil")
		return ReRecount.MySyncPartners and ReRecount.MySyncPartners[name] and ReRecount.MySyncPartners[name][target] and ReRecount.MySyncPartners[name][target][type]
	end
end

function ReRecount:GetLazySyncTouched(name, target)
	return ReRecount.MySyncPartners and ReRecount.MySyncPartners[name] and ReRecount.MySyncPartners[name][target] and ReRecount.MySyncPartners[name][target].Touched
end

function ReRecount:ClearLazySyncTouched(name, target)
	ReRecount.MySyncPartners = ReRecount.MySyncPartners or {}
	ReRecount.MySyncPartners[name] = ReRecount.MySyncPartners[name] or {}
	ReRecount.MySyncPartners[name][target] = ReRecount.MySyncPartners[name][target] or {}
	ReRecount.MySyncPartners[name][target].Touched = nil
end
--[[function ReRecount:AddAllLazySyncAmount(name,type, amount)
	
	if not ReRecount.VerNum then return end -- Noone there to sync for.
	
	for k, v in ReRecount.VerNum do
		if v >= MinimumV and k ~= name then
			ReRecount:AddLazySyncAmount(k,name,type,amount)
		end
	end
end]]

function ReRecount:AddOwnerPetLazySyncAmount(who,type, amount)
	if not who then return end
	
	if who.Name == ReRecount.PlayerName or ReRecount.MySyncPartners and ReRecount.MySyncPartners[who.Name] then
--		ReRecount:DPrint("Adding sync pool player: "..who.Name)
		ReRecount:AddLazySyncAmount(who.Name,who.Name,type, amount)
	elseif who.Owner == ReRecount.PlayerName or ReRecount.MySyncPartners and ReRecount.MySyncPartners[who.Owner] then
--		ReRecount:DPrint("Adding sync pool player pet: "..who.Name.." "..who.Owner)
		ReRecount:AddLazySyncAmount(who.Owner,who.Name.." <"..who.Owner..">",type, amount)
	elseif ReRecount.MySyncPartners and (who.type == "Boss" or (who.level and who.level > UnitLevel("player")+2)) then
--		ReRecount:DPrint("Adding sync pool boss: "..who.Name)
		for k,v in pairs(ReRecount.MySyncPartners) do
			ReRecount:AddLazySyncAmount(k,who.Name,type, amount) -- ReRecount.PlayerName
		end
	end
end

function ReRecount:AddLazySyncAmount(name, target, type, amount)
--	ReRecount:DPrint(name.." "..target.." "..type.." "..amount)
	ReRecount.MySyncPartners = ReRecount.MySyncPartners or {}
	ReRecount.MySyncPartners[name] = ReRecount.MySyncPartners[name] or {}
	ReRecount.MySyncPartners[name][target] = ReRecount.MySyncPartners[name][target] or {}
	local who = ReRecount.MySyncPartners[name][target]
	who.Touched = true
	who[type] = who[type] or 0
	who[type] = who[type]+amount
end

--[[function ReRecount:AddSyncAmount(who, type, amount)

	if not who then return end

	who.Sync = who.Sync or {}
	who.Sync.LastChanged=GetTime()
	who.Sync.Touched = true
	who.Sync[type] = who.Sync[type] or 0
	who.Sync[type]=who.Sync[type]+amount
end]]

