-- Elsia: For delete on instance entry
-- Deletes data whenever a new, not the same instance is entered. This should safe-guard against corpse-run-reenters and the like.
local revision = tonumber(string.sub("$Revision: 78174 $", 12, -3))
if ReRecount.Version < revision then ReRecount.Version = revision end

function ReRecount:DetectInstanceChange() -- Elsia: With thanks to Loggerhead

	local zone = GetRealZoneText()

	if zone == nil or zone == "" then
		-- zone hasn't been loaded yet, try again in 5 secs.
		self:ScheduleTimer("DetectInstanceChange",5)
		return
	end

	local inInstance, instanceType = IsInInstance()
	if ReRecount.SetZoneFilter and not UnitIsGhost(ReRecount.PlayerName) then ReRecount:SetZoneFilter(instanceType) end -- Use zone-based filters.

	if not ReRecount.db.profile.AutoDeleteNewInstance then return end
	
	local ct = 0; for k,v in pairs(ReRecount.db2.combatants) do ct = ct + 1; break; end
	if ct==0 then -- Elsia: Already deleted
		return
	end
	
	if inInstance and (not ReRecount.db.profile.DeleteNewInstanceOnly or ReRecount.db.profile.LastInstanceName ~= zone) and CurrentDataCollect then
	   
		if ReRecount.db.profile.ConfirmDeleteInstance == true then
			ReRecount:ShowReset() -- Elsia: Confirm & Delete!
		else
			ReRecount:ResetData()		-- Elsia: Delete!
		end
		ReRecount.db.profile.LastInstanceName = zone -- Elsia: We'll set the instance even if the user opted to not delete...
	end
end

-- Elsia: For delete on join raid/group

function ReRecount:PartyMembersChanged()

	local ct = 0; for k,v in pairs(ReRecount.db2.combatants) do ct = ct + 1; break; end
	if ct==0 then -- Elsia: Already deleted
		return
	end

	local NumRaidMembers = GetNumRaidMembers()
	local NumPartyMembers = GetNumPartyMembers()

	if ReRecount.db.profile.DeleteJoinRaid and not ReRecount.inRaid and NumRaidMembers > 0 then
		if ReRecount.db.profile.ConfirmDeleteRaid then
			ReRecount:ShowReset() -- Elsia: Confirm & Delete!
		else
			ReRecount:ResetData()		-- Elsia: Delete!
		end
		
		if ReRecount.RequestVersion then ReRecount:RequestVersion() end -- Elsia: If LazySync is present request version when entering raid
	end

	if ReRecount.db.profile.DeleteJoinGroup and not ReRecount.inGroup and NumPartyMembers > 0 and NumRaidMembers == 0 then
		if ReRecount.db.profile.ConfirmDeleteGroup then
			ReRecount:ShowReset() -- Elsia: Confirm & Delete!
		else
			ReRecount:ResetData()		-- Elsia: Delete!
		end

		if ReRecount.RequestVersion then ReRecount:RequestVersion() end -- Elsia: If LazySync is present request version when entering party
	end
	
	ReRecount.inGroup = false
	ReRecount.inRaid = false
	
	if NumRaidMembers == 0 and NumPartyMembers > 0 or UnitInParty("player") then
	   ReRecount.inGroup = true
	end

	if NumRaidMembers > 0 or UnitInRaid("player") then
	   ReRecount.inRaid = true
	end
	
	if ReRecount.GroupCheck then ReRecount:GroupCheck() end -- Elsia: Reevaluate group flagging on group changes.
end

function ReRecount:InitPartyBasedDeletion()
	local NumRaidMembers = GetNumRaidMembers()
	local NumPartyMembers = GetNumPartyMembers()

	ReRecount.inGroup = false
	ReRecount.inRaid = false

	if NumPartyMembers > 0 and NumRaidMembers == 0 then ReRecount.inGroup = true end
	if NumRaidMembers > 0 then ReRecount.inRaid = true end

	ReRecount:RegisterEvent("PARTY_MEMBERS_CHANGED","PartyMembersChanged")
	
	ReRecount:RegisterEvent("RAID_ROSTER_UPDATE","PartyMembersChanged")
end

function ReRecount:ReleasePartyBasedDeletion()
	if ReRecount.db.profile.DeleteJoinGroup == false and ReRecount.db.profile.DeleteJoinRaid == false then
		ReRecount:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		ReRecount:UnregisterEvent("RAID_ROSTER_UPDATE")
	end
end
