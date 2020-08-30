-- Copyright 2020 Alexandr 'JFAexe' Konichenko
-- https://github.com/JFAexe/Control-HUD
-- Commercial use is allowed only by request

--------------------------------------------------------------------------------------------------
-- < Localizing >
--------------------------------------------------------------------------------------------------
local srf, drw, rnd, mth    = surface, draw, render, math
local hook, NewConv, GetVar = hook, CreateClientConVar, GetConVar

local NewHook, RemHook, lerp, insert  = hook.Add, hook.Remove, Lerp, table.insert
local floor, clamp, rad, sin, cos     = mth.floor, mth.Clamp, mth.rad, mth.sin, mth.cos
local NoTexture, SetColor, ColorAlpha = drw.NoTexture, srf.SetDrawColor, ColorAlpha
local DrawRect, DrawRectRot, DrawPoly = srf.DrawRect, srf.DrawTexturedRectRotated, srf.DrawPoly
local DrawLine, NewFont, SimpleText   = srf.DrawLine, srf.CreateFont, drw.SimpleText


--------------------------------------------------------------------------------------------------
-- < Global variables >
--------------------------------------------------------------------------------------------------
ControlHUD.ConVars = {
    ['control_hud_enable'] = { id = 0.1, type = 'b', def = 1,  min = 0,   max = 1,   desc = 'Enable Control HUD' },
    ['control_hud_hiddef'] = { id = 0.2, type = 'b', def = 1,  min = 0,   max = 1,   desc = 'Disable default HUD' },
    ['control_hud_hiddov'] = { id = 0.3, type = 'b', def = 1,  min = 0,   max = 1,   desc = 'Override default HUD elements', help = 'Enable default if unused' },
    ['control_hud_showhp'] = { id = 0.4, type = 'b', def = 1,  min = 0,   max = 1,   desc = 'Display health bar' },
    ['control_hud_showar'] = { id = 0.5, type = 'b', def = 1,  min = 0,   max = 1,   desc = 'Display armor bar' },
    ['control_hud_showam'] = { id = 0.6, type = 'b', def = 1,  min = 0,   max = 1,   desc = 'Display ammunition bar' },
    ['control_hud_showwi'] = { id = 0.7, type = 'b', def = 0,  min = 0,   max = 1,   desc = 'Display weapon information' },
    ['control_hud_sepbul'] = { id = 0.8, type = 'b', def = 1,  min = 0,   max = 1,   desc = 'Divide ammunition bar on segments' },
    ['control_hud_noanim'] = { id = 0.9, type = 'b', def = 0,  min = 0,   max = 1,   desc = 'Disable fade animation', help = 'Weapon related stuff only' },
    ['control_hud_showcr'] = { id = 1.0, type = 'b', def = 1,  min = 0,   max = 1,   desc = 'Display crosshair' },
    ['control_hud_showlh'] = { id = 1.1, type = 'b', def = 1,  min = 0,   max = 1,   desc = 'Display low health effect' },
    ['control_hud_showds'] = { id = 1.2, type = 'b', def = 1,  min = 0,   max = 1,   desc = 'Display death screen effect' },
    ['control_hud_showmt'] = { id = 1.3, type = 'b', def = 1,  min = 0,   max = 1,   desc = 'Display map title', help = 'Only on first spawn' },
    ['control_hud_crosst'] = { id = 1.4, type = 'i', def = 1,  min = 1,   max = 8,   desc = 'Crosshair type' },
    ['control_hud_amarcr'] = { id = 1.5, type = 'i', def = 72, min = 32,  max = 128, desc = 'Ammunition bar radius' },
    ['control_hud_amarct'] = { id = 1.6, type = 'i', def = 6,  min = 4,   max = 12,  desc = 'Ammunition bar thickness' },
    ['control_hud_crsize'] = { id = 1.7, type = 'f', def = 1,  min = 0.5, max = 2,   desc = 'Crosshair size multiplier' },
    ['control_hud_hpsmul'] = { id = 1.8, type = 'f', def = 2,  min = 1,   max = 4,   desc = 'Health bar size multiplier' },
    ['control_hud_arsmul'] = { id = 1.9, type = 'f', def = 3,  min = 1,   max = 5,   desc = 'Armor bar size multiplier' },
    ['control_hud_animtm'] = { id = 2.0, type = 'f', def = 4,  min = 1,   max = 6,   desc = 'Fade animations time' },
}

ControlHUD.sw, ControlHUD.sh = ScrW(), ScrH()
ControlHUD.wc, ControlHUD.hc = ControlHUD.sw * 0.5, ControlHUD.sh * 0.5

