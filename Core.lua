local origCEPGP_ListButton_OnClick = CEPGP_ListButton_OnClick
local origCEPGP_sendChatMessage = CEPGP_sendChatMessage
local origCEPGP_UpdateLootScrollBar = CEPGP_UpdateLootScrollBar
local origCEPGP_addAddonMsg = CEPGP_addAddonMsg
local origCEPGP_populateFrame = CEPGP_populateFrame
--CEPCSGP_ITEM_TABLE,CEPCSGP_PLAYER_CLASS_TABLE

--/run CEPGP_distribute_popup:Show()

SLASH_CEPGPCSGP1 = "/cepcpcsgp"
SLASH_CEPGPCSGP2 = "/cepcsgp"
function SlashCmdList.CEPGPCSGP(msg, editbox) 
    if msg == "" then
        CEPCSGP_StaticPopupImport()
    elseif msg == "send" then 
        CEPCSGP_SendAll()
        CEPGP_print("Sending all Player Spec Data")
    elseif msg == "clear class" then
        CEPCSGP_PLAYER_CLASS_TABLE = {}
        CEPGP_print("CEPCSGP Player Spec Table cleared")
    elseif msg == "clear item" then
        CEPCSGP_ITEM_TABLE = {}
        CEPGP_print("CEPCSGP Items cleared")
    end
end



local function createDropdown()
    CEPCSGP_ClassCP_Dropdown = CreateFrame("Frame", '$parent_GP_Class_dropdown', CEPGP_distribute_popup, 'UIDropDownMenuTemplate')    
    CEPCSGP_ClassCP_Dropdown:SetPoint("LEFT", CEPGP_distribute_popup, "TOPLEFT", 0, -60);

    CEPCSGP_ClassCP_Dropdown_title = CEPCSGP_ClassCP_Dropdown:CreateFontString(CEPCSGP_ClassCP_Dropdown, 'OVERLAY', 'GameFontNormal')
    CEPCSGP_ClassCP_Dropdown_title:SetPoint("TOPLEFT", 20, 10)    
    CEPCSGP_ClassCP_Dropdown_title:SetText('GP Class')

end


-- Button.lua 245 || Handlers.lua 80
-- CEPGP_announceResponses() : Utility.Lua 553
--CEPGP_addAddonMsg() CEÜGÜ_addAddonMsg 1463 called from Loot.lua 248
-- /cep log

