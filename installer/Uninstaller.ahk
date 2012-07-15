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
SetWorkingDir, %A_ScriptDir%
Menu, Tray, NoStandard

title = SciTE4AutoHotkey uninstallation

if GetWinVer() >= 6 && !A_IsAdmin
{
	MsgBox, 16, %title%, Admin rights required.
	ExitApp
}

if 1 = /perform
	goto DoIt

MsgBox, 52, %title%, Are you sure you want to remove SciTE4AutoHotkey?
IfMsgBox, No
	ExitApp

FileCopy, %A_ScriptFullPath%, %A_Temp%\s4a-uninst.exe, 1
Run, "%A_Temp%\s4a-uninst.exe" /perform "%A_ScriptDir%"
ExitApp

DoIt:
FileRemoveDir, %2%, 1
RegRead, ov, HKCR, AutoHotkeyScript\Shell\Edit\command
if ov = "%2%\SciTE.exe" "`%1"
	RegWrite, REG_SZ, HKCR, AutoHotkeyScript\Shell\Edit\command,, notepad.exe `%1
RegDelete, HKLM, Software\Microsoft\Windows\CurrentVersion\Uninstall\SciTE4AutoHotkey
RegDelete, HKLM, Software\Classes\SciTE4AHK.Application
RegDelete, HKLM, Software\Classes\CLSID\{D7334085-22FB-416E-B398-B5038A5A0784}
MsgBox, 52, %title%, Do you want to remove the user profile?
IfMsgBox, Yes
	WipeProfile(A_MyDocuments "\AutoHotkey\SciTE")
FileDelete, %A_DesktopCommon%\SciTE4AutoHotkey.lnk
FileRemoveDir, %A_ProgramsCommon%\SciTE4AutoHotkey, 1
MsgBox, 64, %title%, SciTE4AutoHotkey removed successfully!
ExitApp
