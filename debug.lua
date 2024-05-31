
if false then

function ReRecount:DPrint(str)
end

--ReRecount.DPrint = function() end

else

ReRecount.Debug = true

function ReRecount:GetDebugFrame()
	for i=1,NUM_CHAT_WINDOWS do
		local windowName = GetChatWindowInfo(i);
		if windowName == "Debug" then
			return getglobal("ChatFrame" .. i)
		end
	end
end

function ReRecount:DPrint(str)
	local debugframe = ReRecount:GetDebugFrame()

	if debugframe then
		ReRecount:Print(debugframe, str)
	end
end

end