local function refreshDropdown(player, itemID)
    itemID = tonumber(itemID)
    if CEPCSGP_ITEM_TABLE[itemID] == nil then
        CEPGP_print("Item ID " .. itemID .. " not in Table")
        if CEPCSGP_ClassCP_Dropdown then
            CEPCSGP_ClassCP_Dropdown:Hide()
        end
        return 
    end
    CEPCSGP_ClassCP_Dropdown:Show()
    local classTable = {}

    for class, _ in pairs(CEPCSGP_ITEM_TABLE[itemID]) do
        table.insert(classTable,class)
    end

    local defaultVal
    if CEPCSGP_PLAYER_CLASS_TABLE[player] then
        defaultVal = CEPCSGP_PLAYER_CLASS_TABLE[player]
        local itemGP = CEPCSGP_ITEM_TABLE[itemID][defaultVal]['GP']
        CEPGP_distribute_GP_value:SetText(itemGP)
        CEPGP_distribute_popup_gp_full:SetText(itemGP)          
        origCEPGP_addAddonMsg("SetSpec;" .. player .. ";" .. CEPCSGP_PLAYER_CLASS_TABLE[player], "GUILD")
    else 
        defaultVal = ''
    end

    --Update Dopdown Menu    
    local dropdown_width = 0
    for _, entry in pairs(classTable) do -- Sets the dropdown width to the largest item string width.
        CEPCSGP_ClassCP_Dropdown_title:SetText(entry)
        local text_width = CEPCSGP_ClassCP_Dropdown_title:GetStringWidth() + 20
        if text_width > dropdown_width then
            dropdown_width = text_width
        end
    end

    UIDropDownMenu_SetWidth(CEPCSGP_ClassCP_Dropdown, dropdown_width)
    UIDropDownMenu_SetText(CEPCSGP_ClassCP_Dropdown, defaultVal)
    CEPCSGP_ClassCP_Dropdown_title:SetText('GP Class')

    UIDropDownMenu_Initialize(CEPCSGP_ClassCP_Dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        for key, val in pairs(classTable) do
            info.text = val;
            info.checked = false
            info.menuList= key
            info.hasArrow = false
            
            
            local classNamesTable = {"Warlock", "Druid", "Rogue", "Hunter", "Mage", "Priest", "Shaman", "Paladin", "Warrior",}
            for ID, class in pairs(classNamesTable) do
                if string.find(val, class) then                    
                        if class == "Warlock"  then
                            info.colorCode = "\124cff9482C9"
                        elseif class == "Druid"  then
                            info.colorCode = "\124cffFF7D0A"
                        elseif class == "Rogue"  then
                            info.colorCode = "\124cffFFF569"
                        elseif class == "Hunter"  then
                            info.colorCode = "\124cffABD473"
                        elseif class == "Mage"  then
                            info.colorCode = "\124cff69CCF0"
                        elseif class == "Shaman"  then
                            info.colorCode = "\124cff0070DE"
                        elseif class == "Priest"  then
                            info.colorCode = "\124cffFFFFFF"
                        elseif class == "Paladin"  then
                            info.colorCode = "\124cffF58CBA"
                        elseif class == "Warrior"  then
                            info.colorCode = "\124cffC79C6E"
                        end
                    break
                end
            end
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(CEPCSGP_ClassCP_Dropdown, b.value, b.value)
                UIDropDownMenu_SetText(CEPCSGP_ClassCP_Dropdown, b.value)
                b.checked = true
                local itemGP = CEPCSGP_ITEM_TABLE[itemID][b.value]['GP']
                CEPGP_distribute_GP_value:SetText(itemGP)
                CEPGP_distribute_popup_gp_full:SetText(itemGP)    
                CEPCSGP_PLAYER_CLASS_TABLE[player] = b.value
                origCEPGP_addAddonMsg("SetSpec;" .. player .. ";" .. CEPCSGP_PLAYER_CLASS_TABLE[player], "GUILD")
                CEPCSGP_UpdateLootScrollBar(true)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end



function CEPCSGP_Init()
    print("CEPCSGP INIT")
	if (_G.CEPGP) then
		_G.CEPGP_ListButton_OnClick = CEPGP_ListButton_OnClick_Hook
        _G.CEPGP_sendChatMessage = CEPCSGP_sendChatMessage
        _G.CEPGP_UpdateLootScrollBar = CEPCSGP_UpdateLootScrollBar
        _G.CEPGP_addAddonMsg = CEPCSGP_addAddonMsg
        _G.CEPGP_populateFrame = CEPCSGP_populateFrame
	end
    --CEPGP_frame:SetWidth(800)
    _G["CEPGP_distribute_raid_prio"] = CEPGP_distribute_item_tex:CreateFontString("CEPGP_distribute_raid_prio", "OVERLAY", "GameFontNormal")
    _G["CEPGP_distribute_raid_prio"]:SetPoint("LEFT",CEPGP_distribute_item_tex, "LEFT",  635, -34)   
    _G["CEPGP_distribute_raid_prio"]:SetText("Prio")

    if _G["CEPGP_ST_History"] then
        _G["CEPGP_ST_History"]:SetHeight(600)
    end

    local CEPCSGP_EventFrame = CreateFrame("Frame")
    CEPCSGP_EventFrame:RegisterEvent('CHAT_MSG_ADDON')
    CEPCSGP_EventFrame:RegisterEvent('CHAT_MSG_WHISPER')
    CEPCSGP_EventFrame:SetScript("OnEvent", CEPCSGP_EventHandler)
    --C_ChatInfo.RegisterAddonMessagePrefix(CEPCSGP_prefix)    

    CEPGP_distribute_popup:SetHeight(130)
    if not CEPCSGP_PLAYER_CLASS_TABLE then
        CEPCSGP_PLAYER_CLASS_TABLE = {}
    end
    createDropdown()
end

function CEPCSGP_EventHandler(self, event, ...)
    local prefix, message, cannel, _, sender = ...
    local arg1 = prefix

    --if sender == UnitName("player") then do return end end
    if event == "CHAT_MSG_ADDON" and prefix == "CEPGP" then 
        local args = CEPGP_split(message, ";");
        if args[1] == "SetSpec" then
            CEPCSGP_PLAYER_CLASS_TABLE[args[2]] = args[3]
            CEPGP_print("SetSpec: [" .. args[2] .. "] = " .. args[3])
        end
    elseif event == "CHAT_MSG_WHISPER" and CEPGP_Info.Loot.Distributing and CEPGP_Info.Loot.ItemsTable[sender] then
        if string.lower(arg1) == "pass" or string.lower(arg1) == "passe" then
            CEPGP_handleComms("CHAT_MSG_WHISPER", nil, sender, 6, CEPGP_Info.Loot.GUID)
            return;
        end
        for i = 1, 4 do
            if string.lower(arg1) == string.lower(CEPGP.Loot.GUI.Buttons[i][4]) then         
                CEPGP_handleComms("CHAT_MSG_WHISPER", nil, sender, i, CEPGP_Info.Loot.GUID)
                return;
            end
        end
    end
end

function CEPCSGP_SendAll()
    for name, spec in pairs(CEPCSGP_PLAYER_CLASS_TABLE) do        
        origCEPGP_addAddonMsg("SetSpec;" .. name .. ";" .. spec, "GUILD")
    end
end

-- [[ CEPGP Hook ]] --
function CEPGP_ListButton_OnClick_Hook(obj, button)
    
	if button == "LeftButton" then
        
        if strfind(obj, "LootDistButton") then
            local player = _G[_G[obj]:GetName() .. "Info"]:GetText()
            local itemID = CEPGP_getItemID(_G["CEPGP_distribute_item_name"]:GetText())
            refreshDropdown(player, itemID)
        end
	end
	origCEPGP_ListButton_OnClick(obj, button)
end

function CEPCSGP_addAddonMsg(message, channel, player)
    local args = CEPGP_split(message, ";")

    if args[1] == "CallItem"  and CEPCSGP_ITEM_TABLE[tonumber(args[2])] then
        local itemID = tonumber(args[2])
        local messageEnd = ""

        for i = 4, #args do
            messageEnd = messageEnd .. ";" .. args[i]
        end
                       
        --if all items have same GP send to Raid
        local lastGP = -1
        local differentGP = false
        for class, tbl in pairs(CEPCSGP_ITEM_TABLE[tonumber(args[2])]) do
            local gp = tonumber(tbl["GP"])
            if lastGP ~= gp then
                if lastGP == -1 then
                    lastGP = gp
                else
                    differentGP = true
                    break
                end
            end
        end
        if not differentGP then            
            message = args[1] .. ";" .. args[2] .. ";" .. lastGP .. messageEnd
            CEPGP_print("AddonMSG RAID")
            origCEPGP_addAddonMsg(message, channel, player)
        end

        for index = 1, GetNumGroupMembers() do
            local name = GetRaidRosterInfo(index);
            if UnitIsConnected("raid" .. index) then
                local playerGP

                if CEPCSGP_PLAYER_CLASS_TABLE[name] and CEPCSGP_ITEM_TABLE[itemID][CEPCSGP_PLAYER_CLASS_TABLE[name]] then
                    playerGP = CEPCSGP_ITEM_TABLE[itemID][CEPCSGP_PLAYER_CLASS_TABLE[name]]['GP']
                else 
                    playerGP = 9999
                end
                --print("  ", name .. ", " .. channel .. ", " , player)
                --print("   MSG Orig:",   message)
                message = args[1] .. ";" .. args[2] .. ";" .. playerGP .. messageEnd
                --print("   MSG New:",   message)

                origCEPGP_addAddonMsg(message, "WHISPER", name);

                if name == UnitName("player") then
                    _G["CEPGP_respond_gp_value"]:SetText(playerGP)
                    if CEPGP_Info.Guild.Roster[name] then
                        local gindex = CEPGP_getIndex(name);
                        local EP, GP = CEPGP_getEPGP(name, gindex);
                        local actualPR = math.floor((EP/GP)*100)/100
                        local potentialPR = math.floor((EP/(GP+playerGP))*100)/100
                        prChangeText = "PR: " .. actualPR .. " -> " .. potentialPR;
                    end
                    _G["CEPGP_respond_gp_change"]:SetText(prChangeText)
                end
            end
        end        
        
        C_Timer.After(0.5, function()            
            _G["CEPGP_distribute_GP_value"]:Hide()
            _G["CEPGP_distribute_GP_head"]:Hide()
        end)
    else
        origCEPGP_addAddonMsg(message, channel, player)
    end
end

function CEPCSGP_sendChatMessage(msg, channel)
	if not msg then return; end
    if string.match(msg, ".+ %(%w+%) needs %(.+%)%. %(.+ PR%) %(Rolled %d+%)") then

        local name = string.match(msg, "(.+) %(%w+%) needs")
        local reason = string.match(msg, ".+ %(%w+%) needs %((.+)%)%. %(.+ PR%) %(Rolled %d+%)")
        local PR = string.match(msg, ".+ %(%w+%) needs %(.+%)%. %((.+) PR%) %(Rolled %d+%)")
        local roll = string.match(msg, ".+ %(%w+%) needs %(.+%)%. %(.+ PR%) %(Rolled (%d+)%)")

        if CEPCSGP_PLAYER_CLASS_TABLE[name] then            
            local itemID = tonumber(CEPGP_getItemID(_G["CEPGP_distribute_item_name"]:GetText()))
            local class = CEPCSGP_PLAYER_CLASS_TABLE[name]  
            if CEPCSGP_ITEM_TABLE[itemID] and CEPCSGP_ITEM_TABLE[itemID][class]and CEPCSGP_ITEM_TABLE[itemID][class]['GP'] and CEPCSGP_ITEM_TABLE[itemID][class]['Prio'] then
                local gp = CEPCSGP_ITEM_TABLE[itemID][class]['GP']
                local prio = CEPCSGP_ITEM_TABLE[itemID][class]['Prio']
                if prio ~= "" then prio = ", Prio: " .. prio end

                SendChatMessage(name .. " <" .. CEPCSGP_PLAYER_CLASS_TABLE[name] .. " " .. gp .. "GP> (" .. reason .. ", PR: " .. PR .. prio .. ", R: " .. roll .. ")", CEPGP.LootChannel)
            else 
                origCEPGP_sendChatMessage(msg, channel)
            end
        else
            SendChatMessage(name .. " <" .. "no class set" .."> (" .. reason .. ", PR: " .. PR .. ", Prio: unknown, R: " .. roll .. ")", CEPGP.LootChannel)
        end
    else
        origCEPGP_sendChatMessage(msg, channel)
    end
end

function CEPCSGP_UpdateLootScrollBar(PRsort, sort)
    origCEPGP_UpdateLootScrollBar(PRsort, sort)
    local index = 1

    while(true) do
        
        if not _G["LootDistButton" .. index] then break end

        local name =  _G["LootDistButton" .. index .. "Info"]:GetText()
        local prio = "no class set"
        if CEPCSGP_PLAYER_CLASS_TABLE[name] then   
            local itemID = tonumber(CEPGP_getItemID(_G["CEPGP_distribute_item_name"]:GetText()))
            local class = CEPCSGP_PLAYER_CLASS_TABLE[name]
            if CEPCSGP_ITEM_TABLE[itemID] and CEPCSGP_ITEM_TABLE[itemID][class] and CEPCSGP_ITEM_TABLE[itemID][class]['Prio'] then
                prio = CEPCSGP_ITEM_TABLE[itemID][class]['Prio']
            else
                prio = ""
            end
        end
        if not _G["LootDistButton" .. index .. "Prio"] then
            _G["LootDistButton" .. index .. "PrioFontstring"] = _G["LootDistButton" .. index]:CreateFontString("LootDistButton" .. index .. "PrioFontstring", "OVERLAY", "GameFontHighlightSmall")
            _G["LootDistButton" .. index .. "PrioFontstring"]:SetPoint("LEFT",_G["LootDistButton" .. index], "LEFT",  650, 0) 
            
            _G["LootDistButton" .. index .. "Prio"] = CreateFrame("Button", "LootDistButton" .. index .. "Prio", _G["LootDistButton" .. index], nil)
            _G["LootDistButton" .. index .. "Prio"]:SetWidth(60)
            _G["LootDistButton" .. index .. "Prio"]:SetHeight(15)
            _G["LootDistButton" .. index .. "Prio"]:SetPoint("LEFT", _G["LootDistButton" .. index], "LEFT", 650, 0)
            --_G["LootDistButton" .. index .. "Prio"]:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"})
            --_G["LootDistButton" .. index .. "Prio"]:SetBackdropColor(0 ,0 ,0 ,0)
            _G["LootDistButton" .. index .. "Prio"]:RegisterForDrag("LeftButton")
            _G["LootDistButton" .. index .. "Prio"]:SetFrameStrata("MEDIUM") 
            _G["LootDistButton" .. index .. "Prio"]:SetFrameLevel(7)         
            _G["LootDistButton" .. index .. "Prio"]:SetScript('OnLeave', function(self, motion)  
                GameTooltip:Hide()
            end)
        end
        _G["LootDistButton" .. index .. "PrioFontstring"]:SetText(prio)
                 
        _G["LootDistButton" .. index .. "Prio"]:SetScript('OnEnter', function(self, motion)  
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(prio)--_G["LootDistButton" .. index .. "Prio"]:GetText())--getglobal(self:GetName().."Text"):GetText())
            GameTooltip:Show()
        end)    

        index = index + 1
    end
