local SM = LibStub:GetLibrary("LibSharedMedia-3.0")
local Graph = LibStub:GetLibrary("LibGraph-2.0")

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale( "ReRecount" )
local BC = LibStub("LibBabble-Class-3.0"):GetLookupTable()

-- Elsia: Note, most strings here haven't been localized. Need to grab all button and text labels here and put into localization registration.
-- Just started with the color selection ones to give an example. See ReRecount.lua.

local me={}

local SavedCheckVars={}

local EditableColors={
	["Window"]={
		"Title",
		"Background",
		"Title Text",
	},
	["Other Windows"]={
		"Title",
		"Background",
		"Title Text",
	},
	["Bar"]={
		"Bar Text",
		"Total Bar",
	},
	["Class"]={
		"Druid",
		"Hunter",
		"Mage",
		"Paladin",
		"Priest",
		"Rogue",
		"Shaman",
		"Warlock",
		"Warrior",
		"Pet",
--		"Guardian",
		"Mob",
	}
}

local ClassStrings={
	["DRUID"]=true,
	["HUNTER"]=true,
	["MAGE"]=true,
	["PALADIN"]=true,
	["PRIEST"]=true,
	["ROGUE"]=true,
	["SHAMAN"]=true,
	["WARLOCK"]=true,
	["WARRIOR"]=true,
	["PET"]=false, -- Elsia: These two are not supported by RAID_CLASS_COLORS or Babble-Class
--	["GUARDIAN"]=false,
	["MOB"]=false,
	["HOSTILE"]=false,
	["UNGROUPED"]=false,
}

function me:LBC(Name) -- Allow localization of unit strings via Babble-Class
	local CName = string.upper(Name)
	if ClassStrings[CName] then -- Elsia: Only Babble what babble knows
		return BC[Name]
	else
		return L[Name]
	end
end

function ReRecount:FixUnitString(Name) -- This is to handle caps of default unit strings
	local CName = string.upper(Name)
	if ClassStrings[CName]~=nil then -- Elsia: Caps all unit strings
		return CName
	else
		return Name
	end
end

function ReRecount:ResetDefaultWindowColors()
	ReRecount.Colors:SetColor("Window", "Title", { r = 1, g = 0, b = 0, a = 1})
	ReRecount.Colors:SetColor("Window", "Background", { r = 24/255, g = 24/255, b = 24/255, a = 1})
	ReRecount.Colors:SetColor("Window", "Title Text", { r = 1, g = 1, b = 1, a = 1})
	ReRecount.Colors:SetColor("Other Windows", "Title", { r = 1, g = 0, b = 0, a = 1})
	ReRecount.Colors:SetColor("Other Windows", "Background", { r = 24/255, g = 24/255, b = 24/255, a = 1})
	ReRecount.Colors:SetColor("Other Windows", "Title Text", { r = 1, g = 1, b = 1, a = 1})
end

function ReRecount:ResetDefaultClassColors()
	for k,v in pairs(EditableColors.Class) do
		v = ReRecount:FixUnitString(v)
		if v=="PET" then
			ReRecount.Colors:SetColor("Class", "PET", { r = 0.09, g = 0.61, b = 0.55, a = 1 })
--		elseif v=="GUARDIAN" then
--			ReRecount.Colors:SetColor("Class", "GUARDIAN", { r = 0.61, g = 0.09, b = 0.09 })
		elseif v=="MOB" then
			ReRecount.Colors:SetColor("Class", "MOB", { r = 0.58, g = 0.24, b = 0.63, a = 1 })
		else
			local classcols = RAID_CLASS_COLORS[v]
			classcols.a = 1
			ReRecount.Colors:SetColor("Class", v, classcols) 
		end
	end
	ReRecount.Colors:SetColor("Bar", "Bar Text", { r = 1, g = 1, b = 1, a = 1})
	ReRecount.Colors:SetColor("Bar", "Total Bar", { r = 0.75, g = 0.75, b = 0.75, a=1})
end


function me:SetColorRow(Branch,Name)
	self.Branch=Branch
	self.Text:SetText(me:LBC(Name))
	Name = ReRecount:FixUnitString(Name)
	self.Name=Name
	ReRecount.Colors:UnregisterItem(self.Background)
	ReRecount.Colors:UnregisterItem(self.Key)
	ReRecount.Colors:RegisterTexture(Branch,Name,self.Background)
	ReRecount.Colors:RegisterTexture(Branch,Name,self.Key)
end

function me:CreateColorRow(parent, frame)
	local theFrame=CreateFrame("Frame",nil,parent)

	theFrame:SetWidth(190)
	theFrame:SetHeight(13)

	theFrame.Background=theFrame:CreateTexture(nil,"BACKGROUND")
	theFrame.Background:SetAllPoints(theFrame)
	theFrame.Background:SetTexture(1,1,1,0.3)
	theFrame.Background:Hide()

	theFrame.Key=theFrame:CreateTexture(nil,"OVERLAY")
	theFrame.Key:SetHeight(13)
	theFrame.Key:SetWidth(13)
	theFrame.Key:SetPoint("LEFT",theFrame,"LEFT",0,0)
	theFrame.Key:SetTexture(1,1,1)

	theFrame.Text=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Text:SetPoint("LEFT",theFrame,"LEFT",16,0)

	theFrame:EnableMouse(true)
	theFrame:SetScript("OnEnter",function() theFrame.Background:Show() end)
	theFrame:SetScript("OnLeave",function() theFrame.Background:Hide() end)
	theFrame:SetScript("OnMouseDown",function() ReRecount.Colors:EditColor(this.Branch,this.Name,me.ConfigWindow) end)
	theFrame.SetRow=me.SetColorRow

	return theFrame
end

function me:CreateWindowColorSelection(parent)
	me.WindowColorOptions=CreateFrame("Frame",nil,parent)

	local theFrame=me.WindowColorOptions

	theFrame:SetHeight(200)
	theFrame:SetWidth(200)
	theFrame:SetPoint("TOPLEFT",parent,"TOPLEFT",0,-34)

	theFrame.Rows={}

	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetPoint("TOP",theFrame,"TOP",0,-2)
	theFrame.Title:SetText(L["Window Color Selection"])

	local i=1
	theFrame.MainWindowTitle=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.MainWindowTitle:SetPoint("TOP",theFrame,"TOP",0,-4-i*14)
	theFrame.MainWindowTitle:SetText(L["Main Window"])
	i=i+1
	for k,v in pairs(EditableColors.Window) do
		theFrame.Rows[i]=me:CreateColorRow(theFrame)
		theFrame.Rows[i]:SetRow("Window",v)
		theFrame.Rows[i]:SetPoint("TOP",theFrame,"TOP",4,-2-i*14)
		i=i+1
		if i>16 then
			return
		end
	end
	theFrame.DetailWindowTitle=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.DetailWindowTitle:SetPoint("TOP",theFrame,"TOP",0,-4-i*14)
	theFrame.DetailWindowTitle:SetText(L["Other Windows"])
	i=i+1
	for k,v in pairs(EditableColors.Window) do
		theFrame.Rows[i]=me:CreateColorRow(theFrame)
		theFrame.Rows[i]:SetRow("Other Windows",v)
		theFrame.Rows[i]:SetPoint("TOP",theFrame,"TOP",4,-4-i*14)
		i=i+1
		if i>16 then
			return
		end
	end

	theFrame.ResetColButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.ResetColButton:SetWidth(120)
	theFrame.ResetColButton:SetHeight(18)
	theFrame.ResetColButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",40,-210)
	theFrame.ResetColButton:SetScript("OnClick",function() ReRecount:ResetDefaultWindowColors() end)
	theFrame.ResetColButton:SetText(L["Reset Colors"])
end

function me:CreateClassColorSelection(parent)
	me.ClassColorOptions=CreateFrame("Frame",nil,parent)

	local theFrame=me.ClassColorOptions

	theFrame:SetHeight(200)
	theFrame:SetWidth(200)
	theFrame:SetPoint("TOPLEFT",parent,"TOPLEFT",200,-34)

	theFrame.Rows={}

	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetPoint("TOP",theFrame,"TOP",0,-2)
	theFrame.Title:SetText(L["Bar Color Selection"])
	
	local i=1
	for k,v in pairs(EditableColors.Bar) do
		theFrame.Rows[i]=me:CreateColorRow(theFrame)
		theFrame.Rows[i]:SetRow("Bar",v)
		theFrame.Rows[i]:SetPoint("TOP",theFrame,"TOP",4,-2-i*14)
		i=i+1
		if i>16 then
			return
		end
	end
	
	theFrame.ClassTitle=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.ClassTitle:SetPoint("TOP",theFrame,"TOP",0,-2-i*14)
	theFrame.ClassTitle:SetText(L["Class Colors"])
	i=i+1
	for k,v in pairs(EditableColors.Class) do
		theFrame.Rows[i]=me:CreateColorRow(theFrame)
		theFrame.Rows[i]:SetRow("Class",v)
		theFrame.Rows[i]:SetPoint("TOP",theFrame,"TOP",4,-2-i*14)
		i=i+1
		if i>16 then
			return
		end
	end

	i=i+1
	theFrame.ResetColButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.ResetColButton:SetWidth(120)
	theFrame.ResetColButton:SetHeight(18)
	theFrame.ResetColButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",40,-210)
	theFrame.ResetColButton:SetScript("OnClick",function() ReRecount:ResetDefaultClassColors() end)
	theFrame.ResetColButton:SetText(L["Reset Colors"])
end

