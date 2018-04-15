--[[
## Interface: 70300
## Title: IDVerwalter
## Autor: Loky
## Version: 0.1
--]]


IDSelection = {}

function IDSelection:Init(event, addon)
	print("Event: " .. event .. " und Addon: " ..addon)
	if (event == "ADDON_LOADED" and addon == "IDVerwalter") then
		IDSelection:CreateGUI(IDSelectionFrame)
	end
end

local selectionFrame =	CreateFrame("Frame", "IDSelectionFrame", UIParent)
selectionFrame:SetScript("onEvent", IDSelection.Init)
selectionFrame:RegisterEvent("ADDON_LOADED")

function IDV_OnLoad(self)
---------
    selectionFrame:RegisterEvent("ADDON_LOADED")
	--[[
    self:RegisterEvent("VARIABLES_LOADED")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	--]]
    IDV_Msg("ID Verwalter loaded (ver "..GetAddOnMetadata("IPVerwalter", "Version").."). Type /IDV help for more information.\nConfigure messages using the options screen.")
	SLASH_IDVerwalter1 = "/IDVerwalter"
    SLASH_IDVerwalter2 = "/IDV"
    SlashCmdList["IDVerwalter"] = function(msg, editBox)
        IDV_SlashCommandHandler(msg, editBox)
    end
end


--IPV_SlashCommandHandler
function IDV_SlashCommandHandler(msg, editBox)

    msg = strlower(msg)
    if (msg == "") then
        IDV_Prefs.ShowUI = IDV_Toggle()
    elseif (msg == "show") then
        IDV_Prefs.ShowUI = IDV_Toggle(true)
    elseif (msg == "hide") then
        IDV_Prefs.ShowUI = IDV_Toggle(false)
    elseif (msg == "status") then
        IDV_ShowStatus()
    elseif (msg == "options") or (msg == "o") then
        IDV_Options_Open()
    else
        DEFAULT_CHAT_FRAME:AddMessage("ID Verwalter Version "..GetAddOnMetadata("IDVerwalter", "Version"), 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("  /IDV options |cFFFFFFFF- to set announcement channel", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("  /IDV [show/hide] |cFFFFFFFF- show/hide window", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("  /IDV status |cFFFFFFFF- BGDefender status", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("clicking the o button will open the options screen", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("clicking the m or p button will toggle moving the window", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("clicking the x button will close the UI, but you can reopen it by typing /IDV", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage(" ", 1.0, 0.5, 0.0)
    end
end

function IDV_Msg(text)
---------
    if (text) then
        DEFAULT_CHAT_FRAME:AddMessage(text, 1, 0, 0)
        UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0, 1, 10) 
    end
end


--Selection Window

--CreateGUI
function IDSelection:CreateGUI(frame)
	
	--window coommon 
	local frame = IDSelection:CreateWindow(frame)
	
	--Button Dungeon 
	local Dungeon = IDSelection:CreateButton(frame, "DungeonButton", "Dungeon", 150, 35, 50, -50)

	--Button close 
	local close = IDSelection:CreateButton(frame, "closeButton", nil, 30, 30, 465, -5,"UIPanelCloseButton")
		
	--font greeting Uberschrift
	local greeting = IDSelection:CreateFont(frame, "fontGreeting", "IDVerwalter", 150, -15, 25)
	
	--font greeting Version
	local Version = IDSelection:CreateFont(frame, "fontVersion", "V0.1", 465, -475, 12)
end


--CreateWindow
function IDSelection:CreateWindow(frame)
	frame:SetWidth(500)  			--Breite
	frame:SetHeight(500)			--Hoehe
	frame:SetPoint("Center", 0, 0)	--Position
	frame:SetBackdrop(				--Fester
		{
			bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
			edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
			tile= true, tileSize = 32, edgeSize = 32,
			insets = {left = 4, right =4, top = 4, bottom = 4}
		}
	)	
	frame:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
	return (frame)
end


--CreateButton
function IDSelection:CreateButton(frame, name, text, width, height, x, y, template)
	if (template == nil) then
		template = "OptionsButtonTemplate"
	end
	local button = CreateFrame("Button", name, frame, template)
		button:SetPoint("TOPLEFT", x, y)
		button:SetWidth(width)
		button:SetHeight(height)
		button:SetText(text)
		return (button)
end


--CreateFont
function IDSelection:CreateFont(frame, name, text, x, y, size)
	if size == nil then
		size = 15
	end
	local fontString = frame:CreateFontString(name)
		fontString:SetPoint("TOPLEFT", x, y)
		fontString:SetFont("Fonts\\MORPHEUS.ttf", size, "")
		fontString:SetText(text)
	return (fontString)
end
