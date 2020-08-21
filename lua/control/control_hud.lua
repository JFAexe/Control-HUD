-- Copyright 2020 Alexandr 'JFAexe' Konichenko
-- https://github.com/JFAexe/Control-HUD
-- Commercial use is allowed only by request

ControlHUD = ControlHUD or {}

ControlHUD.Version = '1.0'
ControlHUD.Author  = 'JFAexe'
ControlHUD.HooksID = 'control_hud'


--------------------------------------------------------------------------------------------------
-- < Localizing >
--------------------------------------------------------------------------------------------------
local srf, drw, rnd, mth    = surface, draw, render, math
local hook, NewConv, GetVar = hook, CreateClientConVar, GetConVar

local NewHook, Lerp, insert           = hook.Add, Lerp, table.insert
local floor, clamp, rad, sin, cos     = mth.floor, mth.Clamp, mth.rad, mth.sin, mth.cos
local NoTexture, SetColor, ColorAlpha = drw.NoTexture, srf.SetDrawColor, ColorAlpha
local DrawRect, DrawRectRot, DrawPoly = srf.DrawRect, srf.DrawTexturedRectRotated, srf.DrawPoly
local DrawLine, NewFont, SimpleText   = srf.DrawLine, srf.CreateFont, drw.SimpleText


--------------------------------------------------------------------------------------------------
-- < Global variables >
--------------------------------------------------------------------------------------------------
ControlHUD.sw, ControlHUD.sh   = ScrW(), ScrH()
ControlHUD.swc, ControlHUD.shc = ControlHUD.sw * 0.5, ControlHUD.sh * 0.5

ControlHUD.TG = Color(20, 20, 20, 140)
ControlHUD.TW = Color(240, 240, 240, 40)
ControlHUD.TR = Color(255, 20, 20, 60)
ControlHUD.OR = Color(255, 89, 0)
ControlHUD.RD = Color(255, 20, 20)
ControlHUD.LB = Color(15, 173, 194)
ControlHUD.WH = Color(255, 255, 255)
ControlHUD.LG = Color(200, 200, 200)
ControlHUD.BL = Color(0, 0, 0)
ControlHUD.WS = Color(33, 44, 59)

ControlHUD.ConVars = {
    ['control_hud_enable'] = { id = 1, type = 'b', def = 1, min = 0, max = 1, desc = 'Enable Control HUD' },
    ['control_hud_hiddef'] = { id = 2, type = 'b', def = 1, min = 0, max = 1, desc = 'Disable default HUD' },
    ['control_hud_showhp'] = { id = 3, type = 'b', def = 1, min = 0, max = 1, desc = 'Display health bar' },
    ['control_hud_showar'] = { id = 4, type = 'b', def = 1, min = 0, max = 1, desc = 'Display armor bar' },
    ['control_hud_showam'] = { id = 5, type = 'b', def = 1, min = 0, max = 1, desc = 'Display ammunition bar' },
    ['control_hud_showwi'] = { id = 6, type = 'b', def = 0, min = 0, max = 1, desc = 'Display weapon information' },
    ['control_hud_showcr'] = { id = 7, type = 'b', def = 1, min = 0, max = 1, desc = 'Display crosshair' },
    ['control_hud_showdt'] = { id = 8, type = 'b', def = 1, min = 0, max = 1, desc = 'Display death screen effect' },
    ['control_hud_sepbul'] = { id = 9, type = 'b', def = 1, min = 0, max = 1, desc = 'Divide ammunition bar on segments' },
    ['control_hud_noanim'] = { id = 10, type = 'b', def = 0, min = 0, max = 1, desc = 'Disable fade animation for weapon related stuff' },
    ['control_hud_crosst'] = { id = 11, type = 'i', def = 1, min = 1, max = 5, desc = 'Crosshair type' },
    ['control_hud_amarcr'] = { id = 13, type = 'i', def = 72, min = 32, max = 128, desc = 'Ammunition bar radius' },
    ['control_hud_amarct'] = { id = 14, type = 'i', def = 6, min = 4, max = 12, desc = 'Ammunition bar thickness' },
    ['control_hud_crosss'] = { id = 12, type = 'f', def = 1, min = 0.5, max = 2, desc = 'Crosshair size multiplier' },
    ['control_hud_hpsmul'] = { id = 15, type = 'f', def = 2, min = 1, max = 4, desc = 'Health bar size multiplier' },
    ['control_hud_arsmul'] = { id = 16, type = 'f', def = 3, min = 1, max = 5, desc = 'Armor bar size multiplier' },
    ['control_hud_animtm'] = { id = 17, type = 'f', def = 4, min = 1, max = 6, desc = 'Fade animations time' },
}