function me:CreateIconFrame(parent,texture,title,text)
	local theFrame=CreateFrame("Frame",nil,parent)
	theFrame:SetWidth(18)
	theFrame:SetHeight(18)

	theFrame.texture=theFrame:CreateTexture(nil,"OVERLAY")
	theFrame.texture:SetAllPoints(theFrame)
	theFrame.texture:SetTexture(texture)
	theFrame.title=title
	theFrame.text=text

	theFrame:SetScript("OnEnter",function()
					GameTooltip:SetOwner(theFrame, "ANCHOR_TOPRIGHT")
					GameTooltip:ClearLines()
					GameTooltip:AddLine(theFrame.title)
					GameTooltip:AddLine(theFrame.text,1,1,1,true)
					GameTooltip:Show()
				     end)
	theFrame:SetScript("OnLeave",function() GameTooltip:Hide() end)

	theFrame:EnableMouse()
	theFrame:Show()

	return theFrame
end

function me:ConfigureCheckbox(check)
	check:SetWidth(20)
	check:SetHeight(20)
	check:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true) else this:SetChecked(false) end end)
	check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
end

function me:CreateSavedCheckbox(Text, parent,VarTop,VarName)
	local Checkbox=CreateFrame("CheckButton",nil,parent)
	me:ConfigureCheckbox(Checkbox)

	Checkbox.Text=Checkbox:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Checkbox.Text:SetText(Text)
	Checkbox.Text:SetPoint("LEFT",Checkbox,"RIGHT",8,0)

	SavedCheckVars[#SavedCheckVars+1]={Checkbox,VarTop,VarName}

	return Checkbox
end

function me:CreateFilterRow(parent,label,header)
	local theFrame=CreateFrame("Frame",nil,parent)

	theFrame:SetWidth(196)
	theFrame:SetHeight(16)
	
	theFrame.Label=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	if not header then
		theFrame.Label:SetTextColor(1,1,1,1)
	end
	theFrame.Label:SetText(" "..label)
	theFrame.Label:SetPoint("LEFT",theFrame,"LEFT",0,0)

	theFrame.ShowData=CreateFrame("CheckButton",nil,theFrame)
	me:ConfigureCheckbox(theFrame.ShowData)
	theFrame.ShowData:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true);  else this:SetChecked(false); end  me:SaveFilterConfig(); ReRecount:RefreshMainWindow() end)

	theFrame.RecordData=CreateFrame("CheckButton",nil,theFrame)
	me:ConfigureCheckbox(theFrame.RecordData)
	theFrame.RecordData:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true);theFrame.RecordTime:Enable();theFrame.TrackDeaths:Enable();theFrame.TrackBuffs:Enable() else this:SetChecked(false);theFrame.RecordTime:Disable();theFrame.TrackDeaths:Disable();theFrame.TrackBuffs:Disable() end me:SaveFilterConfig() end)


	theFrame.RecordTime=CreateFrame("CheckButton",nil,theFrame)	
	me:ConfigureCheckbox(theFrame.RecordTime)
	theFrame.RecordTime:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true);  else this:SetChecked(false); end  me:SaveFilterConfig()  end)

	theFrame.TrackDeaths=CreateFrame("CheckButton",nil,theFrame)
	me:ConfigureCheckbox(theFrame.TrackDeaths)
	theFrame.TrackDeaths:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true);  else this:SetChecked(false); end  me:SaveFilterConfig()  end)

	theFrame.TrackBuffs=CreateFrame("CheckButton",nil,theFrame)
	me:ConfigureCheckbox(theFrame.TrackBuffs)
	theFrame.TrackBuffs:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true);  else this:SetChecked(false); end  me:SaveFilterConfig()  end)


	theFrame.ShowData:SetPoint("RIGHT",theFrame.RecordData,"LEFT",0,0)
	theFrame.RecordData:SetPoint("RIGHT",theFrame.RecordTime,"LEFT",0,0)
	theFrame.RecordTime:SetPoint("RIGHT",theFrame.TrackDeaths,"LEFT",0,0)
	theFrame.TrackDeaths:SetPoint("RIGHT",theFrame.TrackBuffs,"LEFT",0,0)
	theFrame.TrackBuffs:SetPoint("RIGHT",theFrame,"RIGHT",-1,0)

	theFrame.ShowData:Show()
	theFrame.RecordData:Show()
	theFrame.RecordTime:Show()
	theFrame.TrackDeaths:Show()
	theFrame.TrackBuffs:Show()

	return theFrame
end

function me:SetupFilterOptions(parent)
	me.FilterOptions=CreateFrame("Frame",nil,parent)
	local theFrame=me.FilterOptions

	theFrame:SetHeight(196)
	theFrame:SetWidth(196)
	theFrame:SetPoint("TOPLEFT",parent,"TOPLEFT",2,-34)

	theFrame.Title_Show=me:CreateIconFrame(theFrame,"Interface/Icons/INV_Misc_Eye_01",L["Show"],L["Is this shown in the main window?"])
	theFrame.Title_Data=me:CreateIconFrame(theFrame,"Interface/Icons/INV_Misc_Note_02",L["Record Data"],L["Whether data is recorded for this type"])
	theFrame.Title_Time=me:CreateIconFrame(theFrame,"Interface/Icons/INV_Misc_PocketWatch_02",L["Record Time Data"],L["Whether time data is recorded for this type (used for graphs can be a |cffff2020memory hog|r if you are concerned about memory)"])
	theFrame.Title_Deaths=me:CreateIconFrame(theFrame,"Interface/Icons/Ability_Creature_Cursed_02",L["Record Deaths"],L["Records when deaths occur and the past few actions involving this type"])
	theFrame.Title_Buffs=me:CreateIconFrame(theFrame,"Interface/Icons/Ability_Warrior_SavageBlow",L["Record Buffs/Debuffs"],L["Records the times and applications of buff/debuffs on this type"])
	
	theFrame.Title_Show:SetPoint("RIGHT",theFrame.Title_Data,"LEFT",-2,0)
	theFrame.Title_Data:SetPoint("RIGHT",theFrame.Title_Time,"LEFT",-2,0)
	theFrame.Title_Time:SetPoint("RIGHT",theFrame.Title_Deaths,"LEFT",-2,0)
	theFrame.Title_Deaths:SetPoint("RIGHT",theFrame.Title_Buffs,"LEFT",-2,0)
	theFrame.Title_Buffs:SetPoint("TOPRIGHT",theFrame,"TOPRIGHT",-2,-2)

	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetText(L["Filters"])
	theFrame.Title:SetPoint("TOPLEFT",theFrame,"TOPLEFT",2,-4)



	theFrame.Filters={}
	local Filters=theFrame.Filters

	theFrame.TitlePlayers=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.TitlePlayers:SetText(" "..L["Players"])
	theFrame.TitlePlayers:SetPoint("TOPLEFT",theFrame,"TOPLEFT",0,-26)

	Filters.Self=me:CreateFilterRow(theFrame,"  "..L["Self"])
	Filters.Self:SetPoint("TOPLEFT",theFrame.TitlePlayers,"BOTTOMLEFT",0,-1)

	Filters.Grouped=me:CreateFilterRow(theFrame,"  "..L["Grouped"])
	Filters.Grouped:SetPoint("TOPLEFT",Filters.Self,"BOTTOMLEFT",0,-1)

	Filters.Ungrouped=me:CreateFilterRow(theFrame,"  "..L["Ungrouped"])
	Filters.Ungrouped:SetPoint("TOP",Filters.Grouped,"BOTTOM",0,-1)

	Filters.Hostile=me:CreateFilterRow(theFrame,"  "..L["Hostile"])
	Filters.Hostile:SetPoint("TOP",Filters.Ungrouped,"BOTTOM",0,-1)

	Filters.Pet=me:CreateFilterRow(theFrame,L["Pets"],true)
	Filters.Pet:SetPoint("TOP",Filters.Hostile,"BOTTOM",0,-1)

	theFrame.TitleMobs=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.TitleMobs:SetText(" "..L["Mobs"])
	theFrame.TitleMobs:SetPoint("TOPLEFT",Filters.Pet,"BOTTOMLEFT",0,-1)

	Filters.Trivial=me:CreateFilterRow(theFrame,"  "..L["Trivial"])
	Filters.Trivial:SetPoint("TOPLEFT",theFrame.TitleMobs,"BOTTOMLEFT",0,-1)

	Filters.Nontrivial=me:CreateFilterRow(theFrame,"  "..L["Non-Trivial"])
	Filters.Nontrivial:SetPoint("TOP",Filters.Trivial,"BOTTOM",0,-1)

	Filters.Boss=me:CreateFilterRow(theFrame,"  "..L["Bosses"])
	Filters.Boss:SetPoint("TOP",Filters.Nontrivial,"BOTTOM",0,-1)

	Filters.Unknown=me:CreateFilterRow(theFrame,L["Unknown"],true)
	Filters.Unknown:SetPoint("TOP",Filters.Boss,"BOTTOM",0,-1)

	theFrame.MergePets=me:CreateSavedCheckbox(L["Merge Pets w/ Owners"],theFrame,"Data","MergePets")
	theFrame.MergePets:SetPoint("TOPLEFT",Filters.Unknown,"BOTTOMLEFT",0,-1)
	theFrame.MergePets:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MergePets = true; ReRecount.db.profile.Filters.Show["Pet"]=false else this:SetChecked(false); ReRecount.db.profile.MergePets = false; ReRecount.db.profile.Filters.Show["Pet"]=true end me.FilterOptions.Filters.Pet.ShowData:SetChecked(ReRecount.db.profile.Filters.Show["Pet"]); ReRecount:FullRefreshMainWindow(); ReRecount:RefreshMainWindow() end)

end


function me:SetBarTexture()
	local BarTextures=SM:List("statusbar")
	ReRecount:SetBarTextures(BarTextures[this.value])
	
	UIDropDownMenu_SetSelectedID(me.MiscOptions.StatusBarDropDown,this.value);
end

