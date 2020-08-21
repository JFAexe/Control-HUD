-- Copyright 2020 Alexandr 'JFAexe' Konichenko
-- https://github.com/JFAexe/Control-HUD
-- Commercial use is allowed only by request

--------------------------------------------------------------------------------------------------
-- < Setup >
--------------------------------------------------------------------------------------------------
local function LoadFileCS(file)
	if CLIENT then include(file) else AddCSLuaFile(file) end
end

LoadFileCS('control/control_hud.lua')
LoadFileCS('control/control_menu.lua')

--          Nobody knew her name
--      But she turned up just the same
--  There was a knock on the door,
--      A thump on the floor,
--          and the party turned insane
--      As she called out her name.
--  And she walked in looking like dynamite
--      She said now come along boogaloo through the night
--          And by the way she's moving well
--      Dynamite might she not with all
--  she's got she's got the whole town lighting up dynamite
--      Nobody quite knowing what to do
--          Wrong or right
--      But they all know Jesse is Dynamite
--  They're right.