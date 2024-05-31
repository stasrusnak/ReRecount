-- Elsia: This handles filters for zones/instances

function ReRecount:SetZoneFilter(instanceType)
	
	if not instanceType then return end
	
	if ReRecount.db.profile.ZoneFilters[instanceType] then
		if ReRecount.db.profile.HideCollect and not ReRecount.CurrentDataCollect then
			ReRecount.MainWindow:Show()
		end
		ReRecount.CurrentDataCollect = true
	else
		if ReRecount.db.profile.HideCollect and ReRecount.CurrentDataCollect then
			ReRecount.MainWindow:Hide()
		end
		ReRecount.CurrentDataCollect = false
	end
end