function me:BarTextureDropDown_Initialize()	
	local BarTextures=SM:List("statusbar")
	local LookingFor

	if not LookingFor then
		LookingFor=ReRecount.db.profile.BarTexture
	end

	if not LookingFor then
		LookingFor="BantoBar"
	end

	for k,v in pairs(BarTextures) do
		local info = {};
		info.text = v;
		info.value = k;
		info.func = me.SetBarTexture;
		UIDropDownMenu_AddButton(info);
		if v==LookingFor then
			LookingFor=k
		end
	end

	UIDropDownMenu_SetSelectedID(me.MiscOptions.StatusBarDropDown,LookingFor);
end

function me:SetSelectStatusBar(texture)
	if texture==nil then
		self:Hide()
		return
	end
	self.Text:SetText(texture)
	self.Texture:SetTexture(SM:Fetch("statusbar",texture))
	self.SetTo=texture
	self:Show()
end

function me:UpdateStatusBars()
	for _, v in pairs(me.TextureOptions.Rows) do
		if v.SetTo==ReRecount.db.profile.BarTexture then
			v.Texture:SetVertexColor(0.2,0.9,0.2)
		else
			v.Texture:SetVertexColor(0.9,0.2,0.2)
		end
	end
end

function me:CreateSelectStatusBar(parent)
	local frame=CreateFrame("Frame",nil,parent)
	frame:SetHeight(13)
	frame:SetWidth(180)
	frame.Text=frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	frame.Text:SetText("Temp")
	frame.Text:SetPoint("CENTER",frame,"CENTER")
	frame.Texture=frame:CreateTexture(nil,"BACKGROUND")
	frame.Texture:SetAllPoints(frame)
	frame.SetTexture=me.SetSelectStatusBar
	frame:EnableMouse()
	frame:SetScript("OnMouseDown",function() ReRecount:SetBarTextures(this.SetTo)
						me:SetTestBarTexture(this.SetTo)
						me:UpdateStatusBars() end)
	return frame
end

function me:RefreshStatusBars()	
	local BarTextures=SM:List("statusbar")
	local size=table.getn(BarTextures)
	
	FauxScrollFrame_Update(me.TextureOptions.ScrollBar, size, 13, 12)
	local offset = FauxScrollFrame_GetOffset(me.TextureOptions.ScrollBar)
	
	for i=1,13 do
		me.TextureOptions.Rows[i]:SetTexture(BarTextures[i+offset])	
	end

	me:UpdateStatusBars()
end

function me:SetTestBarTexture(handle)
	local Texture=SM:Fetch(SM.MediaType.STATUSBAR,handle) -- "statusbar"
	me.BarOptions.TestBar.StatusBar:SetStatusBarTexture(Texture)
end



function me:SetTestBar(num,left,right,value,color)

	local Row=me.BarOptions.TestBar
	Row:Show()
	Row.StatusBar:SetValue(value)
	Row.LeftText:SetText(left)
	Row.RightText:SetText(right)
	Row.Name=left

	if color then
		Row.StatusBar:SetStatusBarColor(color.r,color.g,color.b,1)
	end
	
	Row.LeftText:SetTextColor(ReRecount.db.profile.Colors.Bar["Bar Text"].r,ReRecount.db.profile.Colors.Bar["Bar Text"].g,ReRecount.db.profile.Colors.Bar["Bar Text"].b,1);
	Row.RightText:SetTextColor(ReRecount.db.profile.Colors.Bar["Bar Text"].r,ReRecount.db.profile.Colors.Bar["Bar Text"].g,ReRecount.db.profile.Colors.Bar["Bar Text"].b,1);
end

function me:RefreshTestBar()
	local lefttext = ReRecount.db.profile.MainWindow.BarText.RankNum and "1. "..ReRecount.PlayerName or ReRecount.PlayerName
	local righttext = ReRecount:FormatLongNums(37815)
	if ReRecount.db.profile.MainWindow.BarText.PerSec then
		righttext = righttext .. string.format(" (%s","93.2")
		if ReRecount.db.profile.MainWindow.BarText.Percent then
			righttext = righttext .. string.format(", %.1f%%)",100.0)
		else
			righttext = righttext .. ")"
		end
	elseif ReRecount.db.profile.MainWindow.BarText.Percent then
		righttext = righttext .. string.format(" (%.1f%%)",100.0)
	end
		
	local _, enClass = UnitClass("player")
	me:SetTestBar(0,lefttext,righttext,100,ReRecount.db.profile.Colors.Class[enClass])	
end

function me:CreateBarSelection(parent)
	me.BarOptions=CreateFrame("Frame",nil,parent)

	local theFrame=me.BarOptions

	theFrame:SetHeight(200)
	theFrame:SetWidth(200)
	theFrame:SetPoint("TOPLEFT",parent,"TOPLEFT",000,-34)

	--[[theFrame.Background=theFrame:CreateTexture(nil,"BACKGROUND")
	theFrame.Background:SetAllPoints(theFrame)
	theFrame.Background:SetTexture(0,0,0,0.3)]]

	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetText(L["Bar Text Options"])
	theFrame.Title:SetPoint("TOP",theFrame,"TOP",0,-2)
	
	local row=CreateFrame("Button","ReRecount_ConfigWindow_BarOptions_TestBar",theFrame)
	
	row:SetPoint("TOPLEFT",theFrame,"TOPLEFT",2,-16)
	row:SetHeight(14)
	row:SetWidth(196)
	ReRecount:SetupBar(row)
	local Font, Height, Flags = row.LeftText:GetFont()
	row.LeftText:SetFont(Font, 14*0.75, Flags)
	local Font, Height, Flags = row.RightText:GetFont()
	row.RightText:SetFont(Font, 14*0.75, Flags)

	ReRecount.Colors:RegisterFont("Bar","Bar Text",row.LeftText)
	ReRecount.Colors:RegisterFont("Bar","Bar Text",row.RightText)
	theFrame.TestBar = row

	me:RefreshTestBar()
	
	theFrame.RankNum=me:CreateSavedCheckbox(L["Rank Number"],theFrame,"Window","RankNum")
	theFrame.RankNum:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-23-14)
	theFrame.RankNum:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.BarText.RankNum = true; ReRecount:RefreshMainWindow(); me:RefreshTestBar() else this:SetChecked(false); ReRecount.db.profile.MainWindow.BarText.RankNum = false; ReRecount:RefreshMainWindow(); me:RefreshTestBar()end end)
	
	theFrame.PerSec=me:CreateSavedCheckbox(L["Per Second"],theFrame,"Window","PerSec")
	theFrame.PerSec:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-40-14)
	theFrame.PerSec:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.BarText.PerSec = true; ReRecount:RefreshMainWindow();me:RefreshTestBar() else this:SetChecked(false); ReRecount.db.profile.MainWindow.BarText.PerSec = false; ReRecount:RefreshMainWindow(); me:RefreshTestBar()end end)
	
	theFrame.Percent=me:CreateSavedCheckbox(L["Percent"],theFrame,"Window","Percent")
	theFrame.Percent:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-57-14)
	theFrame.Percent:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.BarText.Percent = true; ReRecount:RefreshMainWindow();me:RefreshTestBar() else this:SetChecked(false); ReRecount.db.profile.MainWindow.BarText.Percent = false; ReRecount:RefreshMainWindow(); me:RefreshTestBar()end end)

	theFrame.Title2=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title2:SetText(L["Number Format"])
	theFrame.Title2:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-77-14)

	theFrame.Standard=me:CreateSavedCheckbox(L["Standard"],theFrame,"Window","Standard")
	theFrame.Standard:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-91-14)
	theFrame.Standard:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); this:GetParent().Commas:SetChecked(false); this:GetParent().Short:SetChecked(false); ReRecount.db.profile.MainWindow.BarText.NumFormat = 1; ReRecount:RefreshMainWindow(); me:RefreshTestBar() else this:SetChecked(true); end end)
	
	theFrame.Commas=me:CreateSavedCheckbox(L["Commas"],theFrame,"Window","Commas")
	theFrame.Commas:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-108-14)
	theFrame.Commas:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); this:GetParent().Standard:SetChecked(false); this:GetParent().Short:SetChecked(false); ReRecount.db.profile.MainWindow.BarText.NumFormat = 2; ReRecount:RefreshMainWindow();me:RefreshTestBar() else this:SetChecked(true); end end)
	
	theFrame.Short=me:CreateSavedCheckbox(L["Short"],theFrame,"Window","Short")
	theFrame.Short:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-125-14)
	theFrame.Short:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); this:GetParent().Standard:SetChecked(false); this:GetParent().Commas:SetChecked(false); ReRecount.db.profile.MainWindow.BarText.NumFormat = 3; ReRecount:RefreshMainWindow();me:RefreshTestBar() else this:SetChecked(true); end end)

	
end

function me:CreateTextureSelection(parent)
	me.TextureOptions=CreateFrame("Frame",nil,parent)

	local theFrame=me.TextureOptions
	local BarTextures=SM:List("statusbar")

	theFrame:SetHeight(200)
	theFrame:SetWidth(200)
	theFrame:SetPoint("TOPLEFT",parent,"TOPLEFT",400,-34)

	--[[theFrame.Background=theFrame:CreateTexture(nil,"BACKGROUND")
	theFrame.Background:SetAllPoints(theFrame)
	theFrame.Background:SetTexture(0,0,0,0.3)]]

	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetText(L["Bar Selection"])
	theFrame.Title:SetPoint("TOP",theFrame,"TOP",0,-2)

	theFrame.Rows={}
	for i=1,13 do
		theFrame.Rows[i]=me:CreateSelectStatusBar(theFrame)
		theFrame.Rows[i]:SetPoint("TOP",theFrame,"TOP",-8,-i*14-2)
		theFrame.Rows[i]:SetTexture(BarTextures[i])
	end
	me:UpdateStatusBars()

	if table.getn(BarTextures)<=13 then
		for i=1,13 do
			theFrame.Rows[i]:SetWidth(196)
			theFrame.Rows[i]:SetPoint("TOP",theFrame,"TOP",0,-i*14-2)
		end
	end

	theFrame.ScrollBar=CreateFrame("SCROLLFRAME","ReRecount_Config_StatusBar_Scrollbar",theFrame,"FauxScrollFrameTemplate")
	theFrame.ScrollBar:SetScript("OnVerticalScroll", function() FauxScrollFrame_OnVerticalScroll(12, me.RefreshStatusBars) end)
	theFrame.ScrollBar:SetPoint("TOPLEFT",theFrame.Rows[1],"TOPLEFT")	
	theFrame.ScrollBar:SetPoint("BOTTOMRIGHT",theFrame.Rows[13],"BOTTOMRIGHT",-5,0)

	ReRecount:SetupScrollbar("ReRecount_Config_StatusBar_Scrollbar")

	me:RefreshStatusBars()
