local revision = tonumber(string.sub("$Revision: 78940 $", 12, -3))
if ReRecount.Version < revision then ReRecount.Version = revision end

local Fights={}
ReRecount.Fights=Fights

function Fights:CopyCurrentFights()
		for _,v in pairs(ReRecount.db2.combatants) do
			--v.Fights.LastFightData=v.Fights.CurrentFightData -- Copy current even for short fights
			ReRecount:ResetFightData(v.Fights["CurrentFightData"])
		end
end

function Fights:MoveFights()
	local ReuseFight
	
	if not ReRecount.db.profile.SegmentBosses or ReRecount.FightingLevel == -1 then
		for i=math.min(#ReRecount.db2.FoughtWho,ReRecount.db.profile.MaxFights-1),1,-1 do
			ReRecount.db2.FoughtWho[i+1]=ReRecount.db2.FoughtWho[i]
		end
		ReRecount.db2.FoughtWho[1]=ReRecount.FightingWho.." "..ReRecount.InCombatF.."-"..date("%H:%M:%S")
	end
		
	for k,v in pairs(ReRecount.db2.combatants) do		
		--ReuseFight=v.Fights.LastFightData
		ReuseFight = nil
		
		v.Fights.LastFightData=v.Fights.CurrentFightData

		if not ReRecount.db.profile.SegmentBosses or ReRecount.FightingLevel == -1 then
			v.FightsSaved = v.FightsSaved or 0
			if v.FightsSaved==ReRecount.db.profile.MaxFights then
				ReuseFight=v.Fights["Fight"..v.FightsSaved]
			end
			v.FightsSaved = v.FightsSaved or 0
			for i=math.min(v.FightsSaved,ReRecount.db.profile.MaxFights-1),1,-1 do
				v.Fights["Fight"..i+1]=v.Fights["Fight"..i]
			end
		
			if v.LastFightIn==ReRecount.db2.FightNum then
				v.Fights["Fight1"]=v.Fights.CurrentFightData		
			else
				v.Fights["Fight1"]=nil
			end

			if v.FightsSaved<ReRecount.db.profile.MaxFights then
				v.FightsSaved=v.FightsSaved+1
			end
		else
			
		end

		if not ReuseFight or ReuseFight == v.Fights.LastFightData then
			v.Fights["CurrentFightData"]=ReRecount:GetTable()
			ReRecount:InitFightData(v.Fights["CurrentFightData"])
		else
			ReRecount:ResetFightData(ReuseFight)
			v.Fights["CurrentFightData"]=ReuseFight
		end		
	end

	--Main Window Display Cache needs to be reset should fix several bugs
	ReRecount:FullRefreshMainWindow() -- Elsia: Made a function for this as it's also needed for deleting combatants and refreshing when options change
	
	local FightNum=tonumber(string.match(ReRecount.db.profile.CurDataSet,"Fight(%d+)"))
	
	if FightNum then
		ReRecount.FightName=ReRecount.db2.FoughtWho[FightNum]
	end
end

function Fights:DeleteOverflowFights(newmax)
	for k,v in pairs(ReRecount.db2.combatants) do		
	        for i=newmax+1, ReRecount.db.profile.MaxFights, 1 do
			v.Fights["Fight"..i]=nil
			ReRecount.db2.FoughtWho[i]=nil
		end
	end
end

function Fights:RemoveFight(num)
end

function Fights:ChangeFightNum(num)
end
