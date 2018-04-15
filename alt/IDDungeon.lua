--[[
## Interface: 70300
## Title: IDVerwalter/IDDungeon
## Autor: Loky
## Version: 0.1
--]]


IDDungeon = {}

function IDDungeon:Init(event, addon)
	print("Event: " .. event .. " und Addon: " ..addon)
	if (event == "ADDON_LOADED" and addon == "IDVerwalter") then
		IDDungeon:CreateGUI(IDDungeonFrame)
	end
end

local dungeonFrame =	CreateFrame("Frame", "IDDungeonFrame", UIParent)
dungeonFrame:SetScript("onEvent", IDDungeon.Init)
dungeonFrame:RegisterEvent("ADDON_LOADED")

function IDV_OnLoad(self)
---------
    dungeonFrame:RegisterEvent("ADDON_LOADED")
	
end









--dungeon Window

--CreateGUI
function IDDungeon:CreateGUI(frame)
	
	--window coommon 
	local frame = IDDungeon:CreateWindow(frame)

--Button	
	--Button Dungeon 
	local Dungeon = IDDungeon:CreateButton(frame, "DungeonButton", "Dungeon", 150, 35, 20, -50)
--	dungeonFrame:SetScript("OnClick" function() IDDungeon:CreateGUI(IDDungeonFrame) end)
	--Button Schlachtfelder
	local Schlachtfelder = IDDungeon:CreateButton(frame, "SchlachtfelderButton", "Schlachtfelder", 150, 35, 20, -90)
	--Button Schlatzüge
	local Schlatzuege = IDDungeon:CreateButton(frame, "SchlatzügeButton", "Schlatzüge", 150, 35, 20, -130)
	--Button WeltQuest
	local WeltQuest = IDDungeon:CreateButton(frame, "WeltQuestButton", "WeltQuest", 150, 35, 20, -170)
	--Button WeltBoss
	local WeltBoss = IDDungeon:CreateButton(frame, "WeltBossButton", "WeltBoss", 150, 35, 20, -210)
	--Button close 
	local close = IDDungeon:CreateButton(frame, "closeButton", nil, 30, 30, 165, -5,"UIPanelCloseButton")
	
	--EditBox Hinzufügen
	local editbox1 = IDDungeon:CreateEditBox(frame, "editbox1", 150, 35, 23, -250)

	--font greeting Uberschrift
	local greeting = IDDungeon:CreateFont(frame, "fontGreeting", "IDVerwalter", 15, -15, 25)
	--font greeting Version
	local Version = IDDungeon:CreateFont(frame, "fontVersion", "V0.1", 165, -325, 12)
end
--[[
function IDDungeon:CreateGUI(frame)
	--window coommon 
	local frame = IDDungeon:CreateWindow(frame)
	
	--Button2 close 
	local close = IDDungeon:CreateButton(frame, "closeButton", nil, 30, 30, 465, -5,"UIPanelCloseButton")
	
	
	--font greeting Uberschrift
	local greeting = IDDungeon:CreateFont(frame, "fontGreeting", "IDDungeon", 150, -15, 25)
	--font greeting Version
	local Version = IDDungeon:CreateFont(frame, "fontVersion", "V0.1", 465, -475, 12)
	--font tägliche Hero
	local täglicheHero = IDDungeon:CreateFont(frame, "täglicheHero", "tägliche Hero", 20, -50, 15)

	
end
--]]

--CreateWindow
function IDDungeon:CreateWindow(frame)
	frame:SetWidth(200)  			--Breite
	frame:SetHeight(350)			--Hoehe
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
function IDDungeon:CreateButton(frame, name, text, width, height, x, y, template)
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


--CreateEditBox
function IDDungeon:CreateEditBox(frame, name, width, height, x, y)
	local editBox = CreateFrame("EditBox", name, frame, "InputBoxTemplate")
	editBox:SetPoint("TOPLEFT", x, y)
	editBox:SetWidth(width)
	editBox:SetHeight(height)
	editBox:SetAutoFocus(false)
	editBox:Show()
	return(editbox)
end
	
	
--CreateFont
function IDDungeon:CreateFont(frame, name, text, x, y, size)
	if size == nil then
		size = 15
	end
	local fontString = frame:CreateFontString(name)
		fontString:SetPoint("TOPLEFT", x, y)
		fontString:SetFont("Fonts\\MORPHEUS.ttf", size, "")
		fontString:SetText(text)
	return (fontString)
end
