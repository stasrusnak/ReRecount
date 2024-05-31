ReRecount = LibStub("AceAddon-3.0"):NewAddon("ReRecount", "AceConsole-3.0","AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local SM = LibStub:GetLibrary("LibSharedMedia-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale( "ReRecount" )
  
local DataVersion	= "1.3"
local FilterSize	= 20
local RampUp		= 5
local RampDown		= 10
      
ReRecount.Version = tonumber(string.sub("$Revision: 78940 $", 12, -3))

local UnitLevel = UnitLevel
local UnitClass = UnitClass
local UnitIsTrivial = UnitIsTrivial
local UnitIsPlayer = UnitIsPlayer
local UnitExists = UnitExists
local UnitName = UnitName
local GetTime = GetTime
local UnitIsFriend = UnitIsFriend
local GetNumRaidMembers = GetNumRaidMembers
local GetNumPartyMembers = GetNumPartyMembers

  
-- Elsia: This is straight from GUIDRegistryLib-0.1 by ArrowMaster.
local bit_bor	= bit.bor
local bit_band  = bit.band
   
local COMBATLOG_OBJECT_AFFILIATION_MINE		= COMBATLOG_OBJECT_AFFILIATION_MINE		or 0x00000001
local COMBATLOG_OBJECT_AFFILIATION_PARTY	= COMBATLOG_OBJECT_AFFILIATION_PARTY	or 0x00000002
local COMBATLOG_OBJECT_AFFILIATION_RAID		= COMBATLOG_OBJECT_AFFILIATION_RAID		or 0x00000004
local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER	= COMBATLOG_OBJECT_AFFILIATION_OUTSIDER	or 0x00000008
local COMBATLOG_OBJECT_AFFILIATION_MASK		= COMBATLOG_OBJECT_AFFILIATION_MASK		or 0x0000000F
-- Reaction
local COMBATLOG_OBJECT_REACTION_FRIENDLY	= COMBATLOG_OBJECT_REACTION_FRIENDLY	or 0x00000010
local COMBATLOG_OBJECT_REACTION_NEUTRAL		= COMBATLOG_OBJECT_REACTION_NEUTRAL		or 0x00000020
local COMBATLOG_OBJECT_REACTION_HOSTILE		= COMBATLOG_OBJECT_REACTION_HOSTILE		or 0x00000040
local COMBATLOG_OBJECT_REACTION_MASK		= COMBATLOG_OBJECT_REACTION_MASK		or 0x000000F0
-- Ownership
local COMBATLOG_OBJECT_CONTROL_PLAYER		= COMBATLOG_OBJECT_CONTROL_PLAYER		or 0x00000100
local COMBATLOG_OBJECT_CONTROL_NPC			= COMBATLOG_OBJECT_CONTROL_NPC			or 0x00000200
local COMBATLOG_OBJECT_CONTROL_MASK			= COMBATLOG_OBJECT_CONTROL_MASK			or 0x00000300
-- Unit type
local COMBATLOG_OBJECT_TYPE_PLAYER			= COMBATLOG_OBJECT_TYPE_PLAYER			or 0x00000400
local COMBATLOG_OBJECT_TYPE_NPC				= COMBATLOG_OBJECT_TYPE_NPC				or 0x00000800
local COMBATLOG_OBJECT_TYPE_PET				= COMBATLOG_OBJECT_TYPE_PET				or 0x00001000
local COMBATLOG_OBJECT_TYPE_GUARDIAN		= COMBATLOG_OBJECT_TYPE_GUARDIAN		or 0x00002000
local COMBATLOG_OBJECT_TYPE_OBJECT			= COMBATLOG_OBJECT_TYPE_OBJECT			or 0x00004000
local COMBATLOG_OBJECT_TYPE_MASK			= COMBATLOG_OBJECT_TYPE_MASK			or 0x0000FC00

-- Special cases (non-exclusive)
local COMBATLOG_OBJECT_TARGET				= COMBATLOG_OBJECT_TARGET				or 0x00010000
local COMBATLOG_OBJECT_FOCUS				= COMBATLOG_OBJECT_FOCUS				or 0x00020000
local COMBATLOG_OBJECT_MAINTANK				= COMBATLOG_OBJECT_MAINTANK				or 0x00040000
local COMBATLOG_OBJECT_MAINASSIST			= COMBATLOG_OBJECT_MAINASSIST			or 0x00080000
local COMBATLOG_OBJECT_RAIDTARGET1			= COMBATLOG_OBJECT_RAIDTARGET1			or 0x00100000
local COMBATLOG_OBJECT_RAIDTARGET2			= COMBATLOG_OBJECT_RAIDTARGET2			or 0x00200000
local COMBATLOG_OBJECT_RAIDTARGET3			= COMBATLOG_OBJECT_RAIDTARGET3			or 0x00400000
local COMBATLOG_OBJECT_RAIDTARGET4			= COMBATLOG_OBJECT_RAIDTARGET4			or 0x00800000
local COMBATLOG_OBJECT_RAIDTARGET5			= COMBATLOG_OBJECT_RAIDTARGET5			or 0x01000000
local COMBATLOG_OBJECT_RAIDTARGET6			= COMBATLOG_OBJECT_RAIDTARGET6			or 0x02000000
local COMBATLOG_OBJECT_RAIDTARGET7			= COMBATLOG_OBJECT_RAIDTARGET7			or 0x04000000
local COMBATLOG_OBJECT_RAIDTARGET8			= COMBATLOG_OBJECT_RAIDTARGET8			or 0x08000000
local COMBATLOG_OBJECT_NONE					= COMBATLOG_OBJECT_NONE					or 0x80000000
local COMBATLOG_OBJECT_SPECIAL_MASK			= COMBATLOG_OBJECT_SPECIAL_MASK			or 0xFFFF0000

local LIB_FILTER_RAIDTARGET	= bit_bor(
	COMBATLOG_OBJECT_RAIDTARGET1, COMBATLOG_OBJECT_RAIDTARGET2, COMBATLOG_OBJECT_RAIDTARGET3, COMBATLOG_OBJECT_RAIDTARGET4,
	COMBATLOG_OBJECT_RAIDTARGET5, COMBATLOG_OBJECT_RAIDTARGET6, COMBATLOG_OBJECT_RAIDTARGET7, COMBATLOG_OBJECT_RAIDTARGET8
)
local LIB_FILTER_ME = bit_bor(
	COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_PLAYER
)
local LIB_FILTER_MY_PET = bit_bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PET
						)
local LIB_FILTER_PARTY = bit_bor(COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_AFFILIATION_PARTY)
local LIB_FILTER_RAID  = bit_bor(COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_AFFILIATION_RAID)
local LIB_FILTER_GROUP = bit_bor(LIB_FILTER_PARTY, LIB_FILTER_RAID)

--[[local DefaultConfig={
	char={
		combatants={
			['*'] = {
				Init=false,
				Owner=false,
				AbilityType={},
				TimeLast={},
				TimeData={
					Damage={{},{}},
					DamageTaken={{},{}},
					Healing={{},{}},
					Overhealing={{},{}},
					HealingTaken={{},{}},
					Threat={{},{}}
				},

				TimeWindows={
					Damage={['*']=0},
					DamageTaken={['*']=0},
					Healing={['*']=0},
					HealingTaken={['*']=0},
					Overhealing={['*']=0},
					Threat={['*']=0},
				},
				Fights={
					['*']={
						Damage=0,
						FDamage=0,
						DamageTaken=0,
						Healing=0,
						HealingTaken=0,
						Overhealing=0,
						DeathCount=0,
						DOT_Time=0,
						HOT_Time=0,
						Interrupts=0,
						Dispels=0,
						Dispelled=0,
						ActiveTime=0,
						TimeHeal=0,
						TimeDamage=0,
						CCBreak=0,
						Threat=0,
						ThreatNonZero=0,
						ManaGain=0,
						EnergyGain=0,
						RageGain=0,
						Ressed=0,

						--Ability Data
						Attacks={},
						FAttacks={},
						Heals={},
						OverHeals={},
						DOTs={},
						HOTs={},
						InterruptData={},
						CCBroken={},

						--Interaction Data
						DamagedWho={}, --Who did I damage?
						FDamagedWho={}, --Who did I damage?
						WhoDamaged={}, --Who damaged me?
						HealedWho={}, --Who did I heal?
						WhoHealed={}, --Who healed me?
						DispelledWho={}, --Who did I dispel?
						WhoDispelled={}, --Who dispelled me?
						PartialResist={},	--What spells partially resisted
						PartialBlock={}, -- What attacks partially blocked
						PartialAbsorb={}, -- What damage partially absorbed
						TimeSpent={},	--Where did I spend my time
						TimeDamaging={},	--Where did I spend my time attacking
						TimeHealing={},	--Where did I spend my time healing
						ManaGained={},	--Where did I gain mana
						EnergyGained={}, --Where did I gain energy
						RageGained={}, --Where did I gain rage
						ManaGainedFrom={},	--Where did I gain mana
						EnergyGainedFrom={}, --Where did I gain energy
						RageGainedFrom={}, --Where did I gain rage
						RessedWho={},

						--Elemental Tracking
						ElementDone={},
						ElementDoneResist={},
						ElementDoneBlock={},
						ElementDoneAbsorb={},
						ElementTaken={},
						ElementTakenResist={},
						ElementTakenBlock={},
						ElementTakenAbsorb={},

						ElementHitsDone={},
						ElementHitsTaken={},
					}
				},





				TimeNeedZero={},

				LastEvents={},
				LastEventHealth={},
				LastEventHealthNum={},
				LastEventTimes={},
				LastEventType={},
				LastEventIncoming={},
				LastEventNum={},

				NextEventNum=1,

				LastThreat=0,
				LastAbility=0,
				LastActive=0,

				LastFightIn=0,
				UnitLockout=0,

				HealBuffHas=nil,
				HealBuffName=nil,

				DeathLogs={},

				FightsSaved=0,

				Sync={
					MsgNum=0,
					LastSent=0,
					LastChanged=0,

					Damage=0,
					DamageTaken=0,
					FDamage=0,
					Healing=0,
					HealingTaken=0,
					Overhealing=0,

					ActiveTime=0,
					
					OverhealCorrection=0,
					HealingCorrection=0,
				},
			}
		},
		GUID=nil,
		PetGUID=nil,
		FoughtWho={},
		FightNum=0,
		CombatTimes={},
		version=0,
	}
}
]]