end

function CEPCSGP_populateFrame(items)
    origCEPGP_populateFrame(items)
    if items and type(items) == table then
        i = 1
        for _, _ in pairs(items) do
            if _G[CEPGP_Info.Mode..'item'..i] then
                _G[CEPGP_Info.Mode..'itemGP'..i]:SetText("-1")
            end
            i = i + 1
        end
    end
end

function CEPCSGP_StaticPopupImport()    
    StaticPopupDialogs["CEPCSGP_IMPORT"] =
        StaticPopupDialogs["CEPCSGP_IMPORT"] or
        {
            text = "Paste Import String:",
            button1 = "Import",
            hasEditBox = 1,
            hasWideEditBox = 1,
            editBoxWidth = 350,
            preferredIndex = 3,
            OnShow = function(this, ...)
                this:SetWidth(420)
                --print("CEPCSGP Usage:\nPaste the ItemID and GP Values in this format seperated by ',' (without '): \n['itemID'] = 'GPvalue', 'itemID' = GPvalue, 'etc'")

                local editBox = _G[this:GetName() .. "WideEditBox"] or _G[this:GetName() .. "EditBox"]
              
                editBox:SetText("")
                editBox:SetFocus()
                editBox:HighlightText(false)

                local button = _G[this:GetName() .. "Button2"]
                button:ClearAllPoints()
                button:SetWidth(200)
                button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
            end,
            OnHide = NOP,
            OnAccept = function(this, ...)

                local editbox = _G[this:GetParent():GetName() .. "WideEditBox"] or _G[this:GetName() .. "EditBox"]

                local importstring = "CEPCSGP_ITEM_TABLE = {" .. editbox:GetText() .. "}"

                local _, err = loadstring(importstring)

                if not err then
                    assert(loadstring(importstring))()
                    
                    
                    local idTable = {}
                    local i = 0         

                    local p = 0
                    for itemID, data in pairs(CEPCSGP_ITEM_TABLE) do
                        p = p + 1
                    end
                    print("length CEPCSGP_ITEM_TABLE:", p)

                    for id, _ in pairs (CEPCSGP_ITEM_TABLE) do
                        i = i + 1
                        idTable[i] = id
                    end

                    i = 1
                    local limit = #idTable
                else
                    message("Import Error")
                    print("error: " .. err)                    
                end
            end,
            OnCancel = NOP,
            EditBoxOnEscapePressed = function(this, ...)
                this:GetParent():Hide()
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1
        }
        
    StaticPopup_Show("CEPCSGP_IMPORT", export_text)
end

CEPCSGP_Init()

