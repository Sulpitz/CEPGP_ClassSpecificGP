local origCEPGP_ListButton_OnClick = CEPGP_ListButton_OnClick
local origCEPGP_sendChatMessage = CEPGP_sendChatMessage
local origCEPGP_UpdateLootScrollBar = CEPGP_UpdateLootScrollBar
local origCEPGP_addAddonMsg = CEPGP_addAddonMsg
--GP_CLASS_TABLE,CEPGPCSGP_Player_Class

--/run CEPGP_distribute_popup:Show()

SLASH_CEPGPCSGP1 = "/cepcpcsgp"
SLASH_CEPGPCSGP2 = "/cepcsgp"
function SlashCmdList.CEPGPCSGP(msg, editbox) 
    if msg == "" then
        CEPCSGP_StaticPopupImport()
    elseif msg == "send" then 
        CEPCSGP_SendAll()
        CEPGP_print("Sending all Player Spec Data")
    elseif msg == "clear" then
        CEPGPCSGP_Player_Class = {}
        CEPGP_print("CEPCSGP Player Spec Table cleared")
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
    if GP_CLASS_TABLE[itemID] == nil then
        CEPGP_print("Item ID " .. itemID .. " not in Table")
        if CEPCSGP_ClassCP_Dropdown then
            CEPCSGP_ClassCP_Dropdown:Hide()
        end
        return 
    end
    CEPCSGP_ClassCP_Dropdown:Show()
    local classTable = {}

    for class, _ in pairs(GP_CLASS_TABLE[itemID]) do
        table.insert(classTable,class)
    end

    local defaultVal
    if CEPGPCSGP_Player_Class[player] then
        defaultVal = CEPGPCSGP_Player_Class[player]
        local itemGP = GP_CLASS_TABLE[itemID][defaultVal]['GP']
        CEPGP_distribute_GP_value:SetText(itemGP)
        CEPGP_distribute_popup_gp_full:SetText(itemGP)          
        origCEPGP_addAddonMsg("SetSpec;" .. player .. ";" .. CEPGPCSGP_Player_Class[player], "GUILD")
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
                local itemGP = GP_CLASS_TABLE[itemID][b.value]['GP']
                CEPGP_distribute_GP_value:SetText(itemGP)
                CEPGP_distribute_popup_gp_full:SetText(itemGP)    
                CEPGPCSGP_Player_Class[player] = b.value
                origCEPGP_addAddonMsg("SetSpec;" .. player .. ";" .. CEPGPCSGP_Player_Class[player], "GUILD")
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
	end
    --CEPGP_frame:SetWidth(800)
    _G["CEPGP_distribute_raid_prio"] = CEPGP_distribute_item_tex:CreateFontString("CEPGP_distribute_raid_prio", "OVERLAY", "GameFontNormal")
    _G["CEPGP_distribute_raid_prio"]:SetPoint("LEFT",CEPGP_distribute_item_tex, "LEFT",  635, -34)   
    _G["CEPGP_distribute_raid_prio"]:SetText("Prio")

    local CEPCSGP_EventFrame = CreateFrame("Frame")
    CEPCSGP_EventFrame:RegisterEvent('CHAT_MSG_ADDON')
    CEPCSGP_EventFrame:SetScript("OnEvent", CEPCSGP_EventHandler)
    --C_ChatInfo.RegisterAddonMessagePrefix(CEPCSGP_prefix)    

    CEPGP_distribute_popup:SetHeight(130)
    if not CEPGPCSGP_Player_Class then
        CEPGPCSGP_Player_Class = {}
    end
    createDropdown()
end

function CEPCSGP_SendAll()
    for name, spec in pairs(CEPGPCSGP_Player_Class) do        
        origCEPGP_addAddonMsg("SetSpec;" .. name .. ";" .. spec, "GUILD")
    end
end

function CEPCSGP_EventHandler(self, event, ...)
    local prefix, message, cannel, _, sender = ...

    --if sender == UnitName("player") then do return end end

    if event == "CHAT_MSG_ADDON" and prefix == "CEPGP" then 
        local args = CEPGP_split(message, ";");
        if args[1] == "SetSpec" then
            CEPGPCSGP_Player_Class[args[2]] = args[3]
            CEPGP_print("SetSpec: [" .. args[2] .. "] = " .. args[3])
        end
    end

end

