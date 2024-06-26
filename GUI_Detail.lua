local Graph = LibStub:GetLibrary("LibGraph-2.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale( "ReRecount" )
local me={}
local Epsilon=0.000000000000000001

local revision = tonumber(string.sub("$Revision: 73286 $", 12, -3))
if ReRecount.Version < revision then ReRecount.Version = revision end

local RowHeight=14
local function ReRecountSortFunc(a,b)
	if a[2]>b[2] then
		return true
	end
	return false
end

function ReRecount:SelectUpperDetailTable(num)
	if num==nil or num<1 or (ReRecount.DetailWindow.PieMode.UpperTable and num>table.maxn(ReRecount.DetailWindow.PieMode.UpperTable)) or ReRecount.DetailWindow.Locked then
		return
	end

	local Rows=ReRecount.DetailWindow.PieMode.TopRows

	for i=1,8 do
		Rows[i].Background:Hide()
		Rows[i].Selected:Hide()
	end

	if num<=8 then
		Rows[num].Background:Show()
	end

	local offset = FauxScrollFrame_GetOffset(ReRecount.DetailWindow.PieMode.ScrollBar1)
	ReRecount.DetailWindow.PieMode.Selected=num+offset
	if ReRecount.DetailWindow.PieMode.UpperTable and ReRecount.DetailWindow.PieMode.UpperTable[num+offset] and ReRecount.DetailWindow.PieMode.UpperTable[num+offset][3] then
		ReRecount:FillLowerDetailTable(ReRecount.DetailWindow.PieMode.UpperTable[num+offset][3])
	end
end

function ReRecount:SelectUpperDetailTablePie(num)
	if num==nil or num<1 or (ReRecount.DetailWindow.PieMode.UpperTable and num>table.maxn(ReRecount.DetailWindow.PieMode.UpperTable)) or ReRecount.DetailWindow.Locked then
		return
	end

	local Rows=ReRecount.DetailWindow.PieMode.TopRows

	local offset = FauxScrollFrame_GetOffset(ReRecount.DetailWindow.PieMode.ScrollBar1)
	num=num-offset

	for i=1,8 do
		Rows[i].Background:Hide()
		Rows[i].Selected:Hide()
	end

	if num>=1 and num<=8 then
		Rows[num].Background:Show()
	end

	
	ReRecount.DetailWindow.PieMode.Selected=num+offset
	if ReRecount.DetailWindow.PieMode.UpperTable and ReRecount.DetailWindow.PieMode.UpperTable[num+offset] and ReRecount.DetailWindow.PieMode.UpperTable[num+offset][3] then
		ReRecount:FillLowerDetailTable(ReRecount.DetailWindow.PieMode.UpperTable[num+offset][3])
	end
end

function ReRecount:LockUpperDetailTable(num)
	if num==nil or num<1 or (ReRecount.DetailWindow.PieMode.UpperTable and num>table.maxn(ReRecount.DetailWindow.PieMode.UpperTable)) then
		return
	end

	local Rows=ReRecount.DetailWindow.PieMode.TopRows

	for i=1,8 do
		Rows[i].Background:Hide()
		Rows[i].Selected:Hide()
	end

	if num<=8 then
		Rows[num].Background:Show()
		Rows[num].Selected:Show()
	end

	local offset = FauxScrollFrame_GetOffset(ReRecount.DetailWindow.PieMode.ScrollBar1)
	
	if ReRecount.DetailWindow.Locked and ReRecount.DetailWindow.PieMode.Selected==(num+offset) then
		ReRecount.DetailWindow.Locked=nil
		Rows[num].Selected:Hide()
		return
	end

	ReRecount.DetailWindow.Locked=true
	ReRecount.DetailWindow.PieMode.Selected=num+offset
	if ReRecount.DetailWindow.PieMode.UpperTable and ReRecount.DetailWindow.PieMode.UpperTable[num+offset] and ReRecount.DetailWindow.PieMode.UpperTable[num+offset][3] then
		ReRecount:FillLowerDetailTable(ReRecount.DetailWindow.PieMode.UpperTable[num+offset][3])
	end
end

function me:SelectLowerDetailTable(num)
	if num==nil then
		return
	end

	local Rows=ReRecount.DetailWindow.PieMode.BotRows

	for i=1,8 do
		Rows[i].Background:Hide()
	end

	if num>=1 and num<=8 then
		Rows[num].Background:Show()
	end
end

function me:HideDetailModes()
	ReRecount.DetailWindow.PieMode:Hide()
	ReRecount.DetailWindow.DeathMode:Hide()
	ReRecount.DetailWindow.SummaryMode:Hide()
end

local FreeTables={}

function ReRecount:FillUpperDetailTable(Data)

	if not ReRecount.DetailWindow.SummaryEnabled then
		me:HideDetailModes()
		ReRecount.DetailWindow.PieMode:Show()
	end

	ReRecount.DetailWindow.CurMode=ReRecount.DetailWindow.PieMode

	if Data==nil then
		Data={}
	end

	local UpperTable=ReRecount.DetailWindow.PieMode.UpperTable

	for k,v in ipairs(UpperTable) do 
		FreeTables[#FreeTables+1]=v
		UpperTable[k]=nil
	end

	local total=0
	for k,v in pairs(Data) do
		if FreeTables[#FreeTables] then
			UpperTable[#UpperTable+1]=FreeTables[#FreeTables]
			FreeTables[#FreeTables]=nil

			UpperTable[#UpperTable][1]=k
			UpperTable[#UpperTable][2]=v.amount
			UpperTable[#UpperTable][3]=v.Details
			UpperTable[#UpperTable][6]=v.count
		else
			UpperTable[#UpperTable+1]={k,v.amount,v.Details,nil,nil,v.count}
		end
		
		
		total=total+v.amount
	end

	table.sort(UpperTable,ReRecountSortFunc)

	local PieChart=ReRecount.DetailWindow.PieMode.TopPieChart

	PieChart:ResetPie()

	local MaxNum=table.maxn(UpperTable)

	for k,v in ipairs(UpperTable) do
		v[4]=100*v[2]/total

		if k~=MaxNum then
			v[5]=PieChart:AddPie(v[4])
		else
			v[5]=PieChart:CompletePie()
		end
	end
	
	me:RefreshUpperDetails()
	
	--ReRecount:SetWindowTop(ReRecount.DetailWindow)
end

function me:RefreshUpperDetails()
	local UpperTable=ReRecount.DetailWindow.PieMode.UpperTable
	FauxScrollFrame_Update(ReRecount.DetailWindow.PieMode.ScrollBar1, table.maxn(UpperTable), 8, 13)
	local offset = FauxScrollFrame_GetOffset(ReRecount.DetailWindow.PieMode.ScrollBar1)

	for i=1,8 do
		local entry=UpperTable[i+offset]
		local row=ReRecount.DetailWindow.PieMode.TopRows[i]
		if entry then
			row.Background:SetVertexColor((entry[5][1]+0.5)/2,(entry[5][2]+0.5)/2,(entry[5][3]+0.5)/2,0.3)
			row.Selected:SetVertexColor(entry[5][1],entry[5][2],entry[5][3],1.0)

			if ReRecount.DetailWindow.PieMode.Selected == i+offset then
				row.Background:Show()
				if ReRecount.DetailWindow.Locked then
					row.Selected:Show()
				end
			else
				row.Background:Hide()
				row.Selected:Hide()
			end

			row.Key:SetVertexColor(entry[5][1],entry[5][2],entry[5][3],1.0)
			row.Count:SetText(i+offset)
			row.Name:SetText(entry[1])
			row.ACount:SetText(entry[6])
			row.Amount:SetText(entry[2])
			row.Percent:SetText(string.format("%.1f",entry[4]).."%")
			row.Data=entry[3]
			row:Show()
		else
			row:Hide()
		end
	end
	
	if ReRecount.DetailWindow.PieMode.Selected and UpperTable[ReRecount.DetailWindow.PieMode.Selected] and UpperTable[ReRecount.DetailWindow.PieMode.Selected][3] then
		ReRecount:FillLowerDetailTable(UpperTable[ReRecount.DetailWindow.PieMode.Selected][3])
	else
		for i=1,8 do
			ReRecount.DetailWindow.PieMode.BotPieChart:ResetPie()
			ReRecount.DetailWindow.PieMode.BotRows[i]:Hide()
		end
	end
	ReRecount.DetailWindow:Show()
end

local HitTypeColors={
	Hit={0.0,0.9,0.0},
	Crit={0.9,0.0,0.0},
	Tick={1.0,0.5,0.0},
	Miss={0.0,1.0,1.0},
	Dodge={0.5,0.0,1.0},
	Parry={0.5,0.5,0.5},
	Resist={0.0,0.5,0.5},
	Immune={0.5,0.0,0.0},
	Block={0.0,0.5,0.0},
	Glancing={0.5,1.0,0.5},
	Crushing={0.5,0.0,0.5},
	Absorb={0.25,0.25,0.25},
}
function ReRecount:FillLowerDetailTable(Data)
	local dispTable=ReRecount.DetailWindow.PieMode.LowerTable
	local total=0

	for k,v in ipairs(dispTable) do 
		FreeTables[#FreeTables+1]=v
		dispTable[k]=nil
	end


	for k,v in pairs(Data) do
		local avg

		if v.amount then
			avg=math.floor(v.amount/v.count+0.5)
		end

		if FreeTables[#FreeTables] then
			dispTable[#dispTable+1]=FreeTables[#FreeTables]
			FreeTables[#FreeTables]=nil

			dispTable[#dispTable][1]=k
			dispTable[#dispTable][2]=v.count
			dispTable[#dispTable][3]=v.min
			dispTable[#dispTable][4]=avg
			dispTable[#dispTable][5]=v.max
		else
			dispTable[#dispTable+1]={k,v.count,v.min,avg,v.max}
		end
		total=total+v.count
	end

	table.sort(dispTable,ReRecountSortFunc)

	local PieChart=ReRecount.DetailWindow.PieMode.BotPieChart

	PieChart:ResetPie()

	local MaxNum=table.maxn(dispTable)

	for k,v in ipairs(dispTable) do
		v[6]=100*v[2]/total
		v[7]=HitTypeColors[v[1]]

		if k~=MaxNum then
			v[7]=PieChart:AddPie(v[6],v[7])
		else
			v[7]=PieChart:CompletePie(v[7])
		end
	end

	for i=1,8 do
		local entry=dispTable[i]
		local row=ReRecount.DetailWindow.PieMode.BotRows[i]
		if entry then
			row.Key:SetVertexColor(entry[7][1],entry[7][2],entry[7][3],1.0)
			row.Background:SetVertexColor((entry[7][1]+0.5)/2,(entry[7][2]+0.5)/2,(entry[7][3]+0.5)/2,0.3)
			row.Name:SetText(entry[1])
			row.Count:SetText(entry[2])
			if entry[3] then
				row.Min:SetText(entry[3])
				row.Min:Show()
			else
				row.Min:Hide()
			end

			if entry[4] then
				row.Avg:SetText(entry[4])
				row.Avg:Show()
			else
				row.Avg:Hide()
			end

			if entry[5] then
				row.Max:SetText(entry[5])
				row.Max:Show()
			else
				row.Max:Hide()
			end

			row.Percent:SetText(string.format("%.1f",entry[6]).."%")
			row.Data=entry[3]
			row:Show()
		else
			row:Hide()
		end
	end
end


--The titles are slightly different for various modes
--.TopNames = Names of the entries for the top data
--.TopCount = Names of the count for the top data
--.TopAmount = What we call the amount for the top
--.BotNames = Names of the entries for the bottom
--.BotMin = The minimum label for bottom
--.BotAvg = The average label for bottom
--.BotMax = The minimum label for bottom
--.BotAmount = Label for what the amount is on the bottom
function ReRecount:SetupDetailTitles(ForWho,MainTitle,Titles)
	ReRecount.DetailWindow.TitleText=ForWho..MainTitle
	ReRecount.DetailWindow.ForWho=ForWho
	ReRecount.DetailWindow.CurTitle=L["Detail Window"].." - "..ForWho..MainTitle
	if not ReRecount.DetailWindow.SummaryEnabled then
		ReRecount.DetailWindow.Title:SetText(ReRecount.DetailWindow.CurTitle)
	end
	local Labels=ReRecount.DetailWindow.PieMode.TopRowLabels
	Labels.Name:SetText(Titles.TopNames)
	Labels.ACount:SetText(Titles.TopCount)
	Labels.Amount:SetText(Titles.TopAmount)

	Labels=ReRecount.DetailWindow.PieMode.BotRowLabels
	Labels.Name:SetText(Titles.BotNames)
	Labels.Min:SetText(Titles.BotMin)
	Labels.Avg:SetText(Titles.BotAvg)
	Labels.Max:SetText(Titles.BotMax)
	Labels.Count:SetText(Titles.BotAmount)
end

function ReRecount:SetDeathDetails(Who,Data)	
	if not ReRecount.DetailWindow.SummaryEnabled then
		me:HideDetailModes()
		ReRecount.DetailWindow.DeathMode:Show()
	end
	
	ReRecount.DetailWindow.CurMode=ReRecount.DetailWindow.DeathMode


	ReRecount.DetailWindow.DeathMode.Data=Data
	me:RefreshDeathDetails()

	ReRecount.DetailWindow.DeathMode.WhosDeaths=Who
	ReRecount.DetailWindow.Title:SetText(L["Detail Window"].." - "..L["Death Details for"].." "..Who)
	
	
	ReRecount.DetailWindow:Show()
end

function me:RefreshDeathDetails()
	local Row,DataRow
	local Data=ReRecount.DetailWindow.DeathMode.Data
	local size
	
	if data then
		size = table.getn(Data)
	else
		size = 0
	end
		
	FauxScrollFrame_Update(ReRecount.DetailWindow.DeathMode.ScrollBar1, size, 17, 18)

	local offset = FauxScrollFrame_GetOffset(ReRecount.DetailWindow.DeathMode.ScrollBar1)
	local Selected = (ReRecount.DetailWindow.DeathMode.SelectedNum or 1)-offset

	for i=1,17 do
		Row=ReRecount.DetailWindow.DeathMode.Deaths[i] or 0
		DataRow=Data and Data[i+offset]
		if DataRow then
			Row.Data=DataRow
			Row.Time:SetText(date("%H:%M:%S",DataRow.DeathAt))
			if DataRow.KilledBy then
				Row.Who:SetText(DataRow.KilledBy)
			else
				Row.Who:SetText("-")
			end
			ReRecount:CheckFontStringLength(Row.Who,80)

			if Selected==i then
				Row.Selected:Show()
			else
				Row.Selected:Hide()
			end

			Row:Show()
		else
			Row:Hide()
		end
	end
	
end

function ReRecount:WrapFontString(fontstring,maxwidth)
	local Text=fontstring:GetText()
	local Returning=""
	local Temp,NextWhite
	
	while fontstring:GetStringWidth()>maxwidth do		
		Temp=string.reverse(Text)
		_,NextWhite=string.find(Temp,"( +)")
		
		Returning=string.sub(Text,string.len(Text)-NextWhite+1,string.len(Text))..Returning
		Text=string.sub(Text, 1, string.len(Text)-NextWhite)
		fontstring:SetText(Text)
	end
	return Returning
end

function ReRecount:SetDeathLogDetails(id)
	ReRecount:DPrint("id: "..id)
	ReRecount:DPrint(debugstack(2, 3, 2))
	for i=1,17 do
		ReRecount.DetailWindow.DeathMode.Deaths[i].Selected:Hide()
	end
	ReRecount.DetailWindow.DeathMode.Deaths[id].Selected:Show()

	local offset = FauxScrollFrame_GetOffset(ReRecount.DetailWindow.DeathMode.ScrollBar1)

	ReRecount.DetailWindow.DeathMode.SelectedNum=id+offset
	ReRecount.DetailWindow.DeathMode.SelectedData=ReRecount.DetailWindow.DeathMode.Deaths[id].Data

	if ReRecount.DeathGraph and ReRecount.DeathGraph:IsShown() then
		me:ShowDeathGraph()
	end
	me:DetermineDeathFilters()
	me:RefreshDeathLogDetails()
end

local DeathLogColors={
	DAMAGE={1.0,0.2,0.2},
	HEAL={0.2,1.0,0.2},
	MISC={0.2,0.2,0.2}
}

function me:FilterDeathData(filterType,filterIncoming)
	local Data=ReRecount.DetailWindow.DeathMode.SelectedData
	local FilterData=ReRecount.DetailWindow.DeathMode.FilteredData
	
	for _, v in pairs(FilterData) do
		for k in pairs(v) do
			v[k]=nil
		end
	end

	if Data==nil then
		return
	end

	for i=1,#Data.Messages do
		if filterType[Data.MessageType[i]] and filterIncoming[Data.MessageIncoming[i]] then
			table.insert(FilterData.Messages,Data.Messages[i])
			table.insert(FilterData.MessageType,Data.MessageType[i])
			table.insert(FilterData.MessageIncoming,Data.MessageIncoming[i])
			table.insert(FilterData.MessageTimes,Data.MessageTimes[i])
			table.insert(FilterData.Health,Data.Health[i])
			table.insert(FilterData.HealthNum,Data.HealthNum[i])
		end
	end
end

function me:ShowDeathGraph()
	local Data=ReRecount.DetailWindow.DeathMode.SelectedData
--	local Title=ReRecount.DetailWindow.DeathMode.WhosDeaths.." killed by "..Data.KilledBy.." at "..date("%H:%M:%S",Data.DeathAt)
	local Health=ReRecount:GetTable()
	local Hits, Heals

	if Data then
		for k,time in pairs(Data.MessageTimes) do
			Health[#Health+1]={time,Data.HealthNum[k]}

			if Data.EventNum[k] then
				if Data.MessageType[k]=="HEAL" then
					if Heals==nil then
						Heals=ReRecount:GetTable()
					end
					Heals[#Heals+1]={time,Data.EventNum[k]}
					ReRecount:DPrint("Heal: "..time.." "..Data.EventNum[k])
				elseif Data.MessageType[k]=="DAMAGE" then
					if Hits==nil then
						Hits=ReRecount:GetTable()
					end
					Hits[#Hits+1]={time,Data.EventNum[k]}
					ReRecount:DPrint("Hits: "..time.." "..Data.EventNum[k])
				end
			end
		end
	end

	ReRecount:ShowDeathGraph(Health,Heals,Hits)
end

--Since lines can potentially span multiple lines need to count manually
function me:CountDeathLogLines()
	local lines=0
	
	local Data=ReRecount.DetailWindow.DeathMode.FilteredData
	local Row=ReRecount.DetailWindow.DeathMode.DeathLog[1]
	local NextLine

	for i=1,#Data.Messages do
		Row.Msg:SetText("("..L["Health"]..": "..Data.Health[i]..") "..Data.Messages[i])
		lines=lines+1

		NextLine=ReRecount:WrapFontString(Row.Msg,235)
		if NextLine~="" then
			Row.Msg:SetText(" "..NextLine)
			lines=lines+1
			NextLine=ReRecount:WrapFontString(Row.Msg,235)
		end

		NextLine=ReRecount:WrapFontString(Row.Msg,235)
		if NextLine~="" then
			Row.Msg:SetText(" "..NextLine)
			lines=lines+1
			NextLine=ReRecount:WrapFontString(Row.Msg,235)
		end
	end

	return lines
end

function me:DetermineOffset(num)
	if num==0 then
		return 0
	end

	local lines=0
	
	local Data=ReRecount.DetailWindow.DeathMode.FilteredData
	local Row=ReRecount.DetailWindow.DeathMode.DeathLog[1]
	local NextLine

	for i=1,#Data.Messages do
		Row.Msg:SetText("("..L["Health"]..": "..Data.Health[i]..") "..Data.Messages[i])
		lines=lines+1

		if lines==num then
			return i+1
		end

		NextLine=ReRecount:WrapFontString(Row.Msg,235)
		if NextLine~="" then
			Row.Msg:SetText(" "..NextLine)
			lines=lines+1
			NextLine=ReRecount:WrapFontString(Row.Msg,235)

			if lines==num then
				return i+1
			end
		end

		NextLine=ReRecount:WrapFontString(Row.Msg,235)
		if NextLine~="" then
			Row.Msg:SetText(" "..NextLine)
			lines=lines+1
			NextLine=ReRecount:WrapFontString(Row.Msg,235)

			if lines==num then
				return i+1
			end
		end
	end
	return #Data.Messages
end

function me:RefreshDeathLogDetails()
	local Data=ReRecount.DetailWindow.DeathMode.FilteredData
	local Row, NextLine
	
	local size
	if not Data or type(Data.Messages)~="table" then
		size=0
	else
		size=me:CountDeathLogLines()
	end
	
	FauxScrollFrame_Update(ReRecount.DetailWindow.DeathMode.ScrollBar2, size, 18, 13)
	local offset = me:DetermineOffset(FauxScrollFrame_GetOffset(ReRecount.DetailWindow.DeathMode.ScrollBar2))
	local RowOffset=0

	if Data then
		for i=1,20 do
			if i+RowOffset>20 then
				break
			end

			Row=ReRecount.DetailWindow.DeathMode.DeathLog[i+RowOffset]
			if Data.Messages[i+offset] then
				if Data.MessageTimes[i+offset]<0 then
					Row.Time:SetText(string.format("%.2f",Data.MessageTimes[i+offset]))
				else
					Row.Time:SetText(string.format("+%.2f",Data.MessageTimes[i+offset]))
				end
				Row.Msg:SetText("("..L["Health"]..": "..Data.Health[i+offset]..") "..Data.Messages[i+offset])

				local Color=DeathLogColors[Data.MessageType[i+offset]]
				Row.Background:SetVertexColor(Color[1],Color[2],Color[3])
				Row:Show()
				
				NextLine=ReRecount:WrapFontString(Row.Msg,235)
				if NextLine~="" and (i+RowOffset)<20 then
					RowOffset=RowOffset+1
					Row=ReRecount.DetailWindow.DeathMode.DeathLog[i+RowOffset]
					Row.Time:SetText("")
					Row.Msg:SetText(" "..NextLine)
					Row.Background:SetVertexColor(Color[1],Color[2],Color[3])
					Row:Show()
				end

				NextLine=ReRecount:WrapFontString(Row.Msg,235)
				if NextLine~="" and (i+RowOffset)<20 then
					RowOffset=RowOffset+1
					Row=ReRecount.DetailWindow.DeathMode.DeathLog[i+RowOffset]
					Row.Time:SetText("")
					Row.Msg:SetText(" "..NextLine)
					Row.Background:SetVertexColor(Color[1],Color[2],Color[3])
					Row:Show()
				end
			else
				Row:Hide()
			end
		end
	else
		for i=1,20 do
			ReRecount.DetailWindow.DeathMode.DeathLog[i]:Hide()
		end
	end
end



--Summary Report Functions
local FontHeight=14.5

local SummaryDamageTypes={
	"Melee",
	"Physical",
	"Arcane",
	"Fire",
	"Frost",
	"Holy",
	"Nature",
	"Shadow",
}

local SummaryHitTypes={
	"Glancing",
	"Hit",
	"Crushing",
	"Crit",
	"Miss",
	"Dodge",
	"Parry",
	"Block",
	"Resist",
}
function me:CreateSummaryColumn(Title,Color)
	local theFrame=CreateFrame("Frame",nil,ReRecount.DetailWindow.SummaryMode)

	theFrame:SetWidth(47)
	theFrame:SetHeight(156+26)

	theFrame.Background=theFrame:CreateTexture(nil,"BACKGROUND")
	theFrame.Background:SetAllPoints(theFrame)
	theFrame.Background:SetTexture(Color[1],Color[2],Color[3],0.1)

	theFrame.Selected=theFrame:CreateTexture(nil,"BACKGROUND")
	theFrame.Selected:SetAllPoints(theFrame)
	theFrame.Selected:SetTexture(Color[1],Color[2],Color[3],0.3)
	theFrame.Selected:Hide()
	
	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	theFrame.Title:SetText(Title)
	theFrame.Title:SetPoint("TOP",theFrame,"TOP",0,-2)
	ReRecount:AddFontString(theFrame.Title)

	local RowSpacing=-12.8

	theFrame.Damage=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	theFrame.Damage:SetTextColor(1,1,1)
	theFrame.Damage:SetText("-")
	theFrame.Damage:SetPoint("TOP",theFrame,"TOP",0,RowSpacing)
	theFrame.Damage:SetFont("Fonts\\ARIALN.TTF",11)
	ReRecount:AddFontString(theFrame.Damage)

	theFrame.Resisted=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	theFrame.Resisted:SetTextColor(1,1,1)
	theFrame.Resisted:SetText("-")
	theFrame.Resisted:SetPoint("TOP",theFrame,"TOP",0,RowSpacing*2)
	theFrame.Resisted:SetFont("Fonts\\ARIALN.TTF",11)
	ReRecount:AddFontString(theFrame.Resisted)

	theFrame.Blocked=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	theFrame.Blocked:SetTextColor(1,1,1)
	theFrame.Blocked:SetText("-")
	theFrame.Blocked:SetPoint("TOP",theFrame,"TOP",0,RowSpacing*3)
	theFrame.Blocked:SetFont("Fonts\\ARIALN.TTF",11)
	ReRecount:AddFontString(theFrame.Blocked)

	theFrame.Absorbed=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	theFrame.Absorbed:SetTextColor(1,1,1)
	theFrame.Absorbed:SetText("-")
	theFrame.Absorbed:SetPoint("TOP",theFrame,"TOP",0,RowSpacing*4)
	theFrame.Absorbed:SetFont("Fonts\\ARIALN.TTF",11)
	ReRecount:AddFontString(theFrame.Absorbed)

	local i=5
	
	for _, k in pairs(SummaryHitTypes) do
		theFrame[k]=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
		theFrame[k]:SetTextColor(1,1,1)
		theFrame[k]:SetText("-")
		theFrame[k]:SetPoint("TOP",theFrame,"TOP",-11.5,RowSpacing*i)
		theFrame[k]:SetFont("Fonts\\ARIALN.TTF",11)
		ReRecount:AddFontString(theFrame[k])
		theFrame[k.."P"]=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
		theFrame[k.."P"]:SetTextColor(1,1,1)
		theFrame[k.."P"]:SetText("-")
		theFrame[k.."P"]:SetPoint("TOP",theFrame,"TOP",11.5,RowSpacing*i)
		theFrame[k.."P"]:SetFont("Fonts\\ARIALN.TTF",11)
		ReRecount:AddFontString(theFrame[k.."P"])
		i=i+1
	end

	theFrame.Report=me.ReportElement
	theFrame:EnableMouse()
	theFrame.SelectMe=me.SelectSummaryItem
	theFrame:SetScript("OnMouseDown",theFrame.SelectMe)
	return theFrame
end

local SummaryActive={
	Melee=true,
	Physical=true,
	Arcane=false,
	Fire=false,
	Frost=false,
	Holy=false,
	Nature=false,
	Shadow=false,
}

function me:LoadSummaryData(damage,resisted,hitData,blocked,absorbed)
	local SummaryMode=ReRecount.DetailWindow.SummaryMode
	local damageFrame

	--Reset values
	for _, dt in pairs(SummaryDamageTypes) do
		damageFrame=SummaryMode[dt]
		damageFrame.Damage:SetText("-")
		damageFrame.Resisted:SetText("-")
		damageFrame.Blocked:SetText("-")
		damageFrame.Absorbed:SetText("-")
		for _, ht in pairs(SummaryHitTypes) do
			damageFrame[ht]:SetText("-")
			damageFrame[ht.."P"]:SetText("-")
		end

		SummaryActive[dt]=false
	end

	SummaryActive.Melee=true
	SummaryActive.Physical=true

	if damage then
		for k, v in pairs(damage) do
			if SummaryMode[k] then
				SummaryMode[k].Damage:SetText(v)
				if SummaryMode[k].Damage~=0 then
					SummaryActive[k]=true
				end
			end
		end
	end
	
	if resisted then
		for k, v in pairs(resisted) do
			if SummaryMode[k] then
				SummaryMode[k].Resisted:SetText(v)
				if SummaryMode[k].Resisted~=0 then
					SummaryActive[k]=true
				end
			end
		end
	end

	if blocked then
		for k, v in pairs(blocked) do
			if SummaryMode[k] then
				SummaryMode[k].Blocked:SetText(v)
				if SummaryMode[k].Blocked~=0 then
					SummaryActive[k]=true
				end
			end
		end
	end

	if absorbed then
		for k, v in pairs(absorbed) do
			if SummaryMode[k] then
				SummaryMode[k].Absorbed:SetText(v)
				if SummaryMode[k].Absorbed~=0 then
					SummaryActive[k]=true
				end
			end
		end
	end

	if hitData then
		for k, v in pairs(hitData) do
			damageFrame=SummaryMode[k]
			if damageFrame then
				local Total=v.amount
				for k2, v2 in pairs(v.Details) do
					if k2=="Tick" then
						Total=Total-v2.count
					end
				end
				for k2, v2 in pairs(v.Details) do
					if damageFrame[k2] then
						damageFrame[k2]:SetText(v2.count)
						damageFrame[k2.."P"]:SetText((math.floor(1000*v2.count/Total+0.5)/10).."%")
						SummaryActive[k]=true
						
					end
				end
			end
		end
	end
		
	local numShown=0
	for k, v in pairs(SummaryActive) do
		if v then
			SummaryMode[k]:Show()
			numShown=numShown+1
		else
			SummaryMode[k]:Hide()
		end
	end
	local Width=(390+30)/numShown
	for k, v in pairs(SummaryActive) do
		if v then
			SummaryMode[k]:SetWidth(Width-2)
		end
	end

	Width=(Width-2)/4

	local Previous=SummaryMode.AttackLabels
	for _, v in pairs(SummaryDamageTypes) do
		if SummaryMode[v]:IsShown() then
			SummaryMode[v]:SetPoint("TOPLEFT",Previous,"TOPRIGHT",2,0)
			Previous=SummaryMode[v]
			local i=5
			for _, k in pairs(SummaryHitTypes) do
				SummaryMode[v][k]:SetPoint("TOP",SummaryMode[v],"TOP",-Width,-12.8*i)
				SummaryMode[v][k.."P"]:SetPoint("TOP",SummaryMode[v],"TOP",Width,-12.8*i)
				i=i+1
			end
		end		
	end
end

function me:ReportElement(loc,loc2)
	if ReRecount.DetailWindow.SummaryMode.DamageMode then
		SendChatMessage(L["ReRecount"].." - "..L["Outgoing"].." "..self.Title:GetText().." "..L["Damage Report for"].." "..ReRecount.DetailWindow.Showing,loc,nil,loc2)
	else
		SendChatMessage(L["ReRecount"].." - "..L["Incoming"].." "..self.Title:GetText().." "..L["Damage Report for"].." "..ReRecount.DetailWindow.Showing,loc,nil,loc2)
	end

	local Num,Per

	Num=self.Damage:GetText()
	if Num~="-" then
		SendChatMessage(L["Damage"]..": "..Num,loc,nil,loc2)
	end

	Num=self.Resisted:GetText()
	if Num~="-" then
		SendChatMessage(L["Resisted"]..": "..Num,loc,nil,loc2)
	end

	Num=self.Blocked:GetText()
	if Num~="-" then
		SendChatMessage(L["Blocked"]..": "..Num,loc,nil,loc2)
	end

	Num=self.Absorbed:GetText()
	if Num~="-" then
		SendChatMessage(L["Absorbed"]..": "..Num,loc,nil,loc2)
	end

	for _, HitType in pairs(SummaryHitTypes) do 
		Num=self[HitType]:GetText()
		Per=self[HitType.."P"]:GetText()
		if Num~="-" then
			SendChatMessage(HitType..": "..Num.."x "..Per,loc,nil,loc2)
		end
	end
end

function me:SelectSummaryItem()
	if ReRecount.DetailWindow.SummaryMode.Selected then
		ReRecount.DetailWindow.SummaryMode.Selected.Selected:Hide()
		if ReRecount.DetailWindow.SummaryMode.Selected==self then
			ReRecount.DetailWindow.SummaryMode.Selected=nil
			return
		end
	end
	ReRecount.DetailWindow.SummaryMode.Selected=self
	self.Selected:Show()
end

function me:SetValue(v)
	self.Value:SetText(v)
end

function me:CreateDataItem(parent,text,value,font)
	local theFrame=CreateFrame("Frame",nil,parent)

	theFrame:SetWidth(150+(50/3))

	if not font then
		font="GameFontNormalSmall"
		theFrame:SetHeight(14)
	else
		theFrame:SetHeight(16)
	end

	theFrame.Text=theFrame:CreateFontString(nil,"OVERLAY",font)
	theFrame.Text:SetText(text)
	theFrame.Text:SetPoint("LEFT",theFrame,"LEFT",4,0)
	ReRecount:AddFontString(theFrame.Text)

	theFrame.Value=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	theFrame.Value:SetText(value)
	theFrame.Value:SetTextColor(1,1,1)
	theFrame.Value:SetPoint("RIGHT",theFrame,"RIGHT",-4,0)
	ReRecount:AddFontString(theFrame.Value)

	theFrame.SetValue=me.SetValue
	theFrame.GetText=me.GetTextDataItem

	return theFrame
end

function me:GetTextDataItem()
	return self.Text:GetText().." "..self.Value:GetText()
end

function me:GetTextTitle()
	return self.Text:GetText()
end

function me:CreateTitle(parent,text,font)
	local theFrame=CreateFrame("Frame",nil,parent)

	theFrame:SetWidth(150+(50/3))

	if not font then
		font="GameFontNormalSmall"
		theFrame:SetHeight(14)
	else
		theFrame:SetHeight(16)
	end

	theFrame.Text=theFrame:CreateFontString(nil,"OVERLAY",font)
	theFrame.Text:SetText(text)
	theFrame.Text:SetPoint("CENTER",theFrame,"CENTER",0,0)
	ReRecount:AddFontString(theFrame.Text)

	theFrame.GetText=me.GetTextTitle

	return theFrame
end
local SummarySet={
	"Total",
	"PerSec",
	"Overhealing",
	"Taken",
	"Time",
	"Focus",
	"Misc"
}
function me:ReportSummarySet(loc,loc2)
	SendChatMessage(L["ReRecount"].." - "..self.Title:GetText().." "..L["Report for"].." "..ReRecount.DetailWindow.Showing,loc,nil,loc2)
	for _,v in pairs(SummarySet) do
		if self[v] then
			SendChatMessage(self[v]:GetText(),loc,nil,loc2)
		end
	end
end

local SummaryLabels={
	L["Damage"],
	L["Resisted"],
	L["Blocked"],
	L["Absorbed"],
	L["Glancing"],
	L["Hit"],
	L["Crushing"],
	L["Crit"],
	L["Miss"],
	L["Dodge"],
	L["Parry"],
	L["Block"],
	L["Resist"],
}

function me:CreateSummaryMode()
	ReRecount.DetailWindow.SummaryMode=CreateFrame("Frame",nil,ReRecount.DetailWindow)
	
	local theFrame=ReRecount.DetailWindow.SummaryMode

	theFrame:ClearAllPoints()
	theFrame:SetPoint("BOTTOM",ReRecount.DetailWindow)
	theFrame:SetHeight(320-32+26)
	theFrame:SetWidth(450+50)

	theFrame.AttackLabels=CreateFrame("Frame",nil,theFrame)
	theFrame.AttackLabels:SetWidth(55+20)
	theFrame.AttackLabels:SetHeight(156+26)
	theFrame.AttackLabels:SetPoint("BOTTOMLEFT",theFrame,"BOTTOMLEFT",0,2)


	local i=1
	for _,k in pairs(SummaryLabels) do
		theFrame.AttackLabels[k]=theFrame.AttackLabels:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
		theFrame.AttackLabels[k]:SetPoint("TOPRIGHT",theFrame.AttackLabels,"TOPRIGHT",-2,-12.8*i)
		theFrame.AttackLabels[k]:SetText(k..":")
		ReRecount:AddFontString(theFrame.AttackLabels[k])
		i=i+1
	end
	SummaryLabels=nil

	theFrame.Melee=me:CreateSummaryColumn(L["Melee"],{0.5,0.5,0.5})
	theFrame.Melee:SetPoint("TOPLEFT",theFrame.AttackLabels,"TOPRIGHT",2,0)

	theFrame.Physical=me:CreateSummaryColumn(L["Physical"],{0.6,0.4,0.2})
	theFrame.Physical:SetPoint("TOPLEFT",theFrame.Melee,"TOPRIGHT",2,0)

	theFrame.Arcane=me:CreateSummaryColumn(L["Arcane"],{1.0,1.0,1.0})
	theFrame.Arcane:SetPoint("TOPLEFT",theFrame.Physical,"TOPRIGHT",2,0)

	theFrame.Fire=me:CreateSummaryColumn(L["Fire"],{1.0,0.0,0.0})
	theFrame.Fire:SetPoint("TOPLEFT",theFrame.Arcane,"TOPRIGHT",2,0)

	theFrame.Frost=me:CreateSummaryColumn(L["Frost"],{0.5,0.5,1.0})
	theFrame.Frost:SetPoint("TOPLEFT",theFrame.Fire,"TOPRIGHT",2,0)

	theFrame.Holy=me:CreateSummaryColumn(L["Holy"],{1.0,1.0,0.5})
	theFrame.Holy:SetPoint("TOPLEFT",theFrame.Frost,"TOPRIGHT",2,0)

	theFrame.Nature=me:CreateSummaryColumn(L["Nature"],{0.5,1.0,0.5})
	theFrame.Nature:SetPoint("TOPLEFT",theFrame.Holy,"TOPRIGHT",2,0)

	theFrame.Shadow=me:CreateSummaryColumn(L["Shadow"],{0.5,0.1,0.7})
	theFrame.Shadow:SetPoint("TOPLEFT",theFrame.Nature,"TOPRIGHT",2,0)

	--Damage Data
	theFrame.Damage=CreateFrame("Frame",nil,theFrame)
	theFrame.Damage:SetHeight(105)
	theFrame.Damage:SetWidth(149+(50/3))
	theFrame.Damage:SetPoint("TOPLEFT",theFrame,"TOPLEFT",1,2)
	theFrame.Damage:SetFrameLevel(theFrame:GetFrameLevel())
	theFrame.Damage.Report=me.ReportSummarySet

	theFrame.Damage.SelectMe=me.SelectSummaryItem
	theFrame.Damage:EnableMouse()
	theFrame.Damage:SetScript("OnMouseDown",theFrame.Damage.SelectMe)

	theFrame.Damage.Selected=theFrame.Damage:CreateTexture(nil,"BACKGROUND")
	theFrame.Damage.Selected:SetTexture(1.0,0.0,0,0.1)
	theFrame.Damage.Selected:SetAllPoints(theFrame.Damage)
	theFrame.Damage.Selected:Hide()

	theFrame.Damage.Title=me:CreateTitle(theFrame,L["Damage"],"GameFontNormal")
	theFrame.Damage.Title:SetPoint("TOPLEFT",theFrame.Damage,"TOPLEFT",0,0)
	theFrame.Damage.Total=me:CreateDataItem(theFrame.Damage,L["Total"]..":",0)
	theFrame.Damage.Total:SetPoint("TOP",theFrame.Damage.Title,"BOTTOM",0,0)
	theFrame.Damage.PerSec=me:CreateDataItem(theFrame.Damage,L["DPS"]..":",0)
	theFrame.Damage.PerSec:SetPoint("TOP",theFrame.Damage.Total,"BOTTOM",0,0)	
	theFrame.Damage.Taken=me:CreateDataItem(theFrame.Damage,L["Taken"]..":",0)
	theFrame.Damage.Taken:SetPoint("TOP",theFrame.Damage.PerSec,"BOTTOM",0,0)
	theFrame.Damage.Time=me:CreateDataItem(theFrame.Damage,L["Time"]..":",0)
	theFrame.Damage.Time:SetPoint("TOP",theFrame.Damage.Taken,"BOTTOM",0,0)
	theFrame.Damage.Focus=me:CreateDataItem(theFrame.Damage,L["Damage Focus"]..":",0)
	theFrame.Damage.Focus:SetPoint("TOP",theFrame.Damage.Time,"BOTTOM",0,0)
	theFrame.Damage.Misc=me:CreateDataItem(theFrame.Damage,L["Avg. DOTs Up"]..":",0)
	theFrame.Damage.Misc:SetPoint("TOP",theFrame.Damage.Focus,"BOTTOM",0,0)

	ReRecount.Colors:RegisterTexture("Other Windows","Title",Graph:DrawLine(theFrame,150+(50/3),290+26,150+(50/3),186+26,24,{0.5,0.0,0.0,1.0},"ARTWORK"),{r=0.5,g=0.5,b=0.5,a=1})

	--Pet Damage
	theFrame.Pet=CreateFrame("Frame",nil,theFrame)
	theFrame.Pet:SetHeight(105)
	theFrame.Pet:SetWidth(150+(50/3))
	theFrame.Pet:SetPoint("LEFT",theFrame.Damage,"RIGHT")
	theFrame.Pet:SetFrameLevel(theFrame:GetFrameLevel())
	theFrame.Pet.Report=me.ReportSummarySet

	theFrame.Pet.SelectMe=me.SelectSummaryItem
	theFrame.Pet:EnableMouse()
	theFrame.Pet:SetScript("OnMouseDown",function()
							ReRecount.DetailWindow.SummaryMode.CurrentPet = ReRecount.DetailWindow.SummaryMode.CurrentPet +1
							ReRecount:UpdateSummaryMode(ReRecount.MainWindow.Selected)
							theFrame.Pet.SelectMe(theFrame.Pet) end)

	theFrame.Pet.Selected=theFrame.Damage:CreateTexture(nil,"BACKGROUND")
	theFrame.Pet.Selected:SetTexture(1.0,0.0,0,0.1)
	--ReRecount.Colors:RegisterTexture("Window","Title",theFrame.Pet.Selected)
	theFrame.Pet.Selected:SetAllPoints(theFrame.Pet)
	theFrame.Pet.Selected:Hide()

	theFrame.Pet.Title=me:CreateDataItem(theFrame,L["Pet Damage"]..":",L["No Pet"],"GameFontNormal")
	theFrame.Pet.Title:SetPoint("TOPLEFT",theFrame.Pet,"TOPLEFT",0,0)
	theFrame.Pet.Total=me:CreateDataItem(theFrame.Pet,L["Total"]..":",0)
	theFrame.Pet.Total:SetPoint("TOP",theFrame.Pet.Title,"BOTTOM",0,0)
	theFrame.Pet.PerSec=me:CreateDataItem(theFrame.Pet,L["DPS"]..":",0)
	theFrame.Pet.PerSec:SetPoint("TOP",theFrame.Pet.Total,"BOTTOM",0,0)	
	theFrame.Pet.Taken=me:CreateDataItem(theFrame.Pet,L["Taken"]..":",0)
	theFrame.Pet.Taken:SetPoint("TOP",theFrame.Pet.PerSec,"BOTTOM",0,0)
	theFrame.Pet.Time=me:CreateDataItem(theFrame.Pet,L["Pet Time"]..":",0)
	theFrame.Pet.Time:SetPoint("TOP",theFrame.Pet.Taken,"BOTTOM",0,0)
	theFrame.Pet.Focus=me:CreateDataItem(theFrame.Pet,L["Pet Focus"]..":",0)
	theFrame.Pet.Focus:SetPoint("TOP",theFrame.Pet.Time,"BOTTOM",0,0)
	theFrame.Pet.Page=theFrame.Pet:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Pet.Page:SetText("")
	theFrame.Pet.Page:SetPoint("TOP",theFrame.Pet.Focus,"BOTTOM",0,0)
	ReRecount:AddFontString(theFrame.Pet.Page)

	ReRecount.Colors:RegisterTexture("Other Windows","Title",Graph:DrawLine(theFrame,300+(50*2/3),290+26,300+(50*2/3),186+26,24,{0.5,0.0,0.0,1.0},"ARTWORK"),{r=0.5,g=0.5,b=0.5,a=1})

	--Healing Line
	theFrame.Healing=CreateFrame("Frame",nil,theFrame)
	theFrame.Healing:SetHeight(105)
	theFrame.Healing:SetWidth(149+(50/3))
	theFrame.Healing:SetPoint("LEFT",theFrame.Pet,"RIGHT")
	theFrame.Healing:SetFrameLevel(theFrame:GetFrameLevel())
	theFrame.Healing.Report=me.ReportSummarySet

	theFrame.Healing.SelectMe=me.SelectSummaryItem
	theFrame.Healing:EnableMouse()
	theFrame.Healing:SetScript("OnMouseDown",theFrame.Healing.SelectMe)

	theFrame.Healing.Selected=theFrame.Damage:CreateTexture(nil,"BACKGROUND")
	theFrame.Healing.Selected:SetTexture(1.0,0.0,0,0.1)
	theFrame.Healing.Selected:SetAllPoints(theFrame.Healing)
	theFrame.Healing.Selected:Hide()

	theFrame.Healing.Title=me:CreateTitle(theFrame,L["Healing"],"GameFontNormal")
	theFrame.Healing.Title:SetPoint("TOPLEFT",theFrame.Healing,"TOPLEFT",0,0)
	theFrame.Healing.Total=me:CreateDataItem(theFrame.Healing,L["Total"]..":",0)
	theFrame.Healing.Total:SetPoint("TOP",theFrame.Healing.Title,"BOTTOM",0,0)
	theFrame.Healing.Overhealing=me:CreateDataItem(theFrame.Healing,L["Overhealing"]..":",0)
	theFrame.Healing.Overhealing:SetPoint("TOP",theFrame.Healing.Total,"BOTTOM",0,0)	
	theFrame.Healing.Taken=me:CreateDataItem(theFrame.Healing,L["Taken"]..":",0)
	theFrame.Healing.Taken:SetPoint("TOP",theFrame.Healing.Overhealing,"BOTTOM",0,0)
	theFrame.Healing.Time=me:CreateDataItem(theFrame.Healing,L["Time"]..":",0)
	theFrame.Healing.Time:SetPoint("TOP",theFrame.Healing.Taken,"BOTTOM",0,0)
	theFrame.Healing.Focus=me:CreateDataItem(theFrame.Healing,L["Heal Focus"]..":",0)
	theFrame.Healing.Focus:SetPoint("TOP",theFrame.Healing.Time,"BOTTOM",0,0)
	theFrame.Healing.Misc=me:CreateDataItem(theFrame.Healing,L["Avg. HOTs Up"]..":",0)
	theFrame.Healing.Misc:SetPoint("TOP",theFrame.Healing.Focus,"BOTTOM",0,0)

	ReRecount.Colors:RegisterTexture("Other Windows","Title",Graph:DrawLine(theFrame,1,186+26,449+50,186+26,24,{0.5,0.0,0.0,1.0},"ARTWORK"),{r=0.5,g=0.5,b=0.5,a=1})
	
	theFrame.DamageMode=true
	theFrame.CurrentPet=1

	--Frame for switching between done/taken
	theFrame.AttackSummary=CreateFrame("Frame",nil,theFrame)
	local AttackSummary=theFrame.AttackSummary

	AttackSummary:SetWidth(270+50)
	AttackSummary:SetHeight(20)
	AttackSummary:SetPoint("TOP",theFrame,"TOP",0,-106)
	
	AttackSummary.Background=AttackSummary:CreateTexture(nil,"BACKGROUND")
	AttackSummary.Background:SetAllPoints(AttackSummary)
	AttackSummary.Background:SetTexture(0,0,0,0.3)

	AttackSummary.Text=AttackSummary:CreateFontString(nil,"OVERLAY","GameFontNormal")
	AttackSummary.Text:SetText(L["Attack Summary Outgoing (Click for Incoming)"])
	AttackSummary.Text:SetPoint("CENTER",AttackSummary,"CENTER")
	ReRecount:AddFontString(AttackSummary.Text)

	AttackSummary:EnableMouse()
	AttackSummary:SetScript("OnMouseDown", function()
							ReRecount.DetailWindow.SummaryMode.DamageMode=not ReRecount.DetailWindow.SummaryMode.DamageMode

							if ReRecount.DetailWindow.SummaryMode.DamageMode then
								AttackSummary.Text:SetText(L["Attack Summary Outgoing (Click for Incoming)"])								
							else
								AttackSummary.Text:SetText(L["Attack Summary Incoming (Click for Outgoing)"])
							end
							ReRecount:UpdateSummaryMode(ReRecount.MainWindow.Selected)
						end)

	theFrame:Hide()
end

function me:CalculateFocus(t)
	local Total=0
	local Focus,Temp
	Focus=0

	if t then
		for _,v in pairs(t) do
			Total=Total+v.amount
		end
		for _,v in pairs(t) do
			Temp=v.amount/Total
			Focus=Focus+Temp*Temp
		end
	end
	
	return math.floor(10/Focus+0.5)/10, math.floor(Focus*100+0.5)
end

function ReRecount:UpdateSummaryMode(name)
	local Num, Focus
	local data=ReRecount.db2.combatants[name]
	ReRecount.DetailWindow.SummaryTitle=L["Summary Report for"].." "..name
	ReRecount.DetailWindow.Showing=name

	if ReRecount.DetailWindow.SummaryEnabled then
		ReRecount.DetailWindow.Title:SetText(ReRecount.DetailWindow.SummaryTitle)
	end

	local data2 = data.Fights[ReRecount.db.profile.CurDataSet]

	local timedamage = data2.TimeDamage or 0
	local TotalTime=(data2.TimeHeal or 0)+(timedamage or 0)+Epsilon
	local theFrame=ReRecount.DetailWindow.SummaryMode

	local damage = data2.Damage or 0
	local activetime = (data2.ActiveTime or 0)+Epsilon
	local damagetake = data2.DamageTaken or 0
	local dot_time = data2.DOT_Time or 0
	theFrame.Damage.Total:SetValue(damage)
	theFrame.Damage.Taken:SetValue(damagetaken)
	theFrame.Damage.PerSec:SetValue((math.floor(10*damage/(activetime)+0.5)/10))	
	theFrame.Damage.Time:SetValue(timedamage.."s ("..math.floor(100*timedamage/TotalTime+0.5).."%)")
	theFrame.Damage.Misc:SetValue(math.floor(10*dot_time/(activetime)+0.5)/10)

	--Set Pet Data
	if data.Pet and #data.Pet>0 then
		if ReRecount.DetailWindow.SummaryMode.CurrentPet > #data.Pet then ReRecount.DetailWindow.SummaryMode.CurrentPet = 1 end
		--if not ReRecount.db2.combatants[data.Pet[ReRecount.DetailWindow.SummaryMode.CurrentPet] ] then
		--	ReRecount:Print("uninitialized Pet: "..data.Pet[ReRecount.DetailWindow.SummaryMode.CurrentPet].." "..#data.Pet.." please report")
		--end
		while not ReRecount.db2.combatants[data.Pet[ReRecount.DetailWindow.SummaryMode.CurrentPet] ]  and #data.Pet > 0 do
			for k,v in pairs(data.Pet) do
				if v == data.Pet[ReRecount.DetailWindow.SummaryMode.CurrentPet] then
					--ReRecount:Print("removed: "..v)
					table.remove(data.Pet,k) -- Elsia: Remove deleted pet
				--else
					--ReRecount:Print("eek")
				end
			end
			ReRecount.DetailWindow.SummaryMode.CurrentPet = ReRecount.DetailWindow.SummaryMode.CurrentPet +1
			if ReRecount.DetailWindow.SummaryMode.CurrentPet > #data.Pet then ReRecount.DetailWindow.SummaryMode.CurrentPet = 1 end
		end
	end
	
	if data.Pet and #data.Pet > 0 then
		local currentPet = ReRecount.DetailWindow.SummaryMode.CurrentPet
		local pet=ReRecount.db2.combatants[data.Pet[currentPet] ]
		theFrame.Pet.Title:SetValue(pet.Name)
		local petdata2 = pet.Fights[ReRecount.db.profile.CurDataSet]
		local petdamage = petdata2 and petdata2.Damage or 0
		local petdamagetaken = petdata2 and petdata2.DamageTaken or 0
		local petactivetime = (petdata2 and petdata2.ActiveTime or 0)+Epsilon
		local pettimedamage = petdata2 and petdata2.TimeDamage or 0
		local pettimedamaging = petdata2 and petdata2.TimeDamaging
		theFrame.Pet.Total:SetValue(petdamage.." ("..math.floor(100*petdamage/(petdamage+damage+Epsilon)+0.5).."%)")
		theFrame.Pet.Taken:SetValue(petdamagetaken)
		theFrame.Pet.PerSec:SetValue((math.floor(10*petdamage/petactivetime+0.5)/10))
		theFrame.Pet.Time:SetValue(pettimedamage)
		Num, Focus = me:CalculateFocus(pettimedamaging)
		theFrame.Pet.Focus:SetValue(Num.." ("..Focus.."%)")

		if #data.Pet > 1 then
			theFrame.Pet.Page:SetText(L["Click for next Pet"])
		else
			theFrame.Pet.Page:SetText(" ")
		end
	else
		theFrame.Pet.Title:SetValue(L["No Pet"])
		theFrame.Pet.Total:SetValue("0")
		theFrame.Pet.PerSec:SetValue("0")
		theFrame.Pet.Taken:SetValue("0")
		theFrame.Pet.Time:SetValue("0")
		theFrame.Pet.Focus:SetValue("0")
		theFrame.Pet.Page:SetText(" ")
	end

	local healing = data2.Healing or 0
	local overhealing = data2.Overhealing or 0
	local healingtaken = data2.HealingTaken or 0
	local timeheal = data2.TimeHeal or 0
	local hot_time = data2.HOT_Time or 0
	
	theFrame.Healing.Total:SetValue(healing.." ("..(math.floor(10*healing/(activetime)+0.5)/10)..")")
	theFrame.Healing.Taken:SetValue(healingtaken)
	theFrame.Healing.Overhealing:SetValue(overhealing.." ("..(math.floor(1000*overhealing/(overhealing+healing+Epsilon)+0.5)/10).."%)")
	theFrame.Healing.Time:SetValue(timeheal.."s ("..math.floor(100*timeheal/TotalTime+0.5).."%)")
	theFrame.Healing.Misc:SetValue(math.floor(10*hot_time/(activetime)+0.5)/10)

	

	local timedamaging = data2.TimeDamaging

	Num, Focus = me:CalculateFocus(timedamaging)
	theFrame.Damage.Focus:SetValue(Num.." ("..Focus.."%)")

	local timehealing = data2.TimeHealing
	
	Num, Focus = me:CalculateFocus(timehealing)
	theFrame.Healing.Focus:SetValue(Num.." ("..Focus.."%)")
	

	theFrame.Name=name
	if theFrame.DamageMode then
		me:LoadSummaryData(data2.ElementDone,data2.ElementDoneResist,data2.ElementHitsDone,data2.ElementDoneBlock,data2.ElementDoneAbsorb)
	else
		me:LoadSummaryData(data2.ElementTaken,data2.ElementTakenResist,data2.ElementHitsTaken,data2.ElementTakenBlock,data2.ElementTakenAbsorb)
	end
end


--Create Detail Window Function
function ReRecount:CreateDetailWindow()
	ReRecount.DetailWindow=CreateFrame("Frame","ReRecount_DetailWindow",UIParent)

	local theFrame=ReRecount.DetailWindow

	theFrame:ClearAllPoints()
	theFrame:SetPoint("CENTER",UIParent)
	theFrame:SetHeight(320+26)
	theFrame:SetWidth(450+50)
	theFrame:SetFrameLevel(ReRecount.MainWindow:GetFrameLevel()+10)

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
						  local point,relativeTo,relativePoint,xOfs,yOfs = this:GetPoint(1)
						  ReRecount.db.profile.DetailWindowX=xOfs
						  ReRecount.db.profile.DetailWindowY=yOfs
						  this:StopMovingOrSizing();
						  this.isMoving = false;
						 end
						end)
	theFrame:SetScript("OnShow", function()
						ReRecount:SetWindowTop(this)
						end)
					
	theFrame:SetScript("OnHide", function()
						if ( this.isMoving ) then
						  local point,relativeTo,relativePoint,xOfs,yOfs = this:GetPoint(1)
						  ReRecount.db.profile.DetailWindowX=xOfs
						  ReRecount.db.profile.DetailWindowY=yOfs
						  this:StopMovingOrSizing();
						  this.isMoving = false;
						 end
						end)

	theFrame.Title=theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
	theFrame.Title:SetPoint("TOPLEFT",theFrame,"TOPLEFT",6,-15)
	theFrame.Title:SetTextColor(1.0,1.0,1.0,1.0)
	theFrame.Title:SetText(L["Detail Window"].." - Hostile Abilites")
	ReRecount:AddFontString(theFrame.Title)

--	ReRecount.Colors:UnregisterItem(ReRecount.DetailWindow.Title)
	ReRecount.Colors:RegisterFont("Other Windows","Title Text",ReRecount.DetailWindow.Title)

	
	theFrame.CloseButton=CreateFrame("Button",nil,theFrame)
	theFrame.CloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up.blp")
	theFrame.CloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down.blp")
	theFrame.CloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	theFrame.CloseButton:SetWidth(20)
	theFrame.CloseButton:SetHeight(20)
	theFrame.CloseButton:SetPoint("TOPRIGHT",theFrame,"TOPRIGHT",-4,-12)
	theFrame.CloseButton:SetScript("OnClick",function() this:GetParent():Hide() end)

	theFrame.LeftButton=CreateFrame("Button",nil,theFrame)
	theFrame.LeftButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up.blp")
	theFrame.LeftButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down.blp")
	theFrame.LeftButton:SetWidth(16)
	theFrame.LeftButton:SetHeight(18)
	theFrame.LeftButton:SetPoint("TOPRIGHT",theFrame,"TOPRIGHT",-40,-12)
	theFrame.LeftButton:SetScript("OnClick",function() ReRecount:DetailWindowPrevMode() end)

	theFrame.RightButton=CreateFrame("Button",nil,theFrame)
	theFrame.RightButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up.blp")
	theFrame.RightButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down.blp")	
	theFrame.RightButton:SetWidth(16)
	theFrame.RightButton:SetHeight(18)
	theFrame.RightButton:SetPoint("LEFT",theFrame.LeftButton,"RIGHT",1,0)
	theFrame.RightButton:SetScript("OnClick",function() ReRecount:DetailWindowNextMode() end)

	theFrame.ReportButton=CreateFrame("Button",nil,theFrame)
	theFrame.ReportButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up.blp")
	theFrame.ReportButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	theFrame.ReportButton:SetWidth(16)
	theFrame.ReportButton:SetHeight(16)
	theFrame.ReportButton:SetPoint("RIGHT",theFrame.LeftButton,"LEFT",-2,0)
	theFrame.ReportButton:SetScript("OnClick",function() ReRecount:ShowReport("Detail",ReRecount.ReportDetail) end)

	theFrame.SummaryButton=CreateFrame("Button",nil,theFrame)
	theFrame.SummaryButton:SetNormalTexture("Interface\\Addons\\ReRecount\\Textures\\icon-summary")
	theFrame.SummaryButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	theFrame.SummaryButton:SetWidth(16)
	theFrame.SummaryButton:SetHeight(16)
	theFrame.SummaryButton:SetPoint("RIGHT",theFrame.ReportButton,"LEFT",-2,0)
	theFrame.SummaryButton:SetScript("OnClick",function() 
								ReRecount.DetailWindow.SummaryEnabled= not ReRecount.DetailWindow.SummaryEnabled
								if ReRecount.DetailWindow.SummaryEnabled then
									me:HideDetailModes()
									ReRecount.DetailWindow.Title:SetText(ReRecount.DetailWindow.SummaryTitle)
									ReRecount.DetailWindow.SummaryMode:Show()
								else
									me:HideDetailModes()
									ReRecount.DetailWindow.Title:SetText(ReRecount.DetailWindow.CurTitle)
									ReRecount.DetailWindow.CurMode:Show()
								end end)
	

	theFrame.PieMode=CreateFrame("Frame","ReRecount_DetailWindow_PieDetails",theFrame)
	local PieMode=theFrame.PieMode

	PieMode:ClearAllPoints()
	PieMode:SetPoint("BOTTOM",theFrame)
	PieMode:SetHeight(320-32+26)
	PieMode:SetWidth(450+50)

	PieMode.TopPieChart=Graph:CreateGraphPieChart("ReRecount_DetailWindow_TopPieChart",PieMode,"LEFT","LEFT",0,72.5,150,150)--56.5,150,150)
	PieMode.BotPieChart=Graph:CreateGraphPieChart("ReRecount_DetailWindow_BotPieChart",PieMode,"LEFT","LEFT",0,-72.5,150,150)---88,150,150)

	PieMode.TopPieChart:SetSelectionFunc(ReRecount.SelectUpperDetailTablePie)
	PieMode.BotPieChart:SetSelectionFunc(me.SelectLowerDetailTable)
	
	PieMode.TopRowLabels=CreateFrame("FRAME",nil,PieMode)
	local Labels=PieMode.TopRowLabels

	Labels:SetPoint("TOPLEFT",PieMode,"TOP",-70-25,0)
	Labels:SetWidth(270+50)
	Labels:SetHeight(RowHeight)

	Labels.Key=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Key:SetPoint("LEFT",Labels,"LEFT",2,0)
	Labels.Key:SetText("K")
	ReRecount:AddFontString(Labels.Key)

	Labels.Count=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Count:SetPoint("LEFT",Labels,"LEFT",16,0)
	Labels.Count:SetText("#")
	ReRecount:AddFontString(Labels.Count)

	Labels.Name=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Name:SetPoint("LEFT",Labels,"LEFT",30,0)
	Labels.Name:SetText(L["Name of Ability"])
	ReRecount:AddFontString(Labels.Name)

	Labels.ACount=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.ACount:SetPoint("RIGHT",Labels,"RIGHT",-120,0)
	Labels.ACount:SetText(L["Count"])
	ReRecount:AddFontString(Labels.ACount)

	Labels.Amount=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Amount:SetPoint("RIGHT",Labels,"RIGHT",-50,0)
	Labels.Amount:SetText(L["Damage"])
	ReRecount:AddFontString(Labels.Amount)

	Labels.Percent=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Percent:SetPoint("RIGHT",Labels,"RIGHT",4,0)
	Labels.Percent:SetText("%")
	ReRecount:AddFontString(Labels.Percent)

	PieMode.TopRows={}
	
	for i=1,8 do
		local Row=CreateFrame("FRAME",nil,PieMode)

		Row.id=i
		Row:EnableMouse(true)
		Row:SetScript("OnEnter", function() ReRecount:SelectUpperDetailTable(this.id) end)
		Row:SetScript("OnMouseDown", function() ReRecount:LockUpperDetailTable(this.id) end)

		Row:SetWidth(270+50)
		Row:SetHeight(RowHeight)
		Row:SetPoint("TOPLEFT",PieMode,"TOP",-70-25,-(RowHeight+2)*i)

		Row.Background=Row:CreateTexture(nil,"BACKGROUND")
		Row.Background:SetAllPoints(Row)
		Row.Background:SetTexture("Interface\\Buttons\\WHITE8X8.blp")
		Row.Background:Hide()

		Row.Key=Row:CreateTexture(nil,"OVERLAY")
		Row.Key:SetPoint("LEFT",Row,"LEFT",0,0)
		Row.Key:SetTexture("Interface\\Buttons\\WHITE8X8.blp")
		Row.Key:SetWidth(RowHeight)
		Row.Key:SetHeight(RowHeight)

		Row.Selected=Row:CreateTexture(nil,"OVERLAY")
		Row.Selected:SetPoint("RIGHT",Row,"LEFT",0,0)
		Row.Selected:SetTexture("Interface\\Addons\\ReRecount\\Textures\\arrow.tga")
		Row.Selected:SetWidth(RowHeight)
		Row.Selected:SetHeight(RowHeight)
		Row.Selected:Hide()


		Row.Count=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Count:SetPoint("LEFT",Row.Key,"LEFT",16,0)
		Row.Count:SetText(i)
		Row.Count:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Count)
		
		Row.Name=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Name:SetPoint("LEFT",Row,"LEFT",30,0)
		Row.Name:SetText("Test")
		Row.Name:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Name)

		Row.ACount=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.ACount:SetPoint("RIGHT",Row,"RIGHT",-120,0)
		Row.ACount:SetText("815")
		Row.ACount:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.ACount)

		Row.Amount=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Amount:SetPoint("RIGHT",Row,"RIGHT",-50,0)
		Row.Amount:SetText("12345")
		Row.Amount:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Amount)

		Row.Percent=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Percent:SetPoint("RIGHT",Row,"RIGHT",4,0)
		Row.Percent:SetText("10%")
		Row.Percent:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Percent)


		PieMode.TopRows[i]=Row
	end

	PieMode.ScrollBar1=CreateFrame("SCROLLFRAME","ReRecount_PieMode_Scrollbar2",PieMode,"FauxScrollFrameTemplate")
	PieMode.ScrollBar1:SetScript("OnVerticalScroll", function() FauxScrollFrame_OnVerticalScroll(12, me.RefreshUpperDetails) end)
	PieMode.ScrollBar1:SetPoint("TOPLEFT",PieMode.TopRows[1],"TOPLEFT")	
	PieMode.ScrollBar1:SetPoint("BOTTOMRIGHT",PieMode.TopRows[8],"BOTTOMRIGHT")
	ReRecount:SetupScrollbar("ReRecount_PieMode_Scrollbar2")

	local Halfway=(PieMode:GetHeight())/2
	ReRecount.Colors:RegisterTexture("Other Windows","Title",Graph:DrawLine(PieMode,2,Halfway,PieMode:GetWidth()-2,Halfway,24,{0.6,0.0,0.0,1.0},"ARTWORK"),{r=0.5,g=0.5,b=0.5,a=1})


	PieMode.BotRowLabels=CreateFrame("FRAME",nil,PieMode)
	local Labels=PieMode.BotRowLabels

	Labels:SetPoint("TOPLEFT",PieMode,"TOP",-70-25,-Halfway) -- This is 50/2, the added width of the bars in the view.
	Labels:SetWidth(270+50)
	Labels:SetHeight(RowHeight)

	Labels.Key=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Key:SetPoint("LEFT",Labels,"LEFT",2,0)
	Labels.Key:SetText("K")
	ReRecount:AddFontString(Labels.Key)

	Labels.Pos=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Pos:SetPoint("LEFT",Labels,"LEFT",16,0)
	Labels.Pos:SetText("#")
	ReRecount:AddFontString(Labels.Pos)

	Labels.Name=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Name:SetPoint("LEFT",Labels,"LEFT",30,0)
	Labels.Name:SetText(L["Type"])
	ReRecount:AddFontString(Labels.Name)

	Labels.Min=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Min:SetPoint("RIGHT",Labels,"RIGHT",-185,0)
	Labels.Min:SetText(L["Min"])
	ReRecount:AddFontString(Labels.Min)

	Labels.Avg=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Avg:SetPoint("RIGHT",Labels,"RIGHT",-140,0)
	Labels.Avg:SetText(L["Avg"])
	ReRecount:AddFontString(Labels.Avg)

	Labels.Max=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Max:SetPoint("RIGHT",Labels,"RIGHT",-95,0)
	Labels.Max:SetText(L["Max"])
	ReRecount:AddFontString(Labels.Max)

	Labels.Count=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Count:SetPoint("RIGHT",Labels,"RIGHT",-50,0)
	Labels.Count:SetText(L["Count"])
	ReRecount:AddFontString(Labels.Count)

	Labels.Percent=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Percent:SetPoint("RIGHT",Labels,"RIGHT",4,0)
	Labels.Percent:SetText("%")
	ReRecount:AddFontString(Labels.Percent)

	PieMode.BotRows={}
	
	for i=1,8 do
		local Row=CreateFrame("FRAME",nil,PieMode)

		Row.id=i
		Row:EnableMouse(true)
		Row:SetScript("OnEnter", function() me:SelectLowerDetailTable(this.id) end)

		Row:SetWidth(270+50)
		Row:SetHeight(RowHeight)
		Row:SetPoint("TOPLEFT",PieMode,"TOP",-70-25,-Halfway-(RowHeight+2)*i)

		Row.Background=Row:CreateTexture(nil,"BACKGROUND")
		Row.Background:SetAllPoints(Row)
		Row.Background:SetTexture("Interface\\Buttons\\WHITE8X8.blp")
		Row.Background:Hide()

		Row.Key=Row:CreateTexture(nil,"OVERLAY")
		Row.Key:SetPoint("LEFT",Row,"LEFT",0,0)
		Row.Key:SetTexture("Interface\\Buttons\\WHITE8X8.blp")
		Row.Key:SetWidth(12)
		Row.Key:SetHeight(12)

		Row.Pos=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Pos:SetPoint("LEFT",Row.Key,"LEFT",16,0)
		Row.Pos:SetText(i)
		Row.Pos:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Pos)
		
		Row.Name=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Name:SetPoint("LEFT",Row,"LEFT",30,0)
		Row.Name:SetText("Test")
		Row.Name:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Name)

		Row.Min=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Min:SetPoint("RIGHT",Row,"RIGHT",-185,0)
		Row.Min:SetText("32")
		Row.Min:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Min)

		Row.Avg=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Avg:SetPoint("RIGHT",Row,"RIGHT",-140,0)
		Row.Avg:SetText("32")
		Row.Avg:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Avg)

		Row.Max=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Max:SetPoint("RIGHT",Row,"RIGHT",-95,0)
		Row.Max:SetText("32")
		Row.Max:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Max)

		Row.Count=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Count:SetPoint("RIGHT",Row,"RIGHT",-50,0)
		Row.Count:SetText("32")
		Row.Count:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Count)

		Row.Percent=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Percent:SetPoint("RIGHT",Row,"RIGHT",4,0)
		Row.Percent:SetText("10%")
		Row.Percent:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Percent)


		PieMode.BotRows[i]=Row
	end

	theFrame.DeathMode=CreateFrame("FRAME","ReRecount_DetailWindow_DeathMode",theFrame)
	local DeathMode=theFrame.DeathMode

	DeathMode:ClearAllPoints()
	DeathMode:SetPoint("BOTTOM",theFrame)
	DeathMode:SetHeight(320-32+26)
	DeathMode:SetWidth(450+50)

	DeathMode.DeathLabels=CreateFrame("FRAME",nil,DeathMode)
	local Labels=DeathMode.DeathLabels

	Labels:SetPoint("TOPLEFT",DeathMode,"TOPLEFT",2,0)
	Labels:SetWidth(150+25-10)
	Labels:SetHeight(RowHeight)

	Labels.Times=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Times:SetPoint("LEFT",Labels,"LEFT",0,0)
	Labels.Times:SetText(L["Time"])
	ReRecount:AddFontString(Labels.Times)

	Labels.Who=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Who:SetPoint("RIGHT",Labels,"RIGHT",-10,0)
	Labels.Who:SetText(L["Killed By"])
	ReRecount:AddFontString(Labels.Who)

	DeathMode.Deaths={}


	
	for i=1,17 do
		local Row=CreateFrame("FRAME",nil,DeathMode)

		Row.id=i
		Row:EnableMouse(true)
		Row:SetScript("OnEnter", function() Row.Highlighted:Show() end)
		Row:SetScript("OnLeave",function() Row.Highlighted:Hide() end)
		Row:SetScript("OnMouseDown",function() ReRecount:SetDeathLogDetails(this.id) end)

		Row:SetWidth(125+25+25-10)
		Row:SetHeight(RowHeight)
		Row:SetPoint("TOPLEFT",DeathMode,"TOPLEFT",2,-(RowHeight+2)*i)

		Row.Selected=Row:CreateTexture(nil,"BACKGROUND")
		Row.Selected:SetAllPoints(Row)
		Row.Selected:SetTexture(1,1,0,0.3)
		Row.Selected:Hide()

		Row.Highlighted=Row:CreateTexture(nil,"BACKGROUND")
		Row.Highlighted:SetAllPoints(Row)
		Row.Highlighted:SetTexture(1,0,0,0.3)
		Row.Highlighted:Hide()

		Row.Time=Row:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
		Row.Time:SetPoint("LEFT",Row,"LEFT",0,0)
		Row.Time:SetText(i)
		Row.Time:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Time)
		
		Row.Who=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")
		Row.Who:SetPoint("RIGHT",Row,"RIGHT",-10,0)
		Row.Who:SetText("Test")
		Row.Who:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Who)

		DeathMode.Deaths[i]=Row
	end

	DeathMode.ScrollBar1=CreateFrame("SCROLLFRAME",DeathMode:GetName().."_Scrollbar1",DeathMode,"FauxScrollFrameTemplate")
	DeathMode.ScrollBar1:SetScript("OnVerticalScroll", function() FauxScrollFrame_OnVerticalScroll(17, me.RefreshDeathDetails) end)
	DeathMode.ScrollBar1:SetPoint("TOPLEFT",DeathMode.Deaths[1],"TOPLEFT")	
	DeathMode.ScrollBar1:SetPoint("BOTTOMRIGHT",DeathMode.Deaths[17],"BOTTOMRIGHT",-1,0)

	DeathMode.DeathLogLabels=CreateFrame("FRAME",nil,DeathMode)
	local Labels=DeathMode.DeathLogLabels

	Labels:SetPoint("TOPRIGHT",DeathMode,"TOPRIGHT",0,0)
	Labels:SetWidth(300+25-10)
	Labels:SetHeight(RowHeight)

	Labels.Times=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Times:SetPoint("LEFT",Labels,"LEFT",3,-1)
	Labels.Times:SetText(L["Time"])
	ReRecount:AddFontString(Labels.Times)

	Labels.Who=Labels:CreateFontString(nil,"OVERLAY","GameFontNormal")
	Labels.Who:SetPoint("LEFT",Labels,"LEFT",40+20,-1)
	Labels.Who:SetText(L["Combat Messages"])
	ReRecount:AddFontString(Labels.Who)

	DeathMode.DeathLog={}

	for i=1,20 do
		local Row=CreateFrame("FRAME",nil,DeathMode)

		Row.id=i

		Row:SetWidth(270+25-10)
		Row:SetHeight(13)
		Row:SetPoint("TOPRIGHT",DeathMode,"TOPRIGHT",-25,-14-13*(i-1))

		Row.Background=Row:CreateTexture(nil,"BACKGROUND")
		Row.Background:SetAllPoints(Row)
		Row.Background:SetTexture(1,1,1,0.25)
		Row.Background:Show()

		Row.Time=Row:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
		Row.Time:SetPoint("LEFT",Row,"LEFT",3,0)
		Row.Time:SetText(i)
		Row.Time:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Time)
		
		Row.Msg=Row:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
		Row.Msg:SetPoint("LEFT",Row,"LEFT",40,0)
		Row.Msg:SetText("Test")
		Row.Msg:SetTextColor(1.0,1.0,1.0,1.0)
		ReRecount:AddFontString(Row.Msg)

		Row:Hide()

		DeathMode.DeathLog[i]=Row
	end
	
	ReRecount.Colors:RegisterTexture("Other Windows","Title",Graph:DrawLine(DeathMode,150+25,1,150+25,DeathMode:GetHeight()+1+13,24,{0.5,0.0,0.0,1.0},"ARTWORK"),{r=0.5,g=0.5,b=0.5,a=1})

	DeathMode.ScrollBar2=CreateFrame("SCROLLFRAME",DeathMode:GetName().."_Scrollbar2",DeathMode,"FauxScrollFrameTemplate")
	DeathMode.ScrollBar2:SetScript("OnVerticalScroll", function() FauxScrollFrame_OnVerticalScroll(12, me.RefreshDeathLogDetails) end)
	DeathMode.ScrollBar2:SetPoint("TOPLEFT",DeathMode.DeathLog[1],"TOPLEFT")	
	DeathMode.ScrollBar2:SetPoint("BOTTOMRIGHT",DeathMode.DeathLog[20],"BOTTOMRIGHT")


	DeathMode.Damage=CreateFrame("CheckButton",nil,DeathMode)
	me:ConfigureDeathCheckbox(DeathMode.Damage)
	DeathMode.Damage:SetPoint("TOPLEFT",DeathMode.DeathLog[20],"BOTTOMLEFT",0,-4)

	DeathMode.DamageText=DeathMode:CreateFontString(nil,"OVERLAY","GameFontNormal")
	DeathMode.DamageText:SetText(L["Damage"])
	DeathMode.DamageText:SetPoint("LEFT",DeathMode.Damage,"RIGHT",2,0)
	ReRecount:AddFontString(DeathMode.DamageText)

	DeathMode.Heal=CreateFrame("CheckButton",nil,DeathMode)
	me:ConfigureDeathCheckbox(DeathMode.Heal)
	DeathMode.Heal:SetPoint("LEFT",DeathMode.Damage,"LEFT",75,0)

	DeathMode.HealText=DeathMode:CreateFontString(nil,"OVERLAY","GameFontNormal")
	DeathMode.HealText:SetText(L["Heals"])
	DeathMode.HealText:SetPoint("LEFT",DeathMode.Heal,"RIGHT",2,0)
	ReRecount:AddFontString(DeathMode.HealText)

	DeathMode.Misc=CreateFrame("CheckButton",nil,DeathMode)
	me:ConfigureDeathCheckbox(DeathMode.Misc)
	DeathMode.Misc:SetPoint("LEFT",DeathMode.Heal,"LEFT",60,0)

	DeathMode.MiscText=DeathMode:CreateFontString(nil,"OVERLAY","GameFontNormal")
	DeathMode.MiscText:SetText(L["Misc"])
	DeathMode.MiscText:SetPoint("LEFT",DeathMode.Misc,"RIGHT",2,0)
	ReRecount:AddFontString(DeathMode.MiscText)

	DeathMode.Incoming=CreateFrame("CheckButton",nil,DeathMode)
	me:ConfigureDeathCheckbox(DeathMode.Incoming)
	DeathMode.Incoming:SetPoint("TOPLEFT",DeathMode.DeathLog[20],"BOTTOMLEFT",0,-20)

	DeathMode.IncomingText=DeathMode:CreateFontString(nil,"OVERLAY","GameFontNormal")
	DeathMode.IncomingText:SetText(L["Incoming"])
	DeathMode.IncomingText:SetPoint("LEFT",DeathMode.Incoming,"RIGHT",2,0)
	ReRecount:AddFontString(DeathMode.IncomingText)

	DeathMode.Outgoing=CreateFrame("CheckButton",nil,DeathMode)
	me:ConfigureDeathCheckbox(DeathMode.Outgoing)
	DeathMode.Outgoing:SetPoint("LEFT",DeathMode.Incoming,"LEFT",80,0)

	DeathMode.OutgoingText=DeathMode:CreateFontString(nil,"OVERLAY","GameFontNormal")
	DeathMode.OutgoingText:SetText(L["Outgoing"])
	DeathMode.OutgoingText:SetPoint("LEFT",DeathMode.Outgoing,"RIGHT",2,0)
	ReRecount:AddFontString(DeathMode.OutgoingText)

	DeathMode.ShowDeathGraph=CreateFrame("Button",nil,DeathMode,"OptionsButtonTemplate")
	DeathMode.ShowDeathGraph:SetWidth(110)
	DeathMode.ShowDeathGraph:SetHeight(24)
	DeathMode.ShowDeathGraph:SetPoint("BOTTOMRIGHT",DeathMode,"BOTTOMRIGHT",-4,4)
	DeathMode.ShowDeathGraph:SetScript("OnClick",function() me:ShowDeathGraph() end)
	DeathMode.ShowDeathGraph:SetText(L["Show Graph"])


	ReRecount.DetailWindow.DeathMode.Damage:SetChecked(ReRecount.db.profile.FilterDeathType.DAMAGE)
	ReRecount.DetailWindow.DeathMode.Heal:SetChecked(ReRecount.db.profile.FilterDeathType.HEAL)
	ReRecount.DetailWindow.DeathMode.Misc:SetChecked(ReRecount.db.profile.FilterDeathType.MISC)
	ReRecount.DetailWindow.DeathMode.Incoming:SetChecked(ReRecount.db.profile.FilterDeathIncoming[true])
	ReRecount.DetailWindow.DeathMode.Outgoing:SetChecked(ReRecount.db.profile.FilterDeathIncoming[false])

	ReRecount:SetupScrollbar(DeathMode:GetName().."_Scrollbar1")
	ReRecount:SetupScrollbar(DeathMode:GetName().."_Scrollbar2")

	ReRecount.DetailWindow.DeathMode.FilteredData={
		MessageTimes={},
		Messages={},
		MessageType={},
		MessageIncoming={},
		Health={},
		HealthNum={}
	}

	theFrame:Hide()

	ReRecount.DetailWindow.PieMode.UpperTable={}
	ReRecount.DetailWindow.PieMode.LowerTable={}

	me:CreateSummaryMode()
end

function me:DetermineDeathFilters()
	ReRecount.db.profile.FilterDeathType.DAMAGE=ReRecount.DetailWindow.DeathMode.Damage:GetChecked()==1
	ReRecount.db.profile.FilterDeathType.HEAL=ReRecount.DetailWindow.DeathMode.Heal:GetChecked()==1
	ReRecount.db.profile.FilterDeathType.MISC=ReRecount.DetailWindow.DeathMode.Misc:GetChecked()==1

	ReRecount.db.profile.FilterDeathIncoming[true]=ReRecount.DetailWindow.DeathMode.Incoming:GetChecked()==1
	ReRecount.db.profile.FilterDeathIncoming[false]=ReRecount.DetailWindow.DeathMode.Outgoing:GetChecked()==1

	me:FilterDeathData(ReRecount.db.profile.FilterDeathType,ReRecount.db.profile.FilterDeathIncoming)
	me:RefreshDeathLogDetails()
end

function me:ConfigureDeathCheckbox(check)
	check:SetWidth(20)
	check:SetHeight(20)
	check:SetScript("OnClick",function () if this:GetChecked() then this:SetChecked(true) else this:SetChecked(false) end me:DetermineDeathFilters() end)
	check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
end

function ReRecount:ReportDetail(amount,loc,loc2)
	if ReRecount.DetailWindow.SummaryEnabled then
		if ReRecount.DetailWindow.SummaryMode.Selected and ReRecount.DetailWindow.SummaryMode.Selected.Report then
			ReRecount.DetailWindow.SummaryMode.Selected:Report(loc,loc2)
		else
			ReRecount:Print("Need to select one of the summary data sets to report")
		end
		return
	end

	if ReRecount.DetailWindow.PieMode:IsVisible() then
		local UpperTable=ReRecount.DetailWindow.PieMode.UpperTable
		local Entry
		
		if not ReRecount.DetailWindow.Locked then
			
			if amount>#UpperTable then
				amount=#UpperTable
			end
			
			SendChatMessage("ReRecount - "..ReRecount.DetailWindow.TitleText,loc,nil,loc2)
			for i=1,amount do
				Entry=UpperTable[i]
				SendChatMessage(i..". "..(Entry[1] or "").." "..(Entry[6] or "").." "..(Entry[2] or "").." ("..math.floor(Entry[4]+0.5).."%)",loc,nil,loc2)
			end
		else
			local LowerTable=ReRecount.DetailWindow.PieMode.LowerTable
			local Min,Avg, Max, Count
			local Labels=ReRecount.DetailWindow.PieMode.BotRowLabels
			Min=Labels.Min:GetText()
			Avg=Labels.Avg:GetText()
			Max=Labels.Max:GetText()
			Count=Labels.Count:GetText()
			local Text

			if amount>#LowerTable then
				amount=#LowerTable
			end
			
			SendChatMessage("ReRecount - "..ReRecount.DetailWindow.TitleText..": "..UpperTable[ReRecount.DetailWindow.PieMode.Selected][1],loc,nil,loc2)
			for i=1,amount do
				Entry=LowerTable[i]
				Text=i..". "..Entry[1].." "..Entry[2].." ("..math.floor(Entry[6]+0.5).."%)"
				if Entry[3] or Entry[4] or Entry[5] then
					Text=Text.." ("
				end
				if Entry[3] then
					Text=Text..Min..": "..Entry[3]
				end
				if Entry[4] then
					Text=Text.." "..Avg..": "..Entry[4]
				end
				if Entry[5] then
					Text=Text.." "..Max..": "..Entry[5]
				end
				if Entry[3] or Entry[4] or Entry[5] then
					Text=Text..")"
				end

				SendChatMessage(Text,loc,nil,loc2)
			end
		end
	elseif ReRecount.DetailWindow.DeathMode:IsVisible() then
		if ReRecount.DetailWindow.DeathMode.SelectedNum and ReRecount.DetailWindow.DeathMode.Data[ReRecount.DetailWindow.DeathMode.SelectedNum] then
			local DeathData=ReRecount.DetailWindow.DeathMode.Data[ReRecount.DetailWindow.DeathMode.SelectedNum]
			local MsgTimes=ReRecount.DetailWindow.DeathMode.FilteredData.MessageTimes
			local Msgs=ReRecount.DetailWindow.DeathMode.FilteredData.Messages
			local Health=ReRecount.DetailWindow.DeathMode.FilteredData.Health
			local Entries=#MsgTimes
			local Start			

			if Entries>amount then
				Start=Entries-amount+1
			else
				Start=1
			end
			
			SendChatMessage("ReRecount - Death for "..ReRecount.DetailWindow.DeathMode.WhosDeaths.." by "..(DeathData.KilledBy or "Unknown").." at "..date("%H:%M:%S",DeathData.DeathAt),loc,nil,loc2)
			for i=Start,Entries do
				if MsgTimes[i]<0 then
					SendChatMessage(string.format("%.2f - (Health: %s) "..Msgs[i],MsgTimes[i],Health[i]),loc,nil,loc2)
				else
					SendChatMessage(string.format("+%.2f - (Health: %s) "..Msgs[i],MsgTimes[i],Health[i]),loc,nil,loc2)
				end
			end
		else
			ReRecount:Print("Need to have a death selected in the detail window to report a death")
		end
	end
end
