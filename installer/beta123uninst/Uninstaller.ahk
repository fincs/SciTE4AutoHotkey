;
; File encoding:  UTF-8
; Platform:  Windows XP/Vista/7
; Author:    A.N.Other <myemail@nowhere.com>
;
; Script description:
;	Template script
;

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
#Include Uninstall.ahk
SetWorkingDir, %A_ScriptDir%
Menu, Tray, NoStandard

title = SciTE4AutoHotkey uninstallation

if GetWinVer() >= 6 && !A_IsAdmin
{
	MsgBox, 16, %title%, Admin rights required.
	ExitApp
}

MsgBox, 52, %title%, Are you sure you want to remove SciTE4AutoHotkey?
IfMsgBox, No
	ExitApp

rc := UninstallOldBetas()
MsgBox, 64, %title%, % rc ? "SciTE4AutoHotkey removed successfully!" : "There weren't any SciTE4AutoHotkey betas detected."
ExitApp

GetWinVer()
{
	pack := DllCall("GetVersion", "uint")
	return ((pack >> 16) "." (pack & 0xFFFF)) + 0.0
}

GetAutoHotkeyDir()
{
	if A_AhkPath =
		return
	SplitPath, A_AhkPath,, ahkdir
	return ahkdir
}

Util_Is64bitOS()
{
	return (A_PtrSize = 8) || DllCall("IsWow64Process", "ptr", DllCall("GetCurrentProcess"), "int*", isWow64) && isWow64
}