ControlHUD.Crosshairs = {
    [1] = { -- Grip
        [1] = { w = 14, h = 2, ang = 45, x = -7, y = -7 },
        [2] = { w = 14, h = 2, ang = -45, x = 7, y = -7 },
        [3] = { w = 14, h = 2, ang = -45, x = -7, y = 7 },
        [4] = { w = 14, h = 2, ang = 45, x = 7, y = 7 },
    },
    [2] = { -- Spin
        [1] = { w = 20, h = 2, ang = 90, x = 0, y = -26 },
        [2] = { w = 20, h = 2, ang = 35, x = -22, y = 16 },
        [3] = { w = 20, h = 2, ang = -35, x = 22, y = 16 },
    },
    [3] = { -- Charge
        [1] = { w = 20, h = 2, ang = -60, x = -7, y = 3 },
        [2] = { w = 20, h = 2, ang = 60, x = 7, y = 3 },
        [3] = { w = 20, h = 2, ang = 0, x = 0, y = -9 },
    },
    [4] = { -- Pierce
        [1] = { w = 16, h = 2, ang = -45, x = -14, y = -14 },
        [2] = { w = 16, h = 2, ang = 45, x = 14, y = -14 },
        [3] = { w = 16, h = 2, ang = 45, x = -14, y = 14 },
        [4] = { w = 16, h = 2, ang = -45, x = 14, y = 14 },
    },
    [5] = { -- Shatter
        [1] = { w = 20, h = 2, ang = 90, x = -35, y = 0 },
        [2] = { w = 16, h = 2, ang = -50, x = -30, y = 16 },
        [3] = { w = 16, h = 2, ang = 50, x = -30, y = -16 },
        [4] = { w = 16, h = 2, ang = -50, x = 30, y = -16 },
        [5] = { w = 16, h = 2, ang = 50, x = 30, y = 16 },
        [6] = { w = 20, h = 2, ang = 90, x = 35, y = 0 },
    },
}

ControlHUD.HideElements = {
    ['CHudZoom']                  = true,
    ['CHudAmmo']                  = true,
    ['CHudHealth']                = true,
    ['CHudGeiger']                = true,
    ['CHudBattery']               = true,
    ['CHudCrosshair']             = true,
    ['CHUDQuickInfo']             = true,
    ['CHudSuitPower']             = true,
    ['CHudSquadStatus']           = true,
    ['CHudSecondaryAmmo']         = true,
    ['CHudDamageIndicator']       = true,
    ['CHudPoisonDamageIndicator'] = true,
}

ControlHUD.DeathEffect = {
    ['$pp_colour_addr']       = 0,
    ['$pp_colour_addg']       = 0,
    ['$pp_colour_addb']       = 0,
    ['$pp_colour_mulr']       = 255,
    ['$pp_colour_mulg']       = 0,
    ['$pp_colour_mulb']       = 0,
    ['$pp_colour_colour']     = 1,
    ['$pp_colour_contrast']   = 0.15,
    ['$pp_colour_brightness'] = -1,
}


