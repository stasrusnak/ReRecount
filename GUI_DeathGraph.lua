local Graph = LibStub:GetLibrary("LibGraph-2.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale( "ReRecount" )
local me={}

function me:CreateDeathGraphWindow()
	local theFrame=ReRecount:CreateFrame("ReRecount_DeathGraph",L["Death Graph"],182,200)

	local g=Graph:CreateGraphLine("ReRecount_DeathScatter",theFrame,"BOTTOM","BOTTOM",0,2,197,149)
	g:SetXAxis(-15,1)
	g:SetYAxis(0,100)
	g:SetGridSpacing(1,25)
	g:SetGridColor({0.5,0.5,0.5,0.5})
	g:SetAxisDrawing(true,true)
	g:SetAxisColor({1.0,1.0,1.0,1.0})
	g:SetYLabels(true,false)
	theFrame.Graph=g

	g=Graph:CreateGraphScatterPlot("ReRecount_DeathScatter",theFrame,"BOTTOM","BOTTOM",0,2,197,149)
	g:SetXAxis(-15,1)
	g:SetYAxis(0,100)
	g:SetGridSpacing(100,100)
	g:SetGridColor({0.5,0.5,0.5,0})
	g:SetAxisDrawing(false,false)
	g:SetAxisColor({1.0,1.0,1.0,0})
	g:SetFrameLevel(theFrame.Graph:GetFrameLevel()+1)
	
	theFrame.Scatter=g
	
	--Need to add it to our window ordering system
	ReRecount:AddWindow(theFrame)

	ReRecount.DeathGraph=theFrame
end

function ReRecount:ShowDeathGraph(Health,Heals,Hits)
	if not ReRecount.DeathGraph then
		me:CreateDeathGraphWindow()
	end

	local DeathGraph=ReRecount.DeathGraph
	DeathGraph:Show()
	--DeathGraph.Title:SetText("Death Graph - "..Title)
	DeathGraph.Graph:ResetData()
	DeathGraph.Graph:AddDataSeries(Health,{0.2,1.0,0.2,0.8},false)

	
	DeathGraph.Scatter:ResetData()
	if Heals then
		DeathGraph.Scatter:AddDataSeries(Heals,{0.1,1.0,0.1,0.8})
	end
	if Hits then
		DeathGraph.Scatter:AddDataSeries(Hits,{1.0,0.1,0.1,0.8})
	end
end