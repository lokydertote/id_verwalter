
function IDV_OnLoad(self)
	print(CalendarGetDate())
	print( GetNumSavedInstances() )
	a,b,c,d=GetInstanceLockTimeRemaining()
	for i=0,c do
		print (GetInstanceLockTimeRemainingEncounter(i))
	end
	print( GetInstanceLockTimeRemaining())
	print("Hello World")
    self:RegisterEvent("ADDON_LOADED")
    SLASH_IDVerwalter1 = "/IDVerwalter"
    SLASH_IDVerwalter2 = "/idv"
    SlashCmdList["IDVerwalter"] = function(msg, editBox)
        IDV_SlashCommandHandler(msg, editBox)
    end
end

function IDV_Dungeon(self)
	print("Dungeon Pressed")
	IDV_Toggle(false)
	IDV_Toggle(true,"DungeonFrame")
end

function IDV_PVP(self)
	print("|cffffcc00PVP Pressed")
	IDV_Toggle(false)
	IDV_Toggle(true,"PVPFrame")
end	

function PlayerBegruesung(self)
	local playerName = UnitName("player");
	local playerClass, englishClass = UnitClass("player");
	local color = ""
	print(englishClass)
		if englishClass == "WARRIOR" then
			color = "|cffC79C6E"
		elseif englishClass == "ROGUE" then
			color = "|cffFFF569"
		elseif englishClass == "PALADIN" then
			color = "|cffF58CBA"
		elseif englishClass == "HUNTER" then
			color = "|cffABD473"
		elseif englishClass == "PRIEST" then
			color = "|cffFFFFFF"
		elseif englishClass == "DEATHKNIGHT" then
			color = "|cffC41F3B"
		elseif englishClass == "SHAMAN" then
			color = "|cff0070DE"
		elseif englishClass == "MAGE" then
			color = "|cff69CCF0"
		elseif englishClass == "WARLOCK" then
			color = "|cff9482C9"
		elseif englishClass == "MONK" then
			color = "|cff00FF96"
		elseif englishClass == "DRUID" then
			color = "|cffFF7D0A"
		elseif englishClass == "DEMONHUNTER" then
			color = "|cffA330C9"
		end
	ChatFrame1:AddMessage(color .. 'Hallo lieber ' .. playerName .. ' bester ' .. playerClass .. ' von Azeroth.');
end

function PlayerIgnorse(self)
	local Iignnorsenummer = GetNumIgnores("player")
	print(Iignnorsenummer)	
end

function IDV_Close(self)

	print("close")
	IDV_Toggle(false)
	IDV_Toggle(false,"DungeonFrame")
	IDV_Toggle(false,"PVPFrame")
	IDV_Toggle(false,"OptFrame")
end

function IDV_Opt(self)

	print("Opt")
	IDV_Toggle(false)
	IDV_Toggle(false,"DungeonFrame")
	IDV_Toggle(false,"PVPFrame")
	IDV_Toggle(true,"OptFrame")
end

function IDV_Return(self)

	print("return")
	IDV_Toggle(true)
	IDV_Toggle(false,"DungeonFrame")
	IDV_Toggle(false,"PVPFrame")
	IDV_Toggle(false,"OptFrame")
end
--[[
function IDV_OnEvent(frame, event, ...)
---------
    if (event == "ADDON_LOADED") then
        if not IDV_Prefs then
            IDV_Settings_Default()
        end
        IDV_Prefs.version = GetAddOnMetadata("IDVefender", "Version")
    end

end
--]]
function IDV_Toggle(state,frame_name)
---------
	if not frame_name then 
	frame_name = "TestFrame"
	end
	
    local frame  = getglobal(frame_name)
    local status = nil
    if (frame) then
        if (state == false) then
            frame:Hide()
            status = false
        elseif (state == true) then
            frame:Show()
            status = true
        else
            if(frame:IsVisible()) then
                frame:Hide()
                status = false
            else
                frame:Show()
                status = true
            end
        end
        return status
    end
end

function IDV_SlashCommandHandler(msg, editBox)
---------
    msg = strlower(msg)
    if (msg == "") then
         IDV_Toggle()
    elseif (msg == "show") then
         IDV_Toggle(true)
    elseif (msg == "hide") then
         IDV_Toggle(false)
    end
end
--[[
function IDV_DungeonCheck(self)

end

function
CalendarGetRaidInfo (monthOffset, day, eventIndex)- returns name, calendarType, raidID, hour, minute, difficulty 
end
--]]