end


function me:SetSelectFont(font)
	if font==nil then
		self:Hide()
		return
	end
	self.Text:SetText(font)
	self.Text:SetFont(SM:Fetch("font",font),12)
	self.SetTo=font
	self:Show()
end

function me:UpdateFonts()
	for _, v in pairs(me.FontOptions.Rows) do
		if v.SetTo==ReRecount.db.profile.Font then
			v.Texture:SetVertexColor(0.2,0.9,0.2)
		else
			v.Texture:SetVertexColor(0.9,0.2,0.2)
		end
	end
end

function me:CreateSelectFont(parent)
	local frame=CreateFrame("Frame",nil,parent)
	frame:SetHeight(13)
	frame:SetWidth(180)
	frame.Text=frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	frame.Text:SetText("Temp")
	frame.Text:SetPoint("CENTER",frame,"CENTER")
	frame.Texture=frame:CreateTexture(nil,"BACKGROUND")
	frame.Texture:SetAllPoints(frame)
	frame.Texture:SetTexture(1,1,1,0.5)
	frame.SetFont=me.SetSelectFont
	frame:EnableMouse()
	frame:SetScript("OnMouseDown",function() ReRecount:SetFont(this.SetTo)
						me:UpdateFonts() end)
	return frame
end

function me:RefreshFonts()	
	local Fonts=SM:List("font")
	local size=table.getn(Fonts)
	
	FauxScrollFrame_Update(me.FontOptions.ScrollBar, size, 13, 12)
	local offset = FauxScrollFrame_GetOffset(me.FontOptions.ScrollBar)
	
	for i=1,13 do
		me.FontOptions.Rows[i]:SetFont(Fonts[i+offset])	
	end

	me:UpdateFonts()
end


function me:CreateFontSelection(parent)
	me.FontOptions=CreateFrame("Frame",nil,parent)

	local theFrame=me.FontOptions
	local Fonts=SM:List("font")

	theFrame:SetHeight(200)
	theFrame:SetWidth(200)
	theFrame:SetPoint("TOPLEFT",parent,"TOPLEFT",200,-34)

	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetText(L["Font Selection"])
	theFrame.Title:SetPoint("TOP",theFrame,"TOP",0,-2)

	theFrame.Rows={}
	for i=1,13 do
		theFrame.Rows[i]=me:CreateSelectFont(theFrame)
		theFrame.Rows[i]:SetPoint("TOP",theFrame,"TOP",-8,-i*14-2)
		theFrame.Rows[i]:SetFont(Fonts[i])
	end
	me:UpdateFonts()

	if table.getn(Fonts)<=13 then
		for i=1,13 do
			theFrame.Rows[i]:SetWidth(196)
			theFrame.Rows[i]:SetPoint("TOP",theFrame,"TOP",0,-i*14-2)
		end
	end

	theFrame.ScrollBar=CreateFrame("SCROLLFRAME","ReRecount_Config_Fonts_Scrollbar",theFrame,"FauxScrollFrameTemplate")
	theFrame.ScrollBar:SetScript("OnVerticalScroll", function() FauxScrollFrame_OnVerticalScroll(12, me.RefreshFonts) end)
	theFrame.ScrollBar:SetPoint("TOPLEFT",theFrame.Rows[1],"TOPLEFT")	
	theFrame.ScrollBar:SetPoint("BOTTOMRIGHT",theFrame.Rows[13],"BOTTOMRIGHT",-5,0)

	ReRecount:SetupScrollbar("ReRecount_Config_Fonts_Scrollbar")

	me:RefreshFonts()
end

function me:SetupWindowOptions(parent)
	me.WindowOptions=CreateFrame("Frame",nil,parent)
	local theFrame=me.WindowOptions

	theFrame:SetHeight(200)
	theFrame:SetWidth(200)
	theFrame:SetPoint("TOPLEFT",parent,"TOPLEFT",200,-34)

	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetText(L["General Window Options"])
	theFrame.Title:SetPoint("TOP",theFrame,"TOP",0,-2)

	theFrame.ResetWinButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.ResetWinButton:SetWidth(120)
	theFrame.ResetWinButton:SetHeight(24)
	theFrame.ResetWinButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",40,-20)
	theFrame.ResetWinButton:SetScript("OnClick",function() ReRecount:ResetPositions() end)
	theFrame.ResetWinButton:SetText(L["Reset Positions"])
	
	local slider = CreateFrame("Slider", "ReRecount_ConfigWindow_Scaling_Slider", theFrame,"OptionsSliderTemplate")
	theFrame.ScalingSlider=slider
	slider:SetOrientation("HORIZONTAL")
	slider:SetMinMaxValues(0.5, 1.5)
	slider:SetValueStep(0.05)
	slider:SetWidth(180)
	slider:SetHeight(16)
	slider:SetPoint("TOP", theFrame, "TOP", 0, -58)
	slider:SetScript("OnValueChanged",function() ReRecount.db.profile.Scaling=math.floor(this:GetValue()*100+0.5)/100;getglobal(this:GetName().."Text"):SetText(L["Window Scaling"]..": "..ReRecount.db.profile.Scaling);ReRecount:ScaleWindows(ReRecount.db.profile.Scaling) end)
	slider:SetScript("OnMouseUp", function() me:ScaleConfigWindow(ReRecount.db.profile.Scaling) end)
	getglobal(slider:GetName().."High"):SetText("1.5");
	getglobal(slider:GetName().."Low"):SetText("0.5");
	getglobal(slider:GetName().."Text"):SetText(L["Window Scaling"]..": "..ReRecount.db.profile.Scaling)

--[[	theFrame.ShowCurAndLast=me:CreateSavedCheckbox(L["Autoswitch Shown Fight"],theFrame,"Window","ShowCurAndLast")
	theFrame.ShowCurAndLast:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-82)
	theFrame.ShowCurAndLast:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.Window.ShowCurAndLast = true; else this:SetChecked(false); ReRecount.db.profile.Window.ShowCurAndLast = false; end end)
]] -- Elsia: Making this default in modified form
	theFrame.LockWin=me:CreateSavedCheckbox(L["Lock Windows"],theFrame,"Window","LockWin")
	theFrame.LockWin:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-82)
	theFrame.LockWin:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.Locked = true; ReRecount:LockWindows(true); else this:SetChecked(false); ReRecount.db.profile.Locked = false; ReRecount:LockWindows(false); end end)

end

function me:SetupDeletionOptions(parent)
	me.DeletionOptions=CreateFrame("Frame",nil,parent)
	local theFrame=me.DeletionOptions
	theFrame:SetHeight(200)
	theFrame:SetWidth(200)
	theFrame:SetPoint("TOPLEFT",parent,"TOPLEFT",400,-34)
	
	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetText(L["Data Deletion"])
	theFrame.Title:SetPoint("TOP",theFrame,"TOP",0,-2)
	
	theFrame.Autodelete=me:CreateSavedCheckbox(L["Autodelete Time Data"],theFrame,"Data","AutodeleteTime")
	theFrame.Autodelete:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-23)
	theFrame.Autodelete:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.AutoDelete = true; else this:SetChecked(false); ReRecount.db.profile.AutoDelete = false; end end)


	theFrame.TitleInstance=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.TitleInstance:SetText(L["Instance Based Deletion"])
	theFrame.TitleInstance:SetPoint("TOP",theFrame,"TOP",0,-46)
	
	theFrame.AutodeleteI=me:CreateSavedCheckbox(L["Delete on Entry"],theFrame,"Data","AutodeleteInstance") -- Elsia: Bye Autodeletecombatants
	theFrame.AutodeleteI:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-63)	
	theFrame.AutodeleteI:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.AutoDeleteNewInstance = true; theFrame.AutodeleteINew:Enable(); theFrame.AutodeleteIConf:Enable() else this:SetChecked(false); ReRecount.db.profile.AutoDeleteNewInstance = false; theFrame.AutodeleteINew:Disable(); theFrame.AutodeleteIConf:Disable() end ReRecount:DetectInstanceChange() end)
	theFrame.AutodeleteINew=me:CreateSavedCheckbox(L["New"],theFrame,"Data","AutodeleteInstanceNew") -- Elsia: Bye Autodeletecombatants
	theFrame.AutodeleteINew:SetPoint("TOPLEFT",theFrame,"TOPLEFT",132,-63)	
	theFrame.AutodeleteINew:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.DeleteNewInstanceOnly = true; else this:SetChecked(false); ReRecount.db.profile.DeleteNewInstanceOnly = false; end end)

	theFrame.AutodeleteIConf=me:CreateSavedCheckbox(L["Confirmation"],theFrame,"Data","AutodeleteInstanceConf") -- Elsia: Bye Autodeletecombatants
	theFrame.AutodeleteIConf:SetPoint("TOPLEFT",theFrame,"TOPLEFT",36,-80)	
	theFrame.AutodeleteIConf:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.ConfirmDeleteInstance = true; else this:SetChecked(false); ReRecount.db.profile.ConfirmDeleteInstance = false; end end)

	theFrame.TitleInstance=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.TitleInstance:SetText(L["Group Based Deletion"])
	theFrame.TitleInstance:SetPoint("TOP",theFrame,"TOP",0,-103)
	
	theFrame.AutodeleteG=me:CreateSavedCheckbox(L["Delete on New Group"],theFrame,"Data","AutodeleteGroup") -- Elsia: Bye Autodeletecombatants
	theFrame.AutodeleteG:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-120)	
	theFrame.AutodeleteG:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.DeleteJoinGroup = true; theFrame.AutodeleteGConf:Enable(); ReRecount:InitPartyBasedDeletion() else this:SetChecked(false); ReRecount.db.profile.DeleteJoinGroup= false; theFrame.AutodeleteGConf:Disable(); ReRecount:ReleasePartyBasedDeletion() end end)

	theFrame.AutodeleteGConf=me:CreateSavedCheckbox(L["Confirmation"],theFrame,"Data","AutodeleteGroupConf") -- Elsia: Bye Autodeletecombatants
	theFrame.AutodeleteGConf:SetPoint("TOPLEFT",theFrame,"TOPLEFT",36,-139)	
	theFrame.AutodeleteGConf:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.ConfirmDeleteGroup = true; else this:SetChecked(false); ReRecount.db.profile.ConfirmDeleteGroup = false; end end)

	theFrame.AutodeleteR=me:CreateSavedCheckbox(L["Delete on New Raid"],theFrame,"Data","AutodeleteRaid") -- Elsia: Bye Autodeletecombatants
	theFrame.AutodeleteR:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-154)	
	theFrame.AutodeleteR:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.DeleteJoinRaid = true; theFrame.AutodeleteRConf:Enable(); ReRecount:InitPartyBasedDeletion() else this:SetChecked(false); ReRecount.db.profile.DeleteJoinRaid= false; theFrame.AutodeleteRConf:Disable(); ReRecount:ReleasePartyBasedDeletion() end end)

	theFrame.AutodeleteRConf=me:CreateSavedCheckbox(L["Confirmation"],theFrame,"Data","AutodeleteRaidConf") -- Elsia: Bye Autodeletecombatants
	theFrame.AutodeleteRConf:SetPoint("TOPLEFT",theFrame,"TOPLEFT",36,-171)	
	theFrame.AutodeleteRConf:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.ConfirmDeleteRaid = true; else this:SetChecked(false); ReRecount.db.profile.ConfirmDeleteRaid = false; end end)

