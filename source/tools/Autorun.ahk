;
; SciTE4AutoHotkey Autorun Script
;

#NoEnv
#NoTrayIcon
SetWorkingDir, %A_ScriptDir%

oSciTE := GetSciTEInstance()
if !oSciTE
{
	MsgBox, 16, SciTE4AutoHotkey, Cannot find SciTE!
	ExitApp
}

UserAutorun := oSciTE.UserDir "\Autorun.ahk"

bUpdatesEnabled := oSciTE.ResolveProp("automatic.updates") + 0
bTillaGotoEnabled := oSciTE.ResolveProp("tillagoto.enable") + 0

if bUpdatesEnabled
	Run, "%A_AhkPath%" SciTEUpdate.ahk /silent

if bTillaGotoEnabled
	Run, "%A_AhkPath%" TillaGoto.ahk

IfExist, %UserAutorun%
	Run, "%A_AhkPath%" "%UserAutorun%"
