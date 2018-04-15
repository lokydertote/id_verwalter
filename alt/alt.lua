    self:RegisterEvent("VARIABLES_LOADED")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	--]]
    IDV_Msg("ID Verwalter loaded (ver "..GetAddOnMetadata("IPVerwalter", "Version").."). Type /IDV help for more information.\nConfigure messages using the options screen.")
	SLASH_IDVerwalter1 = "/IDVerwalter"
    SLASH_IDVerwalter2 = "/IDV"
    SlashCmdList["IDVerwalter"] = function(msg, editBox)
        IDV_SlashCommandHandler(msg, editBox)
		end
		
		
		
		---------
function IDV_OnEvent(frame, event, ...)

    if (event == "ADDON_LOADED") then
        if not BGD_Prefs then
            BGD_Settings_Default()
        else
            -- Update old BATTLEGROUND channel prefs to new INSTANCE_CHAT
            if BGD_Prefs.BGChat == "BATTLEGROUND" then
                BGD_Prefs.BGChat       = "INSTANCE_CHAT"
                BGD_Prefs.BGChatTemp   = "INSTANCE_CHAT"
            end
        end
        BGD_Prefs.version = GetAddOnMetadata("BGDefender", "Version")
        BGD_Opt_Frame_Setup()
        BGD_Opt_Frame_UpdateViews()
        if (BGD_Prefs.locale == nil) then
            BGD_Prefs.locale = GetLocale()
        end
        if (BGD_Prefs.locale ~= "enUS") then
            -- Make sure that the enUS locale is always loaded. Guarantees that there is a fallback
            -- for stuff that hasn't been translated.
            BGD_initLocale("enUS")
        end
        BGD_initLocale(BGD_Prefs.locale)
        BGD_initCustomSubZones()
    end
    if ((event == "ZONE_CHANGED_NEW_AREA") or (event == "ADDON_LOADED")) then
        if(BGD_isInBG()) then            
            -- SetMapToCurrentZone()
            BGD_Prefs.ShowUI = BGD_Toggle(true)
       else
            BGD_Prefs.ShowUI = BGD_Toggle(false)
       end
    end
end


--[[Sprache
function IDV_initLocale(locale)

    if (locale == "deDE") then		--Deutsch
        IDV_init_deDE()
    elseif (locale == "enEN") then	--Englisch
        IDV_init_enUS()
    end
end
--]]

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

---------
function IDV_Toggle(state)
---------
    local frame  = getglobal("IDSelectionFrame")
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


-------
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




		
		
		