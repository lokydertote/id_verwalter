IDV_Prefs = nil

-- Binding Variables
BINDING_HEADER_IDVEFENDER             = "Battleground Defender";
BINDING_NAME_IDVEFENDER_OPTIONS       = "Options Screen";
BINDING_NAME_IDVEFENDER_ANNOUNCE1     = "1 incoming";
BINDING_NAME_IDVEFENDER_ANNOUNCE2     = "2 incoming";
BINDING_NAME_IDVEFENDER_ANNOUNCE3     = "3 incoming";
BINDING_NAME_IDVEFENDER_ANNOUNCE4     = "4 incoming";
BINDING_NAME_IDVEFENDER_ANNOUNCE5     = "5 incoming";
BINDING_NAME_IDVEFENDER_ANNOUNCE6     = "More than 5 incoming";
BINDING_NAME_IDVEFENDER_ANNOUNCE_HELP = "Need help";
BINDING_NAME_IDVEFENDER_ANNOUNCE_SAFE = "Node safe";


---------
function IDV_OnLoad(self)
---------
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("VARIABLES_LOADED")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    IDV_Msg("ID Verwalter loaded (ver "..GetAddOnMetadata("IDVefender", "Version").."). Type /IDV help for more information.\nConfigure messages using the options screen.")
    SLASH_IDVefender1 = "/IDVefender"
    SLASH_IDVefender2 = "/IDV"
    SlashCmdList["IDVefender"] = function(msg, editBox)
        IDV_SlashCommandHandler(msg, editBox)
    end
end


---------
function IDV_OnEvent(frame, event, ...)
---------
    if (event == "ADDON_LOADED") then
        if not IDV_Prefs then
            IDV_Settings_Default()
        else
            -- Update old BATTLEGROUND channel prefs to new INSTANCE_CHAT
            if IDV_Prefs.BGChat == "BATTLEGROUND" then
                IDV_Prefs.BGChat       = "INSTANCE_CHAT"
                IDV_Prefs.BGChatTemp   = "INSTANCE_CHAT"
            end
        end
        IDV_Prefs.version = GetAddOnMetadata("IDVefender", "Version")
        IDV_Opt_Frame_Setup()
        IDV_Opt_Frame_UpdateViews()
        if (IDV_Prefs.locale == nil) then
            IDV_Prefs.locale = GetLocale()
        end
        if (IDV_Prefs.locale ~= "enUS") then
            -- Make sure that the enUS locale is always loaded. Guarantees that there is a fallback
            -- for stuff that hasn't been translated.
            IDV_initLocale("enUS")
        end
        IDV_initLocale(IDV_Prefs.locale)
        IDV_initCustomSubZones()
    end
    if ((event == "ZONE_CHANGED_NEW_AREA") or (event == "ADDON_LOADED")) then
        if(IDV_isInBG()) then            
            -- SetMapToCurrentZone()
            IDV_Prefs.ShowUI = IDV_Toggle(true)
       else
            IDV_Prefs.ShowUI = IDV_Toggle(false)
       end
    end
end


---------
function IDV_initLocale(locale)
---------
    if (locale == "deDE") then
        IDV_init_deDE()
    elseif ((locale == "esMX") or (locale == "esES")) then
        IDV_init_esMX()
    elseif (locale == "frFR") then
        IDV_init_frFR()
    elseif (locale == "ruRU") then
        IDV_init_ruRU()
    elseif (locale == "zhCN") then
        IDV_init_zhCN()
    elseif (locale == "zhTW") then
        IDV_init_zhTW()
    else
        IDV_init_enUS()
    end
end


---------
function IDV_initCustomSubZones()
---------
	IDV_rcSilverShardMines = IDV_RcSMZone();
	IDV_rcDeepwindGorge = IDV_RcDwGZone();
end


---------
function IDV_StartMoving(self)
---------
    if (IDV_Prefs.movable == true) then
        self:StartMoving()
    end
end


---------
function IDV_StopMovingOrSizing(self)
---------
    self:StopMovingOrSizing()
end


---------
function IDV_Toggle_Movable()
---------
    if (IDV_Prefs.movable == true) then
        IDV_Prefs.movable = false
        Button11:SetText(" p ")
    else
        IDV_Prefs.movable = true
        Button11:SetText(" m ")
    end