--------------------------------------------------------------------------------------------------
-- < Local variables >
--------------------------------------------------------------------------------------------------
local lerpsizehp, lerpsizear, lerpsizeam, arhidetime, wehidetime, wepanim = 0, 0, 0, 0, 0, 0
local oldarmor, oldweap, oldclip, oldprim, oldsecn, oldprmf, oldsecf      = 0, 0, 0, 0, 0, 0, 0


--------------------------------------------------------------------------------------------------
-- < Utils >
--------------------------------------------------------------------------------------------------
function ControlHUD:AddHook(hook, name, func)
    if not func then return end

    NewHook(hook, self.HooksID .. '_' .. name, function(...)
        return func(self, ...)
    end)
end

function ControlHUD:GetConv(var, type)
    local CheckType = {
        ['i'] = function(v) return v:GetInt() end,
        ['b'] = function(v) return v:GetBool() end,
        ['f'] = function(v) return v:GetFloat() end,
    }

    return CheckType[type](GetVar(var))
end

function ControlHUD:UpdateVariables() -- < questionable / bad code >
    self.Enable = self:GetConv('control_hud_enable', 'b')
    self.HideGm = self:GetConv('control_hud_hiddef', 'b')
    self.Health = self:GetConv('control_hud_showhp', 'b')
    self.Armor  = self:GetConv('control_hud_showar', 'b')
    self.Ammo   = self:GetConv('control_hud_showam', 'b')
    self.WepInf = self:GetConv('control_hud_showwi', 'b')
    self.Crossh = self:GetConv('control_hud_showcr', 'b')
    self.Death  = self:GetConv('control_hud_showdt', 'b')
    self.Sepbul = self:GetConv('control_hud_sepbul', 'b')
    self.NoAnim = self:GetConv('control_hud_noanim', 'b')
    self.CrossT = self:GetConv('control_hud_crosst', 'i')
    self.AmArcR = self:GetConv('control_hud_amarcr', 'i')
    self.AmArcT = self:GetConv('control_hud_amarct', 'i')
    self.CrossS = self:GetConv('control_hud_crosss', 'f')
    self.HpSMul = self:GetConv('control_hud_hpsmul', 'f')
    self.ArSMul = self:GetConv('control_hud_arsmul', 'f')
    self.AnTime = self:GetConv('control_hud_animtm', 'f')
end

function ControlHUD:GetThirdpersonPos(x, y)
    local lp = LocalPlayer()

    if not lp:ShouldDrawLocalPlayer() then return x, y end

    local td  = {}
    td.start  = lp:GetShootPos()
    td.endpos = td.start + (lp:EyeAngles() + lp:GetPunchAngle()):Forward() * 16384
    td.filter = lp

    tr   = util.TraceLine(td)
    pos  = tr.HitPos:ToScreen()
    x, y = pos.x, pos.y

    return x, y
end

function ControlHUD:ColorAlphaAnim(color, anim, col)
    local result = ColorAlpha(color, clamp(color.a * anim, 0, color.a))

    return col and result or SetColor(result)
end

function ControlHUD:UpdateWeaponAnim(lp, wep)
    local clip    = wep:Clip1()
    local maxclip = wep:GetMaxClip1()
    local primar  = lp:GetAmmoCount(wep:GetPrimaryAmmoType())
    local second  = lp:GetAmmoCount(wep:GetSecondaryAmmoType())
    local nextpf  = wep:GetNextPrimaryFire()
    local nextsf  = wep:GetNextSecondaryFire()

    local CT = CurTime()

    -- < questionable / bad code >
    if oldweap ~= wep
    or oldclip ~= clip
    or oldprim ~= primar
    or oldsecn ~= second
    or oldprmf ~= nextpf
    or oldsecf ~= nextsf then
        wehidetime = CT + self.AnTime
        oldweap, oldclip = wep, clip
        oldprim, oldsecn = primar, second
        oldprmf, oldsecf = nextpf, nextsf
    end

    wepanim = self.NoAnim and 1 or wehidetime - CT
