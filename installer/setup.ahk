;
; SciTE4AutoHotkey Setup
;
; Most GUI code is borrowed from the AutoHotkey installer (written by Lexikos).
;

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
SendMode, Input
SetWorkingDir, %A_ScriptDir%

global uititle := "SciTE4AutoHotkey Setup"
global programVer ; will be filled in later
global winVer := Util_GetWinVer()
global ahkPath := Util_GetAhkPath()
global ahkVer := Util_GetAhkVer()
global intlAhkName := ""
global hasLegacyAhk := ahkVer < "1.1"
global previousInstallDir := ""
global inInstall := false

SplitPath, A_AhkPath, intlAhkName
global installDebug := !InStr(intlAhkName, "InternalAHK")

if (winVer < 6) or !A_Is64bitOS
{
	MsgBox, 16, %uititle%, This version of Microsoft Windows is not supported by SciTE4AutoHotkey.
	ExitApp
}

if 1 = /uninstall
{
	MsgBox, 52, %uititle%, Are you sure you want to remove SciTE4AutoHotkey?
	IfMsgBox, Yes
	{
		FileCopy, %A_AhkPath%, %A_Temp%, 1
		FileCopy, %A_ScriptFullPath%, %A_Temp%, 1
		runasverb := A_IsAdmin ? "" : "*RunAs "
		Run, %runasverb%"%A_Temp%\%intlAhkName%" /CP65001 "%A_Temp%\%A_ScriptName%" /douninstall
	}
	ExitApp
}
if 1 = /douninstall
{
	Btn_PerformUninstall()
	ExitApp
}

scitepath := installDebug ? "..\source\SciTE.exe" : "SciTE.exe"
Menu, Tray, Icon, %scitepath%
FileGetVersion, programVer, %scitepath%
programVer := Format("{:d}.{:d}.{:d}", StrSplit(programVer, ".")*)

if !installDebug
	SetWorkingDir ..
else
	hasLegacyAhk := true