ControlHUD.TG = Color(20, 20, 20, 140)
ControlHUD.TW = Color(240, 240, 240, 20)
ControlHUD.TR = Color(255, 20, 20, 60)
ControlHUD.OR = Color(255, 89, 0)
ControlHUD.RD = Color(255, 20, 20)
ControlHUD.LB = Color(15, 173, 194)
ControlHUD.WH = Color(255, 255, 255)
ControlHUD.LG = Color(200, 200, 200)
ControlHUD.BL = Color(0, 0, 0)
ControlHUD.WS = Color(33, 44, 59)

ControlHUD.Crosshairs = {
    [1] = {}, -- < Dot >
    [2] = { -- < Grip >
        [1] = { w = 10, h = 2, ang = 45,  x = -5, y = -5 },
        [2] = { w = 10, h = 2, ang = -45, x = 5,  y = -5 },
        [3] = { w = 10, h = 2, ang = -45, x = -5, y = 5 },
        [4] = { w = 10, h = 2, ang = 45,  x = 5,  y = 5 },
    },
    [3] = { -- < Spin >
        [1] = { w = 14, h = 2, ang = 90,  x = 0,   y = -18 },
        [2] = { w = 14, h = 2, ang = 35,  x = -15, y = 10 },
        [3] = { w = 14, h = 2, ang = -35, x = 15,  y = 10 },
    },
    [4] = { -- < Charge >
        [1] = { w = 14, h = 2, ang = -60, x = -5, y = 3 },
        [2] = { w = 14, h = 2, ang = 60,  x = 5,  y = 3 },
        [3] = { w = 14, h = 2, ang = 0,   x = 0,  y = -6 },
    },
    [5] = { -- < Pierce >
        [1] = { w = 10, h = 2, ang = -45, x = -10, y = -10 },
        [2] = { w = 10, h = 2, ang = 45,  x = 10,  y = -10 },
        [3] = { w = 10, h = 2, ang = 45,  x = -10, y = 10 },
        [4] = { w = 10, h = 2, ang = -45, x = 10,  y = 10 },
    },
    [6] = { -- < Shatter >
        [1] = { w = 15, h = 2, ang = 90,  x = -28, y = 0 },
        [2] = { w = 12, h = 2, ang = -45, x = -24, y = 12 },
        [3] = { w = 12, h = 2, ang = 45,  x = -24, y = -12 },
        [4] = { w = 12, h = 2, ang = -45, x = 24,  y = -12 },
        [5] = { w = 12, h = 2, ang = 45,  x = 24,  y = 12 },
        [6] = { w = 15, h = 2, ang = 90,  x = 28,  y = 0 },
    },
    [7] = { -- < Blow >
        [1] = { w = 18, h = 2, ang = 90, x = -14, y = 0 },
        [2] = { w = 16, h = 2, ang = 0,  x = -21, y = -8 },
        [3] = { w = 16, h = 2, ang = 0,  x = 21,  y = -8 },
        [4] = { w = 18, h = 2, ang = 90, x = 14,  y = 0 },
    },
    [8] = { -- < Launch >
        [1] = { w = 18, h = 2, ang = -30, x = -8,  y = 13 },
        [2] = { w = 16, h = 2, ang = 90,  x = -16, y = 0 },
        [3] = { w = 18, h = 2, ang = 30,  x = -8,  y = -13 },
        [4] = { w = 18, h = 2, ang = -30, x = 8,   y = -13 },
        [5] = { w = 16, h = 2, ang = 90,  x = 16,  y = 0 },
        [6] = { w = 18, h = 2, ang = 30,  x = 8,   y = 13 },
    },
}

ControlHUD.HideElements = {
    ['CHudPoisonDamageIndicator'] = true,
    ['CHudDamageIndicator']       = true,
    ['CHudSecondaryAmmo']         = true,
    ['CHudSquadStatus']           = true,
    ['CHudSuitPower']             = true,
    ['CHUDQuickInfo']             = true,
    ['CHudCrosshair']             = true,
    ['CHudBattery']               = true,
    ['CHudGeiger']                = true,
    ['CHudHealth']                = true,
    ['CHudAmmo']                  = true,
    ['CHudZoom']                  = true,
}

ControlHUD.LowHealthEffect = {
    ['$pp_colour_addr']       = 1,
    ['$pp_colour_colour']     = 0.75,
    ['$pp_colour_contrast']   = 0.75,
    ['$pp_colour_brightness'] = -0.75,
}

