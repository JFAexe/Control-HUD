-- Copyright 2020 Alexandr 'JFAexe' Konichenko
-- https://github.com/JFAexe/Control-HUD
-- Commercial use is allowed only by request

if not ControlHUD then return end

local font    = 'DermaDefault'


--------------------------------------------------------------------------------------------------
-- < Presets >
--------------------------------------------------------------------------------------------------
ControlHUD.Presets = ControlHUD.Presets or {}

ControlHUD.Presets.Default = {
    control_hud_enable = '1', control_hud_hiddef = '1', control_hud_showhp = '1',
    control_hud_showar = '1', control_hud_showam = '1', control_hud_showwi = '0',
    control_hud_showcr = '1', control_hud_showdt = '1', control_hud_sepbul = '1',
    control_hud_noanim = '0', control_hud_crosst = '1', control_hud_crosss = '1',
    control_hud_amarcr = '72', control_hud_amarct = '6', control_hud_hpsmul = '2',
    control_hud_arsmul = '3', control_hud_animtm = '4',
}

ControlHUD.Presets.Casual = {
    control_hud_enable = '1', control_hud_hiddef = '1', control_hud_showhp = '1',
    control_hud_showar = '1', control_hud_showam = '1', control_hud_showwi = '1',
    control_hud_showcr = '1', control_hud_showdt = '1', control_hud_sepbul = '0',
    control_hud_noanim = '1', control_hud_crosst = '3', control_hud_crosss = '1',
    control_hud_amarcr = '96', control_hud_amarct = '8', control_hud_hpsmul = '3',
    control_hud_arsmul = '4', control_hud_animtm = '4',
}


--------------------------------------------------------------------------------------------------
-- < Menu >
--------------------------------------------------------------------------------------------------
function ControlHUD:SettingsMenu(panel)
    function panel:Paint(w, h)
        ControlHUD:DrawRect(w - 2, h - 2, 1, 1, ControlHUD.BL)
        ControlHUD:DrawRect(w - 4, h - 4, 2, 2, ControlHUD.WH)
    end

    function panel:AddHelp(text)
        local Help = self:Help(text)
        Help:SetTextColor(ControlHUD.BL)
        Help:SetFont(font)
    end

    function panel:AddCheckBox(var, text)
        local Box = self:CheckBox(text, var)
        Box:SetTextColor(ControlHUD.BL)
        Box:SetFont(font)

        function Box.Button:Paint(w, h)
            ControlHUD:DrawRect(w, h, 0, 0, ControlHUD.BL)
            if self:GetChecked() then ControlHUD:DrawRect(w - 4, h - 4, 2, 2, ControlHUD.WH) end
        end
    end

    function panel:AddSlider(var, min, max, dec, text)
        local Slider = self:NumSlider(text, var, min, max, dec)

        local Area = Slider.TextArea
        Area:SetTextColor(ControlHUD.BL)
        Area:SetHighlightColor(ControlHUD.BL)
        Area:SetFont(font)

        local Label = Slider.Label
        Label:SetTextColor(ControlHUD.BL)
        Label:SetFont(font)

        function Slider.Slider:Paint(w, h)
            ControlHUD:DrawRect(w - 4, 2, 2, h * 0.5 - 1, ControlHUD.TG)
        end

        local Knob = Slider.Slider.Knob
        Knob:SetSize(8, 14)

        function Knob:Paint(w, h)
            ControlHUD:DrawRect(w, h, 0, 0, ControlHUD.BL)
            if self:IsHovered() then ControlHUD:DrawRect(w - 4, h - 4, 2, 2, ControlHUD.WH) end
        end
    end

    function panel:AddButton(text)
        local Button = self:Button(text)
        Button:SetFont(font)

        function Button:Paint(w, h)
            local bool = self:IsHovered()
            Button:SetTextColor(bool and ControlHUD.BL or ControlHUD.WH)
            ControlHUD:DrawRect(w, h, 0, 0, ControlHUD.BL)
            if bool then ControlHUD:DrawRect(w - 4, h - 4, 2, 2, ControlHUD.WH) end
        end
    
        return Button
    end

    local header = panel.Header
    header:SetTextColor(self.BL)
    header.UpdateColours = function(self, skin) return end

    panel:ClearControls()

    panel:AddControl('ComboBox', {
        MenuButton = '1',
        Label      = '#Presets',
        Folder     = 'Control HUD presets',
        CVars      = {''},
        Options    = {
            ['#Default'] = self.Presets.Default,
            ['Casual']   = self.Presets.Casual,
        }
    })

    local AddControl = {
        ['b'] = function(n, d) return panel:AddCheckBox(n, d.desc) end,
        ['i'] = function(n, d) return panel:AddSlider(n, d.min, d.max, 0, d.desc) end,
        ['f'] = function(n, d) return panel:AddSlider(n, d.min, d.max, 1, d.desc) end,
    }

    for name, data in SortedPairsByMemberValue(self.ConVars, 'id') do
        AddControl[data.type](name, data)
    end

    panel:AddHelp('Control HUD v' .. self.Version .. ' by ' .. self.Author)

    panel:AddButton('GitHub').DoClick = function() gui.OpenURL('https://github.com/JFAexe/Control-HUD') end

    panel:AddHelp('')
end

function ControlHUD:CreateMenu()
    spawnmenu.AddToolMenuOption('Utilities', 'User', 'ControlHUD', '#< Control HUD >', '', '', function(panel)
        self:SettingsMenu(panel)
    end)
end


--------------------------------------------------------------------------------------------------
-- < https://open.spotify.com/track/0uYPsl955ngOyNBzfp0EYg?si=RDkVMfgFSAOK5ogooJhbpw >
--------------------------------------------------------------------------------------------------
ControlHUD:AddHook('PopulateToolMenu', 'menu', ControlHUD.CreateMenu)