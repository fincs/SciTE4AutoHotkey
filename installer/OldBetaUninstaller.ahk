;
; SciTE4AutoHotkey Old Beta Uninstaller
;

#NoEnv
#NoTrayIcon
#SingleInstance, Ignore
SetWorkingDir, %A_ScriptDir%
Menu, Tray, NoStandard

global uititle := "SciTE4AutoHotkey Setup"
global programVer := "3.0.01"
global winVer := Util_GetWinVer()
global ahkPath := Util_GetAhkPath()

if (winVer >= 6) && !A_IsAdmin
{
	MsgBox, 16, %uititle%, Admin rights required.
	ExitApp
}

if !ahkPath
{
	MsgBox, 16,, Could not find AutoHotkey installation directory!
	ExitApp
}

MsgBox, 52, %uititle%, Are you sure you want to remove SciTE4AutoHotkey?
IfMsgBox, No
	ExitApp

rc := UninstallOldBetas()
MsgBox, 64, %uititle%, % rc ? "SciTE4AutoHotkey removed successfully!" : "There weren't any SciTE4AutoHotkey betas detected."
ExitApp
