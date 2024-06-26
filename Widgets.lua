local revision = tonumber(string.sub("$Revision: 67838 $", 12, -3))
if ReRecount.Version < revision then ReRecount.Version = revision end

function ReRecount:CreateFrame(Name, Title, Height, Width, ShowFunc, HideFunc)
	local theFrame=CreateFrame("Frame", Name,UIParent)

	theFrame:ClearAllPoints()
	theFrame:SetPoint("CENTER",UIParent)
	theFrame:SetHeight(Height)
	theFrame:SetWidth(Width)

	theFrame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\AddOns\\ReRecount\\textures\\otravi-semi-full-border", edgeSize = 32,
		insets = {left = 1, right = 1, top = 20, bottom = 1},
	})
	theFrame:SetBackdropBorderColor(1.0,0.0,0.0)
	theFrame:SetBackdropColor(24/255, 24/255, 24/255)

	if Name == "ReRecount_MainWindow" then
		ReRecount.Colors:RegisterBorder("Window","Title",theFrame)
		ReRecount.Colors:RegisterBackground("Window","Background",theFrame)
	else
		ReRecount.Colors:RegisterBorder("Other Windows","Title",theFrame)
		ReRecount.Colors:RegisterBackground("Other Windows","Background",theFrame)
	end
	
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

						  if this.SavePosition then
							this:SavePosition()
						  end
						 end
						end)
	theFrame.ShowFunc=ShowFunc	
	theFrame:SetScript("OnShow", function()
						ReRecount:SetWindowTop(this)
						if this.ShowFunc then
							this:ShowFunc()
						end
						end)
	theFrame.HideFunc=HideFunc
	theFrame:SetScript("OnHide", function() 
						if ( this.isMoving ) then
						  this:StopMovingOrSizing();
						  this.isMoving = false;
						 end
						 if this.HideFunc then
							this:HideFunc()
						 end
						end)
	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetPoint("TOPLEFT",theFrame,"TOPLEFT",6,-15)
	theFrame.Title:SetTextColor(1.0,1.0,1.0,1.0)
	theFrame.Title:SetText(Title)
	ReRecount:AddFontString(theFrame.Title)

	if Name == "ReRecount_MainWindow" then
		ReRecount.Colors:UnregisterItem(theFrame.Title)
		ReRecount.Colors:RegisterFont("Window","Title Text",theFrame.Title)
	else
		ReRecount.Colors:UnregisterItem(theFrame.Title)
		ReRecount.Colors:RegisterFont("Other Windows","Title Text",theFrame.Title)
	end
	
	theFrame.CloseButton=CreateFrame("Button",nil,theFrame)
	theFrame.CloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up.blp")
	theFrame.CloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down.blp")
	theFrame.CloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	theFrame.CloseButton:SetWidth(20)
	theFrame.CloseButton:SetHeight(20)
	theFrame.CloseButton:SetPoint("TOPRIGHT",theFrame,"TOPRIGHT",-4,-12)
	theFrame.CloseButton:SetScript("OnClick",function() this:GetParent():Hide() end)

	return theFrame
end


function ReRecount:SetupScrollbar(name)
	local Thumb=getglobal(name.."ScrollBarThumbTexture")
	Thumb:SetTexture("Interface\\AddOns\\ReRecount\\textures\\scrollbar\\UI-ScrollBar-Knob")
	Thumb:SetVertexColor(1,0,0)
	ReRecount.Colors:RegisterTexture("Window","Title",Thumb)

	local Up=getglobal(name.."ScrollBarScrollUpButton")
	Up:SetNormalTexture("Interface\\AddOns\\ReRecount\\textures\\scrollbar\\UI-ScrollBar-ScrollUpButton-Up")
	Up:SetPushedTexture("Interface\\AddOns\\ReRecount\\textures\\scrollbar\\UI-ScrollBar-ScrollUpButton-Up")
	Up:SetDisabledTexture("Interface\\AddOns\\ReRecount\\textures\\scrollbar\\UI-ScrollBar-ScrollUpButton-Disabled")
	Up:SetHighlightTexture("Interface\\AddOns\\ReRecount\\textures\\scrollbar\\UI-ScrollBar-ScrollUpButton-Highlight")

	if not Up.Overlay then
		Up.Overlay=Up:CreateTexture(nil,"OVERLAY")
		Up.Overlay:SetAllPoints(Up)
		Up.Overlay:SetTexture("Interface\\AddOns\\ReRecount\\textures\\scrollbar\\UI-ScrollBar-ScrollUpButton-Overlay")
		Up.Overlay:SetVertexColor(1,0,0)
		Up.Overlay:SetTexCoord(0.25,0.75,0.25,0.75)
		Up.Overlay:SetBlendMode("MOD")
		ReRecount.Colors:RegisterTexture("Window","Title",Up.Overlay)
	end

	local Down=getglobal(name.."ScrollBarScrollDownButton")
	Down:SetNormalTexture("Interface\\AddOns\\ReRecount\\textures\\scrollbar\\UI-ScrollBar-ScrollDownButton-Up")
	Down:SetPushedTexture("Interface\\AddOns\\ReRecount\\textures\\scrollbar\\UI-ScrollBar-ScrollDownButton-Up")
	Down:SetDisabledTexture("Interface\\AddOns\\ReRecount\\textures\\scrollbar\\UI-ScrollBar-ScrollDownButton-Disabled")
	Down:SetHighlightTexture("Interface\\AddOns\\ReRecount\\textures\\scrollbar\\UI-ScrollBar-ScrollDownButton-Highlight")

	if not Down.Overlay then
		Down.Overlay=Up:CreateTexture(nil,"OVERLAY")
		Down.Overlay:SetAllPoints(Down)
		Down.Overlay:SetTexture("Interface\\AddOns\\ReRecount\\textures\\scrollbar\\UI-ScrollBar-ScrollDownButton-Overlay")
		Down.Overlay:SetVertexColor(1,0,0)
		Down.Overlay:SetTexCoord(0.25,0.75,0.25,0.75)
		Down.Overlay:SetBlendMode("MOD")

		ReRecount.Colors:RegisterTexture("Window","Title",Down.Overlay)
	end
	
end

function ReRecount:HideScrollbarElements(name)
	local Thumb=getglobal(name.."ScrollBarThumbTexture")
	local Up=getglobal(name.."ScrollBarScrollUpButton")
	local Down=getglobal(name.."ScrollBarScrollDownButton")


	Thumb:Hide()
	Up:Hide()
	Up:EnableMouse(false)
	if Up.Overlay then Up.Overlay:Hide() end
	Down:Hide()
	Down:EnableMouse(false)
	if Down.Overlay then Down.Overlay:Hide() end
	
	local scrollbar=getglobal(name.."ScrollBar")
	scrollbar:EnableMouse(false)
end

function ReRecount:ShowScrollbarElements(name)
	local Thumb=getglobal(name.."ScrollBarThumbTexture")
	local Up=getglobal(name.."ScrollBarScrollUpButton")
	local Down=getglobal(name.."ScrollBarScrollDownButton")

	Thumb:Show()
	Up:EnableMouse(true)
	Up:Show()
	if Up.Overlay then Up.Overlay:Show() end
	Down:EnableMouse(true)
	Down:Show()
	if Down.Overlay then Down.Overlay:Show() end
	local scrollbar=getglobal(name.."ScrollBar")
	scrollbar:EnableMouse(true)
end

