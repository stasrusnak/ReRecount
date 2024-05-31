local Graph = LibStub:GetLibrary("LibGraph-2.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale( "ReRecount" )
local me={}
local FreeWindows={}
local WindowNum=1

local revision = tonumber(string.sub("$Revision: 79898 $", 12, -3))
if ReRecount.Version < revision then ReRecount.Version = revision end

local _, _, _, tocversion =  GetBuildInfo()

function me:ResizeRealtimeWindow()
	self.Graph:SetWidth(self:GetWidth()-3)
	self.Graph:SetHeight(self:GetHeight()-33)
	self:UpdateTitle()
end

local Log2=math.log(2)


function me:DetermineGridSpacing()
	local MaxValue=self.Graph:GetMaxValue()
	local Spacing,Inbetween

	if MaxValue<25 then
		Spacing=-1
	else
		Spacing=math.log(MaxValue/100)/Log2
	end

	Inbetween=math.ceil(Spacing)-Spacing
	
	if Inbetween==0 then
		Inbetween=1
	end

	Spacing=25*math.pow(2,math.floor(Spacing))
	
	self.Graph:SetGridSpacing(1.0,Spacing)
	self.Graph:SetGridColorSecondary({0.5,0.5,0.5,0.5*Inbetween})
end

function ReRecount:UpdateTitle(theFrame)
	if theFrame:IsShown() then
		if theFrame.UpdateTitle then theFrame:UpdateTitle() else
			ReRecount:Print("Function UpdateTitle missing, please report stack!")
			ReRecount:Print(debugstack(2, 3, 2))
		end
	end
end

function me:UpdateTitle()
	self:DetermineGridSpacing()
	

	local Width,StartText, EndText
	Width=self:GetWidth()-32
	StartText=self.TitleText
	EndText=" - "..string.format("%.1f",self.Graph:GetValue(-0.05))

	self.Title:SetText(StartText..EndText)

	while self.Title:GetStringWidth()>Width do
		StartText=strsub(StartText,1,#StartText-1)
		self.Title:SetText(StartText.."..."..EndText)
	end
end

function me:SavePosition()
	local xOfs, yOfs = self:GetCenter()  -- Elsia: This is clean code straight from ckknight's pitbull
	local s = self:GetEffectiveScale()
	local uis = UIParent:GetScale()
	xOfs = xOfs*s - GetScreenWidth()*uis/2
	yOfs = yOfs*s - GetScreenHeight()*uis/2
	
	if self.id and ReRecount.db.profile.RealtimeWindows[self.id] ~= nil then -- Elsia: Fixed bug for free'd realtime windows
		ReRecount.db.profile.RealtimeWindows[self.id][4]=xOfs/uis
		ReRecount.db.profile.RealtimeWindows[self.id][5]=yOfs/uis
		ReRecount.db.profile.RealtimeWindows[self.id][6]=self:GetWidth()
		ReRecount.db.profile.RealtimeWindows[self.id][7]=self:GetHeight()
		ReRecount.db.profile.RealtimeWindows[self.id][8]=true
	end
end

function me:FreeWindow()
	ReRecount:UnregisterTracking(this.id,this.who,this.tracking)
	table.insert(FreeWindows,this)
	ReRecount:CancelTimer(this.idtoken)
	if not ReRecount.profilechange then
		ReRecount.db.profile.RealtimeWindows[this.id][8]=false -- Elsia: set closed state
	end
end

function me:RestoreWindow()
	ReRecount.db.profile.RealtimeWindows[this.id][8]=true -- Elsia: it's open again
	ReRecount:RegisterTracking(this.id,this.who,this.tracking,this.Graph.AddTimeData,this.Graph)
	for i,v in ipairs(FreeWindows) do
		if v == this then
			table.remove(FreeWindows,i)
		end
	end
	this.UpdateTitle=me.UpdateTitle
	this.idtoken=ReRecount:ScheduleRepeatingTimer("UpdateTitle",0.1,this)
end

function me:SetRealtimeColor()
	self.Graph:SetBarColors(ReRecount.Colors:GetColor("Realtime",self.TitleText.." Bottom"),ReRecount.Colors:GetColor("Realtime",self.TitleText.." Top"))
end

local WhichWindow
local Cur_Branch
local Cur_Name
local TempColor={}

local function Color_Change()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	
	TempColor.r=r
	TempColor.g=g
	TempColor.b=b
	if not ColorPickerFrame.hasOpacity then
		TempColor.a=nil
	else
		TempColor.a=OpacitySliderFrame:GetValue()
	end
	
	ReRecount.Colors:SetColor(Cur_Branch,Cur_Name,TempColor)
end

local function Opacity_Change()	
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local a=OpacitySliderFrame:GetValue()

	TempColor.r=r
	TempColor.g=g
	TempColor.b=b
	TempColor.a=a	

	ReRecount.Colors:SetColor(Cur_Branch,Cur_Name,TempColor)
end

local info = {}
local function ReRecount_CreateColorDropdown(level)
	if (not level) then return end
	for k in pairs(info) do info[k] = nil end
	if (level == 1) then
		-- Create the title of the menu
		local TopColor,BotColor

		TopColor=ReRecount.Colors:GetColor("Realtime",WhichWindow.TitleText.." Top")
		BotColor=ReRecount.Colors:GetColor("Realtime",WhichWindow.TitleText.." Bottom")

		
		
		info.isTitle		= 1
		info.hasColorSwatch = 1
		info.r = TopColor.r
		info.g = TopColor.g
		info.b = TopColor.b
		info.hasOpacity = 1
		info.opacity = TopColor.a
		info.text		= L["Top Color"].." "
		info.notCheckable	= 1
		info.swatchFunc = function() Cur_Branch = "Realtime"; Cur_Name = WhichWindow.TitleText.." Top"; Color_Change() end
		info.opacityFunc = function() Cur_Branch = "Realtime"; Cur_Name = WhichWindow.TitleText.." Top"; Opacity_Change() end
		UIDropDownMenu_AddButton(info, level)

		info.isTitle		= 1
		info.hasColorSwatch = 1
		info.r = BotColor.r
		info.g = BotColor.g
		info.b = BotColor.b
		info.hasOpacity = 1
		info.opacity = BotColor.a
		info.text		= L["Bottom Color"].." "
		info.notCheckable	= 1
		info.swatchFunc = function() Cur_Branch = "Realtime"; Cur_Name = WhichWindow.TitleText.." Bottom"; Color_Change() end
		info.opacityFunc = function() Cur_Branch = "Realtime"; Cur_Name = WhichWindow.TitleText.." Bottom"; Opacity_Change() end
		UIDropDownMenu_AddButton(info, level)
	end
end

function ReRecount:ColorDropDownOpen(myframe)
	ReRecount_ColorDropDownMenu = CreateFrame("Frame", "ReRecount_ColorDropDownMenu", myframe);
	ReRecount_ColorDropDownMenu.displayMode = "MENU";
	ReRecount_ColorDropDownMenu.initialize	= ReRecount_CreateColorDropdown;
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
		UIDropDownMenu_SetAnchor(0, 0, ReRecount_ColorDropDownMenu , oside, myframe, side)
	else
		UIDropDownMenu_SetAnchor(ReRecount_ColorDropDownMenu , 0, 0, oside, myframe, side)
	end
end

function me:CreateRealtimeWindow(who,tracking,ending) -- Elsia: This function creates a new window and stores it. To other ways, either override it's storage or use the other function
	local theFrame=ReRecount:CreateFrame(nil,"",232,200,me.RestoreWindow, me.FreeWindow)

	theFrame:SetResizable(true)

	theFrame:SetMinResize(150,64)
	theFrame:SetMaxResize(400,432)	

	theFrame:SetScript("OnSizeChanged", function()
						if ( this.isResizing ) then
							me.ResizeRealtimeWindow(this) -- Elsia: Changed self to this here to make it work!
							
						end
					end)

	if string.sub(who,1,1)~="!" then
		theFrame.TitleText=who..ending
	else
		theFrame.TitleText=ending
	end

	theFrame.Title:SetText(theFrame.TitleText.." - 0.0")

	theFrame.DragBottomRight = CreateFrame("Button", nil, theFrame)
	if not ReRecount.db.profile.Locked then
		theFrame.DragBottomRight:Show()
	else
		theFrame.DragBottomRight:Hide()
	end
	theFrame.DragBottomRight:SetFrameLevel( theFrame:GetFrameLevel() + 10)
	theFrame.DragBottomRight:SetNormalTexture("Interface\\AddOns\\ReRecount\\ResizeGripRight")
	theFrame.DragBottomRight:SetHighlightTexture("Interface\\AddOns\\ReRecount\\ResizeGripRight")
	theFrame.DragBottomRight:SetWidth(16)
	theFrame.DragBottomRight:SetHeight(16)
	theFrame.DragBottomRight:SetPoint("BOTTOMRIGHT", theFrame, "BOTTOMRIGHT", 0, 0)
	theFrame.DragBottomRight:EnableMouse(true)
	theFrame.DragBottomRight:SetScript("OnMouseDown", function() if ((( not this:GetParent().isLocked ) or ( this:GetParent().isLocked == 0 ) ) and ( arg1 == "LeftButton" ) ) then this:GetParent().isResizing = true; this:GetParent():StartSizing("BOTTOMRIGHT") end end ) -- Elsia: Disallow resizing when locked
	theFrame.DragBottomRight:SetScript("OnMouseUp", function() if this:GetParent().isResizing == true then this:GetParent():StopMovingOrSizing(); this:GetParent().isResizing = false;this:GetParent():SavePosition() end end )


	theFrame.DragBottomLeft = CreateFrame("Button", nil, theFrame)
	if not ReRecount.db.profile.Locked then
		theFrame.DragBottomLeft:Show()
	else
		theFrame.DragBottomLeft:Hide()
	end
	theFrame.DragBottomLeft:SetFrameLevel( theFrame:GetFrameLevel() + 10)
	theFrame.DragBottomLeft:SetNormalTexture("Interface\\AddOns\\ReRecount\\ResizeGripLeft")
	theFrame.DragBottomLeft:SetHighlightTexture("Interface\\AddOns\\ReRecount\\ResizeGripLeft")
	theFrame.DragBottomLeft:SetWidth(16)
	theFrame.DragBottomLeft:SetHeight(16)
	theFrame.DragBottomLeft:SetPoint("BOTTOMLEFT", theFrame, "BOTTOMLEFT", 0, 0)
	theFrame.DragBottomLeft:EnableMouse(true)
	theFrame.DragBottomLeft:SetScript("OnMouseDown", function() if ((( not this:GetParent().isLocked ) or ( this:GetParent().isLocked == 0 ) ) and ( arg1 == "LeftButton" ) ) then this:GetParent().isResizing = true; this:GetParent():StartSizing("BOTTOMLEFT") end end ) -- Elsia: Disallow resizing when locked
	theFrame.DragBottomLeft:SetScript("OnMouseUp", function() if this:GetParent().isResizing == true then this:GetParent():StopMovingOrSizing(); this:GetParent().isResizing = false;this:GetParent():SavePosition() end end )

	local g=Graph:CreateGraphRealtime("ReRecount_Realtime_"..who.."_"..tracking,theFrame,"BOTTOM","BOTTOM",0,2,197,199)
	g:SetAutoScale(true)
	g:SetGridSpacing(1.0,100)
	g:SetYMax(120)
	g:SetXAxis(-10,-0)
	g:SetMode("EXPFAST")
	g:SetDecay(0.5)
	g:SetFilterRadius(2)
	g:SetMinMaxY(100)
	g:SetBarColors(ReRecount.Colors:GetColor("Realtime",theFrame.TitleText.." Bottom"),ReRecount.Colors:GetColor("Realtime",theFrame.TitleText.." Top"))
	
	g:SetUpdateLimit(0.05)
	g:SetGridColorSecondary({0.5,0.5,0.5,0.25})
	g:SetYLabels(true,true)
	g:SetGridSecondaryMultiple(1,2)
	g.Window=theFrame

	g:EnableMouse(true)

	g:SetScript("OnMouseDown",function() WhichWindow=this.Window;ReRecount:ColorDropDownOpen(WhichWindow);ToggleDropDownMenu(1, nil, ReRecount_ColorDropDownMenu) end) --, WhichWindow, 0, WhichWindow:GetHeight()); end)
	
	theFrame.DetermineGridSpacing=me.DetermineGridSpacing
	theFrame.Graph=g
	
	theFrame.id = "Realtime_"..who.."_"..tracking
	theFrame.who=who
	theFrame.ending=ending
	theFrame.tracking=tracking
	theFrame.SavePosition=me.SavePosition
	theFrame.ResizeRealtimeWindow=me.ResizeRealtimeWindow
	theFrame.UpdateTitle=me.UpdateTitle

	ReRecount.db.profile.RealtimeWindows[theFrame.id]={who,tracking,ending}
	theFrame:StartMoving()
	theFrame:StopMovingOrSizing()
	theFrame:UpdateTitle()
	theFrame:SavePosition()

	ReRecount:RegisterTracking(theFrame.id,who,tracking,g.AddTimeData,g)

	--Need to add it to our window ordering system
	ReRecount:AddWindow(theFrame)

	theFrame.idtoken=ReRecount:ScheduleRepeatingTimer("UpdateTitle",0.1,theFrame) -- (me.UpdateTitle

	ReRecount.Colors:RegisterFunction("Realtime",theFrame.TitleText.." Top",me.SetRealtimeColor,theFrame)
	ReRecount.Colors:RegisterFunction("Realtime",theFrame.TitleText.." Bottom",me.SetRealtimeColor,theFrame)

	return theFrame
end

function ReRecount:CreateRealtimeWindow(who,tracking,ending)

	local curID = "Realtime_"..who.."_"..tracking

	if ReRecount.db.profile.RealtimeWindows and ReRecount.db.profile.RealtimeWindows[curID] and ReRecount.db.profile.RealtimeWindows[curID][8] == true then -- Don't allow opening twice
		return
	end

	local Window=table.maxn(FreeWindows)
	if Window>0 then
		if string.sub(who,1,1)~="!" then
			FreeWindows[Window].TitleText=who..ending
		else
			FreeWindows[Window].TitleText=ending
		end
		FreeWindows[Window].Title:SetText(FreeWindows[Window].TitleText.." - 0.0")
		FreeWindows[Window].id=curID
		FreeWindows[Window].who=who
		FreeWindows[Window].tracking=tracking
		FreeWindows[Window].tracking=tracking
		FreeWindows[Window].index = Window
		
		local f = FreeWindows[Window]
		if ReRecount.db.profile.RealtimeWindows and ReRecount.db.profile.RealtimeWindows[FreeWindows[Window].id] then
			ReRecount:RestoreRealtimeWindowPosition(f,ReRecount:RealtimeWindowPositionFromID(FreeWindows[Window].id))
		else
			f:SetWidth(200)
			f:SetHeight(232)
			f:ClearAllPoints()
			f:SetPoint("CENTER",UIParent)
		end
		me.ResizeRealtimeWindow(FreeWindows[Window])

		FreeWindows[Window]:UpdateTitle()
		ReRecount:RegisterTracking(FreeWindows[Window].id,who,tracking,FreeWindows[Window].Graph.AddTimeData,FreeWindows[Window].Graph)
		FreeWindows[Window].UpdateTitle=me.UpdateTitle
		FreeWindows[Window].idtoken=ReRecount:ScheduleRepeatingTimer("UpdateTitle",0.1,FreeWindows[Window])
		local tempshowfunc = FreeWindows[Window].ShowFunc
		FreeWindows[Window].ShowFunc = nil
		FreeWindows[Window]:Show()
		FreeWindows[Window].ShowFunc = tempshowfunc

		ReRecount.Colors:UnregisterItem(FreeWindows[Window])
		ReRecount.Colors:RegisterFunction("Realtime",FreeWindows[Window].TitleText.." Top",me.SetRealtimeColor,FreeWindows[Window])
		ReRecount.Colors:RegisterFunction("Realtime",FreeWindows[Window].TitleText.." Bottom",me.SetRealtimeColor,FreeWindows[Window])

		ReRecount.db.profile.RealtimeWindows[FreeWindows[Window].id]={who,tracking,ending}
		FreeWindows[Window]:SavePosition()
			
		table.remove(FreeWindows,Window)
	else

		if ReRecount.db.profile.RealtimeWindows and ReRecount.db.profile.RealtimeWindows[curID] then
			local x,y,width,height = ReRecount:RealtimeWindowPositionFromID(curID)
			local f=me:CreateRealtimeWindow(who,tracking,ending)
			ReRecount:RestoreRealtimeWindowPosition(f,x,y,width,height)
			f:ResizeRealtimeWindow()
			f:SavePosition()
		else
			local f=me:CreateRealtimeWindow(who,tracking,ending)
		end
	end
end

function ReRecount:RealtimeWindowPositionFromID(id)
	local x,y,width,height
	if ReRecount.db.profile.RealtimeWindows and ReRecount.db.profile.RealtimeWindows[id] then
		x = ReRecount.db.profile.RealtimeWindows[id][4]
		y = ReRecount.db.profile.RealtimeWindows[id][5]
		width = ReRecount.db.profile.RealtimeWindows[id][6]
		height = ReRecount.db.profile.RealtimeWindows[id][7]
	end
	return x,y,width,height
end

function ReRecount:RestoreRealtimeWindowPosition(f,x, y, width, height)
	local s = f:GetEffectiveScale() -- Elsia: Fixed position code, with inspiration from ckknight's handing in pitbull
	local uis = UIParent:GetScale()
	f:SetPoint("CENTER", UIParent, "CENTER", x*uis/s, y*uis/s)
	f:SetWidth(width)
	f:SetHeight(height)
	f:ResizeRealtimeWindow()
	f:SavePosition()
end

function ReRecount:CreateRealtimeWindowSized(who,tracking,ending, x, y, width, height)
	local f=me:CreateRealtimeWindow(who,tracking,ending)
	ReRecount:RestoreRealtimeWindowPosition(f,x,y,width,height)
end

function ReRecount:CloseAllRealtimeWindows()
	ReRecount:HideRealtimeWindows()
end
