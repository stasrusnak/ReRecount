local me={}
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")
local Events = LibStub("AceEvent-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale( "ReRecount" )

local revision = tonumber(string.sub("$Revision: 79898 $", 12, -3))
if ReRecount.Version < revision then ReRecount.Version = revision end

local string_format = string.format
local tinsert = table.insert
local tremove = table.remove

local _, _, _, tocversion =  GetBuildInfo()

-- Based on cck's numeric Short code in DogTag-3.0.
function ReRecount.ShortNumber(value)
	if value >= 10000000 or value <= -10000000 then
		return ("%.1fm"):format(value / 1000000)
	elseif value >= 1000000 or value <= -1000000 then
		return ("%.2fm"):format(value / 1000000)
	elseif value >= 100000 or value <= -100000 then
		return ("%.0fk"):format(value / 1000)
	elseif value >= 10000 or value <= -10000 then
		return ("%.1fk"):format(value / 1000)
	else
		return math.floor(value+0.5)..''
	end
end

-- This is comma_value() by Richard Warburton from: http://lua-users.org/wiki/FormattingNumbers with slight modifications (and a bug fix)
function ReRecount.CommaNumber(n)
	n = ("%.0f"):format(n)
   	local left,num,right = string.match(n,'^([^%d]*%d)(%d+)(.-)$')
   	return left and left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse()) or n --..right
end

local NumFormats =
{
	function(value) return ("%.0f"):format(value) end,
	ReRecount.CommaNumber,
	ReRecount.ShortNumber
}

function ReRecount:FormatLongNums(value)
	return NumFormats[ReRecount.db.profile.MainWindow.BarText.NumFormat](value)
end

function me:SetFontSize(string, size)
	local Font, Height, Flags = string:GetFont()
	string:SetFont(Font, size, Flags)
end

function ReRecount:BarDropDownOpen(myframe)
	ReRecount_BarDropDownMenu = CreateFrame("Frame", "ReRecount_BarDropDownMenu", myframe);
	ReRecount_BarDropDownMenu.displayMode = "MENU";
	ReRecount_BarDropDownMenu.initialize	= ReRecount_CreateBarDropdown;
	local leftPos = myframe:GetLeft() -- Elsia: Side code adapted from Mirror
	local rightPos = myframe:GetRight()
	local side
	local oside
	if not rightPos then
		rightPos = 0
	end
	if not leftPos then
		leftPos = 0
	end

	local rightDist = GetScreenWidth() - rightPos

	if leftPos and rightDist < leftPos then
		side = "TOPLEFT"
		oside = "TOPRIGHT"
	else
		side = "TOPRIGHT"
		oside = "TOPLEFT"
	end
	if tocversion == 30000 then
		UIDropDownMenu_SetAnchor(ReRecount_BarDropDownMenu , 0, 0, oside, myframe, side)
	else
		UIDropDownMenu_SetAnchor(0, 0, ReRecount_BarDropDownMenu , oside, myframe, side)
	end
end

function ReRecount:SetupBar(row)
	row.StatusBar=CreateFrame("StatusBar",nil,row)
	row.StatusBar:SetAllPoints(row)

	local BarTexture

	if not BarTexture then
		BarTexture=ReRecount.db.profile.BarTexture
	end

	if BarTexture==nil then
		BarTexture=SM:Fetch("statusbar","BantoBar")
	else
		BarTexture=SM:Fetch("statusbar",BarTexture)
	end
	row.StatusBar:SetStatusBarTexture(BarTexture)
	row.StatusBar:SetStatusBarColor(.5, .5, .5, 1)
	row.StatusBar:SetMinMaxValues(0,100)
	row.StatusBar:SetValue(100)
	row.StatusBar:Show()

	row.LeftText=row.StatusBar:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
	row.LeftText:SetPoint("LEFT", row.StatusBar,"LEFT",2)
	row.LeftText:SetJustifyH("LEFT")
	row.LeftText:SetText("Test")
	row.LeftText:SetTextColor(1,1,1,1)
	me:SetFontSize(row.LeftText,math.max(ReRecount.db.profile.MainWindow.RowHeight*0.75,ReRecount.db.profile.MainWindow.RowHeight-3))
	ReRecount:AddFontString(row.LeftText)
	
	row.RightText=row.StatusBar:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
	row.RightText:SetPoint("RIGHT", row.StatusBar,"RIGHT",-2)
	row.RightText:SetJustifyH("RIGHT")
	row.RightText:SetText("0")
	row.RightText:SetTextColor(1,1,1,1)
	me:SetFontSize(row.RightText,math.max(ReRecount.db.profile.MainWindow.RowHeight*0.75,ReRecount.db.profile.MainWindow.RowHeight-3))
	ReRecount:AddFontString(row.RightText)

	ReRecount.Colors:RegisterFont("Bar","Bar Text",row.LeftText)
	ReRecount.Colors:RegisterFont("Bar","Bar Text",row.RightText)
end

