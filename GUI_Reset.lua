local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale( "ReRecount" )
local me={}

function me:CreateResetWindow()
	me.ResetFrame=CreateFrame("Frame",nil,UIParent)

	local theFrame=me.ResetFrame

	theFrame:ClearAllPoints()
	theFrame:SetPoint("CENTER",UIParent)
	theFrame:SetHeight(78)
	theFrame:SetWidth(200)

	theFrame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\AddOns\\ReRecount\\textures\\otravi-semi-full-border", edgeSize = 32,
		insets = {left = 1, right = 1, top = 20, bottom = 1},
	})
	theFrame:SetBackdropBorderColor(1.0,0.0,0.0)
	theFrame:SetBackdropColor(24/255, 24/255, 24/255)
	ReRecount.Colors:RegisterBorder("Other Windows","Title",theFrame)
	ReRecount.Colors:RegisterBackground("Other Windows","Background",theFrame)

	theFrame:EnableMouse(true)
	theFrame:SetMovable(true)


	theFrame:SetScript("OnMouseDown", function() 
						if ( ( ( not this.isLocked ) or ( this.isLocked == 0 ) ) and ( arg1 == "LeftButton" ) ) then
						  ReRecount:SetWindowTop(this)
						  this:StartMoving();
						  this.isMoving = true;
						 end
						end)
	theFrame:SetScript("OnMouseUp", function() 
						if ( this.isMoving ) then
						  this:StopMovingOrSizing();
						  this.isMoving = false;
						 end
						end)
	theFrame:SetScript("OnShow", function()
						ReRecount:SetWindowTop(this)
						end)
					
	theFrame:SetScript("OnHide", function()
						if ( this.isMoving ) then
						  this:StopMovingOrSizing();
						  this.isMoving = false;
						 end
						end)
	
	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetPoint("TOPLEFT",theFrame,"TOPLEFT",6,-15)
	theFrame.Title:SetTextColor(1.0,1.0,1.0,1.0)
	theFrame.Title:SetText(L["Reset ReRecount?"])
	ReRecount:AddFontString(theFrame.Title)
	
--	ReRecount.Colors:UnregisterItem(me.ResetFrame.Title)
	ReRecount.Colors:RegisterFont("Other Windows", "Title Text", me.ResetFrame.Title)

	theFrame.Text=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Text:SetPoint("CENTER",theFrame,"CENTER",0,-3)
	theFrame.Text:SetTextColor(1.0,1.0,1.0)
	theFrame.Text:SetText(L["Do you wish to reset the data?"])
	ReRecount:AddFontString(theFrame.Text)

	theFrame.YesButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.YesButton:SetWidth(90)
	theFrame.YesButton:SetHeight(24)
	theFrame.YesButton:SetPoint("BOTTOMRIGHT",theFrame,"BOTTOM",-4,4)
	theFrame.YesButton:SetScript("OnClick",function() ReRecount:ResetData();theFrame:Hide() end)
	theFrame.YesButton:SetText(L["Yes"])


	theFrame.NoButton=CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate")
	theFrame.NoButton:SetWidth(90)
	theFrame.NoButton:SetHeight(24)
	theFrame.NoButton:SetPoint("BOTTOMLEFT",theFrame,"BOTTOM",4,4)
	theFrame.NoButton:SetScript("OnClick",function() theFrame:Hide() end)
	theFrame.NoButton:SetText(L["No"])

	theFrame:Hide()


	--Need to add it to our window ordering system
	ReRecount:AddWindow(theFrame)
end

function ReRecount:ShowReset()
	if me.ResetFrame==nil then
		me:CreateResetWindow()
	end

	me.ResetFrame:Show()
end