end

function me:SetupRealtimeOptions(parent)
	me.RealtimeOptions=CreateFrame("Frame",nil,parent)
	local theFrame=me.RealtimeOptions
	theFrame:SetHeight(200)
	theFrame:SetWidth(200)
	theFrame:SetPoint("TOPLEFT",parent,"TOPLEFT",400,-34)
	
	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetText(L["Global Realtime Windows"])
	theFrame.Title:SetPoint("TOP",theFrame,"TOP",0,-2)

	theFrame.TitleRaid=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.TitleRaid:SetText(L["Raid"])
	theFrame.TitleRaid:SetPoint("TOP",theFrame,"TOP",0,-26)
	
	theFrame.RDPSButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.RDPSButton:SetWidth(90)
	theFrame.RDPSButton:SetHeight(24)
	theFrame.RDPSButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",7,-40)
	theFrame.RDPSButton:SetScript("OnClick",function() ReRecount:CreateRealtimeWindow("!RAID","DAMAGE","Raid DPS") end)
	theFrame.RDPSButton:SetText(L["DPS"])

	theFrame.RDTPSButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.RDTPSButton:SetWidth(90)
	theFrame.RDTPSButton:SetHeight(24)
	theFrame.RDTPSButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",102,-40)
	theFrame.RDTPSButton:SetScript("OnClick",function() ReRecount:CreateRealtimeWindow("!RAID","DAMAGETAKEN","Raid DTPS") end)
	theFrame.RDTPSButton:SetText(L["DTPS"])

	theFrame.RHPSButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.RHPSButton:SetWidth(90)
	theFrame.RHPSButton:SetHeight(24)
	theFrame.RHPSButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",7,-66)
	theFrame.RHPSButton:SetScript("OnClick",function() ReRecount:CreateRealtimeWindow("!RAID","HEALING","Raid HPS") end)
	theFrame.RHPSButton:SetText(L["HPS"])

	theFrame.RHTPSButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.RHTPSButton:SetWidth(90)
	theFrame.RHTPSButton:SetHeight(24)
	theFrame.RHTPSButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",102,-66)
	theFrame.RHTPSButton:SetScript("OnClick",function() ReRecount:CreateRealtimeWindow("!RAID","HEALINGTAKEN","Raid HTPS") end)
	theFrame.RHTPSButton:SetText(L["HTPS"])

	theFrame.TitleRaid=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.TitleRaid:SetText(L["Network"])
	theFrame.TitleRaid:SetPoint("TOP",theFrame,"TOP",0,-106)

	theFrame.FPSButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.FPSButton:SetWidth(90)
	theFrame.FPSButton:SetHeight(24)
	theFrame.FPSButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",7,-120)
	theFrame.FPSButton:SetScript("OnClick",function() ReRecount:CreateRealtimeWindow("FPS","FPS","") end)
	theFrame.FPSButton:SetText(L["FPS"])

	theFrame.LATButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.LATButton:SetWidth(90)
	theFrame.LATButton:SetHeight(24)
	theFrame.LATButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",102,-120)
	theFrame.LATButton:SetScript("OnClick",function() ReRecount:CreateRealtimeWindow("Latency","LAG","") end)
	theFrame.LATButton:SetText(L["Latency"])

	theFrame.UPTButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.UPTButton:SetWidth(90)
	theFrame.UPTButton:SetHeight(24)
	theFrame.UPTButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",7,-146)
	theFrame.UPTButton:SetScript("OnClick",function() ReRecount:CreateRealtimeWindow("Upstream Traffic","UP_TRAFFIC","") end)
	theFrame.UPTButton:SetText(L["Up Traffic"])

	theFrame.DOTButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.DOTButton:SetWidth(90)
	theFrame.DOTButton:SetHeight(24)
	theFrame.DOTButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",102,-146)
	theFrame.DOTButton:SetScript("OnClick",function() ReRecount:CreateRealtimeWindow("Downstream Traffic","DOWN_TRAFFIC","") end)
	theFrame.DOTButton:SetText(L["Down Traffic"])

	theFrame.BWButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.BWButton:SetWidth(90)
	theFrame.BWButton:SetHeight(24)
	theFrame.BWButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",55,-172)
	theFrame.BWButton:SetScript("OnClick",function() ReRecount:CreateRealtimeWindow("Bandwidth Available","AVAILABLE_BANDWIDTH","") end)
	theFrame.BWButton:SetText(L["Bandwidth"])
end

local ZoneLabels = 
{
	["none"] = L["Outside Instances"],
	["party"] = L["Party Instances"],
	["raid"] = L["Raid Instances"],
	["pvp"] = L["Battlegrounds"],
	["arena"] = L["Arenas"]
}

local ZoneOrder = 
{
	"none", "party", "raid", "pvp", "arena"
}

function me:SetupMiscOptions(parent)
	me.MiscOptions=CreateFrame("Frame",nil,parent)
	local theFrame=me.MiscOptions

	theFrame:SetHeight(200)
	theFrame:SetWidth(200)
	theFrame:SetPoint("TOPLEFT",parent,"TOPLEFT",200,-34)

	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetText(L["ReRecount Version"])
	theFrame.Title:SetPoint("TOP",theFrame,"TOP",-20,-2)
	
	theFrame.VersionText=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.VersionText:SetTextColor(1,1,1,1)
	theFrame.VersionText:SetText(ReRecount.Version)
	theFrame.VersionText:SetPoint("LEFT",theFrame.Title,"RIGHT",4,0) -- TOP theFrame TOP -20
	
	theFrame.VerChkButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.VerChkButton:SetWidth(120)
	theFrame.VerChkButton:SetHeight(24)
	theFrame.VerChkButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",40,-18)
	theFrame.VerChkButton:SetScript("OnClick",function() ReRecount.ReportVersions() end)
	theFrame.VerChkButton:SetText(L["Check Versions"])

	theFrame.Title2=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title2:SetText(L["Content-based Filters"])
	theFrame.Title2:SetPoint("TOP",theFrame,"TOP",0,-45)

	local i = 0
	for _,k in pairs(ZoneOrder) do
		theFrame[k]=me:CreateSavedCheckbox(ZoneLabels[k],theFrame,"Data",k)
		theFrame[k]:SetPoint("TOPLEFT",theFrame,"TOPLEFT",10,-59-i*16)
		theFrame[k]:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.ZoneFilters[k] = true; local _,inst=IsInInstance(); ReRecount:SetZoneFilter(inst); ReRecount:RefreshMainWindow(); else this:SetChecked(false); ReRecount.db.profile.ZoneFilters[k] = false; local _,inst=IsInInstance(); ReRecount:SetZoneFilter(inst); ReRecount:RefreshMainWindow() end end)
		i = i+1
	end

	theFrame.GlobalData=me:CreateSavedCheckbox(L["Global Data Collection"],theFrame,"Data","GlobalData")
	theFrame.GlobalData:SetPoint("TOPLEFT",theFrame,"TOPLEFT",10,-59-i*16-3)
	theFrame.GlobalData:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.GlobalDataCollect = true; for k,_ in pairs(ZoneLabels) do theFrame[k]:Enable() end if ReRecount.db.profile.HideCollect then ReRecount.MainWindow:Show() end else this:SetChecked(false); ReRecount.db.profile.GlobalDataCollect = false; for k,_ in pairs(ZoneLabels) do theFrame[k]:Disable() end if ReRecount.db.profile.HideCollect then ReRecount.MainWindow:Hide() end end end)

	i = i+1
	
	theFrame.HideCollect=me:CreateSavedCheckbox(L["Hide When Not Collecting"],theFrame,"Data","HideCollect")
	theFrame.HideCollect:SetPoint("TOPLEFT",theFrame,"TOPLEFT",10,-59-i*16-6)
	theFrame.HideCollect:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.HideCollect = true; local _,inst=IsInInstance(); ReRecount:SetZoneFilter(inst) else this:SetChecked(false); ReRecount.db.profile.HideCollect = false; local _,inst=IsInInstance(); ReRecount:SetZoneFilter(inst) end end)

	theFrame.Title3=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title3:SetText(L["Fight Segmentation"])
	theFrame.Title3:SetPoint("TOP",theFrame,"TOP",0,-88-i*16-4)

	i = i+1

	theFrame.SegmentBosses=me:CreateSavedCheckbox(L["Keep Only Boss Segments"],theFrame,"Data","SegmentBosses")
	theFrame.SegmentBosses:SetPoint("TOPLEFT",theFrame,"TOPLEFT",10,-88-i*16-2)
	theFrame.SegmentBosses:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.SegmentBosses = true; else this:SetChecked(false); ReRecount.db.profile.SegmentBosses = false; end end)