-- [[ CEPGP Hook ]] --
function CEPGP_ListButton_OnClick_Hook(obj, button)
	if CEPGP_DFB_Distributing and button == "LeftButton" then
        if strfind(obj, "LootDistButton") then
            local player = _G[_G[obj]:GetName() .. "Info"]:GetText()
            print("Click", player)
            local itemID = CEPGP_getItemID(_G["CEPGP_distribute_item_name"]:GetText())
            refreshDropdown(player, itemID)
        end
	end
	origCEPGP_ListButton_OnClick(obj, button)
end

function CEPCSGP_addAddonMsg(message, channel, player)
    local args = CEPGP_split(message, ";")

    if args[1] == "CallItem"  and GP_CLASS_TABLE[tonumber(args[2])] then
        local itemID = tonumber(args[2])
        local messageEnd = ""

        for i = 4, #args do
            messageEnd = messageEnd .. ";" .. args[i]
        end  
        
        for index = 1, GetNumGroupMembers() do
            local name = GetRaidRosterInfo(index);
            if UnitIsConnected("raid" .. index) then
                local playerGP

                if CEPGPCSGP_Player_Class[name] and GP_CLASS_TABLE[itemID][CEPGPCSGP_Player_Class[name]] then
                    playerGP = GP_CLASS_TABLE[itemID][CEPGPCSGP_Player_Class[name]]['GP']
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

        if CEPGPCSGP_Player_Class[name] then            
            local itemID = tonumber(CEPGP_getItemID(_G["CEPGP_distribute_item_name"]:GetText()))
            local class = CEPGPCSGP_Player_Class[name]  
            if GP_CLASS_TABLE[itemID] and GP_CLASS_TABLE[itemID][class]and GP_CLASS_TABLE[itemID][class]['GP'] and GP_CLASS_TABLE[itemID][class]['Prio'] then
                local gp = GP_CLASS_TABLE[itemID][class]['GP']
                local prio = GP_CLASS_TABLE[itemID][class]['Prio']
                if prio ~= "" then prio = ", Prio: " .. prio end

                SendChatMessage(name .. " <" .. CEPGPCSGP_Player_Class[name] .. " " .. gp .. "GP> (" .. reason .. ", PR: " .. PR .. prio .. ", R: " .. roll .. ")", CEPGP.LootChannel)
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
        if CEPGPCSGP_Player_Class[name] then   
            local itemID = tonumber(CEPGP_getItemID(_G["CEPGP_distribute_item_name"]:GetText()))
            local class = CEPGPCSGP_Player_Class[name]
            if GP_CLASS_TABLE[itemID] and GP_CLASS_TABLE[itemID][class] and GP_CLASS_TABLE[itemID][class]['Prio'] then
                prio = GP_CLASS_TABLE[itemID][class]['Prio']
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
            _G["LootDistButton" .. index .. "Prio"]:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"})
            _G["LootDistButton" .. index .. "Prio"]:SetBackdropColor(0 ,0 ,0 ,0)
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

                local importstring = "GP_CLASS_TABLE = {" .. editbox:GetText() .. "}"

                local _, err = loadstring(importstring)

                if not err then
                    assert(loadstring(importstring))()
                    
                    
                    local idTable = {}
                    local i = 0         

                    local p = 0
                    for k, v in pairs(GP_CLASS_TABLE) do
                        p = p + 1
                    end
                    print("length GP_CLASS_TABLE:", p)

                    for id, _ in pairs (GP_CLASS_TABLE) do
                        i = i + 1
                        idTable[i] = id
                    end

                    i = 1
                    local limit = #idTable

                    --CEPCSGP_Timer = C_Timer.NewTicker(0.05, function()

                    --    local id = idTable[i]
                    --    local gp = GP_Table[id]
                    --
                    --    local link = CEPGP_getItemLink(id)

                    --    if id == nil then
                    --        CEPCSGP_Timer:Cancel()                            
                    --        CEPGP_print("Import finished!")
                    --    end
                    --    
                    --    if link ~= nil then     

                    --        if CEPGP_itemExists(id) then
                    --            CEPGP.Overrides[link] = gp
                    --            CEPGP_print(math.floor(i/limit*100) .. "%  " ..  i .. "/" .. limit .. "  GP value for " .. link .. " |c006969FFhas been overriden to " .. gp)
                    --        else
                    --            print("ERROR: Item " .. id .. " does not exist")
                    --        end
                    --   
                    --        i = i + 1
                    --        CEPGP_UpdateOverrideScrollBar()
                    --    end
                    --end)                
                    --CEPGP_override:Show()
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