ControlHUD.DeathEffect = {
    ['$pp_colour_addr']       = 1,
    ['$pp_colour_colour']     = -1,
    ['$pp_colour_contrast']   = -1,
    ['$pp_colour_brightness'] = -0.2,
}


--------------------------------------------------------------------------------------------------
-- < Local variables >
--------------------------------------------------------------------------------------------------
local lerpsizehp, lerpsizear, lerpsizeam, arhidetime, wephidetime, wepanim = 0, 0, 0, 0, 0, 0
local oldarmor, oldweap, oldclip, oldprim, oldsecn, oldprmf, oldsecf       = 0, 0, 0, 0, 0, 0, 0
local mapanim, maptitle, spawntime                                         = 0


--------------------------------------------------------------------------------------------------
-- < Utils >
--------------------------------------------------------------------------------------------------
function ControlHUD:AddHook(hook, name, func)
    if not (func and name) then return end

    NewHook(hook, self.HooksID .. '_' .. name, function(...)
        return func(self, ...)
    end)
end

function ControlHUD:RemHook(hook, name)
    if not name then return end

    RemHook(hook, self.HooksID .. '_' .. name)
end

function ControlHUD:GetConv(var, type)
    local CheckType = {
        ['i'] = function(v) return v:GetInt() end,
        ['b'] = function(v) return v:GetBool() end,
        ['f'] = function(v) return v:GetFloat() end,
    }

    return CheckType[type](GetVar(var))
end

function ControlHUD:UpdateVariables()
    self.Should = self:GetConv('cl_drawhud', 'b')
    self.Enable = self:GetConv('control_hud_enable', 'b')
    self.HideGm = self:GetConv('control_hud_hiddef', 'b')
    self.HideOv = self:GetConv('control_hud_hiddov', 'b')
    self.Health = self:GetConv('control_hud_showhp', 'b')
    self.Armor  = self:GetConv('control_hud_showar', 'b')
    self.Ammo   = self:GetConv('control_hud_showam', 'b')
    self.WepInf = self:GetConv('control_hud_showwi', 'b')
    self.Sepbul = self:GetConv('control_hud_sepbul', 'b')
    self.NoAnim = self:GetConv('control_hud_noanim', 'b')
    self.CrShow = self:GetConv('control_hud_showcr', 'b')
    self.LowHP  = self:GetConv('control_hud_showlh', 'b')
    self.Death  = self:GetConv('control_hud_showds', 'b')
    self.MpTitl = self:GetConv('control_hud_showmt', 'b')
    self.CrType = self:GetConv('control_hud_crosst', 'i')
    self.AmArcR = self:GetConv('control_hud_amarcr', 'i')
    self.AmArcT = self:GetConv('control_hud_amarct', 'i')
    self.CrSize = self:GetConv('control_hud_crsize', 'f')
    self.HpSMul = self:GetConv('control_hud_hpsmul', 'f')
    self.ArSMul = self:GetConv('control_hud_arsmul', 'f')
    self.AnTime = self:GetConv('control_hud_animtm', 'f')
end

function ControlHUD:UpdateHideList()
    local el = self.HideElements
    local ov = self.HideOv and true
    local hp = self.Health
    local ar = self.Armor
    local cr = self.CrShow
    local wp = self.WepInf or self.Ammo

    el['CHudAmmo']          = ov or wp
    el['CHudHealth']        = ov or hp
    el['CHudBattery']       = ov or ar
    el['CHudCrosshair']     = ov or cr
    el['CHudSecondaryAmmo'] = ov or wp
end

function ControlHUD:GetThirdpersonPos(x, y)
    local lp = LocalPlayer()

    if not lp:ShouldDrawLocalPlayer() then return x, y end

    local td  = {}
    td.start  = lp:GetShootPos()
    td.endpos = td.start + (lp:EyeAngles() + lp:GetPunchAngle()):Forward() * 16384
    td.filter = lp

    local tr   = util.TraceLine(td)
    local pos  = tr.HitPos:ToScreen()
    local x, y = pos.x, pos.y

    return x, y
end

function ControlHUD:ColorAlphaAnim(color, anim, col)
    local result = ColorAlpha(color, clamp(color.a * anim, 0, color.a))

    return col and result or SetColor(result)
end