if !FileExist("dialog.html") || !FileExist("banner.png")
{
	MsgBox, 48, %uititle%, Oops `;p ; Short msg since so rare.
	ExitApp
}

Gui, New, +LastFound, %uititle%
Gui, Margin, 0, 0
try DllCall("UxTheme\SetWindowThemeAttribute", "ptr", installerHwnd := WinExist(), "int", 1, "int64*", (3<<32)|3, "int", 8) ; Hide window title.
Gui, Add, ActiveX, vwb w600 h420 hwndhwb, Shell.Explorer
ComObjConnect(wb, "wb_")
OnMessage(0x100, "gui_KeyDown", 2)
InitUI()
Gui, Show
return

GuiClose:
Btn_Exit()
return

InitUI()
{
	global wb
	SetWBClientSite(wb)
	wb.Silent := true
	wb.Navigate("file://" A_WorkingDir "\dialog.html")
	while wb.ReadyState != 4
		Sleep, 10
	doc := getDocument()
	doc.getElementById("versionTag").innerText := "version " programVer
	doc.getElementById("yearTag1").innerText := A_Year
	doc.getElementById("yearTag2").innerText := A_Year
	logicalDPI := doc.parentWindow.screen.logicalXDPI, deviceDPI := doc.parentWindow.screen.deviceXDPI
	if (A_ScreenDPI != 96)
		doc.body.style.zoom := A_ScreenDPI/96 * (logicalDPI/deviceDPI)
	doc.body.focus()
}

; Fix keyboard shortcuts in WebBrowser control.
; References:
; http://www.autohotkey.com/community/viewtopic.php?p=186254#p186254
; http://msdn.microsoft.com/en-us/library/ms693360
gui_KeyDown(wParam, lParam, nMsg, hWnd)
{
	global wb
	if (Chr(wParam) ~= "[A-Z]" || wParam = 0x74) ; Disable Ctrl+O/L/F/N and F5.
		return
	pipa := ComObjQuery(wb, "{00000117-0000-0000-C000-000000000046}")
	VarSetCapacity(kMsg, 48), NumPut(A_GuiY, NumPut(A_GuiX
	, NumPut(A_EventInfo, NumPut(lParam, NumPut(wParam
	, NumPut(nMsg, NumPut(hWnd, kMsg)))), "uint"), "int"), "int")
	Loop 2
		r := DllCall(NumGet(NumGet(1*pipa)+5*A_PtrSize), "ptr", pipa, "ptr", &kMsg)
	; Loop to work around an odd tabbing issue (it's as if there
	; is a non-existent element at the end of the tab order).
	until wParam != 9 || wb.Document.activeElement != ""
	ObjRelease(pipa)
	if r = 0 ; S_OK: the message was translated to an accelerator.
		return 0
}

; ahk://Func/Param  -->  Func("Param")
wb_BeforeNavigate2(wb, url, flags, frame, postdata, headers, cancel)
{
	if !RegExMatch(url, "^ahk://(.*?)/(.*)", m)
		return
	static func, prms
	func := m1
	prms := []
	StringReplace, m2, m2, `%20, %A_Space%, All
	Loop, Parse, m2, `,
		prms.Insert(A_LoopField)
	; Cancel: don't load the error page (or execute ahk://whatever
	; if it happens to somehow be a registered protocol).
	NumPut(-1, ComObjValue(cancel), "short")
	; Call after a delay to allow navigation (this might only be
	; necessary if called from NavigateError; i.e. on Windows 8).
	SetTimer, wb_bn2_call, -15
	return
wb_bn2_call:
	%func%(prms*)
	func := prms := ""
	return
}

wb_NavigateError(wb, url, frame, status, cancel)
{
	; This might only be called on Windows 8, which skips the
	; BeforeNavigate2 call (because the protocol is invalid?).
	wb_BeforeNavigate2(wb, url, 0, frame, "", "", cancel)
}

getDocument()
{
	global wb
	return wb.document
}

getWindow()
{
	return getDocument().parentWindow
}

switchPage(page)
{
	getWindow().switchPage(page)
}

Btn_Exit()
{
	global inInstall, installerHwnd
	if inInstall
		return
	Gui %installerHwnd%:Destroy
	ExitApp
}

Btn_Install()
{
	Gui +OwnDialogs
	if !ahkPath
	{
		MsgBox, 16, %uititle%, Could not find existing AutoHotkey installation!
		return
	}

	RegRead, existingSciTEPath, HKLM, Software\SciTE4AutoHotkey, InstallDir
	previousInstall := !ErrorLevel
	if previousInstall
	{
		defPath := existingSciTEPath
		RegRead, defEdit, HKLM, Software\SciTE4AutoHotkey, InstallDefEditor
		RegRead, defSS, HKLM, Software\SciTE4AutoHotkey, InstallDefSS
		RegRead, defDS, HKLM, Software\SciTE4AutoHotkey, InstallDefDS
		previousInstallDir := defPath
	}else
	{
		defPath := ahkPath "\SciTE"
		defEdit := true
		defSS := true
		defDS := true
	}

	document := getDocument()
	document.getElementById("opt_installdir").value := defPath
	SetCheckBox(document.getElementById("opt_defedit"), defEdit)
	SetCheckBox(document.getElementById("opt_startlnks"), defSS)
	SetCheckBox(document.getElementById("opt_desklnks"), defDS)
	document.getElementById("stmtext").innerText .= (winVer < 6.2 || winVer >= 10.0) ? "Create shortcuts in the Start menu" : "Add tiles to the Start screen"
	if hasLegacyAhk
	{
		document.getElementById("obsoletecounter").innerText := "over " (A_Year - 2009) " years old"
		document.getElementById("ahkver").innerText := "v" ahkVer
		switchPage("legacyahkinfo")
	}else
		switchPage("setupopt")
}

Lnk_AhkWebsite()
{
	Run, https://www.autohotkey.com/download
}

SetCheckBox(oCheckBox, state)
{
	oCheckBox.checked := ComBool(state)
}

; Convert a normal boolean value into a COM VT_BOOL
ComBool(x)
{
	return ComObject(0xB, x ? -1 : 0)
}

Btn_Browse()
{
	Gui +OwnDialogs
	oTextBox := getDocument().getElementById("opt_installdir")
	FileSelectFolder, ov, % "*" oTextBox.value, 3, Please select the SciTE4AutoHotkey installation directory.
	if ErrorLevel || !ov
		return
	oTextBox.value := ov
}

closeSciTE()
{
	while WinExist("ahk_class SciTEWindow") ; can't use the COM object because this is an elevated process
	{
		MsgBox, 53, %uititle%, SciTE4AutoHotkey is currently running. Please close it before continuing.
		IfMsgBox, Cancel
			return false
	}
	return true
}

Btn_PerformInstall()
{
	Gui +OwnDialogs

	if installDebug
	{
		switchPage("setuprgr")
		MsgBox, 64, %uititle%, Not going to happen
		return
	}

	if !closeSciTE()
		return

	document := getDocument()
	installDir := document.getElementById("opt_installdir").value
	bDefaultEditor := document.getElementById("opt_defedit").checked != 0
	bStartShortcuts := document.getElementById("opt_startlnks").checked != 0
	bDesktopShortcuts := document.getElementById("opt_desklnks").checked != 0

	folderExists := InStr(FileExist(installDir), "D")

	if !previousInstallDir && folderExists
	{
		MsgBox, 52, %uititle%, The specified installation folder already exists. Setup will first delete all of its contents before installing. Are you sure?
		IfMsgBox, No
			return
	}

	inInstall := true

	switchPage("setuprgr")

	IfNotExist, %installDir%
		FileCreateDir, %installDir%
	else Loop, %installDir%\*.*, 1
	{
		IfInString, A_LoopFileAttrib, D
			RemoveDir(A_LoopFileLongPath)
		else
			FileDelete, %A_LoopFileLongPath%
	}

	oShell := ComObjCreate("Shell.Application")
	targetFolderObj := oShell.Namespace(installDir)
	sourceFolderObj := oShell.Namespace(A_ScriptDir)
	targetFolderObj.CopyHere(sourceFolderObj.Items, 16 | 2048)

	uninstallProg = %installDir%\%intlAhkName%
	uninstallArgs = /CP65001 "%installDir%\%A_ScriptName%" /uninstall
	key = Software\Microsoft\Windows\CurrentVersion\Uninstall\SciTE4AutoHotkey
	RegWrite, REG_SZ, HKLM, %key%, DisplayName, SciTE4AutoHotkey v%programVer%
	RegWrite, REG_SZ, HKLM, %key%, DisplayVersion, v%programVer%
	RegWrite, REG_SZ, HKLM, %key%, Publisher, fincs
	RegWrite, REG_SZ, HKLM, %key%, DisplayIcon, %installDir%\SciTE.exe
	RegWrite, REG_SZ, HKLM, %key%, URLInfoAbout, https://www.autohotkey.com/scite4ahk/
	RegWrite, REG_SZ, HKLM, %key%, UninstallString, "%uninstallProg%" %uninstallArgs%

	; ProgID registering
	RegWrite, REG_SZ, HKLM, Software\Classes\SciTE4AHK.Application,, SciTE4AHK.Application
	RegWrite, REG_SZ, HKLM, Software\Classes\SciTE4AHK.Application\CLSID,, {D7334085-22FB-416E-B398-B5038A5A0784}
	RegWrite, REG_SZ, HKLM, Software\Classes\SciTE4AHK.Application\Shell\Open\command,, "%installDir%\SciTE.exe" "`%1"
	RegWrite, REG_SZ, HKLM, Software\Classes\SciTE4AHK.Application\Shell\Open, FriendlyAppName, SciTE4AutoHotkey
	RegWrite, REG_SZ, HKLM, Software\Classes\CLSID\{D7334085-22FB-416E-B398-B5038A5A0784},, SciTE4AHK.Application
	RegWrite, REG_SZ, HKCR, .ahk\OpenWithProgids, SciTE4AHK.Application

	if bDefaultEditor
		RegWrite, REG_SZ, HKCR, AutoHotkeyScript\Shell\Edit\command,, "%installDir%\SciTE.exe" "`%1"

	if bDesktopShortcuts
		Util_CreateShortcut(A_DesktopCommon "\SciTE4AutoHotkey.lnk", installDir "\SciTE.exe", "AutoHotkey Script Editor")

	if bStartShortcuts
	{
		FileCreateDir, %A_ProgramsCommon%\SciTE4AutoHotkey
		Util_CreateShortcut(A_ProgramsCommon "\SciTE4AutoHotkey\SciTE4AutoHotkey.lnk", installDir "\SciTE.exe", "AutoHotkey Script Editor")
		Util_CreateShortcut(A_ProgramsCommon "\SciTE4AutoHotkey\Uninstall.lnk", uninstallProg, "Uninstall SciTE4AutoHotkey...", uninstallArgs, installDir "\toolicon.icl", 20)
	}

	; Write installer information
	RegWrite, REG_SZ, HKLM, Software\SciTE4AutoHotkey, InstallDir, %installDir%
	RegWrite, REG_DWORD, HKLM, Software\SciTE4AutoHotkey, InstallDefEditor, %bDefaultEditor%
	RegWrite, REG_DWORD, HKLM, Software\SciTE4AutoHotkey, InstallDefSS, %bStartShortcuts%
	RegWrite, REG_DWORD, HKLM, Software\SciTE4AutoHotkey, InstallDefDS, %bDesktopShortcuts%

	MsgBox, 64, %uititle%, Done! Thank you for choosing SciTE4AutoHotkey.
	Util_UserRun(installDir "\SciTE.exe")
	inInstall := false
	gosub GuiClose
}