end

function me:SetupButtonOptions(parent)
	me.ButtonOptions=CreateFrame("Frame",nil,parent)
	local theFrame=me.ButtonOptions

	theFrame:SetHeight(196)
	theFrame:SetWidth(196)
	theFrame:SetPoint("TOPLEFT",parent,"TOPLEFT",0,-34)
	--Reset
	--File
	--Config
	--Report

	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetText(L["Main Window Options"])
	theFrame.Title:SetPoint("TOP",theFrame,"TOP",0,-2)

	theFrame.ButtonsTitle=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.ButtonsTitle:SetText(L["Show Buttons"])
	theFrame.ButtonsTitle:SetPoint("TOP",theFrame,"TOPLEFT",100,-16)
	
	theFrame.ReportButton=CreateFrame("CheckButton",nil,theFrame)
	me:ConfigureCheckbox(theFrame.ReportButton)
	theFrame.ReportButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",8,-18-16)
	theFrame.ReportButton:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.Buttons.ReportButton = true; ReRecount:SetupMainWindowButtons() else this:SetChecked(false); ReRecount.db.profile.MainWindow.Buttons.ReportButton = false; ReRecount:SetupMainWindowButtons() end end)

	theFrame.Report_Icon=theFrame:CreateTexture(nil,"OVERLAY")
	theFrame.Report_Icon:SetWidth(16)
	theFrame.Report_Icon:SetHeight(16)
	theFrame.Report_Icon:SetTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up.blp")
	theFrame.Report_Icon:SetPoint("LEFT",theFrame.ReportButton,"RIGHT",2,0)

	theFrame.Report_Text=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Report_Text:SetText(L["Report"])
	theFrame.Report_Text:SetPoint("LEFT",theFrame.Report_Icon,"RIGHT",2,0)

	theFrame.FileButton=CreateFrame("CheckButton",nil,theFrame)
	me:ConfigureCheckbox(theFrame.FileButton)
	theFrame.FileButton:SetPoint("TOP",theFrame.ReportButton,"BOTTOM",0,-2)
	theFrame.FileButton:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.Buttons.FileButton = true; ReRecount:SetupMainWindowButtons() else this:SetChecked(false); ReRecount.db.profile.MainWindow.Buttons.FileButton = false; ReRecount:SetupMainWindowButtons() end end)

	theFrame.File_Icon=theFrame:CreateTexture(nil,"OVERLAY")
	theFrame.File_Icon:SetWidth(16)
	theFrame.File_Icon:SetHeight(16)
	theFrame.File_Icon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up.blp")
	theFrame.File_Icon:SetPoint("LEFT",theFrame.FileButton,"RIGHT",2,0)

	theFrame.File_Text=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.File_Text:SetText(L["File"])
	theFrame.File_Text:SetPoint("LEFT",theFrame.File_Icon,"RIGHT",2,0)

	theFrame.ConfigButton=CreateFrame("CheckButton",nil,theFrame)
	me:ConfigureCheckbox(theFrame.ConfigButton)
	theFrame.ConfigButton:SetPoint("TOPLEFT",theFrame,"TOPLEFT",100,-18-16)
	theFrame.ConfigButton:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.Buttons.ConfigButton = true; ReRecount:SetupMainWindowButtons() else this:SetChecked(false); ReRecount.db.profile.MainWindow.Buttons.ConfigButton = false; ReRecount:SetupMainWindowButtons() end end)

	theFrame.Config_Icon=theFrame:CreateTexture(nil,"OVERLAY")
	theFrame.Config_Icon:SetWidth(16)
	theFrame.Config_Icon:SetHeight(16)
	theFrame.Config_Icon:SetTexture("Interface\\Addons\\ReRecount\\Textures\\icon-config")
	theFrame.Config_Icon:SetPoint("LEFT",theFrame.ConfigButton,"RIGHT",2,0)

	theFrame.Config_Text=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Config_Text:SetText(L["Config"])
	theFrame.Config_Text:SetPoint("LEFT",theFrame.Config_Icon,"RIGHT",2,0)

	theFrame.ResetButton=CreateFrame("CheckButton",nil,theFrame)
	me:ConfigureCheckbox(theFrame.ResetButton)
	theFrame.ResetButton:SetPoint("TOP",theFrame.ConfigButton,"BOTTOM",0,-2)
	theFrame.ResetButton:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.Buttons.ResetButton = true; ReRecount:SetupMainWindowButtons() else this:SetChecked(false); ReRecount.db.profile.MainWindow.Buttons.ResetButton = false; ReRecount:SetupMainWindowButtons() end end)

	theFrame.Reset_Icon=theFrame:CreateTexture(nil,"OVERLAY")
	theFrame.Reset_Icon:SetWidth(16)
	theFrame.Reset_Icon:SetHeight(16)
	theFrame.Reset_Icon:SetTexture("Interface\\Addons\\ReRecount\\Textures\\icon-reset")
	theFrame.Reset_Icon:SetPoint("LEFT",theFrame.ResetButton,"RIGHT",2,0)

	theFrame.Reset_Text=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Reset_Text:SetText(L["Reset"])
	theFrame.Reset_Text:SetPoint("LEFT",theFrame.Reset_Icon,"RIGHT",2,0)

	theFrame.LeftButton=CreateFrame("CheckButton",nil,theFrame) -- Elsia: Added paging icon toggle support
	me:ConfigureCheckbox(theFrame.LeftButton)
	theFrame.LeftButton:SetPoint("TOP",theFrame.FileButton,"BOTTOM",0,-2)
	theFrame.LeftButton:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.Buttons.LeftButton = true; ReRecount:SetupMainWindowButtons() else this:SetChecked(false); ReRecount.db.profile.MainWindow.Buttons.LeftButton = false; ReRecount:SetupMainWindowButtons() end end)

	theFrame.Left_Icon=theFrame:CreateTexture(nil,"OVERLAY")
	theFrame.Left_Icon:SetWidth(16)
	theFrame.Left_Icon:SetHeight(16)
	theFrame.Left_Icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up.blp")
	theFrame.Left_Icon:SetPoint("LEFT",theFrame.LeftButton,"RIGHT",2,0)

	theFrame.Left_Text=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Left_Text:SetText(L["Previous"])
	theFrame.Left_Text:SetPoint("LEFT",theFrame.Left_Icon,"RIGHT",2,0)

	theFrame.RightButton=CreateFrame("CheckButton",nil,theFrame) -- Elsia: Added paging icon toggle support
	me:ConfigureCheckbox(theFrame.RightButton)
	theFrame.RightButton:SetPoint("TOP",theFrame.ResetButton,"BOTTOM",0,-2)
	theFrame.RightButton:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.Buttons.RightButton = true; ReRecount:SetupMainWindowButtons() else this:SetChecked(false); ReRecount.db.profile.MainWindow.Buttons.RightButton = false; ReRecount:SetupMainWindowButtons() end end)

	theFrame.Right_Icon=theFrame:CreateTexture(nil,"OVERLAY")
	theFrame.Right_Icon:SetWidth(16)
	theFrame.Right_Icon:SetHeight(16)
	theFrame.Right_Icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up.blp")
	theFrame.Right_Icon:SetPoint("LEFT",theFrame.RightButton,"RIGHT",2,0)

	theFrame.Right_Text=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Right_Text:SetText(L["Next"])
	theFrame.Right_Text:SetPoint("LEFT",theFrame.Right_Icon,"RIGHT",2,0)

	local slider = CreateFrame("Slider", "ReRecount_ConfigWindow_RowHeight_Slider", theFrame,"OptionsSliderTemplate")
	theFrame.RowHeightSlider=slider
	slider:SetOrientation("HORIZONTAL")
	slider:SetMinMaxValues(8, 35)
	slider:SetValueStep(1)
	slider:SetWidth(180)
	slider:SetHeight(16)
	slider:SetPoint("TOP", theFrame, "TOP", 0, -96-16) -- Elsia: TODO this number will need adjusting to accommodate the paging config change
	slider:SetScript("OnValueChanged",function() getglobal(this:GetName().."Text"):SetText(L["Row Height"]..": "..this:GetValue());ReRecount.db.profile.MainWindow.RowHeight=this:GetValue();ReRecount:BarsChanged() end)
	getglobal(slider:GetName().."High"):SetText("35");
	getglobal(slider:GetName().."Low"):SetText("8");
	getglobal(slider:GetName().."Text"):SetText(L["Row Height"]..": "..slider:GetValue())

	slider = CreateFrame("Slider", "ReRecount_ConfigWindow_RowSpacing_Slider", theFrame,"OptionsSliderTemplate")
	theFrame.RowSpacingSlider=slider
	slider:SetOrientation("HORIZONTAL")
	slider:SetMinMaxValues(0, 4)
	slider:SetValueStep(1)
	slider:SetWidth(180)
	slider:SetHeight(16)
	slider:SetPoint("TOP", theFrame, "TOP", 0, -130-16)
	slider:SetScript("OnValueChanged",function() getglobal(this:GetName().."Text"):SetText(L["Row Spacing"]..": "..this:GetValue());ReRecount.db.profile.MainWindow.RowSpacing=this:GetValue();ReRecount:BarsChanged() end)
	getglobal(slider:GetName().."High"):SetText("4");
	getglobal(slider:GetName().."Low"):SetText("0");
	getglobal(slider:GetName().."Text"):SetText(L["Row Spacing"]..": "..slider:GetValue())

	theFrame.TotalBar=CreateFrame("CheckButton",nil,theFrame)
	me:ConfigureCheckbox(theFrame.TotalBar)
	theFrame.TotalBar:SetPoint("TOPLEFT",theFrame,"TOPLEFT",12,-158-16)
	theFrame.TotalBar:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.HideTotalBar = false; ReRecount:RefreshMainWindow(); ReRecount:BarsChanged(); else this:SetChecked(false); ReRecount.db.profile.MainWindow.HideTotalBar = true; ReRecount:RefreshMainWindow(); ReRecount:BarsChanged(); end end)

	theFrame.TotalBarText=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.TotalBarText:SetText(L["Show Total Bar"])
	theFrame.TotalBarText:SetPoint("LEFT",theFrame.TotalBar,"RIGHT",8,0)

	theFrame.ShowSB=CreateFrame("CheckButton",nil,theFrame)
	me:ConfigureCheckbox(theFrame.ShowSB)
	theFrame.ShowSB:SetPoint("TOPLEFT",theFrame,"TOPLEFT",12,-175-16)
	theFrame.ShowSB:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.ShowScrollbar = true; ReRecount:ShowScrollbarElements("ReRecount_MainWindow_ScrollBar") else this:SetChecked(false); ReRecount.db.profile.MainWindow.ShowScrollbar = false; ReRecount:HideScrollbarElements("ReRecount_MainWindow_ScrollBar") end ReRecount:RefreshMainWindow() end)

	theFrame.ShowSBText=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.ShowSBText:SetText(L["Show Scrollbar"])
	theFrame.ShowSBText:SetPoint("LEFT",theFrame.ShowSB,"RIGHT",8,0)
	
	theFrame.AutoHide=CreateFrame("CheckButton",nil,theFrame)
	me:ConfigureCheckbox(theFrame.AutoHide)
	theFrame.AutoHide:SetPoint("TOPLEFT",theFrame,"TOPLEFT",12,-192-16)
	theFrame.AutoHide:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true); ReRecount.db.profile.MainWindow.AutoHide = true; else this:SetChecked(false); ReRecount.db.profile.MainWindow.AutoHide = false; end end)

	theFrame.AutohideText=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.AutohideText:SetText(L["Autohide On Combat"])
	theFrame.AutohideText:SetPoint("LEFT",theFrame.AutoHide,"RIGHT",8,0)