function ControlHUD:UpdateWeaponAnim(lp, wep)
    local clip   = wep:Clip1()
    local primar = lp:GetAmmoCount(wep:GetPrimaryAmmoType())
    local second = lp:GetAmmoCount(wep:GetSecondaryAmmoType())
    local nextpf = wep:GetNextPrimaryFire()
    local nextsf = wep:GetNextSecondaryFire()

    local CT = CurTime()

    if oldweap ~= wep
    or oldclip ~= clip
    or oldprim ~= primar
    or oldsecn ~= second
    or oldprmf ~= nextpf
    or oldsecf ~= nextsf then
        wephidetime = CT + self.AnTime
        oldweap, oldclip = wep, clip
        oldprim, oldsecn = primar, second
        oldprmf, oldsecf = nextpf, nextsf
    end

    wepanim = lerp(FrameTime() * 4, wepanim, self.NoAnim and 1 or wephidetime - CT)
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
    local mul  = self.CrSize
    local sz   = 1 * mul
    local back = self:Arc(x, y, sz + 1, 0, 360, 1)
    local fore = self:Arc(x, y, sz, 0, 360, 1)

    NoTexture()
    SetColor(self.TG)
    DrawPoly(back)
    SetColor(self.WH)
    DrawPoly(fore)
end

function ControlHUD:DrawCrosshairParts(x, y)
    local cross = self.Crosshairs[self.CrType]
    local mul   = self.CrSize

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
function ControlHUD:DrawPlayerHUD(lp)
    self:DrawHealth(lp)
    self:DrawArmor(lp)
end

function ControlHUD:DrawHealth(lp)
    local cur, max = lp:Health(), lp:GetMaxHealth()

    if self.LowHP then ControlHUD:DrawLowHealth(cur, max) end

    if not self.Health then return end

    local mul        = self.HpSMul
    local fore, back = clamp(cur, 0, max) * mul, max * mul

    lerpsizehp = lerp(FrameTime() * 4, lerpsizehp, fore)

    self:DrawHealthBar(120, self.sh - 120, fore, lerpsizehp, back, 20, {
        self.LB, self.RD, self.TW, self.TG
    })
end

function ControlHUD:DrawLowHealth(cur, max)
    local low = cur <= floor(max * 0.25)

    if not low then return end

    DrawColorModify(self.LowHealthEffect)

    DrawToyTown(2, self.hc * 0.5)
end

function ControlHUD:DrawArmor(lp)
    if not self.Armor then return end

    local mul, CT    = self.ArSMul, CurTime()
    local cur, max   = lp:Armor(), 100
    local low, pos   = cur <= floor(max * 0.25), 140
    local fore, back = clamp(cur, 0, max) * mul, max * mul

    lerpsizear = lerp(FrameTime() * 4, lerpsizear, fore)

    if oldarmor ~= cur then arhidetime, oldarmor = CT + self.AnTime, cur end

    if arhidetime < CT then return end

    local anim = arhidetime - CT
    local py   = anim < 0.1 and lerp(CT * 3, pos, pos * anim * 10) or pos

    self:DrawBar(self.wc - back * 0.5, py, fore, lerpsizear, back, 15, {
        self:ColorAlphaAnim(self.WH, anim, true),
        self:ColorAlphaAnim(low and self.TR or self.LG, anim, true),
        self:ColorAlphaAnim(self.TW, anim, true),
        self:ColorAlphaAnim(self.TG, anim, true)
    })
end

function ControlHUD:DrawWeaponHUD(lp, wep)
    local clip = wep:Clip1()
    local max  = wep:GetMaxClip1()

    if wepanim < 0 then return end

    if self.Ammo then self:DrawAmmo(lp, wep, max, clip) end

    if self.WepInf then self:DrawWeaponInfo(lp, wep, max, clip) end
end

function ControlHUD:DrawAmmo(lp, wep, max, clip)
    if max <= 0 then return end

    local low  = clip <= floor(max * 0.2)

    local ax, ay = self:GetThirdpersonPos(self.wc, self.hc + 3)

    local a1, a2, ar = 0, 100, self.AmArcR
    local er, br, ea = self.AmArcT, 2, 1

    local clipsize = clamp(a2 - (clip / max) * (a2 - a1), a1, a2)

    lerpsizeam = lerp(FrameTime() * 4, lerpsizeam, clipsize)

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
        local display = max < lim and max or lim

        for i = a1 + a3, a2 + a3, (a2 - a1) / display do
            local x, y = ax + cos(rad(i)) * ar, ay + sin(rad(i)) * ar

            DrawLine(ax, ay, x, y)
        end
    end

    DrawPoly(stencl2)
    self:RemoveStencil()
    self:ColorAlphaAnim(low and self.TR or self.LG, wepanim)
    DrawPoly(smoothd)
    self:ColorAlphaAnim(low and self.OR or self.WH, wepanim)
    DrawPoly(cliparc)
    rnd.SetStencilEnable(false)

    if not low then return end

    self:ShadowText('LOW AMMUNITION', 'ControlFont', ax, ay + ar + 40, {
        self:ColorAlphaAnim(self.OR, wepanim, true),
        self:ColorAlphaAnim(self.TG, wepanim, true)
    }, { TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER })
