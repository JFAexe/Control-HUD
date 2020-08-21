..\..\..\bin\gmad.exe create -out .\control_hud.gma -warninvalid -folder "%~dp0
..\..\..\bin\gmpublish.exe update -id "2204855339" -addon .\control_hud.gma -icon "%~dp0/icon.jpg" -changes "Update"
del .\control_hud.gma
pause