end




function me:ScaleConfigWindow(scale)
	local pointNum=me.ConfigWindow:GetNumPoints()
	local curScale=me.ConfigWindow:GetScale();
	local points={}
	for i=1,pointNum,1 do
		points[i]={};
		points[i][1], points[i][2], points[i][3], points[i][4], points[i][5]=me.ConfigWindow:GetPoint(i)
		points[i][4]=points[i][4]*curScale/scale;
		points[i][5]=points[i][5]*curScale/scale;
	end

	me.ConfigWindow:ClearAllPoints()
	for i=1,pointNum,1 do
		me.ConfigWindow:SetPoint(points[i][1],points[i][2],points[i][3],points[i][4],points[i][5]);
	end

	me.ConfigWindow:SetScale(scale)
end

function me:HideOptions()
	me.ConfigWindow.Data:Hide()
	me.ConfigWindow.Data.Tab.Background:SetVertexColor(1.0,0.2,0.2)
	me.ConfigWindow.Appearance:Hide()
	me.ConfigWindow.Appearance.Tab.Background:SetVertexColor(1.0,0.2,0.2)
	me.ConfigWindow.Window:Hide()
	me.ConfigWindow.Window.Tab.Background:SetVertexColor(1.0,0.2,0.2)
	me.ConfigWindow.ColorOpt:Hide()
	me.ConfigWindow.ColorOpt.Tab.Background:SetVertexColor(1.0,0.2,0.2)
end


function me:CreateDataOptions(parent)
	local theFrame=CreateFrame("FRAME",nil,parent)
	parent.Data=theFrame

	theFrame:SetWidth(600)
	theFrame:SetHeight(200)
	theFrame:SetPoint("TOP",parent,"TOP",0,-22)

	local Tab=CreateFrame("FRAME",nil,parent)
	parent.Data.Tab=Tab

	Tab:SetWidth(100)
	Tab:SetHeight(18)
	Tab:SetPoint("TOPLEFT", parent, "TOPLEFT",4,-35)
	Tab:EnableMouse(true)
	Tab:SetScript("OnMouseDown",function() me:HideOptions();theFrame:Show();this.Background:SetVertexColor(0.2,1.0,0.2) end)
	Tab.Text=Tab:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Tab.Text:SetPoint("CENTER",Tab,"CENTER")
	Tab.Text:SetText(L["Data"])
	Tab.Background=Tab:CreateTexture(nil,"BACKGROUND")
	Tab.Background:SetTexture(1,1,1,0.3)
	Tab.Background:SetVertexColor(0.2,1.0,0.2)
	Tab.Background:SetAllPoints(Tab)


	me:SetupFilterOptions(theFrame)
	me:SetupMiscOptions(theFrame)
	me:SetupDeletionOptions(theFrame)
end

function me:CreateAppearanceOptions(parent)
	local theFrame=CreateFrame("FRAME",nil,parent)
	parent.Appearance=theFrame

	theFrame:SetWidth(600)
	theFrame:SetHeight(200)
	theFrame:SetPoint("TOP",parent,"TOP",0,-22)

	local Tab=CreateFrame("FRAME",nil,parent)
	parent.Appearance.Tab=Tab

	Tab:SetWidth(100)
	Tab:SetHeight(18)
	Tab:SetPoint("TOPLEFT", parent, "TOPLEFT",208,-35)
	Tab:EnableMouse(true)
	Tab:SetScript("OnMouseDown",function() me:HideOptions();theFrame:Show();this.Background:SetVertexColor(0.2,1.0,0.2) end)
	Tab.Text=Tab:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Tab.Text:SetPoint("CENTER",Tab,"CENTER")
	Tab.Text:SetText(L["Appearance"])
	Tab.Background=Tab:CreateTexture(nil,"BACKGROUND")
	Tab.Background:SetTexture(1,1,1,0.3)
	Tab.Background:SetVertexColor(1.0,0.2,0.2)
	Tab.Background:SetAllPoints(Tab)

	me:CreateBarSelection(theFrame)
	me:CreateTextureSelection(theFrame)
	me:CreateFontSelection(theFrame)
	theFrame:Hide()
end

function me:CreateColorOptions(parent)
	local theFrame=CreateFrame("FRAME",nil,parent)
	parent.ColorOpt=theFrame

	theFrame:SetWidth(600)
	theFrame:SetHeight(200)
	theFrame:SetPoint("TOP",parent,"TOP",0,-22)

	local Tab=CreateFrame("FRAME",nil,parent)
	parent.ColorOpt.Tab=Tab

	Tab:SetWidth(100)
	Tab:SetHeight(18)
	Tab:SetPoint("TOPLEFT", parent, "TOPLEFT",310,-35) -- Elsia: Check tab offset
	Tab:EnableMouse(true)
	Tab:SetScript("OnMouseDown",function() me:HideOptions();theFrame:Show();this.Background:SetVertexColor(0.2,1.0,0.2) end)
	Tab.Text=Tab:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Tab.Text:SetPoint("CENTER",Tab,"CENTER")
	Tab.Text:SetText(L["Color"])
	Tab.Background=Tab:CreateTexture(nil,"BACKGROUND")
	Tab.Background:SetTexture(1,1,1,0.3)
	Tab.Background:SetVertexColor(1.0,0.2,0.2)
	Tab.Background:SetAllPoints(Tab)

	me:CreateWindowColorSelection(theFrame)
	me:CreateClassColorSelection(theFrame)
	theFrame:Hide()
end



function me:CreateWindowOptions(parent)
	local theFrame=CreateFrame("FRAME",nil,parent)
	parent.Window=theFrame

	local Tab=CreateFrame("FRAME",nil,parent)
	parent.Window.Tab=Tab

	Tab:SetWidth(100)
	Tab:SetHeight(18)
	Tab:SetPoint("TOPLEFT", parent, "TOPLEFT",106,-35)
	Tab:EnableMouse(true)
	Tab:SetScript("OnMouseDown",function() me:HideOptions();theFrame:Show();this.Background:SetVertexColor(0.2,1.0,0.2) end)
	Tab.Text=Tab:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Tab.Text:SetPoint("CENTER",Tab,"CENTER")
	Tab.Text:SetText(L["Window"])
	Tab.Background=Tab:CreateTexture(nil,"BACKGROUND")
	Tab.Background:SetTexture(1,1,1,0.3)
	Tab.Background:SetVertexColor(1.0,0.2,0.2)
	Tab.Background:SetAllPoints(Tab)

	theFrame:SetWidth(600)
	theFrame:SetHeight(200)
	theFrame:SetPoint("TOP",parent,"TOP",0,-22)

	me:SetupButtonOptions(theFrame)
	me:SetupWindowOptions(theFrame)
	me:SetupRealtimeOptions(theFrame)
	theFrame:Hide()
end

