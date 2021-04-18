SLASH_CEPGPCSGP1 = "/cepcpcsgp"
SLASH_CEPGPCSGP2 = "/cepcsgp"
function SlashCmdList.CEPGPCSGP(msg, editbox) 
    if msg == "" then
        CEPCSGP_StaticPopupImport()
    elseif msg == "t" then 
        CEPGP_distribute_popup:Show()
        refreshDropdown()
    elseif msg == "test" then
        print("test")
        CEPCSGP_Test()
    end
end


local origCEPGP_ListButton_OnClick = CEPGP_ListButton_OnClick
local origCEPGP_sendChatMessage = CEPGP_sendChatMessage
--GP_CLASS_TABLE,CEPGPCSGP_Player_Class

--/run CEPGP_distribute_popup:Show()




--CEPGP_distribute_popup:Show()

--CEPGPCSGP_FontString = CEPGP_distribute_popup:CreateFontString(_, "MEDIUM", "GameFontNormalSmall")
--CEPGPCSGP_FontString:SetText("text!!!!!!!!!!!!!!!!!!!!!")    
--CEPGPCSGP_FontString:SetPoint('LEFT', CEPGP_distribute_popup, 'TOPLEFT', 15, -40)
--CEPGPCSGP_FontString:SetTextHeight(10)

--- Opts:
---     name (string): Name of the dropdown (lowercase)
---     parent (Frame): Parent frame of the dropdown.
---     items (Table): String table of the dropdown options.
---     defaultVal (String): String value for the dropdown to default to (empty otherwise).
---     changeFunc (Function): A custom function to be called, after selecting a dropdown option.



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
	end
    CEPGP_distribute_popup:SetHeight(130)
    if not CEPGPCSGP_Player_Class then
        CEPGPCSGP_Player_Class = {}
    end
    createDropdown()
end



-- [[ CEPGP Hook ]] --
function CEPGP_ListButton_OnClick_Hook(obj, button)
	if CEPGP_DFB_Distributing and button == "LeftButton" then
        if strfind(obj, "LootDistButton") then
            local player = _G[_G[obj]:GetName() .. "Info"]:GetText()
            local itemID = CEPGP_getItemID(_G["CEPGP_distribute_item_name"]:GetText())
            refreshDropdown(player, itemID)
        end
	end
	origCEPGP_ListButton_OnClick(obj, button)
end


function CEPCSGP_sendChatMessage(msg, channel)
	if not msg then return; end
    print(msg)
    if string.match(msg, ".+ %(%w+%) needs %(.+%)%. %(.+ PR%) %(Rolled %d+%)") then

        local name = string.match(msg, "(.+) %(%w+%) needs")
        local reason = string.match(msg, ".+ %(%w+%) needs %((.+)%)%. %(.+ PR%) %(Rolled %d+%)")
        local PR = string.match(msg, ".+ %(%w+%) needs %(.+%)%. %((.+) PR%) %(Rolled %d+%)")
        local roll = string.match(msg, ".+ %(%w+%) needs %(.+%)%. %(.+ PR%) %(Rolled (%d+)%)")
        print(name, reason, PR, roll)

        if CEPGPCSGP_Player_Class[name] then            
            local itemID = tonumber(CEPGP_getItemID(_G["CEPGP_distribute_item_name"]:GetText()))
            local class = CEPGPCSGP_Player_Class[name]     
            local gp = GP_CLASS_TABLE[itemID][class]['GP']
            local prio = GP_CLASS_TABLE[itemID][class]['Prio']
            if prio ~= "" then prio = ", Prio: " .. prio end

            SendChatMessage(name .. " <" .. CEPGPCSGP_Player_Class[name] .. " " .. gp .. "GP> (" .. reason .. ", PR: " .. PR .. prio .. ", R: " .. roll .. ")", CEPGP.LootChannel)
        else
            SendChatMessage(name .. " <" .. "No Class Set" .. " " .. gp .. "GP> (" .. reason .. ", PR: " .. PR .. ", Prio: " .. prio .. ", R: " .. roll .. ")", CEPGP.LootChannel)
        end
    else
        origCEPGP_sendChatMessage(msg, channel)
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