end


---------
function IDV_SlashCommandHandler(msg, editBox)
---------
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
        DEFAULT_CHAT_FRAME:AddMessage("ID Verwalter Version "..GetAddOnMetadata("IDVefender", "Version"), 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("  /IDV options |cFFFFFFFF- to set announcement channel", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("  /IDV [show/hide] |cFFFFFFFF- show/hide window", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("  /IDV status |cFFFFFFFF- IDVefender status", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("clicking the o button will open the options screen", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("clicking the m or p button will toggle moving the window", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("clicking the x button will close the UI, but you can reopen it by typing /IDV", 1.0, 0.5, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage(" ", 1.0, 0.5, 0.0)
    end
end


---------
local function IDV_GetPlayerPosition()
---------
    local px, py = GetPlayerMapPosition("player")
    if px~=nil and py~=nil then
        px=px*100
        py=py*100
        return {px, py}
    end
    return nil
end


---------
local function IDV_GetSubZoneText()
---------
    if IDV_isInNoSubZoneBG() then
        -- Handle battlegrounds that don't have useful subzones.
        local zone = GetZoneText();
        local playerPos = IDV_GetPlayerPosition()

        -- DEFAULT_CHAT_FRAME:AddMessage("IDV debug: player position = {"..playerPos[1]..", "..playerPos[2].."}", 1.0, 0.0, 0.0)

        if playerPos~=nil then
            if zone == IDV_SM then
                local subZoneKey = IDV_rcSilverShardMines:insideZone(playerPos)
                if subZoneKey then
                    return IDV_SM_zones[subZoneKey]
                end
            elseif zone == IDV_DWG then
                local subZoneKey = IDV_rcDeepwindGorge:insideZone(playerPos)
                if subZoneKey then
                    return IDV_DWG_zones[subZoneKey]
                end
            end
        end
        return nil
    else
        return GetSubZoneText()
    end
end


---------
function IDV_NumCall(arg1)
---------
    local location = nil
    local call = ""
    
    if (not IDV_isInBG()) then
        IDV_Msg(IDV_OUT)
        return
    end
    
    location = IDV_GetSubZoneText()
    
    if (location ~= nil and location~="") then
        if (arg1==6) then
            call = IDV_INCPLUS
        elseif (arg1==7) then
            call = IDV_HELP
        elseif (arg1==8) then
            call = IDV_SAFE
        else 
            call = IDV_INC
            call = string.gsub(call, "$num", arg1)
        end
        call = string.gsub(call, "$base", location)
        
        local channel = IDV_Prefs.BGChat
        if (IDV_isInRaidBG()) then
            channel = IDV_Prefs.RaidChat
        end
        if (IDV_Prefs.preface == true) then
            call = "IDVefender: " .. call
        end
        if (channel == IDV_GENERAL) then
            local index, name = GetChannelName(IDV_GENERAL.." - "..GetZoneText())
            if (index~=0) then 
                SendChatMessage(call , "CHANNEL", nil, index)
            end
        elseif (channel == "SELF_WISPER") then
            SendChatMessage(call , "WHISPER", nil, UnitName("player"))
        else
            SendChatMessage(call, channel)
        end
    else
        IDV_Msg(IDV_AWAY)
    end
end


---------
function IDV_Msg(text)
---------
    if (text) then
        DEFAULT_CHAT_FRAME:AddMessage(text, 1, 0, 0)
        UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0, 1, 10) 
    end
end


---------
function IDV_isInRaidBG()
---------
    local zone = GetZoneText()
    local found = false
    if ((zone == IDV_WG) or (zone == IDV_TB)) then
        found = true
    end
    return found
end


---------
function IDV_isInBG()
---------
    local zone = GetZoneText()
    local found = false
    if ((zone == IDV_AV)  or (zone == IDV_AB)   or (zone == IDV_WSG)  or (zone == IDV_WSL) or 
        (zone == IDV_SWH) or (zone == IDV_EOTS) or (zone == IDV_SOTA) or (zone == IDV_IOC) or
        (zone == IDV_GIL) or (zone == IDV_TP)   or (zone == IDV_DMH)  or (zone == IDV_WHS)) then
        found = true
    elseif (IDV_isInRaidBG()) then
        found = true
    elseif (IDV_isInNoSubZoneBG()) then 
		found = true
	end
    return found
end


---------
function IDV_isInNoSubZoneBG()
---------
    local zone = GetZoneText()
    local found = false
	local playerPos = IDV_GetPlayerPosition()
	
	-- Make sure we can get our current position
	if playerPos~=nil then
		if (zone == IDV_SM) then
			found = true
		elseif (zone == IDV_DWG) then
			found = true
		end
	end
    return found
end


---------
function IDV_ShowStatus()
---------
    DEFAULT_CHAT_FRAME:AddMessage(" ", 1.0, 0.5, 0.0)
    DEFAULT_CHAT_FRAME:AddMessage("ID Verwalter Version |cFF00FF00"..GetAddOnMetadata("IDVefender", "Version").."|r Status", 1.0, 0.5, 0.0)
    
    if (IDV_Prefs.ShowUI == true) then
        DEFAULT_CHAT_FRAME:AddMessage("    UI Visible: |cFF00FF00Yes", 1.0, 0.5, 0.0)
    else
        DEFAULT_CHAT_FRAME:AddMessage("    UI Visible: |cFFFF0000No|r (/IDV to display)", 1.0, 0.5, 0.0)
    end
    DEFAULT_CHAT_FRAME:AddMessage("    Locale: |cFF00FF00"..IDV_Prefs.locale, 1.0, 0.5, 0.0)
    DEFAULT_CHAT_FRAME:AddMessage("    Battleground Channel: |cFF00FF00"..IDV_Prefs.BGChat, 1.0, 0.5, 0.0)
    DEFAULT_CHAT_FRAME:AddMessage("    World Zone Channel: |cFF00FF00"..IDV_Prefs.RaidChat, 1.0, 0.5, 0.0)
    DEFAULT_CHAT_FRAME:AddMessage("    Zone: |cFF00FF00"..GetZoneText().."|r (|cFF00FF00"..GetSubZoneText().."|r)", 1.0, 0.5, 0.0)
    if (IDV_isInBG()) then
        DEFAULT_CHAT_FRAME:AddMessage("    Current zone a BG zone? |cFF00FF00Yes", 1.0, 0.5, 0.0)
    else
        DEFAULT_CHAT_FRAME:AddMessage("    Current zone a BG zone? |cFFFF0000No", 1.0, 0.5, 0.0)
    end
    local tmpPos = IDV_GetPlayerPosition()
	if tmpPos~=nil then
		tmpPos = string.format("%.2f, %.2f", tmpPos[1], tmpPos[2])
	else
		tmpPos = "nil, nil"
	end
    DEFAULT_CHAT_FRAME:AddMessage("    Current location on map: |cFF00FF00"..tmpPos, 1.0, 0.5, 0.0)
    DEFAULT_CHAT_FRAME:AddMessage("    Battleground Zones: ", 1.0, 0.5, 0.0)
    DEFAULT_CHAT_FRAME:AddMessage("        "..IDV_AV..", "..IDV_AB..", "..IDV_WSG..","..IDV_EOTS..", ", 1.0, 1.0, 1.0)
    DEFAULT_CHAT_FRAME:AddMessage("        "..IDV_SOTA..", "..IDV_IOC..","..IDV_TP..", "..IDV_GIL..", ", 1.0, 1.0, 1.0)
    -- DEFAULT_CHAT_FRAME:AddMessage("        "..IDV_SM..", "..IDV_DWG, 1.0, 1.0, 1.0)
    DEFAULT_CHAT_FRAME:AddMessage("    World PVP Zones: ", 1.0, 0.5, 0.0)
    DEFAULT_CHAT_FRAME:AddMessage("        "..IDV_WG..", "..IDV_TB, 1.0, 1.0, 1.0)
    if (IDV_Prefs.preface == true) then
        DEFAULT_CHAT_FRAME:AddMessage("    Preface text |cFF00FF00IDVefender:|r will be shown before messages", 1.0, 0.5, 0.5)
    end
end


---------
function IDV_Toggle(state)
---------
    local frame  = getglobal("IDVefenderFrame")
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


---------
function IDV_Close()
---------
    IDV_Prefs.ShowUI = IDV_Toggle(false)
end


---------
function IDV_Options_Open()
---------
    IDV_Prefs.BGChatTemp   = IDV_Prefs.BGChat
    IDV_Prefs.RaidChatTemp = IDV_Prefs.RaidChat
    IDV_Opt_Frame_UpdateViews()
    InterfaceOptionsFrame_OpenToCategory(IDV_Opt_Frame)
end


---------
function IDV_Opt_Frame_OnLoad(IDV_Opt_Frame)
---------
    IDV_Opt_Frame.name    = "ID Verwalter"
    IDV_Opt_Frame.okay    = function (self) IDV_Opt_Frame_Okay(); end
    IDV_Opt_Frame.default = function (self) IDV_Settings_Default(); IDV_Opt_Frame_UpdateViews(); end
    InterfaceOptions_AddCategory(IDV_Opt_Frame)
end


---------
function IDV_Opt_Frame_OnShow(IDV_Opt_Frame)
---------
    -- Moved from IDV_Opt_Frame_Setup, so we don't initialize the drop downs if we don't need them.
    -- Might workaround some taint issues related to eight or more menu items in the dropdown.
    -- DEFAULT_CHAT_FRAME:AddMessage("IDV debug: Initializing drop down menus.", 1.0, 0.0, 0.0)
    UIDropDownMenu_Initialize(IDV_Opt_Drop1, IDV_Opt_Drop1_Initialize)
    UIDropDownMenu_Initialize(IDV_Opt_Drop2, IDV_Opt_Drop2_Initialize)
    UIDropDownMenu_Initialize(IDV_Opt_Drop3, IDV_Opt_Drop3_Initialize)
end


---------
function IDV_Opt_Frame_Okay()
---------
    IDV_Prefs.BGChat   = IDV_Prefs.BGChatTemp
    IDV_Prefs.RaidChat = IDV_Prefs.RaidChatTemp
end


---------
function IDV_Settings_Default()
---------
    IDV_Prefs = {}
    IDV_Prefs.Title        = GetAddOnMetadata("IDVefender", "Title")
    IDV_Prefs.RaidChat     = "RAID"
    IDV_Prefs.RaidChatTemp = "RAID"
    IDV_Prefs.BGChat       = "INSTANCE_CHAT"
    IDV_Prefs.BGChatTemp   = "INSTANCE_CHAT"
    IDV_Prefs.version      = GetAddOnMetadata("IDVefender", "Version")
    IDV_Prefs.preface      = false
    IDV_Prefs.movable      = true
    IDV_Prefs.ShowUI       = IDV_isInBG()
    IDV_Prefs.locale       = GetLocale()
end




IDV_Opt_Title = nil

IDV_Opt_Txt1  = nil
IDV_Opt_Drop1 = nil

IDV_Opt_Txt2  = nil
IDV_Opt_Drop2 = nil

IDV_Opt_Txt3  = nil
IDV_Opt_Drop3 = nil

IDV_Opt_Btn1  = nil

---------
function IDV_Opt_Frame_Setup()
---------
    if (IDV_Opt_Title == nil) then
        IDV_Opt_Title = IDV_Opt_Frame:CreateFontString( "IDV_Opt_Title", "ARTWORK", "GameFontNormalLarge" )
        IDV_Opt_Title:SetPoint( "TOPLEFT", 16, -16 )
        IDV_Opt_Title:SetText( IDV_Prefs.Title .. " V" .. GetAddOnMetadata("IDVefender", "Version"))
    end

    if (IDV_Opt_Txt1 == nil) then
        IDV_Opt_Txt1 = IDV_Opt_Frame:CreateFontString( "IDV_Opt_Txt1", "ARTWORK", "GameFontNormalSmall" )
        IDV_Opt_Txt1:SetPoint( "TOPLEFT", "IDV_Opt_Title", "BOTTOMLEFT", 16, -16 )
        IDV_Opt_Txt1:SetText( "Battleground announcement channel: " )
    end
    if (IDV_Opt_Drop1 == nil) then
        IDV_Opt_Drop1 = CreateFrame("Frame", "DropDown1", IDV_Opt_Frame, "UIDropDownMenuTemplate");
        IDV_Opt_Drop1:SetPoint("TOPLEFT", "IDV_Opt_Txt1", "TOPRIGHT", 0, 8)
        UIDropDownMenu_SetWidth(IDV_Opt_Drop1, 140)
    end

    if (IDV_Opt_Txt2 == nil) then
        IDV_Opt_Txt2 = IDV_Opt_Frame:CreateFontString( "IDV_Opt_Txt2", "ARTWORK", "GameFontNormalSmall" )
        IDV_Opt_Txt2:SetPoint( "TOPLEFT", "IDV_Opt_Txt1", "BOTTOMLEFT", 0, -32 )
        IDV_Opt_Txt2:SetText( "World Zone PVP announcement channel:" )
    end
    if (IDV_Opt_Drop2 == nil) then
        IDV_Opt_Drop2 = CreateFrame("Frame", "DropDown2", IDV_Opt_Frame, "UIDropDownMenuTemplate")
        IDV_Opt_Drop2:SetPoint("TOPLEFT", "DropDown1", "BOTTOMLEFT", 0, -10)
        UIDropDownMenu_SetWidth(IDV_Opt_Drop2, 140)
    end

    if (IDV_Opt_Txt3 == nil) then
        IDV_Opt_Txt3 = IDV_Opt_Frame:CreateFontString( "IDV_Opt_Txt3", "ARTWORK", "GameFontNormalSmall" )
        IDV_Opt_Txt3:SetPoint( "TOPLEFT", "IDV_Opt_Txt2", "BOTTOMLEFT", 0, -32 )
        IDV_Opt_Txt3:SetText( "Locale:" )
    end
    if (IDV_Opt_Drop3 == nil) then
        IDV_Opt_Drop3 = CreateFrame("Frame", "DropDown3", IDV_Opt_Frame, "UIDropDownMenuTemplate")
        IDV_Opt_Drop3:SetPoint("TOPLEFT", "DropDown2", "BOTTOMLEFT", 0, -10)
        UIDropDownMenu_SetWidth(IDV_Opt_Drop3, 140)
    end

    -- Moved to IDV_Opt_Frame_OnShow, so we don't initialize the drop downs if we don't need them.
    -- Might workaround some taint issues related to eight or more menu items in the dropdown.
    --UIDropDownMenu_Initialize(IDV_Opt_Drop1, IDV_Opt_Drop1_Initialize);
    --UIDropDownMenu_Initialize(IDV_Opt_Drop2, IDV_Opt_Drop2_Initialize)
    --UIDropDownMenu_Initialize(IDV_Opt_Drop3, IDV_Opt_Drop3_Initialize)

    IDV_displayLocaleMessages()

    if (IDV_Opt_Btn1 == nil) then
        IDV_Opt_Btn1 = CreateFrame("CheckButton", "IDVefenderPrefaceButton", IDV_Opt_Frame)
        IDV_Opt_Btn1:SetWidth(26)
        IDV_Opt_Btn1:SetHeight(26)
        IDV_Opt_Btn1:SetPoint("TOPLEFT", "IDV_Opt_Txt3",  "BOTTOMLEFT", 0, -16)
        IDV_Opt_Btn1:SetScript("OnClick", function(frame)
            local tick = frame:GetChecked()
            if tick then
                IDV_Prefs.preface = true
            else
                IDV_Prefs.preface = false
            end
        end)
        IDV_Opt_Btn1:SetHitRectInsets(0, -180, 0, 0)
        IDV_Opt_Btn1:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
        IDV_Opt_Btn1:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
        IDV_Opt_Btn1:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
        IDV_Opt_Btn1:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        local IDV_Opt_Btn1Text = IDV_Opt_Btn1:CreateFontString("IDV_Opt_Btn1Text", "ARTWORK", "GameFontHighlight")
        IDV_Opt_Btn1Text:SetPoint("LEFT", IDV_Opt_Btn1, "RIGHT", 0, 1)
        IDV_Opt_Btn1Text:SetText("Display |cFF00FF00IDVefender:|r before each message")
        IDV_Opt_Btn1:SetChecked(IDV_Prefs.preface)
    end
end


IDV_Opt_Messages  = nil
IDV_Opt_Safe      = nil
IDV_Opt_Inc       = nil
IDV_Opt_IncPlus   = nil
IDV_Opt_Help      = nil

---------
function IDV_displayLocaleMessages()
---------
    local call = ""

    IDV_initLocale(IDV_Prefs.locale)
    
    if (IDV_Opt_Messages == nil) then
        IDV_Opt_Messages = IDV_Opt_Frame:CreateFontString( "IDV_Opt_Messages", "ARTWORK", "GameFontNormalSmall" )
        IDV_Opt_Messages:SetPoint("TOPLEFT", "IDV_Opt_Txt3", "BOTTOMLEFT", 0, -64)
        IDV_Opt_Messages:SetText( "Messages:" )
    end
    if (IDV_Opt_Safe == nil) then
        IDV_Opt_Safe = IDV_Opt_Frame:CreateFontString( "IDV_Opt_Safe", "ARTWORK", "GameFontNormalSmall" )
        IDV_Opt_Safe:SetPoint("TOPLEFT", "IDV_Opt_Messages", "BOTTOMLEFT", 16, -16)
    end
    call = IDV_SAFE
    call = string.gsub(call, "$base", GetSubZoneText())
    IDV_Opt_Safe:SetText( "SAFE: |cFF00FF00" ..call )

    if (IDV_Opt_Inc == nil) then
        IDV_Opt_Inc = IDV_Opt_Frame:CreateFontString( "IDV_Opt_Inc", "ARTWORK", "GameFontNormalSmall" )
        IDV_Opt_Inc:SetPoint("TOPLEFT", "IDV_Opt_Messages", "BOTTOMLEFT", 16, -32)
    end
    call = IDV_INC
    call = string.gsub(call, "$num", 1)
    call = string.gsub(call, "$base", GetSubZoneText())
    IDV_Opt_Inc:SetText( "Incoming: |cFF00FF00" ..call )
    

    if (IDV_Opt_IncPlus == nil) then
        IDV_Opt_IncPlus = IDV_Opt_Frame:CreateFontString( "IDV_Opt_IncPlus", "ARTWORK", "GameFontNormalSmall" )
        IDV_Opt_IncPlus:SetPoint("TOPLEFT", "IDV_Opt_Messages", "BOTTOMLEFT", 16, -48)
    end
    call = IDV_INCPLUS
    call = string.gsub(call, "$base", GetSubZoneText())
    IDV_Opt_IncPlus:SetText( "Incoming: |cFF00FF00" ..call )
    
    if (IDV_Opt_Help == nil) then
        IDV_Opt_Help = IDV_Opt_Frame:CreateFontString( "IDV_Opt_Help", "ARTWORK", "GameFontNormalSmall" )
        IDV_Opt_Help:SetPoint("TOPLEFT", "IDV_Opt_Messages", "BOTTOMLEFT", 16, -64)
    end
    call = IDV_HELP
    call = string.gsub(call, "$base", GetSubZoneText())
    IDV_Opt_Help:SetText( "Help: |cFF00FF00" ..call )    
end



---------
function IDV_Opt_Drop1_Initialize()
---------
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Instance"
    info.checked = (IDV_Prefs.BGChatTemp == "INSTANCE_CHAT")
    function info.func(arg1, arg2)
        IDV_Prefs.BGChatTemp = "INSTANCE_CHAT"
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Raid"
    info.checked = (IDV_Prefs.BGChatTemp == "RAID")
    function info.func(arg1, arg2)
        IDV_Prefs.BGChatTemp = "RAID"
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Raid Warning"
    info.checked = (IDV_Prefs.BGChatTemp == "RAID_WARNING")
    function info.func(arg1, arg2)
        IDV_Prefs.BGChatTemp = "RAID_WARNING"
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)
    
    info = UIDropDownMenu_CreateInfo()
    info.text = "Party"
    info.checked = (IDV_Prefs.BGChatTemp == "PARTY")
    function info.func(arg1, arg2)
        IDV_Prefs.BGChatTemp = "PARTY"
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)
    
    info = UIDropDownMenu_CreateInfo()
    info.text = IDV_GENERAL
    info.checked = (IDV_Prefs.BGChatTemp == IDV_GENERAL)
    function info.func(arg1, arg2)
        IDV_Prefs.BGChatTemp = IDV_GENERAL
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Yell"
    info.checked = (IDV_Prefs.BGChatTemp == "YELL")
    function info.func(arg1, arg2)
        IDV_Prefs.BGChatTemp = "YELL"
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Self whisper (debug)"
    info.checked = (IDV_Prefs.BGChatTemp == "SELF_WISPER")
    function info.func(arg1, arg2)
        IDV_Prefs.BGChatTemp = "SELF_WISPER"
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)
end


---------
function IDV_Opt_Drop2_Initialize()
---------
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Raid"
    info.checked = (IDV_Prefs.RaidChatTemp == "RAID")
    function info.func(arg1, arg2)
        IDV_Prefs.RaidChatTemp = "RAID"
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Raid Warning"
    info.checked = (IDV_Prefs.RaidChatTemp == "RAID_WARNING")
    function info.func(arg1, arg2)
        IDV_Prefs.RaidChatTemp = "RAID_WARNING"
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)
    
    info = UIDropDownMenu_CreateInfo()
    info.text = "Party"
    info.checked = (IDV_Prefs.RaidChatTemp == "PARTY")
    function info.func(arg1, arg2)
        IDV_Prefs.RaidChatTemp = "PARTY"
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)
    
    info = UIDropDownMenu_CreateInfo()
    info.text = IDV_GENERAL
    info.checked = (IDV_Prefs.RaidChatTemp == IDV_GENERAL)
    function info.func(arg1, arg2)
        IDV_Prefs.RaidChatTemp = IDV_GENERAL
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Yell"
    info.checked = (IDV_Prefs.RaidChatTemp == "YELL")
    function info.func(arg1, arg2)
        IDV_Prefs.RaidChatTemp = "YELL"
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Self whisper (debug)"
    info.checked = (IDV_Prefs.RaidChatTemp == "SELF_WISPER")
    function info.func(arg1, arg2)
        IDV_Prefs.RaidChatTemp = "SELF_WISPER"
        IDV_Opt_Frame_UpdateViews()
    end
    UIDropDownMenu_AddButton(info)
end


---------
function IDV_Opt_Drop3_Initialize()
---------
    local info = UIDropDownMenu_CreateInfo()
    info.text = "enUS"
    info.checked = (IDV_Prefs.locale == "enUS")
    function info.func(arg1, arg2)
        IDV_Prefs.locale = "enUS"
        IDV_initLocale(IDV_Prefs.locale)
        UIDropDownMenu_SetText(IDV_Opt_Drop3, IDV_Prefs.locale)
        IDV_displayLocaleMessages()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "deDE"
    info.checked = (IDV_Prefs.locale == "deDE")
    function info.func(arg1, arg2)
        IDV_Prefs.locale = "deDE"
        IDV_initLocale(IDV_Prefs.locale)
        UIDropDownMenu_SetText(IDV_Opt_Drop3, IDV_Prefs.locale)
        IDV_displayLocaleMessages()
    end
    UIDropDownMenu_AddButton(info)
    
    info = UIDropDownMenu_CreateInfo()
    info.text = "esMX"
    info.checked = (IDV_Prefs.locale == "esMX")
    function info.func(arg1, arg2)
        IDV_Prefs.locale = "esMX"
        IDV_initLocale(IDV_Prefs.locale)
        UIDropDownMenu_SetText(IDV_Opt_Drop3, IDV_Prefs.locale)
        IDV_displayLocaleMessages()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "esES"
    info.checked = (IDV_Prefs.locale == "esES")
    function info.func(arg1, arg2)
        IDV_Prefs.locale = "esES"
        IDV_initLocale(IDV_Prefs.locale)
        UIDropDownMenu_SetText(IDV_Opt_Drop3, IDV_Prefs.locale)
        IDV_displayLocaleMessages()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "frFR"
    info.checked = (IDV_Prefs.locale == "frFR")
    function info.func(arg1, arg2)
        IDV_Prefs.locale = "frFR"
        IDV_initLocale(IDV_Prefs.locale)
        UIDropDownMenu_SetText(IDV_Opt_Drop3, IDV_Prefs.locale)
        IDV_displayLocaleMessages()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "ruRU"
    info.checked = (IDV_Prefs.locale == "ruRU")
    function info.func(arg1, arg2)
        IDV_Prefs.locale = "ruRU"
        IDV_initLocale(IDV_Prefs.locale)
        UIDropDownMenu_SetText(IDV_Opt_Drop3, IDV_Prefs.locale)
        IDV_displayLocaleMessages()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "zhCN"
    info.checked = (IDV_Prefs.locale == "zhCN")
    function info.func(arg1, arg2)
        IDV_Prefs.locale = "zhCN"
        IDV_initLocale(IDV_Prefs.locale)
        UIDropDownMenu_SetText(IDV_Opt_Drop3, IDV_Prefs.locale)
        IDV_displayLocaleMessages()
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "zhTW"
    info.checked = (IDV_Prefs.locale == "zhTW")
    function info.func(arg1, arg2)
        IDV_Prefs.locale = "zhTW"
        IDV_initLocale(IDV_Prefs.locale)
        UIDropDownMenu_SetText(IDV_Opt_Drop3, IDV_Prefs.locale)
        IDV_displayLocaleMessages()
    end
    UIDropDownMenu_AddButton(info)
end


---------
function IDV_Opt_Frame_UpdateViews()
---------
    if (IDV_Prefs.BGChatTemp == "INSTANCE_CHAT") then
        UIDropDownMenu_SetText(IDV_Opt_Drop1, "Instance")
    elseif (IDV_Prefs.BGChatTemp == "RAID") then
        UIDropDownMenu_SetText(IDV_Opt_Drop1, "Raid")
    elseif (IDV_Prefs.BGChatTemp == "RAID_WARNING") then
        UIDropDownMenu_SetText(IDV_Opt_Drop1, "Raid Warning")
    elseif (IDV_Prefs.BGChatTemp == "PARTY") then
        UIDropDownMenu_SetText(IDV_Opt_Drop1, "Party")
    elseif (IDV_Prefs.BGChatTemp == IDV_GENERAL) then
        UIDropDownMenu_SetText(IDV_Opt_Drop1, IDV_GENERAL)
    elseif (IDV_Prefs.BGChatTemp == "YELL") then
        UIDropDownMenu_SetText(IDV_Opt_Drop1, "Yell")
    elseif (IDV_Prefs.BGChatTemp == "SELF_WISPER") then
        UIDropDownMenu_SetText(IDV_Opt_Drop1, "Self whisper (debug)")
    end

    if (IDV_Prefs.RaidChatTemp == "RAID") then
        UIDropDownMenu_SetText(IDV_Opt_Drop2, "Raid")
    elseif (IDV_Prefs.RaidChatTemp == "RAID_WARNING") then
        UIDropDownMenu_SetText(IDV_Opt_Drop2, "Raid Warning")
    elseif (IDV_Prefs.RaidChatTemp == "PARTY") then
        UIDropDownMenu_SetText(IDV_Opt_Drop2, "Party")
    elseif (IDV_Prefs.RaidChatTemp == IDV_GENERAL) then
        UIDropDownMenu_SetText(IDV_Opt_Drop2, IDV_GENERAL)
    elseif (IDV_Prefs.RaidChatTemp == "YELL") then
        UIDropDownMenu_SetText(IDV_Opt_Drop2, "Yell")
    elseif (IDV_Prefs.RaidChatTemp == "SELF_WISPER") then
        UIDropDownMenu_SetText(IDV_Opt_Drop2, "Self whisper (debug)")
    end
    
    UIDropDownMenu_SetText(IDV_Opt_Drop3, IDV_Prefs.locale)

    IDV_Opt_Btn1:SetChecked(IDV_Prefs.preface)
    
    if (IDV_Prefs.movable == true) then
        Button11:SetText(" m ")
    else
        Button11:SetText(" p ")
    end
end
