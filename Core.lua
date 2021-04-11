SLASH_CEPGPCSGP1 = "/cepgpcsgp"
SLASH_CEPGPCSGP2 = "/cepgsgp"
function SlashCmdList.CEPGPCSGP(msg, editbox) 
    if msg == "" then
        print("CEPGPCSGP")
    elseif msg == "t" then 
        CEPGP_override:Show()
    elseif msg == "test" then
        print("test")
        CEPIGP_Test()
    end
end


--/run CEPGP_distribute_popup:Show()




CEPGP_distribute_popup:Show()

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


local function createDropdown(opts)
    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
    local menu_items = opts['items'] or {}
    local title_text = opts['title'] or ''
    local dropdown_width = 0
    local default_val = opts['defaultVal'] or ''
    local change_func = opts['changeFunc'] or function (dropdown_val) end

    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 20, 10)

    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
        dd_title:SetText(item)
        local text_width = dd_title:GetStringWidth() + 20
        if text_width > dropdown_width then
            dropdown_width = text_width
        end
    end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        for key, val in pairs(menu_items) do
            info.text = val;
            info.checked = false
            info.menuList= key
            info.hasArrow = false
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                UIDropDownMenu_SetText(dropdown, b.value)
                b.checked = true
                change_func(dropdown, b.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return dropdown
end


local GP_Class_opts = {
    ['name']='GP_Class',
    ['parent']=CEPGP_distribute_popup,
    ['title']='GP Class',
    ['items']= {'10', '20', '30' },
    ['defaultVal']='', 
    ['changeFunc']=function(dropdown_frame, dropdown_val)
        CEPGP_distribute_GP_value:SetText(dropdown_val)
        CEPGP_distribute_popup_gp_full:SetText(dropdown_val)
        print(dropdown_val) -- Custom logic goes here, when you change your dropdown option.
    end
}

raidDD = createDropdown(GP_Class_opts)-- Don't forget to set your dropdown's points, we don't do this in the creation method for simplicities sake.
raidDD:SetPoint("LEFT", CEPGP_distribute_popup, "TOPLEFT", 0, -40);