end

function ControlHUD:ApplyStencil()
    rnd.SetStencilReferenceValue(1)
    rnd.SetStencilCompareFunction(STENCIL_NEVER)
    rnd.SetStencilFailOperation(STENCIL_REPLACE)
end

function ControlHUD:RemoveStencil()
    rnd.SetStencilCompareFunction(STENCIL_NOTEQUAL)
    rnd.SetStencilFailOperation(STENCIL_KEEP)
end

function ControlHUD:ResetStencil()
    rnd.SetStencilWriteMask(0xFF)
    rnd.SetStencilTestMask(0xFF)
    rnd.SetStencilReferenceValue(0)
    rnd.SetStencilPassOperation(STENCIL_KEEP)
    rnd.SetStencilZFailOperation(STENCIL_KEEP)
    rnd.ClearStencil()
end


--------------------------------------------------------------------------------------------------
-- < Draw functions >
--------------------------------------------------------------------------------------------------
function ControlHUD:ShadowText(text, font, x, y, color, aligment)
    SimpleText(text, font, x + 1, y + 1, color[2], aligment[1], aligment[2])
    SimpleText(text, font, x, y, color[1], aligment[1], aligment[2])
end

function ControlHUD:DrawRect(w, h, x, y, col)
    SetColor(col)
    DrawRect(x, y, w, h)
end

function ControlHUD:Arc(x, y, r, startAng, endAng, step)
    local positions, ea = {}, 40

    positions[1] = { x = x, y = y }

    for i = startAng + ea, endAng + ea, step do
        insert(positions, {
            x = x + cos(rad(i)) * r,
            y = y + sin(rad(i)) * r
        })
    end

    return positions
end

function ControlHUD:DrawBar(x, y, basw, smtw, maxw, h, cols)
    self:DrawRect(maxw, h, x + 1, y + 1, cols[4])
    self:DrawRect(maxw, h, x, y, cols[3])
    self:DrawRect(smtw, h, x, y, cols[2])
    self:DrawRect(basw, h, x, y, cols[1])
end

function ControlHUD:DrawCross(x, y, cols)
    local s1, s2, mv = 18, 6, 6

    self:DrawRect(s1, s2, x + 1, y + mv + 1, cols[4])
    self:DrawRect(s2, s1, x + mv + 1, y + 1, cols[4])
    self:DrawRect(s1, s2, x, y + mv, cols[1])
    self:DrawRect(s2, s1, x + mv, y, cols[1])
end

function ControlHUD:DrawHealthBar(x, y, basw, smtw, maxw, h, cols)
    self:DrawBar(x, y, basw, smtw, maxw, h, cols)
    self:DrawCross(x - 27, y + 1, cols)
end

function ControlHUD:DrawCrosshairDot(x, y)
    local mul  = self.CrossS
    local sz   = 2 * mul
    local back = self:Arc(x, y, sz + 1, 0, 360, 1)
    local fore = self:Arc(x, y, sz, 0, 360, 1)

    NoTexture()
    SetColor(self.TG)
    DrawPoly(back)
    SetColor(self.WH)
    DrawPoly(fore)
end

function ControlHUD:DrawCrosshairParts(x, y)
    local cross = self.Crosshairs[self.CrossT]
    local mul   = self.CrossS

    NoTexture()

    for _, tbl in pairs(cross) do
        local px, py = tbl.x * mul, tbl.y * mul
        local pw, ph = tbl.w * mul, tbl.h * mul
        local pa     = tbl.ang

        self:ColorAlphaAnim(self.TG, wepanim)
        DrawRectRot(x + px, y + py, pw + 2, ph + 2, pa)

        self:ColorAlphaAnim(self.WH, wepanim)
        DrawRectRot(x + px, y + py, pw, ph, pa)
    end