local Default_Profile={
	profile={
		Colors={
			["Window"]={
				["Title"] = { r = 1, g = 0, b = 0, a = 1},
				["Background"]= { r = 24/255, g = 24/255, b = 24/255, a = 1},
				["Title Text"] = {r = 1, g = 1, b = 1, a = 1},
			},
			["Bar"]={
				["Bar Text"] = {r = 1, g = 1, b = 1},
				["Total Bar"] = { r = 0.75, g = 0.75, b = 0.75},
			},
			["Other Windows"]={
				["Title"] = { r = 1, g = 0, b = 0, a = 1},
				["Background"]= { r = 24/255, g = 24/255, b = 24/255, a = 1},
				["Title Text"] = {r = 1, g = 1, b = 1, a = 1},
			},
			["Detail Window"]={
			},
			["Class"]={
				["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45, a=1 },
				["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79, a=1 },
				["PRIEST"] = { r = 1.0, g = 1.0, b = 1.0, a=1 },
				["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, a=1 },
				["MAGE"] = { r = 0.41, g = 0.8, b = 0.94, a=1 },
				["ROGUE"] = { r = 1.0, g = 0.96, b = 0.41, a=1 },
				["DRUID"] = { r = 1.0, g = 0.49, b = 0.04, a=1 },
				["SHAMAN"] = { r = 0.14, g = 0.35, b = 1.0, a=1 },
				["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, a=1 },
				["PET"] = { r = 0.09, g = 0.61, b = 0.55, a=1 },
--				["GUARDIAN"] = { r = 0.61, g = 0.09, b = 0.09 },
				["MOB"] = { r = 0.58, g = 0.24, b = 0.63, a=1 },
				["UNKNOWN"] = { r = 0.1, g = 0.1, b = 0.1, a=1 },
				["HOSTILE"] = { r = 0.7, g = 0.1, b = 0.1, a=1 },
				["UNGROUPED"] = { r = 0.63, g = 0.58, b = 0.24, a=1 },
			},
			["Realtime"]={
			},
			["Names"]={
			}
		},
		MaxFights=5,
		--Window={
			--ShowCurAndLast=false,
		--},
		MessagesTracked=50,
		GlobalStatusBar=false,
		AutoDelete=true,
		AutoDeleteCombatants=true, -- Elsia: set this to true to reduce data accumulation
		AutoDeleteTime=180,
		AutoDeleteNewInstance=true, -- Elsia: set this to true
		ConfirmDeleteInstance=true, -- Elsia: Get annoying popup box?
		LastInstanceName="", -- Elsia: Last instance is empty by default
		DeleteNewInstanceOnly=true,
		DeleteJoinRaid = true,
		ConfirmDeleteRaid = true,
		DeleteJoinGroup = true,
		ConfirmDeleteGroup = true,
		BarTexture="BantoBar",
		MergePets=true,
		RecordCombatOnly=true,
		SegmentBosses=false,
		MainWindowVis=true,
		MainWindowMode=1,
		Locked=false,
		EnableSync=true, -- Elsia: Default enable sync is set to true again now, thanks to lazy syncing.
		GlobalDataCollect=true, -- Elsia: Global toggle for data collection
		HideCollect=false, -- Elsia: Hide ReRecount window when not collecting data
		Font="ABF",
		Scaling=1,
		MainWindow={
			Buttons={
				ReportButton=true,
				FileButton=true,
				ConfigButton=true,
				ResetButton=true,
				LeftButton=true,
				RightButton=true,
			},
			RowHeight=14,
			RowSpacing=1,
			AutoHide=false,
			ShowScrollbar=true, -- Elsia: Allow toggle of scrollbar
			HideTotalBar=true,
			BarText=
			{
				RankNum =true,
				PerSec = true,
				Percent = true,
				NumFormat = 1,
			},
			Position={
				x = 0,
				y = 0,
				w = 140,
				h = 200,
			},
		},
		Filters={
			Show={
				Self=true,
				Grouped=true,
				Ungrouped=true, -- Elsia: Default show leaving party members
				Hostile=false,
				Pet=false,
				Trivial=false,
				Nontrivial=false,
				Boss=false,
				Unknown=false,
			},
			Data={
				Self=true,
				Grouped=true,
				Ungrouped=false, -- Elsia: Removed to reduce default data accumulation
				Hostile=false,
				Pet=true,
				Trivial=false,
				Nontrivial=false,
				Boss=true,
				Unknown=true,
			},
			TimeData={
				Self=true,
				Grouped=false, -- Elsia: Removed Default timed on for groups
				Ungrouped=false,
				Hostile=false,
				Pet=false,
				Trivial=false,
				Nontrivial=false,
				Boss=false, -- Elsia:Removed Default timed on for bosses
				Unknown=false,
			},
			TrackDeaths={
				Self=true,
				Grouped=true,
				Ungrouped=false,
				Hostile=false,
				Pet=true,
				Trivial=false,
				Nontrivial=false,
				Boss=true,
				Unknown=false,
			},
		},
		ZoneFilters={
			none=true, -- Elsia: These fields are named after what IsInInstance() returns for types.
			pvp=true,
			arena=true,
			party=true,
			raid=true,
		},
		FilterDeathType={
			DAMAGE=true,
			HEAL=true,
			MISC=true,
		},
		FilterDeathIncoming={
			[true]=true,
			[false]=false
		},
		RealtimeWindows={}
	}
} 

SM:Register("statusbar", "Aluminium",			[[Interface\Addons\ReRecount\Textures\statusbar\Aluminium]])
SM:Register("statusbar", "Armory",				[[Interface\Addons\ReRecount\Textures\statusbar\Armory]])
SM:Register("statusbar", "BantoBar",			[[Interface\Addons\ReRecount\Textures\statusbar\BantoBar]])
SM:Register("statusbar", "Flat",				[[Interface\Addons\ReRecount\Textures\statusbar\Flat]])
SM:Register("statusbar", "Minimalist",			[[Interface\Addons\ReRecount\Textures\statusbar\Minimalist]])
SM:Register("statusbar", "Otravi",				[[Interface\Addons\ReRecount\Textures\statusbar\Otravi]])
SM:Register("statusbar", "Empty",               [[Interface\Addons\ReRecount\Textures\statusbar\Empty]])

BINDING_HEADER_ReRecount = "ReRecount"
BINDING_NAME_ReRecount_PREVIOUSPAGE = L["Show previous main page"]
BINDING_NAME_ReRecount_NEXTPAGE = L["Show next main page"]
BINDING_NAME_ReRecount_DAMAGE = L["Display"].." "..L["Damage Done"]
BINDING_NAME_ReRecount_DPS = L["Display"].." "..L["DPS"]
BINDING_NAME_ReRecount_FRIENDLYFIRE = L["Display"].." "..L["Friendly Fire"]
BINDING_NAME_ReRecount_DAMAGETAKEN = L["Display"].." "..L["Damage Taken"]
BINDING_NAME_ReRecount_HEALING = L["Display"].." "..L["Healing Done"]
BINDING_NAME_ReRecount_HEALINGTAKEN = L["Display"].." "..L["Healing Taken"]
BINDING_NAME_ReRecount_OVERHEALING = L["Display"].." "..L["Overhealing Done"]
BINDING_NAME_ReRecount_DEATHS = L["Display"].." "..L["Deaths"]
BINDING_NAME_ReRecount_DOTS = L["Display"].." "..L["DOT Uptime"]
BINDING_NAME_ReRecount_HOTS = L["Display"].." "..L["HOT Uptime"]
BINDING_NAME_ReRecount_DISPELS = L["Display"].." "..L["Dispels"]
BINDING_NAME_ReRecount_DISPELLED = L["Display"].." "..L["Dispelled"]
BINDING_NAME_ReRecount_INTERRUPTS = L["Display"].." "..L["Interrupts"]
BINDING_NAME_ReRecount_CCBREAKER = L["Display"].." "..L["CC Breakers"]
BINDING_NAME_ReRecount_ACTIVITY = L["Display"].." "..L["Activity"]
BINDING_NAME_ReRecount_MANA = L["Display"].." "..L["Mana Gained"]
BINDING_NAME_ReRecount_ENERGY = L["Display"].." "..L["Energy Gained"]
BINDING_NAME_ReRecount_RAGE = L["Display"].." "..L["Rage Gained"]
BINDING_NAME_ReRecount_REPORT_MAIN = L["Report the Main Window Data"]
BINDING_NAME_ReRecount_REPORT_DETAILS = L["Report the Detail Window Data"]
BINDING_NAME_ReRecount_RESET_DATA = L["Resets the data"]
BINDING_NAME_ReRecount_SHOW_MAIN = L["Shows the main window"]
BINDING_NAME_ReRecount_HIDE_MAIN = L["Hides the main window"]
BINDING_NAME_ReRecount_TOGGLE_MAIN = L["Toggles the main window"]

local optFrame

local function deepcopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

ReRecount.consoleOptions = {
	name = L["ReRecount"],
	type = 'group',
	args = {
		confdesc = {
			order = 1,
			type = "description",
			name = L["Config Access"].."\n",
			cmdHidden = true
		},
		windesc = {
			order = 10,
			type = "description",
			name = L["Window Options"].."\n",
			cmdHidden = true
		},
		syncdesc = {
			order = 20,
			type = "description",
			name = L["Sync Options"].."\n",
			cmdHidden = true
		},
		datadesc = {
			order = 30,
			type = "description",
			name = L["Data Options"].."\n",
			cmdHidden = true
		},
		[L["gui"]] = {
			order = 2,
			name = L["GUI"],
			desc = L["Open Ace3 Config GUI"],
			type = 'execute',
			func = function()
				InterfaceOptionsFrame:Hide()
				AceConfigDialog:SetDefaultSize("ReRecount", 500, 550)
				AceConfigDialog:Open("ReRecount") end
		},
		[L["sync"]] = {
			order = 21,
			name  = L["Sync"],
			desc = L["Toggles sending synchronization messages"],
			type = 'toggle',
			get = function(info) return ReRecount.db.profile.EnableSync end,
			set = function(info,v)
				if v then -- Elsia: Make sure it's on before enabling, an event might intervene
					ReRecount:ConfigComm(); 
					ReRecount:Print("Lazy Sync enabled")
				end
					
				ReRecount.db.profile.EnableSync=v
				
				if not v then -- Elsia: Make sure it's off before disabling, an event might intervene
					ReRecount:FreeComm();
					ReRecount:Print("Lazy Sync disabled")
				end
			end,
		},
		[L["reset"]] = {
			order = 31,
			name = L["Reset"],
			desc = L["Resets the data"],
			type = 'execute',
			func = function() ReRecount:ResetData() end
		},
		[L["verChk"]] = {
			order = 22,
			name = L["VerChk"],
			desc = L["Displays the versions of players in the raid"],
			type = 'execute',
			func = function() ReRecount:ReportVersions() end
		},
		[L["show"]] = {
			order = 12,
			name = L["Show"],
			desc = L["Shows the main window"],
			type = 'execute',
			func = function() ReRecount.MainWindow:Show();ReRecount:RefreshMainWindow() end,
			dialogHidden = true
		},
		hide = {
			order = 13,
			name = L["Hide"],
			desc = L["Hides the main window"],
			type = 'execute',
			func = function() ReRecount.MainWindow:Hide() end,
			dialogHidden = true
		},
		toggle = {
			order = 11,
			name = L["Toggle"],
			desc = L["Toggles the main window"],
			type = 'execute',
			func = function() if ReRecount.MainWindow:IsShown() then ReRecount.MainWindow:Hide() else ReRecount.MainWindow:Show();ReRecount:RefreshMainWindow() end end
		},
		config = {
			order = 3,
			name = L["Config"],
			desc = L["Shows the config window"],
			type = 'execute',
			func = function() ReRecount:ShowConfig() end
		},
		resetpos = {
			order = 14,
			name = L["ResetPos"],
			desc = L["Resets the positions of the detail, graph, and main windows"],
			type = 'execute',
			func = function() ReRecount:ResetPositions() end
		},
		lock = {
			order = 15,
			name  = L["Lock"],
			desc = L["Toggles windows being locked"],
			type = 'toggle',
			get = function(info) return ReRecount.db.profile.Locked end,
			set = function(info,v)
				ReRecount.db.profile.Locked=v
				ReRecount:LockWindows(v)
			end,
		},
		maxfights =  {
			  order = 31,
			  name = L["Recorded Fights"],
			  desc = L["Set the maximum number of recorded fight segments"],
			  type = 'range',
			  min = 1,
			  max = 25,
			  step = 1,
			  get = function(info) return ReRecount.db.profile.MaxFights end,
			  set = function(info, v)
			          if v < ReRecount.db.profile.MaxFights then
				     ReRecount.Fights:DeleteOverflowFights(v)
				  end
			          ReRecount.db.profile.MaxFights=v
			  end, 
		},		
	}
}

ReRecount.consoleOptions2 = deepcopy(ReRecount.consoleOptions)	
	
ReRecount.consoleOptions2.args.report = {
			order = 32,
			name = L["Report"],
			type = 'group',
			desc = L["Allows the data of a window to be reported"],
			args = {
				detail = {
					name = L["Detail"],
					desc = L["Report the Detail Window Data"],
					type = 'execute',
					func = function()  ReRecount:ShowReport("Detail",ReRecount.ReportDetail) end
				},
				main ={
					name = L["Main"],
					desc = L["Report the Main Window Data"],
					type = 'execute',
					func = function()  ReRecount:ShowReport("Main",ReRecount.ReportData) end
				}
			}
		}
		
ReRecount.consoleOptions2.args.realtime = {
			name = L["Realtime"],
			type = 'group', 
			desc = L["Specialized Realtime Graphs"],
			args = {
				netfps = {
					name = "Network and FPS",
					type = 'group', inline = true,
					args = {
						fps = {
							name = L["FPS"],
							desc = L["Starts a realtime window tracking your FPS"],
							type = 'execute',
							func = function() ReRecount:CreateRealtimeWindow("FPS","FPS","") end
						},
						lag = {
							name = L["Lag"],
							desc = L["Starts a realtime window tracking your latency"],
							type = 'execute',
							func = function() ReRecount:CreateRealtimeWindow("Latency","LAG","") end
						},
						uptraffic = {
							name = L["Upstream Traffic"],
							desc = L["Starts a realtime window tracking your upstream traffic"],
							type = 'execute',
							func = function() ReRecount:CreateRealtimeWindow("Upstream Traffic","UP_TRAFFIC","") end
						},
						downtraffic = {
							name = L["Downstream Traffic"],
							desc = L["Starts a realtime window tracking your downstream traffic"],
							type = 'execute',
							func = function() ReRecount:CreateRealtimeWindow("Downstream Traffic","DOWN_TRAFFIC","") end
						},
						bandwidth = {
							name = L["Available Bandwidth"],
							desc = L["Starts a realtime window tracking amount of available AceComm bandwidth left"],
							type = 'execute',
							func = function() ReRecount:CreateRealtimeWindow("Bandwidth Available","AVAILABLE_BANDWIDTH","") end
						},
					},
				},
				raid = {
					name = L["Raid"],
					desc = L["Tracks your entire raid"],
					type = 'group', inline = true,

					args = {
						dps = {
							name = L["DPS"],
							desc = L["Tracks Raid Damage Per Second"],
							type = 'execute',
							func = function() ReRecount:CreateRealtimeWindow("!RAID","DAMAGE","Raid DPS") end
						},
						dtps = {
							name = L["DTPS"],
							desc = L["Tracks Raid Damage Taken Per Second"],
							type = 'execute',
							func = function() ReRecount:CreateRealtimeWindow("!RAID","DAMAGETAKEN","Raid DTPS") end
						},
						hps = {
							name = L["HPS"],
							desc = L["Tracks Raid Healing Per Second"],
							type = 'execute',
							func = function() ReRecount:CreateRealtimeWindow("!RAID","HEALING","Raid HPS") end
						},
						htps = {
							name = L["HTPS"],
							desc = L["Tracks Raid Healing Taken Per Second"],
							type = 'execute',
							func = function() ReRecount:CreateRealtimeWindow("!RAID","HEALINGTAKEN","Raid HTPS") end
						},
					}
				}
			}
}

function ReRecount:ReportVersions() -- Elsia: Functionified so GUI can use it too
	ReRecount:Print(L["Displaying Versions"])
	if ReRecount.VerTable then -- Elsia: Fixed nil error on non sync situation.
		for k,v in pairs(ReRecount.VerTable) do
			ReRecount:Print(k.." "..v)
		end
	end
end

function ReRecount:ShowCombatantList()
	for k,v in pairs(ReRecount.db2.combatants) do
		ReRecount:Print(k.." "..(v.Name or "nil").." "..(v.type or "nil").." "..(v.level or "nil").." "..(v.enClass or "nil").." "..(v.class or "nil").." "..(v.GUID or "nil"))
	end
	ReRecount:ShowNrCombatants()
end

function ReRecount:NrCombatants()
	local v = ReRecount.db2.combatants
	local size = 0
	for _,_ in pairs(v) do size = size + 1 end
	return size
end

function ReRecount:ShowNrCombatants()
	ReRecount:Print(ReRecount:NrCombatants())
end

function ReRecount:ResetData()
	if ReRecount.GraphWindow then
		ReRecount.GraphWindow:Hide()
		ReRecount.GraphWindow.LineGraph:LockXMin(false)
		ReRecount.GraphWindow.LineGraph:LockXMax(false)
		ReRecount.GraphWindow.TimeRangeSet=false
	end

	if ReRecount.DetailWindow then
		ReRecount.DetailWindow:Hide()
	end

	for k,v in pairs(ReRecount.db2.combatants) do
		ReRecount:DeleteGuardianOwnerByGUID(ReRecount.db2.combatants[k])
		ReRecount.db2.combatants[k]=nil
	end

	for k,v in pairs(ReRecount.db2.CombatTimes) do
		ReRecount.db2.CombatTimes[k]=nil
	end

	if ReRecount.MainWindow and ReRecount.MainWindow.DispTableSorted then
		ReRecount.MainWindow.DispTableSorted=ReRecount:GetTable()
		ReRecount.MainWindow.DispTableLookup=ReRecount:GetTable()
	end

	if ReRecount.MainWindow then
		ReRecount:RefreshMainWindow()
	end

	if #ReRecount.db2.FoughtWho > 0 then
		ReRecount:SendReset() -- Elsia: Sync the reset if we actually fought something
	end
 
	ReRecount.db2.FoughtWho={}

	ReRecount:ResetTableCache()
	
	if ReRecount.db.profile.CurDataSet ~= "CurrentFightData" and ReRecount.db.profile.CurDataSet ~= "LastFightData" then
		ReRecount.db.profile.CurDataSet = "OverallData"
	end
	
	ReRecount.db2.FightNum=0

	for k,v in pairs(ReRecount.db2.combatants) do
		v.LastFightIn=0
	end
	
	--Perform a garbage collect if they are resetting the data
	collectgarbage("collect")
end

function ReRecount:FindUnit(name)
	local unit --, UnitObj
	--Handle this as two passes
	
	unit=ReRecount:GetUnitIDFromName(name) -- We shouldn't need to find roster units.

	if unit then
		return unit
	end

	unit=ReRecount:FindTargetedUnit(name)

	return unit
end

local Epsilon=0.000000000000000001

function ReRecount:ResetFightData(data)
	--Init Data tracked
	data = data or {}
	data.Damage=0
	data.FDamage=0
	data.DamageTaken=0
	data.Healing=0
	data.HealingTaken=0
	data.Overhealing=0
	data.DeathCount=0
	data.DOT_Time=0
	data.HOT_Time=0
	data.Interrupts=0
	data.Dispels=0
	data.Dispelled=0
	data.ActiveTime=0
	data.TimeHeal=0
	data.TimeDamage=0
	data.CCBreak=0
	if ReRecountThreat then ReRecountThreat:ResetThreat() end
	data.ManaGain=0
	data.EnergyGain=0
	data.RageGain=0
	data.Ressed=0

	for k, v in pairs(data) do
		if type(v)=="table" then
			for k2 in pairs(v) do
				if type(v[k2])=="table" then
					ReRecount:FreeTable(v[k2])
				end
				v[k2]=nil
			end
		else
			data[k]=0
		end

	end
end

function ReRecount:InitFightData(data)
	--Init Data tracked
	data.Damage=0
	data.FDamage=0
	data.DamageTaken=0
	data.Healing=0
	data.HealingTaken=0
	data.Overhealing=0
	data.DeathCount=0
	data.DOT_Time=0
	data.HOT_Time=0
	data.Interrupts=0
	data.Dispels=0
	data.Dispelled=0
	data.ActiveTime=0
	data.TimeHeal=0
	data.TimeDamage=0
	data.CCBreak=0
	if ReRecountThreat then ReRecountThreat:ResetThreat() end
	data.ManaGain=0
	data.EnergyGain=0
	data.RageGain=0
	data.Ressed=0

	--Ability Data
	data.Attacks=ReRecount:GetTable()
	data.FAttacks=ReRecount:GetTable()
	data.Heals=ReRecount:GetTable()
	data.OverHeals=ReRecount:GetTable()
	data.DOTs=ReRecount:GetTable()
	data.HOTs=ReRecount:GetTable()
	data.InterruptData=ReRecount:GetTable()
	data.CCBroken=ReRecount:GetTable()

	--Interaction Data
	data.DamagedWho=ReRecount:GetTable() --Who did I damage?
	data.FDamagedWho=ReRecount:GetTable() --Who did I damage?
	data.WhoDamaged=ReRecount:GetTable() --Who damaged me?
	data.HealedWho=ReRecount:GetTable() --Who did I heal?
	data.WhoHealed=ReRecount:GetTable() --Who healed me?
	data.DispelledWho=ReRecount:GetTable() --Who did I dispel?
	data.WhoDispelled=ReRecount:GetTable() --Who dispelled me?
	data.TimeSpent=ReRecount:GetTable()	--Where did I spend my time
	data.TimeDamaging=ReRecount:GetTable()	--Where did I spend my time attacking
	data.TimeHealing=ReRecount:GetTable()	--Where did I spend my time healing
	data.ManaGained=ReRecount:GetTable()	--Where did I gain mana
	data.EnergyGained=ReRecount:GetTable() --Where did I gain energy
	data.RageGained=ReRecount:GetTable() --Where did I gain rage
	data.ManaGainedFrom=ReRecount:GetTable()	--Where did I gain mana
	data.EnergyGainedFrom=ReRecount:GetTable() --Where did I gain energy
	data.RageGainedFrom=ReRecount:GetTable() --Where did I gain rage
	data.PartialResist=ReRecount:GetTable()	--What spells partially resisted
	data.PartialBlock=ReRecount:GetTable() -- What attacks partially blocked
	data.PartialAbsorb=ReRecount:GetTable() -- What damage partially absorbed
	data.RessedWho=ReRecount:GetTable()

	--Elemental Tracking
	data.ElementDone=ReRecount:GetTable()
	data.ElementDoneResist=ReRecount:GetTable()
	data.ElementDoneBlock=ReRecount:GetTable()
	data.ElementDoneAbsorb=ReRecount:GetTable()
	data.ElementTaken=ReRecount:GetTable()
	data.ElementTakenResist=ReRecount:GetTable()
	data.ElementTakenBlock=ReRecount:GetTable()
	data.ElementTakenAbsorb=ReRecount:GetTable()

	data.ElementHitsDone=ReRecount:GetTable()
	data.ElementHitsTaken=ReRecount:GetTable()
end

function ReRecount:CreateOwnerFlags(nameFlags)
	local ownerFlags=bit_band(nameFlags,COMBATLOG_OBJECT_AFFILIATION_MASK+COMBATLOG_OBJECT_REACTION_MASK+COMBATLOG_OBJECT_CONTROL_MASK)
	if bit_band(nameFlags,COMBATLOG_OBJECT_CONTROL_PLAYER)~=0 then
		ownerFlags = ownerFlags + COMBATLOG_OBJECT_TYPE_PLAYER
	else -- NPC
		ownerFlags = ownerFlags + COMBATLOG_OBJECT_TYPE_NPC
	end	
	
	return ownerFlags
end

function ReRecount:DetermineType(name,nameFlags)
	local combatant=ReRecount.db2.combatants[name]

	if nameFlags then
		if bit_band(nameFlags,COMBATLOG_OBJECT_AFFILIATION_MINE+COMBATLOG_OBJECT_TYPE_PLAYER)==COMBATLOG_OBJECT_AFFILIATION_MINE+COMBATLOG_OBJECT_TYPE_PLAYER and bit_band(nameFlags,COMBATLOG_OBJECT_TYPE_PET+COMBATLOG_OBJECT_TYPE_GUARDIAN)==0 then
			combatant.type="Self"
			return
		elseif bit_band(nameFlags,COMBATLOG_OBJECT_TYPE_PET+COMBATLOG_OBJECT_TYPE_GUARDIAN)~=0 and bit_band(nameFlags,COMBATLOG_OBJECT_AFFILIATION_MINE)~=0 then
			combatant.type="Pet"
			combatant.enClass="PET"
			combatant.Owner=ReRecount.PlayerName
			--ReRecount:SetOwner(combatant,name,combatant.Owner, ReRecount.PlayerGUID, ReRecount:CreateOwnerFlags(nameFlags))
			return
		elseif bit_band(nameFlags,COMBATLOG_OBJECT_TYPE_PET+COMBATLOG_OBJECT_TYPE_GUARDIAN)~=0 and bit_band(nameFlags,COMBATLOG_OBJECT_AFFILIATION_PARTY+COMBATLOG_OBJECT_AFFILIATION_RAID)~=0 then
			--ReRecount:Print("Pet1! "..name)
			combatant.type="Pet"
			combatant.enClass="PET"
			ReRecount:PartyPetOwnerFromGUID(combatant, name, nameGUID, nameFlags)
			return
		elseif bit_band(nameFlags,COMBATLOG_OBJECT_AFFILIATION_PARTY+COMBATLOG_OBJECT_AFFILIATION_RAID)~=0 and bit_band(COMBATLOG_OBJECT_TYPE_PLAYER)~=0 then
			combatant.type="Grouped"
			return
		elseif bit_band(nameFlags,COMBATLOG_OBJECT_TYPE_NPC+COMBATLOG_OBJECT_CONTROL_NPC)==COMBATLOG_OBJECT_TYPE_NPC+COMBATLOG_OBJECT_CONTROL_NPC then
			if combatant.isTrivial then
				combatant.type="Trivial"
			elseif combatant.level==-1 then
				combatant.type="Boss"
			else
				combatant.type="Nontrivial"
			end
			return
		end
	end
	
	if name==ReRecount.PlayerName then
		combatant.type="Self"
		return
	end
	
	if combatant.checkLater then
		combatant.type="Unknown"
		combatant.enClass="UNKNOWN"
		return
	end

	if combatant.isPlayer then
		if combatant.inGroup then
			combatant.type="Grouped"
		elseif combatant.isFriend then
			combatant.type="Ungrouped"
		else
			combatant.type="Hostile"
		end
	else
		if combatant.Owner then
			combatant.type="Pet"
			combatant.enClass="PET"
		else
			if combatant.isTrivial then
				combatant.type="Trivial"
			elseif combatant.level==-1 then
				combatant.type="Boss"
			else
				--ReRecount:Print(name.."nt2")
				--ReRecount:Print(debugstack(2, 3, 2))
				combatant.type="Nontrivial"
			end
		end
	end
end

local FlagsToUnitID =
{
 [COMBATLOG_OBJECT_TARGET]				= "target",
 [COMBATLOG_OBJECT_FOCUS]				= "focus",
 [COMBATLOG_OBJECT_MAINTANK]			= "maintank",
 [COMBATLOG_OBJECT_MAINASSIST]			= "mainassist",
 [COMBATLOG_OBJECT_RAIDTARGET1]			= "raid1target",
 [COMBATLOG_OBJECT_RAIDTARGET2]			= "raid2target",
 [COMBATLOG_OBJECT_RAIDTARGET3]			= "raid3target",
 [COMBATLOG_OBJECT_RAIDTARGET4]			= "raid4target",
 [COMBATLOG_OBJECT_RAIDTARGET5]			= "raid5target",
 [COMBATLOG_OBJECT_RAIDTARGET6]			= "raid6target",
 [COMBATLOG_OBJECT_RAIDTARGET7]			= "raid7target",
 [COMBATLOG_OBJECT_RAIDTARGET8]			= "raid8target",
}

function ReRecount:FindPetUnitFromFlags(unitFlags, unitGUID)
	assert(bit_band(unitFlags,COMBATLOG_OBJECT_TYPE_PET))
	if bit_band(unitFlags,COMBATLOG_OBJECT_TYPE_PET)==0 then -- Elsia: Has to be a pet. Guardians don't yet have unitids
		return
	end
	
	-- Check for my pet
	if bit_band(unitFlags,COMBATLOG_OBJECT_TYPE_PET)~=0 and bit_band(COMBATLOG_OBJECT_AFFILIATION_MINE)~=0 then
		return "pet" -- Elsia: My pet is easy
	end

	local vGUID
	
	-- Check for raid and party pets.
	if bit_band(unitFlags,COMBATLOG_OBJECT_TYPE_PET)~=0 and bit_band(unitFlags,COMBATLOG_OBJECT_AFFILIATION_PARTY+COMBATLOG_OBJECT_AFFILIATION_RAID+COMBATLOG_OBJECT_AFFILIATION_MINE)~=0 then
		if bit_band(unitFlags,COMBATLOG_OBJECT_AFFILIATION_RAID)~=0 then
			local Num=GetNumRaidMembers() 
			if Num>0 then
				for i=1,Num do
					if vGUID == UnitGUID("raidpet"..i) then
						return "raidpet"..i
					end
				end
			end
		elseif bit_band(unitFlags,COMBATLOG_OBJECT_AFFILIATION_PARTY)~=0 then
			local Num=GetNumPartyMembers()
			if Num>0 then
				for i=1,Num do
					if vGUID == UnitGUID("partypet"..i) then
						return "partypet"..i
					end
				end
			end
		end
	end
	
	assert(false) -- This should never happen
	
	return nil
end

function ReRecount:FindUnitFromFlags(unitname,unitFlags)
-- Elisa: This check excludes pets.

	if bit_band(unitFlags,COMBATLOG_OBJECT_TYPE_PLAYER)~=0 and bit_band(unitFlags,COMBATLOG_OBJECT_AFFILIATION_PARTY+COMBATLOG_OBJECT_AFFILIATION_RAID+COMBATLOG_OBJECT_AFFILIATION_MINE)~=0 then
		return unitname -- Elsia: Covers all non-pet players in raid
	end

	-- This returns all target-inferable units from flags.
	for k,v in pairs(FlagsToUnitID) do
		if bit_band(k,unitFlags)~=0 then
			local vname, vrealm = UnitName(v)
			if vname and vname == unitname then
				return v
			end
		end
	end

	return nil
end

function ReRecount:CombatantIsMob(combatant, unit)
	combatant.enClass="MOB"
--	combatant.unit=unit
	combatant.level=UnitLevel(unit)
	combatant.isTrivial=UnitIsTrivial(unit)
	if combatant.isTrivial then
		combatant.type="Trivial"
	elseif combatant.level==-1 then
		combatant.type="Boss"
	else
		combatant.type="Nontrivial"
	end
end

ReRecount.ElementalMobID = {
	[15430] = "3BF8", -- Earth elemental totem and it's greater elemental
	[15439] = "3C4E" -- Fire elemental totem
}

local gopts = {}

function ReRecount:AddGreaterElemental(opts)
	
	local nameGUID, petName, nameFlags, ownerGUID, owner, ownerFlags = unpack(opts)

	--ReRecount:Print(nameGUID)
	
	local newguid1 = tonumber(nameGUID:sub(-1-5,-1),16)+1
	local mobid = tonumber(nameGUID:sub(3+6,3+9),16)
	local newguid2 = tonumber(nameGUID:sub(3,3+5),16)
	local nameGUID2 = string.format("0x%06X",newguid2)..ReRecount.ElementalMobID[mobid]..string.format("%06X",newguid1)
	--ReRecount:Print(mobid.." "..nameGUID.." "..nameGUID2)
	
	ReRecountTempTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	ReRecountTempTooltip:ClearLines()
	ReRecountTempTooltip:SetHyperlink("unit:" .. nameGUID2)	

	if ReRecountTempTooltip:NumLines() > 0 then
		petName = getglobal("ReRecountTempTooltipTextLeft1"):GetText()
		nameGUID = nameGUID2
		--ReRecount:Print("Adding Guardian: "..petName.." "..nameGUID)
		ReRecount:AddPetCombatant(nameGUID, petName, nameFlags, ownerGUID, owner, ownerFlags)
	--else
	--	ReRecount:Print("Eek: ".. ReRecountTempTooltip:NumLines())
	end
end

function ReRecount:ScanGUIDTooltip(nameGUID)
	local newguid1 = tonumber(nameGUID:sub(-1-5,-1),16)
	local mobid = tonumber(nameGUID:sub(3+6,3+9),16)
	local newguid2 = tonumber(nameGUID:sub(3,3+5),16)
	local nameGUID2 = string.format("0x%06X",newguid2)..string.format("%04X",mobid)..string.format("%06X",newguid1)
	ReRecount:Print(mobid.." "..nameGUID.." "..nameGUID2)

	ReRecountTempTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	ReRecountTempTooltip:ClearLines()
	ReRecountTempTooltip:SetHyperlink("unit:" .. nameGUID2)	
	
	local tooltipName = "ReRecountTempTooltip"

	local textLeft, textRight, ttextLeft, ttextRight;

	for idx = 1, ReRecountTempTooltip:NumLines() do
		ttextLeft = getglobal(tooltipName.."TextLeft"..idx)
		if ttextLeft then
			textLeft = ttextLeft:GetText()
			if textLeft then
				ReRecount:Print("left"..idx..": "..textLeft)
			end
		else
			textLeft = nil
		end
			
		ttextRight = getglobal(tooltipName.."TextRight"..idx)
		if ttextRight then
			textRight = ttextRight:GetText()
			if textRight then
				ReRecount:Print("right"..idx..": "..textRight)
			end
		else
			textRight = nil
		end
	end
end

function ReRecount:SetGuardianGUID(name, nameGUID)
	ReRecount.GuardianGUIDs = ReRecount.GuardianGUIDs or {}
	ReRecount.GuardianReverseGUIDs = ReRecount.GuardianReverseGUIDs or {}
	tinsert(ReRecount.GuardianGUIDs, nameGUID, name)
	tinsert(ReRecount.GuardianReverseGUIDs, name, nameGUID)
end

function ReRecount:GetGuardianOwnerByGUID(nameGUID)
	return ReRecount.GuardianOwnerGUIDs and ReRecount.GuardianOwnerGUIDs[nameGUID]
end

function ReRecount:TrackGuardianOwnerByGUID(owner, name, nameGUID)

	owner.GuardianReverseGUIDs = owner.GuardianReverseGUIDs or {}
	ReRecount.GuardianOwnerGUIDs = ReRecount.GuardianOwnerGUIDs or {}

	local oldGUID = owner.GuardianReverseGUIDs and owner.GuardianReverseGUIDs[name]
	
	if not oldGUID then
		owner.GuardianReverseGUIDs[name]=nameGUID
		ReRecount.GuardianOwnerGUIDs[nameGUID]=owner.Name
	else
		owner.GuardianReverseGUIDs[name]=nameGUID
		ReRecount.GuardianOwnerGUIDs[oldGUID]=nil
		ReRecount.GuardianOwnerGUIDs[nameGUID]=owner.Name
	end
end

function ReRecount:DeleteGuardianOwnerByGUID(owner)
	if owner.GuardianReverseGUIDs then

		for k,v in pairs(owner.GuardianReverseGUIDs) do
			if ReRecount.GuardianOwnerGUIDs then
				ReRecount.GuardianOwnerGUIDs[v] = nil
			end
		end
	end
end
	
function ReRecount:AddPetCombatant(nameGUID, petName, nameFlags, ownerGUID, owner, ownerFlags)
	local name=petName.." <"..owner..">"
	local combatant=ReRecount.db2.combatants[name] or {}
	
	if bit_band(ownerFlags, COMBATLOG_OBJECT_AFFILIATION_MINE+COMBATLOG_OBJECT_AFFILIATION_PARTY+COMBATLOG_OBJECT_AFFILIATION_RAID+COMBATLOG_OBJECT_REACTION_FRIENDLY)==0 then
		--return -- Elsia: We only keep affiliated or friendly pets. These flags can be horribly wrong unfortunately
	end
	
	if petName:match("<(.-)>") or owner:match("<(.-)>") then
		--ReRecount:DPrint(petName.." : "..owner.." !Double owner detected! Please report the trace below")
		--ReRecount:DPrint(debugstack(2, 3, 2))
	end
		
	--local elementschool = petName:match("(.*) Elemental Totem")
	--ReRecount:Print(petName.." "..(elementschool or "nil").." "..nameGUID:sub(3,-1))
	if bit_band(nameFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) then
		local mobid = tonumber(nameGUID:sub(3+6,3+9),16)
		if ReRecount.ElementalMobID[mobid] then -- This really summoned a greater fire elemental totem, which is what we really care about.

			--ReRecount:Print("Elem!")
			gopts = {nameGUID, petName, nameFlags, ownerGUID, owner, ownerFlags }
			ReRecount:ScheduleTimer("AddGreaterElemental", 0.2, gopts)
		--else
			--ReRecount:Print(mobid)
		end
		if ReRecount.db2.combatants[owner] then -- We have a valid stored owner.
			ReRecount:TrackGuardianOwnerByGUID(ReRecount.db2.combatants[owner], petName, nameGUID)
		else
			ReRecount:SetOwner(combatant,name,owner,ownerGUID,ownerFlags)
			if ReRecount.db2.combatants[owner] then -- We have a valid stored owner.
				ReRecount:TrackGuardianOwnerByGUID(ReRecount.db2.combatants[owner], petName, nameGUID)
			end
		end
	end

	combatant.GUID=nameGUID
	combatant.LastFlags=nameFlags
	
	if combatant.Name then -- Already have such a pet!
		--ReRecount:DPrint("Pet1: "..name.." "..owner.." "..petName)
		ReRecount:CheckRetention(name)
		return
	end
	
	
	combatant.Name=petName
	ReRecount:SetOwner(combatant,name,owner,ownerGUID,ownerFlags)
	combatant.type="Pet"
	combatant.enClass="PET"
	-- Elsia: We inherit flags from owner, as currently 2.4 ptr the pet flags are not useful (typically 0xa28 for outsider,neutral, npc)
	combatant.inGroup = bit_band(ownerFlags, COMBATLOG_OBJECT_AFFILIATION_MINE+COMBATLOG_OBJECT_AFFILIATION_PARTY+COMBATLOG_OBJECT_AFFILIATION_RAID)~=0
	combatant.isPlayer=false
	combatant.isFriend=bit_band(ownerFlags,COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0
	combatant.unit = ReRecount:FindPetUnitFromFlags(nameFlags, nameGUID)
	if combatant.unit then
		combatant.level = UnitLevel(combatant.unit)
	else
		combatant.level=ReRecount.db2.combatants[owner].level -- Elsia: For guardians and other unidentifiable unitid pets, assume the owner level (heuristic)
	end

--[[	if not combatant then
		if not ReRecount.db.profile.Filters.Data[combatant.type] or not ReRecount.db.profile.GlobalDataCollect or not ReRecount.CurrentDataCollect then
			combatant = nil -- Elsia: We don't keep initial combatant types which we don't collect. Should reduce data growth.
			return
		end
	end]]

	--combatant.Init=true

	--ReRecount:DPrint("Pet2: "..name.." "..owner.." "..petName)
	
	combatant.LastFightIn=ReRecount.db2.FightNum
	combatant.UnitLockout=ReRecount.CurTime
	
	ReRecount:CheckRetention(name)
end

function ReRecount:AddCombatant(name,owner,nameGUID,nameFlags,ownerGUID)
	local combatant = {}
	
	if not nameFlags then
		ReRecount:Print("Improper: ".. name.." "..(nameFlags or "nil"))

		return -- Elsia: Improper!
	end

	combatant.GUID=nameGUID
	
	-- Handle Attributes that can be extracted from flags.
	combatant.inGroup = bit_band(nameFlags, COMBATLOG_OBJECT_AFFILIATION_MINE+COMBATLOG_OBJECT_AFFILIATION_PARTY+COMBATLOG_OBJECT_AFFILIATION_RAID)~=0
	combatant.isPlayer=bit_band(nameFlags, COMBATLOG_OBJECT_TYPE_PLAYER)==COMBATLOG_OBJECT_TYPE_PLAYER
	combatant.isFriend=bit_band(nameFlags,COMBATLOG_OBJECT_REACTION_FRIENDLY) ~= 0
	
	-- Handle identified pets
	if owner then
		combatant.Name=string.match(name,"(.*) <"..owner..">")
		if not combatant.Name then -- Elsia: not sure when this can happen
			combatant.Name = name
			name = name.." <"..owner..">"
		end
		if combatant.Name:match("<(.-)>") or owner:match("<(.-)>") then
			--ReRecount:DPrint(combatant.Name.." : "..owner.." !Double owner detected! Please report the trace below")
			--ReRecount:DPrint(debugstack(2, 3, 2))
		end
	
		ReRecount:SetOwner(combatant,name,owner,ownerGUID, ReRecount:CreateOwnerFlags(nameFlags))
		combatant.type="Pet"
		combatant.enClass="PET"
		combatant.level=1
--		combatant.unit = ReRecount:FindPetUnitFromFlags(nameFlags, nameGUID)
--		if combatant.unit then
--			combatant.level = UnitLevel(combatant.unit)
--		else
--			combatant.level=ReRecount.db2.combatants[owner].level -- Elsia: For guardians and other unidentifiable unitid pets, assume the owner level (heuristic)
--		end
	else
	-- Handle non-pet units
		combatant.Name=name
		combatant.Owner=false -- Not a pet
		
		-- Handle Friendly combatants
		if combatant.isFriend and (combatant.inGroup or combatant.isPlayer)  then
			-- Can find Unit from this
			--unit = ReRecount:FindUnitFromFlags(name,nameFlags)
			
--			if unit and combatant.isPlayer then -- Player Units
			if combatant.isPlayer then -- Player Units
				if ReRecount.PlayerName == name then
					combatant.type = "Self"
					combatant.class, combatant.enClass=UnitClass("player")
					combatant.level = UnitLevel("player")
				-- Handle Friendly grouped combatants
				elseif combatant.inGroup then
					local unit = ReRecount:FindUnitFromFlags(name,nameFlags)
					combatant.type = "Grouped"
					combatant.class, combatant.enClass=UnitClass(unit)
					combatant.level = UnitLevel(unit)
				-- Handle Friendly ungrouped combatants
				else
					combatant.type = "Ungrouped"
					local unit = ReRecount:FindTargetedUnit(name)
					if unit then
						combatant.class, combatant.enClass=UnitClass(unit)
						combatant.level = UnitLevel(unit)
					else
						combatant.enClass = "UNGROUPED" -- Check for target uid here
						combatant.level = 1
					end
				end
			else
				--ReRecount:Print("Got non-player grouped entity: "..name) -- Elsia: This proves to be pets!
				--ReRecount:Print(debugstack(2, 3, 2))
			end
				--combatant.unit=unit
				--combatant.level=UnitLevel(unit)
		-- Handle hostile combatants
		elseif combatant.isPlayer then
			combatant.type = "Hostile"
			local unit = ReRecount:FindTargetedUnit(name)
			if unit then
				combatant.class, combatant.enClass=UnitClass(unit)
				combatant.level = UnitLevel(unit)
			else
				combatant.enClass = "HOSTILE" -- Check for target uid here
				combatant.level = 1
			end
		elseif bit_band(nameFlags,COMBATLOG_OBJECT_NONE) ~= COMBATLOG_OBJECT_NONE then -- Mob units that were flag targets
			combatant.enClass="MOB"
--	combatant.unit=unit
			local unit = ReRecount:FindTargetedUnit(name)
			combatant.level=unit and UnitLevel(unit) or 1
			combatant.isTrivial=unit and UnitIsTrivial(unit) or nil
			if combatant.isTrivial then
				combatant.type="Trivial"
			elseif combatant.level==-1 then
				combatant.type="Boss"
			else
				combatant.type="Nontrivial"
			end
			combatant.enClass="MOB"
			--ReRecount:CombatantIsMob(combatant,unit)
		else
			combatant.type="Unknown"
			combatant.enClass="UNKNOWN"
		end
	end

--[[		else
				unit = ReRecount:FindTargetedUnit(name)
				if unit then -- Mob units that were otherwise raid targets
					if UnitIsPlayer(unit) then
						combatant.type = "Ungrouped"
						combatant.class, combatant.enClass=UnitClass(unit)
						combatant.unit=unit
						combatant.level=UnitLevel(unit)
					else
						ReRecount:CombatantIsMob(combatant,unit)
					end
				else -- Unidentifyable mobs
					ReRecount:DetermineType(name,nameFlags)
					--combatant.type="Unknown"
					combatant.checkLater=true
					combatant.level=0
				end
			end
		else
			unit = ReRecount:FindTargetedUnit(name)
			if unit then -- Mob units that were otherwise raid targets
				if UnitIsPlayer(unit) then
					combatant.type = "Ungrouped"
					combatant.class, combatant.enClass=UnitClass(unit)
					combatant.unit=unit
					combatant.level=UnitLevel(unit)
				else
					ReRecount:CombatantIsMob(combatant,unit)
				end
			end
			ReRecount:DetermineType(name,nameFlags)
	
			if combatant.type=="Pet" then
				combatant.enClass="PET"
			elseif not combatant.isPlayer then
				combatant.enClass="MOB"
			else
	
			-- Can't find Unit from this
				combatant.type="Unknown"
				combatant.enCLASS="UNKNOWN"
				combatant.isFriend=false
				combatant.checkLater=true
				combatant.level=0
			end
		end	
	end

	if combatant.type == "Pet" then
		combatant.enClass = "PET"
	elseif not combatant.enClass then
		combatant.enClass="UNKNOWN"
	end
	]]
--[[	if not combatant then
		if not ReRecount.db.profile.Filters.Data[combatant.type] or not ReRecount.db.profile.GlobalDataCollect or not ReRecount.CurrentDataCollect then
			--ReRecount:Print("purge")
--			combatant = nil -- Elsia: We don't keep initial combatant types which we don't collect. Should reduce data growth.
			return
--		else
			--ReRecount:Print("keep")
		end
	end]]

	--combatant.Init=true

	combatant.LastFightIn=ReRecount.db2.FightNum
	combatant.UnitLockout=ReRecount.CurTime
	ReRecount.db2.combatants[name]=combatant
	ReRecount:InitCombatant(name)
	
	--return ReRecount.db2.combatants[name]
end

function ReRecount:TestRetention(name)
	local combatant = ReRecount.db2.combatants[name]
	if combatant then
		if combatant.type=="Pet" and combatant.Owner and not ReRecount.db.profile.Filters.Data[ReRecount.db2.combatants[combatant.Owner].type] then
			--ReRecount:DPrint("Tested negative on pet: "..name.." "..combatant.Owner.." "..ReRecount.db2.combatants[combatant.Owner].type)
			return nil
		elseif not ReRecount.db.profile.Filters.Data[combatant.type] or not ReRecount.db.profile.GlobalDataCollect or not ReRecount.CurrentDataCollect then
			return nil
		else
			return true
		end
	end
	return nil
end

function ReRecount:CheckRetention(name)
	
	local combatant = ReRecount.db2.combatants[name]

	if combatant then
		if combatant.type=="Pet" and combatant.Owner and ReRecount.db2.combatants[combatant.Owner] and ReRecount.db2.combatants[combatant.Owner].type and not ReRecount.db.profile.Filters.Data[ReRecount.db2.combatants[combatant.Owner].type] then
			--ReRecount:DPrint("Not keeping pet: "..name.." "..combatant.Owner.." "..ReRecount.db2.combatants[combatant.Owner].type)
			ReRecount:DeleteCombatant(combatant.Owner) -- Elsia: We won't keep the pet if we don't keep the owner.
			return nil
		elseif not ReRecount.db.profile.Filters.Data[combatant.type] or not ReRecount.db.profile.GlobalDataCollect or not ReRecount.CurrentDataCollect then
			--ReRecount:Print("purge")
--			combatant = nil -- Elsia: We don't keep initial combatant types which we don't collect. Should reduce data growth.
			--return
			--ReRecount:DPrint("Dumping: "..name.." "..(combatant.type or "nil"))
			ReRecount:DeleteCombatant(name)
			--ReRecount.db2.combatants[name] = nil -- Don't retain
			return nil
		else
			--ReRecount:Print("keep: "..name)
			return true
--		else
		end
	end
	return nil
end

function ReRecount:InitCombatant(name)
	local combatant = ReRecount.db2.combatants[name]
	
	combatant.Fights = {}
end

function ReRecount:PartyPetOwnerFromGUID(who,petName,petGUID, petFlags)
	local ownerName, ownerGUID = ReRecount:FindOwnerPetFromGUID(petName,petGUID)
	--ReRecount:SetOwner(who,petName,ownerName, ownerGUID, ReRecount:CreateOwnerFlags(petFlags))
end

function ReRecount:SetOwner(who,petName,owner,ownerGUID,ownerFlags)

	who.Owner=owner

	if who.Owner then
		if not ReRecount.db2.combatants[who.Owner] then
			ReRecount:AddCombatant(who.Owner, nil,ownerGUID,ownerFlags)
		end
		if not ReRecount.db2.combatants[who.Owner].Pet then 
			ReRecount.db2.combatants[who.Owner].Pet = {}
		end
		
		for i,k in ipairs(ReRecount.db2.combatants[who.Owner].Pet) do -- Prevent multi-pet registration
			if k == petName then return end
		end
		table.insert(ReRecount.db2.combatants[who.Owner].Pet,petName)
	end
end

ReRecount.LastGroupCheck=0
function ReRecount:GroupCheck()
	local gettime = GetTime()

	if ReRecount.LastGroupCheck>gettime and ReRecount.LastGroupCheck-gettime <= 0.25 then
		return
	end
	ReRecount.LastGroupCheck=gettime+0.25

	for k,v in pairs(ReRecount.db2.combatants) do
		local Unit = ReRecount:GetUnitIDFromName(k)

		--ReRecount:Print(k.." "..(v.type or "nil").." "..(v.enClass or "nil"))
		--Must be in our group
		if Unit then
			v.unit=Unit
			v.isPlayer=UnitIsPlayer(Unit)
			v.inGroup=true
		else
			v.inGroup=false
			ReRecount:DeleteVersion(k)
		end

		ReRecount:DetermineType(k)

		if v.type=="Pet" then
			v.enClass="PET"
		elseif not v.isPlayer then
			v.enClass="MOB"
		elseif v.unit then
			if UnitExists(v.unit) and UnitName(v.unit)==k then
				v.Class, v.enClass=UnitClass(v.unit)
			else
				if not v.enClass then
					v.enClass="UNKNOWN"
				end
				v.unit=nil
			end
		end
	end

	ReRecount.Pets:ScanRoster()
end

local FilterWeights={}
local FilterMiddle=0

function ReRecount:CreateFilterWeights()
	local sum=0
	local val,widthUp,widthDown
	local DownAt=FilterSize-RampDown
	widthUp=1/RampUp
	widthDown=1/RampDown

	for i=1,FilterSize do
		if i<=RampUp then
			val=i*widthUp
			FilterWeights[#FilterWeights+1]=val
			sum=sum+val
		elseif i<=DownAt then
			FilterWeights[#FilterWeights+1]=1
			sum=sum+1
		else
			val=(FilterSize-i+1)*widthDown
			FilterWeights[#FilterWeights+1]=val
			sum=sum+val
		end
	end
	for i=1,FilterSize do
		FilterWeights[i]=FilterWeights[i]/sum
		FilterMiddle=FilterMiddle+i*FilterWeights[i]
	end

	FilterMiddle=math.floor(FilterMiddle)-1
end

local LinComp=0.3
function ReRecount:CheckIfAlmostLinear(TimeData, NewTime, NewVal)
	if #TimeData[1]<=1 or (NewTime-TimeData[1][#TimeData[1]])>10 then
		return false
	end

	local MidTime=TimeData[1][#TimeData[1]]
	local MidValue=TimeData[2][#TimeData[2]]

	local Width=NewTime-TimeData[1][#TimeData[1]-1]
	local Lerp=(MidTime-TimeData[1][#TimeData[1]-1])/Width
	local LinValue=Lerp*NewVal+(1-Lerp)*TimeData[2][#TimeData[2]-1]

	if Lerp>0.5 then
		Lerp=1-Lerp
	end

	local Weight=(MidValue-LinValue)/(Lerp*Width)

	if Weight<0 then
		Weight=-Weight
	end

	if Weight<LinComp then
		return true
	end
	return false
end

function ReRecount:TimeTick()
	if not ReRecount.db.profile.GlobalDataCollect or not ReRecount.CurrentDataCollect then
		return
	end
	
	local Time=time()
	local TimeCheck2=GetTime()-FilterSize-1
	local TimeCheck=Time-FilterSize-1
	local TimeFormatted

	--First check if combat status changed
	ReRecount:CheckCombat(Time)
	ReRecount.CurTime=Time
	ReRecount.UnitLockout=Time-5


	--Need to increment where data gets put and erase the old ones
	local PrevTimeStep=ReRecount.TimeStep
	ReRecount.TimeStep=ReRecount.TimeStep+1
	if ReRecount.TimeStep>FilterSize then
		ReRecount.TimeStep=1
	end

	if ReRecountThreat then ReRecountThreat:FindCurrentThreatTarget() end

	local gotdeleted
	
	for name,v in pairs(ReRecount.db2.combatants) do

--[[		if name == "Totemic Call" or name == "Fel Energy" or name == "Evocation" or name == "Furor" or name == "Bloodrage" or name =="Master of Elements" then
			ReRecount:Print(name .. " " .. ( owner or "nil").." ".. (nameGUID or "nil").." "..(nameFlags or "nil") .." "..(ownerGUID or "nil"))
			ReRecount:Print(debugstack(2, 3, 2))
		end]]
		
		if ReRecount.db.profile.GlobalDataCollect == true and ReRecount.CurrentDataCollect and ReRecount.db.profile.Filters.Data[v.type] and ReRecount.db.profile.Filters.TimeData[v.type] and v.TimeLast and v.TimeLast["OVERALL"] and v.TimeLast["OVERALL"]>=TimeCheck then -- Elsia: Added global collection switch
			--First threat data
			if ReRecountThreat then ReRecountThreat:UpdateCurrentThreat(v) end

			for k, v2 in pairs(v.TimeWindows) do
				local Temp
				local NewEntry=0

				if v.TimeLast and v.TimeLast[k] and v.TimeLast[k]>=TimeCheck then
					--Something is strange here but this works
					for k,v3 in ipairs(v2) do
						Temp = (FilterSize-k)+ReRecount.TimeStep
						if Temp>FilterSize then
							NewEntry=NewEntry+v3*FilterWeights[Temp-FilterSize]
						else
							NewEntry=NewEntry+v3*FilterWeights[Temp]
						end
					end
					--Need to set where we will be putting new data to 0
					v2[ReRecount.TimeStep]=0
				end

				v.TimeData = v.TimeData or {}
				v.TimeData[k] = v.TimeData[k] or {{},{}}
				local TimeData=v.TimeData[k]
				if NewEntry~=0 then
					--do we need a leading zero?
					if not v.TimeNeedZero or not v.TimeNeedZero[k] then
						TimeData[1][#TimeData[1]+1]=Time-1-FilterMiddle
						TimeData[2][#TimeData[2]+1]=0

						v.TimeNeedZero = v.TimeNeedZero or {}
						v.TimeNeedZero[k]=true
					end

					if not ReRecount:CheckIfAlmostLinear(TimeData, Time-FilterMiddle, NewEntry) then
						TimeData[1][#TimeData[1]+1]=Time-FilterMiddle
						TimeData[2][#TimeData[2]+1]=NewEntry
					else
						--If almost linear write over the old value
						TimeData[1][#TimeData[1] ]=Time-FilterMiddle
						TimeData[2][#TimeData[2] ]=NewEntry
					end
				elseif v.TimeNeedZero and v.TimeNeedZero[k] then --Check if we need a trailing zero
					TimeData[1][#TimeData[1]+1]=Time-FilterMiddle
					TimeData[2][#TimeData[2]+1]=0
					v.TimeNeedZero = v.TimeNeedZero or {}
					v.TimeNeedZero[k]=false
				end
			end
		end

		--Lets see if this unit needs to be updated
		if ReRecount.db.profile.GlobalDataCollect and ReRecount.CurrentDataCollect and v.checkLater and v.LastFightIn>(ReRecount.db2.FightNum-4) and v.UnitLockout<ReRecount.UnitLockout then
			v.UnitLockout=ReRecount.CurTime
			local Unit=ReRecount:FindUnit(name)
			if Unit then
				v.isFriend=UnitIsFriend("player",Unit)
				v.class, v.enClass=UnitClass(Unit)
				v.checkLater=false
				v.level=UnitLevel(Unit)
				v.isPlayer=UnitIsPlayer(Unit)
				v.isTrivial=UnitIsTrivial(Unit)
				v.unit=Unit

				--Must be in our group
				if UnitExists(name) then -- Elsia: This is much faster than roster scanning
					v.unit=name
					v.inGroup=true
				else
					v.inGroup=false
				end

				--ReRecount:Print("gc: "..name)
				ReRecount:DetermineType(name)

				if v.type=="Pet" then
					v.enClass="PET"
				elseif not v.isPlayer then
					v.enClass="MOB"
				end
			end
		end
		
		local idler = v.checkLater or v.type == "Unknown" or v.enClass == "UNKNOWN" or (not ReRecount.db.profile.Filters.Data[v.type] and not ReRecount.db.profile.Filters.Show[v.type])
		
		v.LastActive = v.LastActive or Time
		if idler and Time-v.LastActive > 30 then
			ReRecount:DeleteCombatant(name)
			gotdeleted = true
--		elseif idler then
--			ReRecount:Print(name.."t: "..(Time-v.LastActive))
		end
	
		if name == ReRecount.Player and not v.inGroup then
			ReRecount:GroupCheck()
			if not v.inGroup then
				ReRecount:DPrint("Yikes, can't get player into group status!")
			end
		end
	end
	
	if gotdeleted then
		ReRecount:SetMainWindowMode(ReRecount.db.profile.MainWindowMode)
		ReRecount:FullRefreshMainWindow()
	end

	
	
	if ReRecount.db.profile.AutoDelete and math.fmod(Time,10)==0 then
		ReRecount:DeleteOldTimeData(Time)
	end
end

function ReRecount:PutInCombat()
	ReRecount.InCombat=true
	ReRecount.InCombatT=ReRecount.CurTime
	ReRecount.InCombatF=date("%H:%M:%S")
	ReRecount.FightingWho=""
	ReRecount.FightingLevel=0

	if ReRecount.db.profile.MainWindow.AutoHide then
		ReRecount.MainWindow:Hide()
	end

	if --[[ReRecount.db.profile.Window.ShowCurAndLast and ]] ReRecount.db.profile.CurDataSet=="LastFightData" then
		ReRecount.db.profile.CurDataSet="CurrentFightData"
		
	end

	--If current mode is not overall data we need to reset disp table
	if ReRecount.db.profile.CurDataSet~="OverallData" then -- Elsia: Fix for double entry in CurAndLast mode
		ReRecount.MainWindow.DispTableSorted=ReRecount:GetTable()
		ReRecount.MainWindow.DispTableLookup=ReRecount:GetTable()
	end
end


function ReRecount:CheckCombat(Time)

	if ReRecount:CheckPartyCombatWithPets() then
		ReRecount:CheckVisible()
	elseif ReRecount.InCombat then
		ReRecount:LeaveCombat(Time)
	end
		
--[[
	local InCombat = ReRecount:CheckPartyCombatWithPets()
	
	if InCombat then ReRecount:CheckVisible() end -- Elsia: Check combat log visibility while in range
	
	if not InCombat and ReRecount.InCombat then --We were in combat but no longer
		ReRecount:LeaveCombat(Time)
--	else
--		ReRecount:Print("hmm")
	end
	]]
	
end

--Moved into a seperate function
function ReRecount:LeaveCombat(Time)

	if ReRecount.db.profile.MainWindow.AutoHide then
		ReRecount.RefreshMainWindow()
		ReRecount.MainWindow:Show()
	end

	--Did we actually fight someone?
	ReRecount.InCombat=false
	if (ReRecount.FightingWho=="") then
		return
	end

	-- Elsia: Only sync for actual fights
	if ReRecount.db.profile.GlobalDataCollect and ReRecount.CurrentDataCollect and ReRecount.db.profile.EnableSync  then -- Elsia: Only sync if collecting
		ReRecount:BroadcastLazySync()
	end

	if abs(Time-ReRecount.InCombatT)>3 then
		ReRecount.db2.CombatTimes[#ReRecount.db2.CombatTimes+1]={ReRecount.InCombatT,Time,ReRecount.InCombatF,date("%H:%M:%S"),ReRecount.FightingWho}

		--Save current data as the last fight
		ReRecount.Fights:MoveFights()

		if --[[ReRecount.db.profile.Window.ShowCurAndLast and]] ReRecount.db.profile.CurDataSet=="CurrentFightData" then
			ReRecount.db.profile.CurDataSet="LastFightData"
		end

		--If current mode is not overall data we need to reset disp table
		if ReRecount.db.profile.CurDataSet~="OverallData" then
			ReRecount.MainWindow.DispTableSorted=ReRecount:GetTable()
			ReRecount.MainWindow.DispTableLookup=ReRecount:GetTable()
		end

		ReRecount.db2.FightNum=ReRecount.db2.FightNum+1
	else
		ReRecount.Fights:CopyCurrentFights()

--		if --[[ReRecount.db.profile.Window.ShowCurAndLast and]] ReRecount.db.profile.CurDataSet=="CurrentFightData" then
--			ReRecount.db.profile.CurDataSet="LastFightData"
--		end
	end
	
end

function ReRecount:DeleteOldTimeData(Time)
	local DeleteTime=Time-60*ReRecount.db.profile.AutoDeleteTime

	for name,v in pairs(ReRecount.db2.combatants) do
		if v.TimeData then
			for _,Check in pairs(v.TimeData) do
				while Check[1][1] and Check[1][1]<DeleteTime do
					table.remove(Check[1],1)
					table.remove(Check[2],1)
				end
			end
		end
	end

	local Fights=ReRecount.db2.CombatTimes

	while Fights[1] and Fights[1][2]<DeleteTime do
		table.remove(Fights,1)
	end
end

function ReRecount:FixLastTime()
	local Time=GetTime()
	for name,v in pairs(ReRecount.db2.combatants) do
		v.LastAbility=Time
	end
end

function ReRecount:DelayedResizeWindows()
	ReRecount:ResizeMainWindow()
	--DelayedResizeWindows=nil
end

function ReRecount:HandleProfileChanges()
	if not ReRecount.MainWindow then
		return
	end

	ReRecount:SetBarTextures(ReRecount.db.profile.BarTexture)
	ReRecount:RestoreMainWindowPosition(ReRecount.db.profile.MainWindow.Position.x,ReRecount.db.profile.MainWindow.Position.y,ReRecount.db.profile.MainWindow.Position.w,ReRecount.db.profile.MainWindow.Position.h)
	ReRecount:ResizeMainWindow()
	ReRecount:FullRefreshMainWindow()
	ReRecount:SetupMainWindowButtons()

	if ReRecount.db.profile.GraphWindow then
		ReRecount.GraphWindow:ClearAllPoints()
		ReRecount.GraphWindow:SetPoint("TOPLEFT",UIParent,"TOPLEFT",ReRecount.db.profile.GraphWindowX,ReRecount.db.profile.GraphWindowY)
	end

	if ReRecount.db.profile.DetailWindow then
		ReRecount.DetailWindow:ClearAllPoints()
		ReRecount.DetailWindow:SetPoint("TOPLEFT",UIParent,"TOPLEFT",ReRecount.db.profile.DetailWindowX,ReRecount.db.profile.DetailWindowY)
	end

	ReRecount.profilechange = true
	ReRecount:CloseAllRealtimeWindows()
	
	if ReRecount.db.profile.RealtimeWindows then
		local Windows=ReRecount.db.profile.RealtimeWindows
		for k,v in pairs(Windows) do
			if v[8] and v[8] == true then -- Elsia: Make sure to respect closed windows as closed on startup
				ReRecount:CreateRealtimeWindowSized(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			end
		end
	end
	ReRecount.profilechange = nil

	ReRecount:ShowConfig()
end

function ReRecount:InitCombatData()
	ReRecount.db2.combatants = ReRecount.db2.combatants or {}
	ReRecount.db2.CombatTimes = ReRecount.db2.CombatTimes or {}
	ReRecount.db2.FoughtWho = ReRecount.db2.FoughtWho or {}
	
end

function ReRecount:OnInitialize()
	local acedb = LibStub:GetLibrary("AceDB-3.0")
	ReRecount.db = acedb:New("ReRecountDB", Default_Profile)
--	ReRecount.db2 = acedb:New("ReRecountPerCharDB", DefaultConfig)
	ReRecountPerCharDB = ReRecountPerCharDB or {}
	ReRecount.db2 = ReRecountPerCharDB
	ReRecount.db2.char = nil -- Elsia: Dump old db data hard.
	ReRecount.db2.global = nil
	ReRecount:InitCombatData()
	self.db.RegisterCallback( self, "OnNewProfile", "HandleProfileChanges" )
	self.db.RegisterCallback( self, "OnProfileReset", "HandleProfileChanges" )
	self.db.RegisterCallback( self, "OnProfileChanged", "HandleProfileChanges" )
	self.db.RegisterCallback( self, "OnProfileCopied", "HandleProfileChanges" )

	ReRecount.consoleOptions2.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(ReRecount.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("ReRecount", ReRecount.consoleOptions2, "ReRecount")
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ReRecount Report",ReRecount.consoleOptions2.args.report)
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ReRecount Realtime",ReRecount.consoleOptions2.args.realtime)
 	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ReRecount Blizz", ReRecount.consoleOptions)

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("ReRecount Profile", ReRecount.consoleOptions2.args.profile)
	
	AceConfigDialog:AddToBlizOptions("ReRecount Blizz", "ReRecount")
	AceConfigDialog:AddToBlizOptions("ReRecount Profile", "Profile", "ReRecount")
	AceConfigDialog:AddToBlizOptions("ReRecount Report", "Report", "ReRecount")
	AceConfigDialog:AddToBlizOptions("ReRecount Realtime", "Realtime", "ReRecount")
	
	if ReRecount.db2["version"]~=DataVersion then
		ReRecount:ResetData()

		ReRecount.db2.version=DataVersion
	end

	ReRecountTempTooltip = CreateFrame("GameTooltip", "ReRecountTempTooltip", nil, "GameTooltipTemplate")
	ReRecountTempTooltip:SetOwner(UIParent, "ANCHOR_NONE")

--[[	self.vars.Llines, self.vars.Rlines = {}, {}
	for i=1,30 do
		self.vars.Llines[i], self.vars.Rlines[i] = tt:CreateFontString(), tt:CreateFontString()
		self.vars.Llines[i]:SetFontObject(GameFontNormal)
		self.vars.Rlines[i]:SetFontObject(GameFontNormal)
		tt:AddFontStrings(self.vars.Llines[i], self.vars.Rlines[i])
	end]]
	
	
	ReRecount.TimeStep=1
	ReRecount.InCombat=false
	ReRecount.db.profile.CurDataSet=ReRecount.db.profile.CurDataSet or "OverallData"
	ReRecount.FightingLevel=0
	ReRecount.CurTime=time()

	ReRecount.CurrentDataCollect = true
	
	ReRecount:CreateMainWindow()

	ReRecount:CreateDetailWindow()
	ReRecount:CreateGraphWindow()
	ReRecount:CreateFilterWeights()
	ReRecount:InitOrder()

	ReRecount:SetupMainWindow()
	ReRecount:ScheduleTimer("DelayedResizeWindows",0.1)

	SM.RegisterCallback(ReRecount, "LibSharedMedia_Registered", "UpdateBarTextures")
	SM.RegisterCallback(ReRecount, "LibSharedMedia_SetGlobal", "UpdateBarTextures")
	if ReRecount.db.profile.BarTexture then
		ReRecount:SetBarTextures(ReRecount.db.profile.BarTexture)
	end

	if ReRecount.db.profile.GraphWindowX then
		ReRecount.GraphWindow:ClearAllPoints()
		ReRecount.GraphWindow:SetPoint("TOPLEFT",UIParent,"TOPLEFT",ReRecount.db.profile.GraphWindowX,ReRecount.db.profile.GraphWindowY)
	end

	if ReRecount.db.profile.DetailWindowX then
		ReRecount.DetailWindow:ClearAllPoints()
		ReRecount.DetailWindow:SetPoint("TOPLEFT",UIParent,"TOPLEFT",ReRecount.db.profile.DetailWindowX,ReRecount.db.profile.DetailWindowY)
	end

	if ReRecount.db.profile.RealtimeWindows then
		local Windows=ReRecount.db.profile.RealtimeWindows
		for k,v in pairs(Windows) do
			if v[8] and v[8] == true then -- Elsia: Make sure to respect closed windows as closed on startup
				ReRecount:CreateRealtimeWindowSized(v[1],v[2],v[3],v[4],v[5],v[6],v[7])
			end
		end
	end
	
	if ReRecountThreat then ReRecountThreat:IsThreatActive() end

	ReRecount.PlayerName=UnitName("player")
	ReRecount.PlayerGUID=nil
	ReRecount.PlayerLevel=UnitLevel("player")

	ReRecount.GuardiansGUIDs={} -- No need to db, guardians are not persistent GUIDs
	ReRecount.LatestGuardian=0

	if ReRecountThreat then ReRecount.ThreatTargetName="GLOBAL" end

	ReRecount.EventNum={}
	ReRecount.EventNum["DAMAGE"]={}
	ReRecount.EventNum["HEALING"]={}

--	ReRecount.db2.FightNum=0

--[[	for k,v in pairs(ReRecount.db2.combatants) do
		v.LastFightIn=0
	end]]
	
	if ReRecount.db.profile.EnableSync then
		ReRecount:ConfigComm()
	end
	
	ReRecount:FixLastTime()
	--ReRecount:ScaleWindows(ReRecount.db.profile.Scaling,true)
	ReRecount:ScaleWindows(ReRecount.db.profile.Scaling) -- Elsia: Bug: Even for first time we need in place code for scaling.

	ReRecount:LockWindows(ReRecount.db.profile.Locked)
end

function ReRecount:OnEnable(first)

	ReRecount.TimeTick() -- Elsia: Prevent that time data is not initialized when an event comes in before the first tick.
	
	if ReRecountThreat then ReRecountThreat:IsThreatActive() end
	ReRecount:ScheduleTimer("GroupCheck",5)

	ReRecount:ScheduleRepeatingTimer("TimeTick",1)

	--ReRecount:RegisterEvent("Threat_Activate") -- Elsia: Threat-1.0 deactivated until Threat-2.0 is ready.
	--ReRecount:RegisterEvent("Threat_Deactivate")

	ReRecount:RegisterEvent("UNIT_PET")
	ReRecount:RegisterEvent("PLAYER_PET_CHANGED")

	ReRecount:RegisterEvent("ZONE_CHANGED_NEW_AREA","DetectInstanceChange") -- Elsia: This is needed for zone change deletion and collection

	ReRecount:DetectInstanceChange() -- Elsia: We need to do this regardless for Zone filtering.

	if ReRecount.db.profile.DeleteJoinRaid or ReRecount.db.profile.DeleteJoinGroup then
		ReRecount:ScheduleTimer("InitPartyBasedDeletion", 5) -- Elsia: Wait 5 seconds before enabling auto-delete to prevent startup popups.
	end
	
	--Parser Events
	ReRecount:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED","CombatLogEvent")
	
	ReRecount.Pets:ScanRoster()

	ReRecount.HasEnabled=true
end

function ReRecount:OnDisable()
	if not ReRecount.HasEnabled then
		return
	end
	ReRecount.HasEnabled=false
	Parser:UnregisterAllEvents("ReRecount")
end

function ReRecount:Threat_Activate()
	ReRecount.ThreatActive=true
end

function ReRecount:Threat_Deactivate()
	ReRecount.ThreatActive=false
end

local Tables={}
function ReRecount:FreeTable(t)
	if type(t)~="table" then
		return
	end

	for k in pairs(t) do
		t[k]=nil
	end

	for _,v in pairs(Tables) do
		if v==t then
			return
		end
	end

	tinsert(Tables,t)
end

function ReRecount:FreeTableRecurse(t)
	--Check the table first before recursing
	for _,v in pairs(Tables) do
		if v==t then
			return
		end
	end

	for k in pairs(t) do
		if type(t[k])=="table" then
			ReRecount:FreeTableRecurse(t[k])
		end
		t[k]=nil
	end

	tinsert(Tables,t)
end

function ReRecount:FreeTableRecurseLimit(t,depth)
	--Check the table first before recursing
	if depth<0 then
		return
	end

	for k in pairs(t) do
		if type(t[k])=="table" then
			ReRecount:FreeTableRecurseLimit(t[k],depth-1)
		end
		t[k]=nil
	end

	tinsert(Tables,t)
end

function ReRecount:GetTable()
	local t
	if #Tables>0 then
		t=Tables[1]
		tremove(Tables,1)
		if #t>0 then
			ReRecount:Print("WARNING! For some reason there is "..#t.." entries left. There is probably a table in use that shouldn't have been freed")
		end
		return t
	else
		return {}
	end
end

function ReRecount:HowManyTables(str)
	if str==nil then
		str=""
	else
		str=str.." "
	end
	ReRecount:Print(str.."Free Tables: "..#Tables)
end

function ReRecount:ResetTableCache()
	Tables=ReRecount:GetTable()
end

function ReRecount:ResetPositions()
	ReRecount:ResetPositionAllWindows()
end

local TestPie
local Amount=0
function ReRecount:TestPie()
	TestPie:ResetPie()
	TestPie:AddPie(Amount,{0.0,1.0,0.0})
	TestPie:CompletePie({0.2,0.2,1.0})

	Amount=Amount+1
	if Amount>=100 then
		Amount=1
	end
end

local function TestPieChart()
	local Graph = LibStub:GetLibrary("LibGraph-2.0")
	local g=Graph:CreateGraphPieChart("TestPieChart",UIParent,"LEFT","LEFT",0,0,150,150)
	TestPie=g
	g:AddPie(35,{1.0,0.0,0.0})
	g:AddPie(21,{0.0,1.0,0.0})
	g:CompletePie({0.2,0.2,1.0})
	ReRecount:ScheduleRepeatingTimer("PieTest",ReRecount.TestPie,0)
end
