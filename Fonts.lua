local FontStrings={}
local FontFile
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")

--First thing first need to add fonts
SM:Register("font", "ABF",		[[Interface\AddOns\ReRecount\Fonts\ABF.ttf]])

function ReRecount:AddFontString(string)
	local Font, Height, Flags

	FontStrings[#FontStrings+1]=string

	if not FontFile and ReRecount.db.profile.Font then
		FontFile=SM:Fetch("font",ReRecount.db.profile.Font)
	end

	if FontFile then
		Font, Height, Flags = string:GetFont()
		if Font~=FontFile then
			string:SetFont(FontFile, Height, Flags)
		end
	end
end

function ReRecount:SetFont(fontname)
	local Height, Flags

	ReRecount.db.profile.Font=fontname
	FontFile=SM:Fetch("font",fontname)

	for _, v in pairs(FontStrings) do
		_, Height, Flags = v:GetFont()
		v:SetFont(FontFile, Height, Flags)
	end
end