end


--------------------------------------------------------------------------------------------------
-- < Elements >
--------------------------------------------------------------------------------------------------
function ControlHUD:DrawHealth(lp)
    local mul          = self.HpSMul
    local curhp, maxhp = lp:Health(), lp:GetMaxHealth()
    local fore, back   = clamp(curhp, 0, maxhp) * mul, maxhp * mul

    lerpsizehp = Lerp(FrameTime() * 4, lerpsizehp, fore)

    self:DrawHealthBar(120, self.sh - 120, fore, lerpsizehp, back, 20, {
        [1] = self.LB, [2] = self.RD, [3] = self.TW, [4] = self.TG
    })
end

function ControlHUD:DrawArmor(lp)
    local mul, CT, pos = self.ArSMul, CurTime(), 140
    local curar, maxar = lp:Armor(), 100
    local lowarmor     = curar <= floor(maxar * 0.25)
    local fore, back   = clamp(curar, 0, maxar) * mul, maxar * mul

    lerpsizear = Lerp(FrameTime() * 4, lerpsizear, fore)

    if oldarmor ~= curar then
        arhidetime = CT + self.AnTime
        oldarmor   = curar
    end

    if arhidetime < CT then return end

    local anim = arhidetime - CT
    local py   = anim < 0.1 and Lerp(CT * 3, pos, pos * anim * 10) or pos

    self:DrawBar(self.swc - back * 0.5, py, fore, lerpsizear, back, 15, {
        [1] = self:ColorAlphaAnim(self.WH, anim, true),
        [2] = self:ColorAlphaAnim(lowarmor and self.TR or self.LG, anim, true),
        [3] = self:ColorAlphaAnim(self.TW, anim, true),
        [4] = self:ColorAlphaAnim(self.TG, anim, true)
    })
end

function ControlHUD:DrawAmmo(lp, wep)
    local clip    = wep:Clip1()
    local maxclip = wep:GetMaxClip1()
    local lowammo = wep:Clip1() <= floor(maxclip * 0.2)

    if wepanim < 0 then return end

    if self.WepInf then -- < should just work >
        local name   = wep:GetPrintName()
        local primar = lp:GetAmmoCount(wep:GetPrimaryAmmoType())
        local second = lp:GetAmmoCount(wep:GetSecondaryAmmoType())

        local font   = 'ControlFont'
        local tx, ty = self.sw - 120 + 27, self.sh - 122
        local tc, ta = { 
            [1] = self:ColorAlphaAnim(self.WH, wepanim, true),
            [2] = self:ColorAlphaAnim(self.TG, wepanim, true)
        }, {
            [1] = TEXT_ALIGN_RIGHT,
            [2] = TEXT_ALIGN_RIGHT
        }

        if second > 0 then
            self:ShadowText(second, font, tx, ty, tc, ta)
            ty = ty - 20
        end

        if primar > 0 then
            self:ShadowText(primar, font, tx, ty, tc, ta)
            ty = ty - 20
        end

        if maxclip > 0 then
            self:ShadowText(clip, font, tx, ty, tc, ta)
            ty = ty - 20
        end

        self:ShadowText(name, font, tx, ty, tc, ta)
    end

    if maxclip <= 0 then return end

    local ax, ay = self:GetThirdpersonPos(self.swc, self.shc + 3)

    if lowammo then
        self:ShadowText('LOW AMMUNITION', 'ControlFont', ax, ay + self.AmArcR + 30, {
            [1] = self:ColorAlphaAnim(self.OR, wepanim, true),
            [2] = self:ColorAlphaAnim(self.TG, wepanim, true)
        }, {
            [1] = TEXT_ALIGN_CENTER,
            [2] = TEXT_ALIGN_CENTER
        })
    end

    local a1, a2, ar = 0, 100, self.AmArcR
    local er, br, ea = self.AmArcT, 2, 1

    local clipsize = clamp(a2 - (clip / maxclip) * (a2 - a1), a1, a2)

    lerpsizeam = Lerp(FrameTime() * 4, lerpsizeam, clipsize)

    local stencl1 = self:Arc(ax, ay, ar, a1 - ea, a2 + ea, 1)
    local stencl2 = self:Arc(ax, ay, ar + br, a1 - ea, a2 + ea, 1)
    local backgrd = self:Arc(ax, ay, ar + er + br, a1 - ea, a2 + ea, 1)
    local smoothd = self:Arc(ax, ay, ar + er, lerpsizeam, a2, 1)
    local cliparc = self:Arc(ax, ay, ar + er, clipsize, a2, 1)

    local lim, a3 = 30, 40

    ar = ar + er + br

    NoTexture()
    SetColor(self.TG)
    self:ResetStencil()
    rnd.SetStencilEnable(true)
    self:ApplyStencil()
    DrawPoly(stencl1)
    self:RemoveStencil()
    self:ColorAlphaAnim(self.TG, wepanim)
    DrawPoly(backgrd)
    self:ApplyStencil()

    if self.Sepbul then
        local maxdisplay = maxclip < lim and maxclip or lim

        for i = a1 + a3, a2 + a3, (a2 - a1) / maxdisplay do
            local x, y = ax + cos(rad(i)) * ar, ay + sin(rad(i)) * ar

            DrawLine(ax, ay, x, y)
        end
    end

    DrawPoly(stencl2)
    self:RemoveStencil()
    self:ColorAlphaAnim(lowammo and self.TR or self.LG, wepanim)
    DrawPoly(smoothd)
    self:ColorAlphaAnim(lowammo and self.OR or self.WH, wepanim)
    DrawPoly(cliparc)
    rnd.SetStencilEnable(false)