--Violation was my reference (I like the basic look of violation just not the backend)
--Make sure to start with row 1 and go upwards when creating though should be safe if you don't just more function calls
function me:CreateRow(num)
	local rowmin = 1
	local offs = 0

	if not ReRecount.db.profile.MainWindow.HideTotalBar then
		offs = 1
		rowmin = 0
	end


	if num<rowmin or ReRecount.MainWindow.Rows[num] then
		return
	end

	
	local row=CreateFrame("Button","ReRecount_MainWindow_Bar"..num,ReRecount.MainWindow)
	
	row:SetPoint("TOPLEFT",ReRecount.MainWindow,"TOPLEFT",2,-32-(ReRecount.db.profile.MainWindow.RowHeight+ReRecount.db.profile.MainWindow.RowSpacing)*(num-1+offs))
	row:SetHeight(ReRecount.db.profile.MainWindow.RowHeight)
	row:SetWidth(ReRecount.MainWindow:GetWidth()-4)
	if num ~= 0 then
		row:SetScript("OnClick", function() 
						if arg1=="RightButton" then
							ReRecount:BarDropDownOpen(this)
							CloseDropDownMenus(1)
							ToggleDropDownMenu(1, nil, ReRecount_BarDropDownMenu)
						elseif type(this.clickFunc)=="function" and this.clickData then
							this:clickFunc(this.clickData)						
						end
					end)
		row:SetScript("OnEnter", function() GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT");ReRecount.MainWindow:TooltipFunc(this.Name,this.TooltipData);GameTooltip:Show() end)
		row:SetScript("OnLeave", function() GameTooltip:Hide() end)
		row:EnableMouse(true)
		row:RegisterForClicks("LeftButtonDown","RightButtonUp")
	else
		row:EnableMouse(false)
	end
	
	--Add code for the button later
	ReRecount:SetupBar(row)
	
	ReRecount.MainWindow.Rows[num]=row
	ReRecount.MainWindow.RowsCreated=num

	row.id=num

end

local info = {}
function ReRecount_CreateBarDropdown(level)
	if (not level) then return end
	for k in pairs(info) do info[k] = nil end
	if (level == 1) then
	if this and this.LeftText then
		info.isTitle		= 1
		info.text		= this.LeftText:GetText()
		info.notCheckable	= 1
		UIDropDownMenu_AddButton(info, level)

		info = {}
		
		info.isTitle		= nil
		info.notCheckable	= 1
		info.disabled		= nil

		info.text		= L["Show Details (Left Click)"]
		info.notCheckable	= 1
		info.func = me.ShowDetail
		info.arg1 = me
		info.arg2 = this.name
		UIDropDownMenu_AddButton(info, level)

		info.text		= L["Show Graph (Shift Click)"]
		info.notCheckable	= 1
		info.func = me.ShowGraphWindow
		info.arg1 = me
		info.arg2 = this.name
		UIDropDownMenu_AddButton(info, level)
		
		info.text		= L["Add to Current Graph (Alt Click)"]
		info.notCheckable	= 1
		info.func = me.AddCombatantToGraph
		info.arg1 = me
		info.arg2 = this.name
		UIDropDownMenu_AddButton(info, level)

		local Settings=ReRecount.MainWindow.RealtimeSettings
		if Settings then
			info.text		= L["Show Realtime Graph (Ctrl Click)"]
			info.notCheckable	= 1
			info.func = me.ShowRealtime
			info.arg1 = me
			info.arg2 = this.name
			UIDropDownMenu_AddButton(info, level)
		end

		info.text		= L["Delete Combatant (Ctrl-Alt Click)"]
		info.notCheckable	= 1
		info.func = me.DeleteCombatant
		info.arg1 = me
		info.arg2 = this.name
		UIDropDownMenu_AddButton(info, level)
	end
	end
end

function ReRecount:DeleteCombatant(name)

	if not ReRecount.db2.combatants[name] then return end

	if ReRecount.db2.combatants[name].Owner then
		local owner = ReRecount.db2.combatants[name].Owner
		if ReRecount.db2.combatants[owner] and ReRecount.db2.combatants[owner].Pet then
			for k,v in pairs(ReRecount.db2.combatants[owner].Pet) do
				if v == name then
					table.remove(ReRecount.db2.combatants[owner].Pet,k) -- Elsia: Remove deleted pet
				end
			end
		end
	end
	
	if ReRecount.db2.combatants[name].Pet then
		for k,v in pairs(ReRecount.db2.combatants[name].Pet) do
			me:DeleteCombatant(v) -- Elsia: Delete all pets with owner
		end
	end
	
	ReRecount:DeleteGuardianOwnerByGUID(ReRecount.db2.combatants[name])
	
	ReRecount.db2.combatants[name]=nil
	
	ReRecount.NewData = true
end

function me:DeleteCombatant(name) -- Elsia: Add delete combatant feature
	ReRecount:DeleteCombatant(name)

	ReRecount:SetMainWindowMode(ReRecount.db.profile.MainWindowMode)
	ReRecount:FullRefreshMainWindow()
end

function ReRecount:FullRefreshMainWindow()
	ReRecount:FreeTableRecurseLimit(ReRecount.MainWindow.DispTableSorted,1)
	ReRecount:FreeTable(ReRecount.MainWindow.DispTableLookup)
	ReRecount.MainWindow.DispTableSorted=ReRecount:GetTable()
	ReRecount.MainWindow.DispTableLookup=ReRecount:GetTable()
end

function me:FixRow(i)
	local row=ReRecount.MainWindow.Rows[i]
	local MaxNameWidth=row:GetWidth()-row.RightText:GetStringWidth()-4
	
	if MaxNameWidth<16 then
		MaxNameWidth=16
	end

	local LText=row.LeftText:GetText()
	
	while row.LeftText:GetStringWidth()>MaxNameWidth do
		LText=strsub(LText,1,#LText-1)
		row.LeftText:SetText(LText.."...")
	end
end

function ReRecount:BarsChanged()
	local offs = 0
	if not ReRecount.db.profile.MainWindow.HideTotalBar then
		offs = 1
	end

	for k, v in pairs(ReRecount.MainWindow.Rows) do
		v:SetHeight(ReRecount.db.profile.MainWindow.RowHeight)
		v:SetPoint("TOPLEFT",ReRecount.MainWindow,"TOPLEFT",2,-32-(ReRecount.db.profile.MainWindow.RowHeight+ReRecount.db.profile.MainWindow.RowSpacing)*(k-1+offs))
		me:SetFontSize(v.LeftText,math.max(ReRecount.db.profile.MainWindow.RowHeight*0.75,ReRecount.db.profile.MainWindow.RowHeight-3))
		me:SetFontSize(v.RightText,math.max(ReRecount.db.profile.MainWindow.RowHeight*0.75,ReRecount.db.profile.MainWindow.RowHeight-3))
	end
	ReRecount:ResizeMainWindow()
end


function ReRecount:UpdateBarTextures()
	for _, v in pairs(ReRecount.MainWindow.Rows) do
		v.StatusBar:SetStatusBarTexture(SM:Fetch(SM.MediaType.STATUSBAR, ReRecount.db.profile.BarTexture))
	end

	if ReRecount.db.profile.Font then
		ReRecount:SetFont(ReRecount.db.profile.Font)
	end
end

function ReRecount:SetBarTextures(handle)
	local Texture=SM:Fetch(SM.MediaType.STATUSBAR,handle) -- "statusbar"
	ReRecount.db.profile.BarTexture=handle
	for _, v in pairs(ReRecount.MainWindow.Rows) do
		v.StatusBar:SetStatusBarTexture(Texture)
	end
end

function me:SetBar(num,left,right,value,colorgroup, colorclass ,clickData,clickFunc,tooltipData)
	local rowmin = 1

	if not ReRecount.db.profile.MainWindow.HideTotalBar then
		rowmin = 0
	end
	
	if num<rowmin or not ReRecount.MainWindow.Rows[num] then
		return
	end
	
	local Row=ReRecount.MainWindow.Rows[num]
	Row:Show()
	Row.StatusBar:SetValue(value)
	Row.LeftText:SetText(left)
	Row.RightText:SetText(right)
	Row.Name=left
	Row.TooltipData=tooltipData
	Row.clickData=clickData
	Row.clickFunc=clickFunc

	if colorgroup and colorclass and type(colorclass)=="string" then
		ReRecount.Colors:UnregisterItem(Row.StatusBar)
		ReRecount.Colors:RegisterTexture(colorgroup,ReRecount:FixUnitString(colorclass),Row.StatusBar)
		--Row.StatusBar:SetStatusBarColor(color.r,color.g,color.b,1)
	end
	
	Row.LeftText:SetTextColor(ReRecount.db.profile.Colors.Bar["Bar Text"].r,ReRecount.db.profile.Colors.Bar["Bar Text"].g,ReRecount.db.profile.Colors.Bar["Bar Text"].b,1);
	Row.RightText:SetTextColor(ReRecount.db.profile.Colors.Bar["Bar Text"].r,ReRecount.db.profile.Colors.Bar["Bar Text"].g,ReRecount.db.profile.Colors.Bar["Bar Text"].b,1);
end

--[[function me:SetBarColors(r,g,b)
	
	self:SetStatusBarColor(r,g,b,1)
end]]

function ReRecount:ResizeMainWindow()
	--How many bars do we have now?
	local Bars=math.floor((ReRecount.MainWindow:GetHeight()-32.95)/(ReRecount.db.profile.MainWindow.RowHeight+ReRecount.db.profile.MainWindow.RowSpacing))
	
	local minbar
	
	if not ReRecount.db.profile.MainWindow.HideTotalBar then
		minbar = 0
		Bars = Bars - 1
	else
		minbar = 1
		if ReRecount.MainWindow.Rows[0] then ReRecount.MainWindow.Rows[0]:Hide() end
	end


	if not ReRecount.db.profile.MainWindow.HideTotalBar and not ReRecount.MainWindow.Rows[0] then -- Elsia: Create Total Bar
		me:CreateRow(0)
	end
	
	if Bars<ReRecount.MainWindow.CurRows then
		for i=Bars+1,ReRecount.MainWindow.CurRows do
			ReRecount.MainWindow.Rows[i]:Hide()
		end
	elseif Bars>ReRecount.MainWindow.RowsCreated then
		for i=ReRecount.MainWindow.RowsCreated+1,Bars do
			me:CreateRow(i)
		end
	end
	
	--Update all the bar widths
	local CurWidth=ReRecount.MainWindow:GetWidth()-4
	for i=minbar,Bars do
		ReRecount.MainWindow.Rows[i]:Show()
		ReRecount.MainWindow.Rows[i]:SetWidth(CurWidth)
	end

	ReRecount.MainWindow.CurRows=Bars

	ReRecount.MainWindow.ScrollBar:SetPoint("TOPLEFT", ReRecount.MainWindow.Rows[1], "TOPLEFT", -4, 0)
	ReRecount.MainWindow.ScrollBar:SetPoint("BOTTOMRIGHT", ReRecount.MainWindow.Rows[Bars], "BOTTOMRIGHT", -4, 0)

	ReRecount:RefreshMainWindow()
end

function ReRecount:CreateMainWindow()
	ReRecount.MainWindow=ReRecount:CreateFrame("ReRecount_MainWindow",L["Main"],140,200, function() ReRecount.MainWindow.timeid=ReRecount:ScheduleRepeatingTimer("RefreshMainWindow",1,true);ReRecount.db.profile.MainWindowVis=true end, function() if ReRecount.MainWindow.timeid then ReRecount:CancelTimer(ReRecount.MainWindow.timeid); ReRecount.MainWindow.timeid=nil end ;ReRecount.db.profile.MainWindowVis=false end)

	local theFrame=ReRecount.MainWindow

	theFrame:SetResizable(true)
	theFrame:SetMinResize(140,63)
	theFrame:SetMaxResize(400,520)		

	theFrame.SaveMainWindowPosition = ReRecount.SaveMainWindowPosition
	
	theFrame:SetScript("OnSizeChanged", function()
						if ( this.isResizing ) then
							ReRecount:ResizeMainWindow()
							
							ReRecount.db.profile.MainWindowHeight=this:GetHeight()
							ReRecount.db.profile.MainWindowWidth=this:GetWidth()
						end
					end)

	theFrame.TitleClick=CreateFrame("FRAME",nil,theFrame)
	theFrame.TitleClick:SetAllPoints(theFrame.Title)
	theFrame.TitleClick:EnableMouse(true)
	theFrame.TitleClick:SetScript("OnMouseDown",function() 
							if arg1=="RightButton" then
								ReRecount:ModeDropDownOpen(this)
								ToggleDropDownMenu(1, nil, ReRecount_ModeDropDownMenu)
							end

							local parent=this:GetParent()
							if ( ( ( not parent.isLocked ) or ( parent.isLocked == 0 ) ) and ( arg1 == "LeftButton" ) ) then
							  ReRecount:SetWindowTop(parent)
							  parent:StartMoving();
							  parent.isMoving = true;
							 end
							end)
	theFrame.TitleClick:SetScript("OnMouseUp", function() 
						local parent=this:GetParent()
						if ( parent.isMoving ) then
						  parent:StopMovingOrSizing();
						  parent.isMoving = false;
						  parent:SaveMainWindowPosition()
						 end
						end)


	theFrame.ScrollBar=CreateFrame("SCROLLFRAME","ReRecount_MainWindow_ScrollBar",theFrame,"FauxScrollFrameTemplate")
	theFrame.ScrollBar:SetScript("OnVerticalScroll", function() FauxScrollFrame_OnVerticalScroll(20, ReRecount.RefreshMainWindow) end)
	ReRecount:SetupScrollbar("ReRecount_MainWindow_ScrollBar")

	if not ReRecount.db.profile.MainWindow.ShowScrollbar then
		ReRecount:HideScrollbarElements("ReRecount_MainWindow_ScrollBar")
	end

	theFrame.DragBottomRight = CreateFrame("Button", "ReRecountResizeGripRight", theFrame) -- Grip Buttons from Omen2
	theFrame.DragBottomRight:Show()
	theFrame.DragBottomRight:SetFrameLevel( theFrame:GetFrameLevel() + 10)
	theFrame.DragBottomRight:SetNormalTexture("Interface\\AddOns\\ReRecount\\ResizeGripRight")
	theFrame.DragBottomRight:SetHighlightTexture("Interface\\AddOns\\ReRecount\\ResizeGripRight")
	theFrame.DragBottomRight:SetWidth(16)
	theFrame.DragBottomRight:SetHeight(16)
	theFrame.DragBottomRight:SetPoint("BOTTOMRIGHT", theFrame, "BOTTOMRIGHT", 0, 0)
	theFrame.DragBottomRight:EnableMouse(true)
	theFrame.DragBottomRight:SetScript("OnMouseDown", function() if ((( not this:GetParent().isLocked ) or ( this:GetParent().isLocked == 0 ) ) and ( arg1 == "LeftButton" ) ) then this:GetParent().isResizing = true; this:GetParent():StartSizing("BOTTOMRIGHT") end end ) -- Elsia: disallow resizing when locked.
	theFrame.DragBottomRight:SetScript("OnMouseUp", function() if this:GetParent().isResizing == true then this:GetParent():StopMovingOrSizing(); this:GetParent():SaveMainWindowPosition(); this:GetParent().isResizing = false; end end )

	theFrame.DragBottomLeft = CreateFrame("Button", "ReRecountResizeGripLeft", theFrame)
	theFrame.DragBottomLeft:Show()
	theFrame.DragBottomLeft:SetFrameLevel( theFrame:GetFrameLevel() + 10)
	theFrame.DragBottomLeft:SetNormalTexture("Interface\\AddOns\\ReRecount\\ResizeGripLeft")
	theFrame.DragBottomLeft:SetHighlightTexture("Interface\\AddOns\\ReRecount\\ResizeGripLeft")
	theFrame.DragBottomLeft:SetWidth(16)
	theFrame.DragBottomLeft:SetHeight(16)
	theFrame.DragBottomLeft:SetPoint("BOTTOMLEFT", theFrame, "BOTTOMLEFT", 0, 0)
	theFrame.DragBottomLeft:EnableMouse(true)
	theFrame.DragBottomLeft:SetScript("OnMouseDown", function() if ((( not this:GetParent().isLocked ) or ( this:GetParent().isLocked == 0 ) ) and ( arg1 == "LeftButton" ) ) then this:GetParent().isResizing = true; this:GetParent():StartSizing("BOTTOMLEFT") end end ) -- Elsia: disallow resizing when locked.
	theFrame.DragBottomLeft:SetScript("OnMouseUp", function() if this:GetParent().isResizing == true then this:GetParent():StopMovingOrSizing(); this:GetParent():SaveMainWindowPosition(); this:GetParent().isResizing = false; end end )

	--ReRecount:ShowGrips(not ReRecount.db.profile.Locked)
	
	theFrame.RightButton=CreateFrame("Button",nil,theFrame)
	theFrame.RightButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up.blp")
	theFrame.RightButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down.blp")	
	theFrame.RightButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	theFrame.RightButton:SetWidth(16)
	theFrame.RightButton:SetHeight(18)
	theFrame.RightButton:SetPoint("TOPRIGHT",theFrame,"TOPRIGHT",-38+16,-12)
	theFrame.RightButton:SetScript("OnClick",function() ReRecount:MainWindowNextMode() end)
	theFrame.RightButton:SetFrameLevel(theFrame.RightButton:GetFrameLevel()+1)

	theFrame.LeftButton=CreateFrame("Button",nil,theFrame)
	theFrame.LeftButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up.blp")
	theFrame.LeftButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down.blp")
	theFrame.LeftButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	theFrame.LeftButton:SetWidth(16)
	theFrame.LeftButton:SetHeight(18)
	theFrame.LeftButton:SetPoint("RIGHT",theFrame.RightButton,"LEFT",0,0)
	theFrame.LeftButton:SetScript("OnClick",function() ReRecount:MainWindowPrevMode() end)
	theFrame.LeftButton:SetFrameLevel(theFrame.LeftButton:GetFrameLevel()+1)

	theFrame.ResetButton=CreateFrame("Button",nil,theFrame)
	theFrame.ResetButton:SetNormalTexture("Interface\\Addons\\ReRecount\\Textures\\icon-reset")
	theFrame.ResetButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	theFrame.ResetButton:SetWidth(16)
	theFrame.ResetButton:SetHeight(16)
	theFrame.ResetButton:SetPoint("RIGHT",theFrame.LeftButton,"LEFT",0,0)
	theFrame.ResetButton:SetScript("OnClick",function() ReRecount:ShowReset() end)
	theFrame.ResetButton:SetFrameLevel(theFrame.ResetButton:GetFrameLevel()+1)

	theFrame.FileButton=CreateFrame("Button",nil,theFrame)
	theFrame.FileButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up.blp")
	theFrame.FileButton:SetPushedTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Down.blp")	
	theFrame.FileButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	theFrame.FileButton:SetWidth(16)
	theFrame.FileButton:SetHeight(16)
	theFrame.FileButton:SetPoint("RIGHT",theFrame.ResetButton,"LEFT",0,0)
	theFrame.FileButton:SetScript("OnClick",function() 
						ReRecount:FightDropDownOpen(this)
						ToggleDropDownMenu(1, nil, ReRecount_FightDropDownMenu) 
						end)
	theFrame.FileButton:SetFrameLevel(theFrame.FileButton:GetFrameLevel()+1)

	theFrame.ConfigButton=CreateFrame("Button",nil,theFrame)
	theFrame.ConfigButton:SetNormalTexture("Interface\\Addons\\ReRecount\\Textures\\icon-config")
	theFrame.ConfigButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	theFrame.ConfigButton:SetWidth(16)
	theFrame.ConfigButton:SetHeight(16)
	theFrame.ConfigButton:SetPoint("RIGHT",theFrame.FileButton,"LEFT",0,0)
	theFrame.ConfigButton:SetScript("OnClick",function() ReRecount:ShowConfig() end)
	theFrame.ConfigButton:SetFrameLevel(theFrame.ConfigButton:GetFrameLevel()+1)

	theFrame.ReportButton=CreateFrame("Button",nil,theFrame)
	theFrame.ReportButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up.blp")
	theFrame.ReportButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	theFrame.ReportButton:SetWidth(16)
	theFrame.ReportButton:SetHeight(16)
	theFrame.ReportButton:SetPoint("RIGHT",theFrame.ConfigButton,"LEFT",0,0)
	theFrame.ReportButton:SetScript("OnClick",function() ReRecount:ShowReport("Main",ReRecount.ReportData) end)
	theFrame.ReportButton:SetFrameLevel(theFrame.ReportButton:GetFrameLevel()+1)

	ReRecount.MainWindow.Rows={}
	ReRecount.MainWindow.CurRows=0
	ReRecount.MainWindow.RowsCreated=0
	
	ReRecount.MainWindow.DispTableSorted={}
	ReRecount.MainWindow.DispTableLookup={}

	theFrame.SavePosition=ReRecount.SaveMainWindowPosition
	ReRecount:RestoreMainWindowPosition(ReRecount.db.profile.MainWindow.Position.x,ReRecount.db.profile.MainWindow.Position.y,ReRecount.db.profile.MainWindow.Position.w,ReRecount.db.profile.MainWindow.Position.h)
	--ReRecount:ResizeMainWindow()
	ReRecount:SetupMainWindowButtons()
	ReRecount:ScheduleRepeatingTimer("RefreshMainWindow",1,true)

	if not ReRecount.db.profile.MainWindowVis then
		theFrame:Hide()
	end
end

function ReRecount:SetupMainWindowButtons()
	for k, v in pairs(ReRecount.db.profile.MainWindow.Buttons) do
		if v then
			ReRecount.MainWindow[k]:Show()
			ReRecount.MainWindow[k]:SetWidth(16)
		else
			--Have to use width of 1 since 0 is invalid but you can't tell the diff really
			ReRecount.MainWindow[k]:SetWidth(1)
			ReRecount.MainWindow[k]:Hide()
			
		end
	end
end


--Actual Data Functions
local function sortFunc(a, b)
	if a[2]>b[2] then
		return true
	elseif a[2]==b[2] then
		if a[1]<b[1] then
			return true
		end
	end
	return false
end

function ReRecount:LoadMainWindowData(DataTable)
	ReRecount.MainWindowData=DataTable
	ReRecount:SetMainWindowMode(ReRecount.db.profile.MainWindowMode or 1)
end

local ConvertName={
	OverallData="(Overall)",
	CurrentFightData="(Current)",
	LastFightData="(Last)",
}


function ReRecount:SetMainWindowMode(mode)
	if not mode or mode > #ReRecount.MainWindowData then
		mode = 1
	end

	ReRecount.db.profile.MainWindowMode=mode
	ReRecount.DetailMode=1
	local data=ReRecount.MainWindowData[mode]
	ReRecount.MainWindow.Title:SetText(data[1])
	ReRecount.MainWindow.GetData=data[2]
	ReRecount.MainWindow.TooltipFunc=data[3]
	ReRecount.MainWindow.SpecialTotal=data[4]
	ReRecount.MainWindow.RealtimeSettings=data[5]
	ReRecount:FreeTableRecurseLimit(ReRecount.MainWindow.DispTableSorted,1)
	ReRecount:FreeTable(ReRecount.MainWindow.DispTableLookup)
	ReRecount.MainWindow.DispTableSorted=ReRecount:GetTable()
	ReRecount.MainWindow.DispTableLookup=ReRecount:GetTable()
	ReRecount:RefreshMainWindow()
end

function me:UpdateDetailData()
	if ReRecount.DetailWindow:IsVisible() and ReRecount.MainWindow.Selected then
		local _, Data=ReRecount.MainWindow:GetData(ReRecount.db2.combatants[ReRecount.MainWindow.Selected])
		local mode=ReRecount.DetailMode

		if type(Data)=="table" then
			if type(Data[mode][2])~="function" then
				ReRecount:SetupDetailTitles(ReRecount.MainWindow.Selected,Data[mode][2],Data[mode][3])
				ReRecount:FillUpperDetailTable(Data[mode][1])
			else
				Data[mode][2](ReRecount,ReRecount.MainWindow.Selected,Data[mode][1])
			end
		end
	end
end

function ReRecount:MainWindowNextMode()
	local mode=ReRecount.db.profile.MainWindowMode+1
	if mode>table.maxn(ReRecount.MainWindowData) then
		mode=1
	end
	ReRecount:SetMainWindowMode(mode)

	me:UpdateDetailData()
end

function ReRecount:MainWindowPrevMode()
	local mode=ReRecount.db.profile.MainWindowMode-1
	if mode==0 then
		mode=table.maxn(ReRecount.MainWindowData)
	end
	ReRecount:SetMainWindowMode(mode)

	me:UpdateDetailData()
end

function ReRecount:DetailWindowNextMode()
	local _, Data=ReRecount.MainWindow:GetData(ReRecount.db2.combatants[ReRecount.MainWindow.Selected])
	
	local mode=ReRecount.DetailMode+1
	if not Data or type(Data)~="table" or mode>table.maxn(Data) then
		mode=1
	end
	ReRecount.DetailMode=mode
	ReRecount.DetailWindow.Locked=false

	me:MainWindowSelectPlayer(ReRecount.MainWindow.Selected)
end

function ReRecount:DetailWindowPrevMode()
	local _, Data=ReRecount.MainWindow:GetData(ReRecount.db2.combatants[ReRecount.MainWindow.Selected])
	local mode=ReRecount.DetailMode-1
	if mode==0 then
		mode=Data and type(Data)=="table" and table.maxn(Data) or 1
	end
	ReRecount.DetailMode=mode
	ReRecount.DetailWindow.Locked=false
	
	me:MainWindowSelectPlayer(ReRecount.MainWindow.Selected)
end

function me:MainWindowSelectPlayer(name)
	if IsShiftKeyDown() then
		me:ShowGraphWindow(name)
		return
	end
	
	if IsControlKeyDown() and IsAltKeyDown() then -- Elsia: Add delete combatant feature
		me:DeleteCombatant(name)
		return
	end
	
	local Settings=ReRecount.MainWindow.RealtimeSettings
	if IsControlKeyDown() and Settings then
		ReRecount:CreateRealtimeWindow(name,Settings[1],Settings[2])
		return
	end

	if IsAltKeyDown() then
		me:AddCombatantToGraph(name)
		return
	end

	me:ShowDetail(name)
end

function me:ShowGraphWindow(name)
	ReRecount:SetGraphData(name,ReRecount.db2.combatants[name].TimeData,ReRecount.db2.CombatTimes)
	ReRecount.GraphCompare=false
end

function me:ShowRealtime(name)
	local Settings=ReRecount.MainWindow.RealtimeSettings
	if Settings then
		ReRecount:CreateRealtimeWindow(name,Settings[1],Settings[2])
	end
end

function me:ShowDetail(name)
	local _, Data=ReRecount.MainWindow:GetData(ReRecount.db2.combatants[name])
	
	if type(Data)=="table" then
		ReRecount.MainWindow.Selected=name
		local mode=ReRecount.DetailMode

		if type(Data[mode][2])~="function" then
			ReRecount:SetupDetailTitles(name,Data[mode][2],Data[mode][3])
			ReRecount:FillUpperDetailTable(Data[mode][1])
			ReRecount:SelectUpperDetailTable(1)
		else
			Data[mode][2](ReRecount,name,Data[mode][1])
			Data[mode][3](ReRecount,1)
		end

		ReRecount:UpdateSummaryMode(name)
		ReRecount:SetWindowTop(ReRecount.DetailWindow)
	end
end

function ReRecount:CheckShowPet(mob)
	if mob.type == "Pet" then
		return ReRecount.db.profile.Filters.Show[DetermineType(mob.Owner)]
	else
		return true
	end
end

local MaxValue = 0

function ReRecount:RefreshMainWindow(datarefresh)
	local MainWindow = ReRecount.MainWindow
	if not MainWindow.GetData or not MainWindow:IsShown() then
		return
	end
	
	-- For periodic data refreshes, only refresh if we actually got new stored data.
	if datarefresh and not ReRecount.NewData then
		return
	else
		ReRecount.NewData = nil
	end
	
	local data=ReRecount.db2.combatants
	local i
	local dispTable=MainWindow.DispTableSorted
	local lookup=MainWindow.DispTableLookup
	local Total=0
	local TotalPerSec=0
	local Value,PerSec

	if type(ReRecount.MainWindowData[ReRecount.db.profile.MainWindowMode][6])=="function" then
		MainWindow.Title:SetText(ReRecount.MainWindowData[ReRecount.db.profile.MainWindowMode][6]())
	end

	for k,v in pairs(lookup) do
		if v[4].Fights[ReRecount.db.profile.CurDataSet] then
			Value=MainWindow:GetData(v[4],1)
		else
			Value=0
		end
		if Value<=0 then
			lookup[k]=nil
					
			for k2,v2 in pairs(dispTable) do
				if v2[1]==v[4] then
					table.remove(dispTable,k2)
					break
				end
			end
		end

	end

	local noUpdates = true
	local FiltersShow = ReRecount.db.profile.Filters.Show
	local Combatants = ReRecount.db2.combatants
	local ClassColors = ReRecount.db.profile.Colors.Class

	if data and type(data)=="table" then
		for k,v in pairs(data) do
			--[[if not v then ReRecount:Print("Unit: "..k.." has nil data, please report")
			elseif not v.type then
				ReRecount:Print("Unit: "..k.." has nil type: "..(v.LastFlags or "nil").." "..(v.enClass or "nil"))
				--ReRecount:Print(name.." "..ReRecount.db2.combatants[name].type.." "..ReRecount.db2.combatants[name].enClass)
			elseif v.type == "Pet" and not v.Owner then  ReRecount:Print("Unit: "..k.." has nil owner, please report")
			end]]
			if v and v.type and FiltersShow[v.type] and not (v.type == "Pet" and v.Owner and Combatants[v.Owner] and not FiltersShow[Combatants[v.Owner].type]) then -- Elsia: Added owner inheritance filtering for pets
				if v.Fights and v.Fights[ReRecount.db.profile.CurDataSet] then
					Value,PerSec=MainWindow:GetData(v,1)
					
					if Value>0 then
						if v.type ~= "Pet" or not ReRecount.db.profile.MergePets then -- Elsia: Only add to total if not merging pets.
							Total=Total+Value
							if type(PerSec)=="number" then
								TotalPerSec=TotalPerSec + PerSec
							end
						end
						
						if type(lookup[k])=="table" then
							if Value~=lookup[k][2] then
								lookup[k][1]=k
								lookup[k][2]=Value
								lookup[k][3]=v.enClass -- ClassColors[v.enClass]
								lookup[k][4]=v
								lookup[k][5]=PerSec
								noUpdates = false
							end
						else
							lookup[k]={k,Value,v.enClass,v,PerSec} -- ReRecount.Colors:GetColor("Class",v.enClass)
							tinsert(dispTable,lookup[k])
							noUpdates = false
						end
					elseif type(lookup[k])=="table" then
						lookup[k] = nil
						
						for k2,v2 in ipairs(dispTable) do
							if v2[1]==k then
								tremove(dispTable,k2)
								break
							end
						end
					end
				end
			end
		end
	end

	local MainWindow_Settings = ReRecount.db.profile.MainWindow
	
	if noUpdates==false and table.maxn(dispTable)>0 then
		table.sort(dispTable,sortFunc)
		MaxValue=dispTable[1][2]
	end

	local RowWidth=MainWindow:GetWidth()-4
	if table.getn(dispTable)>MainWindow.CurRows and MainWindow_Settings.ShowScrollbar == true then
		RowWidth=MainWindow:GetWidth()-23
	end
	
		FauxScrollFrame_Update(MainWindow.ScrollBar, table.getn(dispTable), ReRecount.MainWindow.CurRows, 20)
	local offset = FauxScrollFrame_GetOffset(MainWindow.ScrollBar)

	if type(MainWindow.SpecialTotal)=="function" then
		Total=MainWindow:SpecialTotal()
	end

	local rows = MainWindow.Rows
	
	local MainWindow_BarText_RankNum = MainWindow_Settings.BarText.RankNum
	local MainWindow_BarText_PerSec = MainWindow_Settings.BarText.PerSec
	local MainWindow_BarText_Percent = MainWindow_Settings.BarText.Percent

	if not MainWindow_Settings.HideTotalBar and MainWindow.CurRows > 0 and Total > 0 then
		if TotalPerSec > 0 then
			PerSec=string_format("%.1f", TotalPerSec)
		else
			PerSec=""
		end
		
		if not rows[0] then
			me:CreateRow(0)
		end
		
		local lefttext = MainWindow_BarText_RankNum and "0. "..L["Total"] or L["Total"]
		local righttext = ReRecount:FormatLongNums(Total) --string_format("%.0f",Total)
		if MainWindow_BarText_PerSec and PerSec ~= "" then
			righttext = string_format("%s (%s", righttext, PerSec)
			if MainWindow_BarText_Percent then
				righttext = string_format("%s, %.1f%%)", righttext, 100.0)
			else
				righttext = righttext .. ")"
			end
		elseif MainWindow_BarText_Percent then
			righttext = string_format("%s (%.1f%%)", righttext, 100.0)
		end
			
		me:SetBar(0,lefttext,righttext,100,"Bar","Total Bar",L["Total"],nil,nil)	-- ReRecount.db.profile.Colors.Bar["Total Bar"]
		me:FixRow(0)
		rows[0].name="Total"
		rows[0]:SetWidth(RowWidth)
		--offset = offset+1 -- Add a row
	else
		if rows[0] then rows[0]:Hide() end
	end
	
	for i=1, MainWindow.CurRows do
		local v=dispTable[i+offset]
		
		if v then
			local percent=100*v[2]/Total
			if v[5] then
				if type(v[5])=="number" then
					PerSec=string_format("%.1f",v[5])
				else
					PerSec=v[5]
				end
			else
				PerSec=""
			end
			local lefttext = MainWindow_BarText_RankNum and i+offset..". "..v[1] or v[1]
			local righttext = ReRecount:FormatLongNums(v[2]) --string_format("%.0f",v[2])
			if MainWindow_BarText_PerSec and PerSec~="" then
				righttext =  string_format("%s (%s", righttext, PerSec)
				if MainWindow_BarText_Percent then
					righttext = string_format("%s, %.1f%%)", righttext, percent)
				else
					righttext = righttext .. ")"
				end
			elseif MainWindow_BarText_Percent then
				righttext = string_format("%s (%.1f%%)", righttext, percent)
			end
			
			me:SetBar(i,lefttext,righttext,100*v[2]/MaxValue,"Class",v[3],v[1],me.MainWindowSelectPlayer,v[4])
			me:FixRow(i)
			rows[i].name=v[1]
		else
			rows[i]:Hide()
		end

		rows[i]:SetWidth(RowWidth)
	end

	me:UpdateDetailData()
end

local ConvertDataSet2={}
ConvertDataSet2["OverallData"]="a_overall"
ConvertDataSet2["CurrentFightData"]="b_current"
ConvertDataSet2["LastFightData"]="c_last"

function ReRecount:FightDropDownOpen(myframe)
	ReRecount_FightDropDownMenu = CreateFrame("Frame", "ReRecount_FightDropDownMenu", myframe);
	ReRecount_FightDropDownMenu.displayMode = "MENU";
	ReRecount_FightDropDownMenu.initialize	= me.CreateFightDropdown;
	local leftPos = myframe:GetLeft() -- Elsia: Side code adapted from Mirror
	local rightPos = myframe:GetRight()
	local side
	local oside
	if not rightPos then
		rightPos = 0
	end
	if not leftPos then
		leftPos = 0
	end

	local rightDist = GetScreenWidth() - rightPos

	if leftPos and rightDist < leftPos then
		side = "TOPLEFT"
		oside = "TOPRIGHT"
	else
		side = "TOPRIGHT"
		oside = "TOPLEFT"
	end

	if tocversion == 30000 then
		UIDropDownMenu_SetAnchor(ReRecount_FightDropDownMenu , 0, 0, oside, myframe, side)
	else
		UIDropDownMenu_SetAnchor(0, 0, ReRecount_FightDropDownMenu , oside, myframe, side)
	end
end



--Should add saved datasets here
function me:CreateFightDropdown(level)
		local info = {}

		info.checked = nil
		info.text		= L["Overall Data"]
		if ReRecount.db.profile.CurDataSet == "OverallData" then
			info.checked = 1
		end
		info.func = function() ReRecount.db.profile.CurDataSet="OverallData";me:UpdateDetailData();ReRecount.MainWindow.DispTableSorted={};ReRecount.MainWindow.DispTableLookup={};ReRecount.FightName="Overall Data";ReRecount:RefreshMainWindow() end
		UIDropDownMenu_AddButton(info, level)

		info.checked = nil
		
		info.text = L["Current Fight"]
		if ReRecount.db.profile.CurDataSet == "CurrentFightData" or ReRecount.db.profile.CurDataSet == "LastFightData" then
			info.checked = 1
		end
		info.func = function() if ReRecount.InCombat then ReRecount.db.profile.CurDataSet="CurrentFightData" else ReRecount.db.profile.CurDataSet="LastFightData" end;me:UpdateDetailData();ReRecount.MainWindow.DispTableSorted={};ReRecount.MainWindow.DispTableLookup={}; ReRecount.FightName="Current Fight";ReRecount:RefreshMainWindow() end
		UIDropDownMenu_AddButton(info, level)

		for k, v in pairs(ReRecount.db2.FoughtWho) do
			info.checked = nil
			info.text = L["Fight"].." "..k.." - "..v
			if ReRecount.db.profile.CurDataSet == "Fight"..k then
				info.checked = 1
			end
			info.func = function() ReRecount.db.profile.CurDataSet="Fight"..k;me:UpdateDetailData();ReRecount.MainWindow.DispTableSorted={};ReRecount.MainWindow.DispTableLookup={};ReRecount.FightName=v;ReRecount:RefreshMainWindow() end
			UIDropDownMenu_AddButton(info, level)
		end
end

function ReRecount:ModeDropDownOpen(myframe)
	ReRecount_ModeDropDownMenu = CreateFrame("Frame", "ReRecount_ModeDropDownMenu", myframe);
	ReRecount_ModeDropDownMenu.displayMode = "MENU";
	ReRecount_ModeDropDownMenu.initialize	= me.CreateModeDropdown;
	local leftPos = myframe:GetLeft() -- Elsia: Side code adapted from Mirror
	local rightPos = myframe:GetRight()
	local side
	local oside
	if not rightPos then
		rightPos = 0
	end
	if not leftPos then
		leftPos = 0
	end

	local rightDist = GetScreenWidth() - rightPos

	if leftPos and rightDist < leftPos then
		side = "TOPLEFT"
		oside = "TOPRIGHT"
	else
		side = "TOPRIGHT"
		oside = "TOPLEFT"
	end
	if tocversion == 30000 then
		UIDropDownMenu_SetAnchor(ReRecount_ModeDropDownMenu , 0, 0, oside, myframe, side)
	else
		UIDropDownMenu_SetAnchor(0, 0, ReRecount_ModeDropDownMenu , oside, myframe, side)
	end
end

function me:CreateModeDropdown(level)
	local info = {}
	for k,v in pairs(ReRecount.MainWindowData) do

		info.checked = nil
		info.text = v[1]
		info.func = function() ReRecount:SetMainWindowMode(k) end
		if ReRecount.db.profile.MainWindowMode==k then
			info.checked = 1
		else
			info.checked = nil
		end
		UIDropDownMenu_AddButton(info, level)
	end
end

local ConvertDataSet={}
ConvertDataSet["OverallData"] = L["Overall Data"]
ConvertDataSet["CurrentFightData"]= L["Current Fight"]
ConvertDataSet["LastFightData"] = L["Last Fight"]

function ReRecount:ReportData(amount,loc,loc2)
	local dataMode=ReRecount.MainWindowData[ReRecount.db.profile.MainWindowMode]
	local data=ReRecount.db2.combatants
	local i
	local maxValue = 0
	local reportTable=ReRecount.MainWindow.DispTableSorted
	local lookup=ReRecount.MainWindow.DispTableLookup
	local Total=0
	local TotalPerSec=0
	local Value,PerSec

	local MainWindow_Settings = ReRecount.db.profile.MainWindow

	if type(data)=="table" then
		for k,v in pairs(data) do
			if v and v.type and ReRecount.db.profile.Filters.Show[v.type]  and not (v.type == "Pet" and v.Owner and not ReRecount.db.profile.Filters.Show[ReRecount.db2.combatants[v.Owner].type])  then -- Elsia: Added owner inheritance filtering for pets
				if v.Fights[ReRecount.db.profile.CurDataSet] then
					Value,PerSec=dataMode[2](this,v,1)
					if Value>0 then
						if (v.type ~= "Pet" or not ReRecount.db.profile.MergePets) then -- Elsia: Only add to total if not merging pets.
							Total=Total+Value
							if type(PerSec)=="number" then
								TotalPerSec=TotalPerSec + PerSec
							end
					end

						if type(lookup[k])=="table" then
							lookup[k][1]=k
							lookup[k][2]=Value
							lookup[k][5]=PerSec
						else
							lookup[k]={k,Value,ReRecount.Colors:GetColor("Class",v.enClass),v,PerSec}
							table.insert(reportTable,lookup[k])
						end
					end
				end
			end
		end
	end
	
	if table.maxn(reportTable)>0 then
		table.sort(reportTable,sortFunc)
		maxValue=reportTable[1][2] or 0
	end

	if type(dataMode[4])=="function" then
		Total=ReRecount.MainWindow:SpecialTotal()
	end
	
	if type(dataMode[6])=="function" then
		SendChatMessage("ReRecount - "..dataMode[6](),loc,nil,loc2)
	else
		if ConvertDataSet[ReRecount.db.profile.CurDataSet] then
			SendChatMessage("ReRecount - "..dataMode[1]..L[" for "]..ConvertDataSet[ReRecount.db.profile.CurDataSet],loc,nil,loc2)
		elseif ReRecount.FightName then -- Elsia: Cover nil error here.
			SendChatMessage("ReRecount - "..dataMode[1]..L[" for "]..ReRecount.FightName,loc,nil,loc2)		
		end
	end

	if not MainWindow_Settings.HideTotalBar and Total > 0 then
		if TotalPerSec > 0 then
			PerSec=string_format("%.1f ", TotalPerSec)
		else
			PerSec=""
		end
		
		SendChatMessage("0. Total  "..(math.floor(10*Total)/10).." ("..PerSec..(math.floor(1000)/10).."%)",loc,nil,loc2)
	end

	for i=1,amount do
		if reportTable[i] and reportTable[i][2]>0 then
			if reportTable[i][5] then
				if type(reportTable[i][5])=="number" then
					PerSec=string.format("%.1f, ",reportTable[i][5])
				else
					PerSec=reportTable[i][5]
				end
			else
				PerSec=""
			end
			SendChatMessage(i..". "..reportTable[i][1].."  "..(math.floor(10*reportTable[i][2])/10).." ("..PerSec..(math.floor(1000*reportTable[i][2]/Total)/10).."%)",loc,nil,loc2)
		end
	end
end


--Functions for graph data selecting
local GraphName={
	Damage="Damage",
	DamageTaken="Damage Taken",
	Healing="Healing",
	HealingTaken="Healing Taken",
	Overhealing="Overhealing",
}

function ReRecount:AddGraphNameEntry(k,v)
	GraphName.insert(k,v)
end

function me:AddCombatantToGraph(name)
	local DataComparing=ReRecount.MainWindowData[ReRecount.db.profile.MainWindowMode][7]
	if not DataComparing then
		return
	end

	local DataName=GraphName[DataComparing]

	

	if (not ReRecount.GraphCompare) or (not ReRecount.GraphWindow:IsShown()) or ReRecount.GraphCompareMode~=DataComparing then		
		ReRecount.GraphCompare=true
		ReRecount.GraphCompareMode=DataComparing

		if not ReRecount.GraphClass then
			ReRecount.GraphClass={}
		end

		for k, _ in pairs(ReRecount.GraphClass) do
			ReRecount.GraphClass[k]=nil
		end
		ReRecount.GraphClass[name.."'s "..DataName]=ReRecount.db2.combatants[name].enClass

		ReRecount:SetGraphData(DataName.." Comparison",{[name.."'s "..DataName]=ReRecount.db2.combatants[name].TimeData and ReRecount.db2.combatants[name].TimeData[DataComparing]},ReRecount.db2.CombatTimes)
		return
	end
	
	ReRecount.GraphWindow.Data[name.."'s "..DataName]=ReRecount.db2.combatants[name].TimeData and ReRecount.db2.combatants[name].TimeData[DataComparing]
	ReRecount.GraphClass[name.."'s "..DataName]=ReRecount.db2.combatants[name].enClass
	ReRecount:SetGraphData(DataName.." Comparison",ReRecount.GraphWindow.Data,ReRecount.db2.CombatTimes)	
end

function me:AddCombatantToGraphData(name)
	local DataComparing=ReRecount.MainWindowData[ReRecount.db.profile.MainWindowMode][7]
	if not DataComparing then
		return
	end

	local DataName=GraphName[DataComparing]

	

	if (not ReRecount.GraphCompare) or (not ReRecount.GraphWindow:IsShown()) or ReRecount.GraphCompareMode~=DataComparing then		
		ReRecount.GraphCompare=true
		ReRecount.GraphCompareMode=DataComparing

		if not ReRecount.GraphClass then
			ReRecount.GraphClass={}
		end

		for k, _ in pairs(ReRecount.GraphClass) do
			ReRecount.GraphClass[k]=nil
		end
		ReRecount.GraphClass[name.."'s "..DataName]=ReRecount.db2.combatants[name].enClass

		ReRecount.GraphWindow.Data={}
		ReRecount.GraphWindow.Data[name.."'s "..DataName]=ReRecount.db2.combatants[name].TimeData[DataComparing]
		return
	end
	
	if ReRecount.db2.combatants[name].TimeData then
		ReRecount.GraphWindow.Data[name.."'s "..DataName]=ReRecount.db2.combatants[name].TimeData[DataComparing]
		ReRecount.GraphClass[name.."'s "..DataName]=ReRecount.db2.combatants[name].enClass
	end
end

function ReRecount:AddAllToGraph()
	local DataComparing=ReRecount.MainWindowData[ReRecount.db.profile.MainWindowMode][7]
	if not DataComparing then
		return
	end
	local dispTable=ReRecount.MainWindow.DispTableSorted
	local DataName=GraphName[DataComparing]
	for _,v in pairs(dispTable) do
		me:AddCombatantToGraphData(v[1])
	end

	ReRecount:SetGraphData(DataName.." Comparison",ReRecount.GraphWindow.Data,ReRecount.db2.CombatTimes)
end

function ReRecount:SaveMainWindowPosition()
	local xOfs, yOfs = self:GetCenter()  -- Elsia: This is clean code straight from ckknight's pitbull
	local s = self:GetEffectiveScale()
	local uis = UIParent:GetScale()
	xOfs = xOfs*s - GetScreenWidth()*uis/2
	yOfs = yOfs*s - GetScreenHeight()*uis/2
	
	ReRecount.db.profile.MainWindow.Position.x=xOfs/uis
	ReRecount.db.profile.MainWindow.Position.y=yOfs/uis
	ReRecount.db.profile.MainWindow.Position.w=self:GetWidth()
	ReRecount.db.profile.MainWindow.Position.h=self:GetHeight()
end

function ReRecount:RestoreMainWindowPosition(x, y, width, height)
	local f = ReRecount.MainWindow
	local s = f:GetEffectiveScale() -- Elsia: Fixed position code, with inspiration from ckknight's handing in pitbull
	local uis = UIParent:GetScale()
	f:SetPoint("CENTER", UIParent, "CENTER", x*uis/s, y*uis/s)
	f:SetWidth(width)
	f:SetHeight(height)
	ReRecount:ResizeMainWindow()
	f:SavePosition()
end
