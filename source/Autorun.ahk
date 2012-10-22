; SciTE4AutoHotkey v3 autorun script
;
; November 7, 2010 - fincs
;

#NoEnv
#NoTrayIcon
SetWorkingDir, %A_ScriptDir%

IsPortable := FileExist(A_ScriptDir "\$PORTABLE")
if !IsPortable
	LocalSciTEPath = %A_MyDocuments%\AutoHotkey\SciTE
else
	LocalSciTEPath = %A_ScriptDir%\..\user

UserAutorun = %LocalSciTEPath%\Autorun.ahk

oSciTE := GetSciTEInstance()
if !oSciTE
{
	MsgBox, 16, SciTE4AutoHotkey, Cannot find SciTE!
	return
}

bUpdatesEnabled := oSciTE.ResolveProp("automatic.updates") + 0
bTillaGotoEnabled := oSciTE.ResolveProp("tillagoto.enable") + 0

if bUpdatesEnabled
	Run, "%A_AhkPath%" tools\updater\SciTEUpdate.ahk /silent

if bTillaGotoEnabled
	Run, "%A_AhkPath%" tools\TillaGoto.ahk

IfExist, %UserAutorun%
	Run, "%A_AhkPath%" "%UserAutorun%"