end

function ControlHUD:DrawCrosshair(wep, x, y)
    x, y = self:GetThirdpersonPos(x, y)

    self:DrawCrosshairDot(x, y)

    if not wep:IsValid() then return end

    self:DrawCrosshairParts(x, y)
end


--------------------------------------------------------------------------------------------------
-- < Main functions >
--------------------------------------------------------------------------------------------------
function ControlHUD:Init()
    for name, data in pairs(self.ConVars) do
        NewConv(name, data.def, true, false, data.desc, data.min, data.max)
    end

    NewFont('ControlFont', { font = 'Tahoma', weight = 800, size = 24, antialiasing = false })
end

function ControlHUD:Paint()
    self:UpdateVariables()

    if not self.Enable then return end

    local lp = LocalPlayer()

    if not lp:Alive() then
        if self.Death then DrawColorModify(self.DeathEffect) end

        return
    end

    if self.Health then self:DrawHealth(lp) end

    if self.Armor then self:DrawArmor(lp) end

    local wep = lp:GetActiveWeapon()

    if wep:IsValid() then
        self:UpdateWeaponAnim(lp, wep)

        if self.Ammo then self:DrawAmmo(lp, wep) end
    end

    if self.Crossh then self:DrawCrosshair(wep, self.swc, self.shc) end
end

function ControlHUD:Hide(name)
    return not (self.HideGm and self.HideElements[name])
end

function ControlHUD:Resize(w, h)
    self.sw, self.sh   = ScrW(), ScrH()
    self.swc, self.shc = self.sw * 0.5, self.sh * 0.5
end


--------------------------------------------------------------------------------------------------
-- < Take Control >
--------------------------------------------------------------------------------------------------
ControlHUD:AddHook('InitPostEntity', 'init', ControlHUD.Init)

ControlHUD:AddHook('HUDShouldDraw', 'hide', ControlHUD.Hide)

ControlHUD:AddHook('HUDPaint', 'paint', ControlHUD.Paint)

ControlHUD:AddHook('OnScreenSizeChanged', 'resize', ControlHUD.Resize)