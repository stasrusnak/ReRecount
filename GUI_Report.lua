local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale( "ReRecount" )
local me={}

local revision = tonumber(string.sub("$Revision: 67838 $", 12, -3))
if ReRecount.Version < revision then ReRecount.Version = revision end

local ReportLocations={
	{L["Say"],"SAY"},
	{L["Party"],"PARTY",function() return GetNumPartyMembers()>0 end},
	{L["Raid"],"RAID",function() return UnitInRaid("player") end},
	{L["Guild"],"GUILD",IsInGuild},
	{L["Officer"],"OFFICER",IsInGuild},
	{L["Whisper"],"WHISPER"},
	{L["Whisper Target"],"WHISPER2"}
}

local ReportList

function me:CreateReportList()
	ReportList={}

	for _,v in ipairs(ReportLocations) do
		if type(v[3])=="function" and v[3]() then
			table.insert(ReportList,{v[1],v[2]})
		elseif type(v[3])~="function" then
			table.insert(ReportList,{v[1],v[2]})
		end
	end

	local channels={GetChannelList()}

	for i=1,table.getn(channels)/2 do
		table.insert(ReportList,{channels[i*2-1]..". "..channels[i*2],"CHANNEL",channels[i*2-1]})
	end
end

function me:UncheckAll()
	for _,v in ipairs(me.Rows) do
		v.Enabled:SetChecked(false)
	end
end

function me:AddRow()
	local CurRow=me.NumRows+1
	local Row=CreateFrame("Frame",nil,me.ReportWindow)

	Row:SetPoint("TOP",me.ReportWindow,"TOP",0,-34-36-18*CurRow)

	Row:SetHeight(16)
	Row:SetWidth(180)

	Row.Text=Row:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
	Row.Text:SetPoint("LEFT",Row,"LEFT",0,0)
	Row.Text:SetText("")
	ReRecount:AddFontString(Row.Text)

	Row.Enabled=CreateFrame("CheckButton",nil,Row)
	Row.Enabled:SetPoint("RIGHT",Row,"RIGHT",-4,0)
	Row.Enabled:SetWidth(16)
	Row.Enabled:SetHeight(16)
	Row.Enabled.id=CurRow
	Row.Enabled:SetScript("OnClick",function () if this:GetChecked() then me:UncheckAll();this:SetChecked(true);me.Selected=ReportList[this.id][1] else this:SetChecked(false) end end)
	Row.Enabled:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	Row.Enabled:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	Row.Enabled:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	Row.Enabled:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	Row.Enabled:Show()

	table.insert(me.Rows,Row)

	me.NumRows=CurRow
end

function me:UpdateReportWindow()
	local Amount, Row
	me:CreateReportList()
	Amount=table.getn(ReportList)


	for i=me.NumRows+1,Amount do
		me:AddRow()
	end

	for i=1,Amount do
		Row=me.Rows[i]
		Row.Text:SetText(ReportList[i][1])
		if me.Selected~=nil and ReportList[i][1]==me.Selected then
			Row.Enabled:SetChecked(true)
		else
			Row.Enabled:SetChecked(false)
		end
		Row:Show()
	end

	for i=Amount+1,me.NumRows do
		me.Rows[i]:Hide()
	end

	me.ReportWindow:SetHeight(118+20+18*Amount)

	if me.Title then
		me.ReportWindow.Title:SetText(L["Report Data"].." - "..me.Title)
	end
end

function me:CreateReportWindow()
	me.ReportWindow=ReRecount:CreateFrame("ReRecount_ReportWindow",L["Report Data"],116,200)

	local theFrame=me.ReportWindow

	if me.Title then
		theFrame.Title:SetText(L["Report Data"].." - "..me.Title)
	end

	theFrame.Whisper=CreateFrame("EditBox",nil,theFrame, "InputBoxTemplate")
	theFrame.Whisper:SetWidth(120)
	theFrame.Whisper:SetHeight(13)
	theFrame.Whisper:SetPoint("BOTTOMLEFT",theFrame,"BOTTOM",-32,34)
	theFrame.Whisper:SetAutoFocus(false)

	theFrame.WhisperText=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.WhisperText:SetText(L["Whisper"]..":")
	theFrame.WhisperText:SetPoint("RIGHT",theFrame.Whisper,"LEFT",-8,0)
	ReRecount:AddFontString(theFrame.WhisperText)



	theFrame.ReportTitle=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.ReportTitle:SetPoint("TOPLEFT",theFrame,"TOPLEFT",6,-34-40)
	theFrame.ReportTitle:SetText(L["Report To"])
	ReRecount:AddFontString(theFrame.ReportTitle)

	theFrame.ReportButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.ReportButton:SetWidth(90)
	theFrame.ReportButton:SetHeight(24)
	theFrame.ReportButton:SetPoint("BOTTOM",theFrame,"BOTTOM",0,4)
	theFrame.ReportButton:SetScript("OnClick",function() me:SendReport();theFrame:Hide() end)
	theFrame.ReportButton:SetText(L["Report"])

	local slider = CreateFrame("Slider", "ReRecount_ReportWindow_Slider", theFrame,"OptionsSliderTemplate")
	theFrame.slider=slider
	slider:SetOrientation("HORIZONTAL")
	slider:SetMinMaxValues(1, 25)
	slider:SetValueStep(1)
	slider:SetValue(10)
	slider:SetWidth(180)
	slider:SetHeight(16)
	slider:SetPoint("TOP", theFrame, "TOP", 0, -46)
	slider:SetScript("OnValueChanged",function() getglobal(this:GetName().."Text"):SetText(L["Report Top"]..": "..this:GetValue()) end)
	getglobal(slider:GetName().."High"):SetText("25");
	getglobal(slider:GetName().."Low"):SetText("1");
	getglobal(slider:GetName().."Text"):SetText(L["Report Top"]..": "..slider:GetValue())

	theFrame:Hide()

	me.Rows={}
	me.NumRows=0

	--Need to add it to our window ordering system
	ReRecount:AddWindow(theFrame)
end

function me:SendReport()
	local Num,Loc1,Loc2

	Num=me.ReportWindow.slider:GetValue()

	for k,v in ipairs(me.Rows) do
		if v.Enabled:GetChecked() then
			Loc1=ReportList[k][2]
			Loc2=ReportList[k][3]
		end
	end

	if Loc1=="WHISPER" then
		Loc2=me.ReportWindow.Whisper:GetText()
		if Loc2==nil or Loc2=="" then
			ReRecount:Print("No Target Selected")
			return
		end
	elseif Loc1=="WHISPER2" then
		Loc1="WHISPER"
		if UnitExists("target") then
			if UnitIsPlayer("target") then
				Loc2=UnitName("target")
			else
				ReRecount:Print("Target isn't a player")
				return
			end
		else
			ReRecount:Print("No Target Selected")
			return
		end
	end

	ReRecount:ReportFunc(Num,Loc1,Loc2)
end

function ReRecount:ShowReport(Title,ReportFunc)
	me.Title=Title
	if me.ReportWindow==nil then
		me:CreateReportWindow()
	end

	
	me:UpdateReportWindow()
	me.ReportWindow:Show()
	ReRecount.ReportFunc=ReportFunc
end