end

function ControlHUD:DrawWeaponInfo(lp, wep, max, clip)
    local name   = wep:GetPrintName()
    local primar = lp:GetAmmoCount(wep:GetPrimaryAmmoType())
    local second = lp:GetAmmoCount(wep:GetSecondaryAmmoType())

    local fn, sz = 'ControlFont', 20
    local tx, ty = self.sw - 120 + 27, self.sh - 124
    local tc, ta = {
        self:ColorAlphaAnim(self.WH, wepanim, true),
        self:ColorAlphaAnim(self.TG, wepanim, true)
    }, { TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT }

    if name:StartWith('#') then name = language.GetPhrase(name) end

    if second > 0 then
        self:ShadowText(second, fn, tx, ty, tc, ta)
        ty = ty - sz
    end

    if primar > 0 then
        self:ShadowText(primar, fn, tx, ty, tc, ta)
        ty = ty - sz
    end

    if max > 0 then
        self:ShadowText(clip, fn, tx, ty, tc, ta)
        ty = ty - sz
    end

    self:ShadowText(name, fn, tx, ty, tc, ta)
end

function ControlHUD:DrawCrosshair(wep, x, y)
    x, y = self:GetThirdpersonPos(x, y)

    self:DrawCrosshairDot(x, y)

    if not wep:IsValid() then return end

    self:DrawCrosshairParts(x, y)
end

function ControlHUD:DrawMapTitle()
    local CT = CurTime()

    if not spawntime then spawntime = CT end

    if not maptitle then return end

    mapanim = (spawntime + 1 < CT and spawntime + 5 > CT) and 1 or 0

    self:ShadowText(maptitle, 'ControlFontTitle', self.wc, self.hc, {
        ColorAlpha(self.WH, 255 * mapanim),
        ColorAlpha(self.TG, 255 * mapanim)
    }, { TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER })
end


--------------------------------------------------------------------------------------------------
-- < Main functions >
--------------------------------------------------------------------------------------------------
function ControlHUD:Init()
    for name, data in pairs(self.ConVars) do
        NewConv(name, data.def, true, false, data.desc, data.min, data.max)
    end
    
    self:UpdateVariables()

    local font, size, anti = 'AvantGardeGothicCTT', 28, true

    NewFont('ControlFont', { font = font, size = size, antialiasing = anti })

    if self.MpTitl then
        spawntime, maptitle = nil, (game.GetMap():upper()):Replace('_', ' ')

        srf.SetFont('ControlFont')

        size = clamp(ScreenScale(600 / (srf.GetTextSize(maptitle) / size)), 4, 255)

        NewFont('ControlFontTitle', { font = font, size = size, antialiasing = anti })
    end

    self:RemHook('InitPostEntity', 'init')
end

function ControlHUD:Paint()
    self:UpdateVariables()

    if not (self.Should and self.Enable) then return end

    local lp = LocalPlayer()

    if not lp:Alive() then
        if self.Death then DrawColorModify(self.DeathEffect) end

        return
    end

    self:DrawPlayerHUD(lp)

    local wep = lp:GetActiveWeapon()

    if wep:IsValid() then
        self:UpdateWeaponAnim(lp, wep)

        self:DrawWeaponHUD(lp, wep)
    end

    if self.CrShow then self:DrawCrosshair(wep, self.wc, self.hc) end

    if self.MpTitl then self:DrawMapTitle() end
end

function ControlHUD:Hide(name)
    self:UpdateHideList()

    return not (self.HideGm and self.HideElements[name])
end

function ControlHUD:Resize(w, h)
    self.sw, self.sh = ScrW(), ScrH()
    self.wc, self.hc = self.sw * 0.5, self.sh * 0.5
end


--------------------------------------------------------------------------------------------------
-- < Take Control >
--------------------------------------------------------------------------------------------------
ControlHUD:AddHook('InitPostEntity', 'init', ControlHUD.Init)

ControlHUD:AddHook('HUDShouldDraw', 'hide', ControlHUD.Hide)

ControlHUD:AddHook('HUDPaint', 'paint', ControlHUD.Paint)

ControlHUD:AddHook('OnScreenSizeChanged', 'resize', ControlHUD.Resize)