function me:CreateConfigWindow()
	me.ConfigWindow=ReRecount:CreateFrame("ReRecount_ConfigWindow",L["Config ReRecount"],286,600)

	local theFrame=me.ConfigWindow
	
	ReRecount.Colors:RegisterTexture("Other Windows","Title",Graph:DrawLine(theFrame,200,12,200,233,24,{0.5,0.0,0.0,1.0},"ARTWORK"),{r=0.5,g=0.5,b=0.5,a=1}) -- Elsia: Changed 32->12 for longer separators given no save/revert
	ReRecount.Colors:RegisterTexture("Other Windows","Title",Graph:DrawLine(theFrame,400,12,400,233,24,{0.5,0.0,0.0,1.0},"ARTWORK"),{r=0.5,g=0.5,b=0.5,a=1})
	ReRecount.Colors:RegisterTexture("Other Windows","Title",Graph:DrawLine(theFrame,2,233,598,233,24,{0.5,0.0,0.0,1.0},"ARTWORK"),{r=0.5,g=0.5,b=0.5,a=1})

	theFrame:Hide()

	me:CreateDataOptions(theFrame)
	me:CreateAppearanceOptions(theFrame)
	me:CreateWindowOptions(theFrame)
	me:CreateColorOptions(theFrame)
	
	--Need to add it to our window ordering system
	ReRecount:AddWindow(theFrame)
	ReRecount:LockWindows(ReRecount.db.profile.Locked)
	ReRecount.ConfigWindow = theFrame
end

function me:LoadConfig()
	for k, v in pairs(me.FilterOptions.Filters) do
		v.ShowData:SetChecked(ReRecount.db.profile.Filters.Show[k])
		v.RecordData:SetChecked(ReRecount.db.profile.Filters.Data[k])
		v.RecordTime:SetChecked(ReRecount.db.profile.Filters.TimeData[k])
		v.TrackDeaths:SetChecked(ReRecount.db.profile.Filters.TrackDeaths[k])		
	end

	me.MiscOptions.GlobalData:SetChecked(ReRecount.db.profile.GlobalDataCollect)
	me.MiscOptions.HideCollect:SetChecked(ReRecount.db.profile.HideCollect)
	me.MiscOptions.SegmentBosses:SetChecked(ReRecount.db.profile.SegmentBosses)
	
	for k, v in pairs(ZoneLabels) do
		me.MiscOptions[k]:SetChecked(ReRecount.db.profile.ZoneFilters[k])
	end
	
	for k, v in pairs(ReRecount.db.profile.MainWindow.Buttons) do
		me.ButtonOptions[k]:SetChecked(v)
	end

	me.ButtonOptions.RowHeightSlider:SetValue(ReRecount.db.profile.MainWindow.RowHeight)
	me.ButtonOptions.RowSpacingSlider:SetValue(ReRecount.db.profile.MainWindow.RowSpacing)
	me.ButtonOptions.AutoHide:SetChecked(ReRecount.db.profile.MainWindow.AutoHide)
	me.ButtonOptions.TotalBar:SetChecked(not ReRecount.db.profile.MainWindow.HideTotalBar)
	me.ButtonOptions.ShowSB:SetChecked(ReRecount.db.profile.MainWindow.ShowScrollbar)
	
	me.WindowOptions.ScalingSlider:SetValue(ReRecount.db.profile.Scaling)
--	me.WindowOptions.ShowCurAndLast:SetChecked(ReRecount.db.profile.Window.ShowCurAndLast)
	me.WindowOptions.LockWin:SetChecked(ReRecount.db.profile.Locked)

--	me.MiscOptions.Sync:SetChecked(ReRecount.db.profile.EnableSync)

	me.DeletionOptions.Autodelete:SetChecked(ReRecount.db.profile.AutoDelete)
	me.DeletionOptions.AutodeleteI:SetChecked(ReRecount.db.profile.AutoDeleteNewInstance)
	me.DeletionOptions.AutodeleteIConf:SetChecked(ReRecount.db.profile.ConfirmDeleteInstance)
	me.DeletionOptions.AutodeleteINew:SetChecked(ReRecount.db.profile.DeleteNewInstanceOnly)
	me.DeletionOptions.AutodeleteG:SetChecked(ReRecount.db.profile.DeleteJoinGroup)
	me.DeletionOptions.AutodeleteGConf:SetChecked(ReRecount.db.profile.ConfirmDeleteGroup)
	me.DeletionOptions.AutodeleteR:SetChecked(ReRecount.db.profile.DeleteJoinRaid)
	me.DeletionOptions.AutodeleteRConf:SetChecked(ReRecount.db.profile.ConfirmDeleteRaid)

	
	me.FilterOptions.MergePets:SetChecked(ReRecount.db.profile.MergePets)

	me:ScaleConfigWindow(ReRecount.db.profile.Scaling)
	
	me.BarOptions.RankNum:SetChecked(ReRecount.db.profile.MainWindow.BarText.RankNum)
	me.BarOptions.PerSec:SetChecked(ReRecount.db.profile.MainWindow.BarText.PerSec)
	me.BarOptions.Percent:SetChecked(ReRecount.db.profile.MainWindow.BarText.Percent)

	me.BarOptions.Standard:SetChecked(ReRecount.db.profile.MainWindow.BarText.NumFormat == 1)
	me.BarOptions.Commas:SetChecked(ReRecount.db.profile.MainWindow.BarText.NumFormat == 2)
	me.BarOptions.Short:SetChecked(ReRecount.db.profile.MainWindow.BarText.NumFormat == 3)
end

function me:SaveFilterConfig()
	for k, v in pairs(me.FilterOptions.Filters) do
		ReRecount.db.profile.Filters.Show[k]=v.ShowData:GetChecked()==1
		ReRecount.db.profile.Filters.Data[k]=v.RecordData:GetChecked()==1
		ReRecount.db.profile.Filters.TimeData[k]=v.RecordTime:GetChecked()==1
		ReRecount.db.profile.Filters.TrackDeaths[k]=v.TrackDeaths:GetChecked()==1
	end
	ReRecount:FullRefreshMainWindow()
end

--[ Elsia: This is now obsolete, RIP save
function me:SaveConfig()
	for k, v in pairs(me.FilterOptions.Filters) do
		ReRecount.db.profile.Filters.Show[k]=v.ShowData:GetChecked()==1
		ReRecount.db.profile.Filters.Data[k]=v.RecordData:GetChecked()==1
		ReRecount.db.profile.Filters.TimeData[k]=v.RecordTime:GetChecked()==1
		ReRecount.db.profile.Filters.TrackDeaths[k]=v.TrackDeaths:GetChecked()==1
	end

	for k, v in pairs(ReRecount.db.profile.MainWindow.Buttons) do
		ReRecount.db.profile.MainWindow.Buttons[k]=(me.ButtonOptions[k]:GetChecked()==1)
	end
	ReRecount.db.profile.MainWindow.AutoHide=me.ButtonOptions.AutoHide:GetChecked()==1
	ReRecount.db.profile.MainWindow.HideTotalBar=me.ButtonOptions.TotalBar:GetChecked()~=1

--	ReRecount.db.profile.EnableSync=me.MiscOptions.Sync:GetChecked()==1

	ReRecount.db.profile.AutoDelete=me.DeletionOptions.Autodelete:GetChecked()==1

	ReRecount.db.profile.AutoDeleteNewInstance=me.DeletionOptions.AutodeleteI:GetChecked()==1
	ReRecount.db.profile.ConfirmDeleteInstance=me.DeletionOptions.AutodeleteIConf:GetChecked()==1
	ReRecount.db.profile.DeleteNewInstanceOnly=me.DeletionOptions.AutodeleteINew:GetChecked()==1

	ReRecount.db.profile.DeleteJoinGroup=me.DeletionOptions.AutodeleteG:GetChecked()==1
	ReRecount.db.profile.ConfirmDeleteGroup=me.DeletionOptions.AutodeleteGConf:GetChecked()==1
	ReRecount.db.profile.DeleteJoinRaid=me.DeletionOptions.AutodeleteR:GetChecked()==1
	ReRecount.db.profile.ConfirmDeleteRaid=me.DeletionOptions.AutodeleteRConf:GetChecked()==1

	if (not ReRecount.db.profile.MergePets) and (me.FilterOptions.MergePets:GetChecked()==1) then -- Elsia: Toggle Pet display if merge changed
		ReRecount.db.profile.Filters.Show["Pet"]=false
		me.FilterOptions.Filters.Pet.ShowData:SetChecked(ReRecount.db.profile.Filters.Show["Pet"])
	elseif ReRecount.db.profile.MergePets and (me.FilterOptions.MergePets:GetChecked()~=1) then
		ReRecount.db.profile.Filters.Show["Pet"]=true
		me.FilterOptions.Filters.Pet.ShowData:SetChecked(ReRecount.db.profile.Filters.Show["Pet"])
	end

	me:ScaleConfigWindow(ReRecount.db.profile.Scaling) -- Elsia: Refresh display as we changed options

	-- Elsia: Leave it alone otherwise, people can show the pets that way if they want to, but merge will force display on and off when changed.
	
	ReRecount.db.profile.MergePets=me.FilterOptions.MergePets:GetChecked()==1
	
--	ReRecount.db.profile.Window.ShowCurAndLast=me.WindowOptions.ShowCurAndLast:GetChecked()==1

	ReRecount.MainWindow.DispTableSorted={}
	ReRecount.MainWindow.DispTableLookup={}

	ReRecount:SetupMainWindowButtons()
	ReRecount:RefreshMainWindow()
end
--]

function ReRecount:ShowConfig()
	if type(me.ConfigWindow)=="nil" then
		me:CreateConfigWindow()
	end
	me:LoadConfig()
	me.ConfigWindow:Show()
end


function ReRecount:ConfigWindowStatus()
	local below
	local above

	if me.ConfigWindow.Below then
		below = me.ConfigWindow.Below:GetName()
	else
		below = "(nil)"
	end

	if me.ConfigWindow.Above then
		above = me.ConfigWindow.Above:GetName()
	else
		above = "(nil)"
	end

	ReRecount:Print(below.." Config "..above)
end

