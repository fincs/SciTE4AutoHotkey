; SciTE4AutoHotkey v3 autorun script
;
; November 7, 2010 - fincs
;

#NoEnv
#NoTrayIcon
SetWorkingDir, %A_ScriptDir%

UserAutorun = %A_MyDocuments%\AutoHotkey\SciTE\Autorun.ahk

Run, "%A_AhkPath%" tools\TillaGoto.ahk
IfExist, %UserAutorun%
	Run, "%A_AhkPath%" "%UserAutorun%"