Btn_PerformUninstall()
{
	if !closeSciTE()
		return

	RegRead, installDir, HKLM, Software\SciTE4AutoHotkey, InstallDir
	RegRead, defEdit, HKLM, Software\SciTE4AutoHotkey, InstallDefEditor
	RegRead, defSS, HKLM, Software\SciTE4AutoHotkey, InstallDefSS
	RegRead, defDS, HKLM, Software\SciTE4AutoHotkey, InstallDefDS

	RemoveDir(installDir "\")

	RegDelete, HKLM, Software\SciTE4AutoHotkey
	RegDelete, HKLM, Software\Microsoft\Windows\CurrentVersion\Uninstall\SciTE4AutoHotkey
	RegDelete, HKLM, Software\Classes\SciTE4AHK.Application
	RegDelete, HKLM, Software\Classes\CLSID\{D7334085-22FB-416E-B398-B5038A5A0784}
	RegDelete, HKCR, .ahk\OpenWithProgids, SciTE4AHK.Application

	if defEdit
		RegWrite, REG_SZ, HKCR, AutoHotkeyScript\Shell\Edit\command,, notepad.exe `%1

	if defSS
		RemoveDir(A_ProgramsCommon "\SciTE4AutoHotkey\")

	if defDS
		FileDelete, %A_DesktopCommon%\SciTE4AutoHotkey.lnk

	MsgBox, 52, %uititle%, Do you want to remove the user profile?
	IfMsgBox, Yes
		WipeProfile(A_MyDocuments "\AutoHotkey\SciTE\")

	MsgBox, 64, %uititle%, SciTE4AutoHotkey uninstalled successfully!
}
