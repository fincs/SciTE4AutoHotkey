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
global intlAhkName := ""
global v3Upgrade := false
global ahkVer := Util_GetAhkVer()
global hasLegacyAhk := ahkVer < "1.1"
global previousInstallDir := ""
global inInstall := false

SplitPath, A_AhkPath, intlAhkName

if winVer < 5.1
{
	MsgBox, 16, %uititle%, Windows 2000 and earlier are not supported.
	ExitApp
}

if 1 = /douninstall
	goto UninstallMain

FileRead, programVer, %A_ScriptDir%\$DATA\$VER

if FileExist("SciTE.exe")
	bUninstall := true
else if ErrorLevel || !FileExist("$DATA\") || !FileExist("dialog.html") || !FileExist("banner.png")
{
	MsgBox, 48, %uititle%, Oops `;p ; Short msg since so rare.
	ExitApp
}

if bUninstall
	goto UninstallPrompt

Menu, Tray, Icon, $DATA\SciTE.exe

Gui, Margin, 0, 0
Gui, Add, ActiveX, vwb w600 h400 hwndhwb, Shell.Explorer
ComObjConnect(wb, "wb_")
OnMessage(0x100, "gui_KeyDown", 2)
InitUI()
Gui, Show,, %uititle%
return

GuiClose:
if inInstall
	return
Gui, Destroy
ExitApp

UninstallPrompt:
MsgBox, 52, %uititle%, Are you sure you want to remove SciTE4AutoHotkey?
IfMsgBox, No
	ExitApp

FileCopy, %A_AhkPath%, %A_Temp%, 1
FileCopy, %A_ScriptFullPath%, %A_Temp%, 1
runasverb := A_IsAdmin ? "" : "*RunAs "
Run, %runasverb%"%A_Temp%\%intlAhkName%" /CP65001 "%A_Temp%\%A_ScriptName%" /douninstall
ExitApp

UninstallMain:
Btn_PerformUninstall()
ExitApp

InitUI()
{
	global wb
	SetWBClientSite(wb)
	wb.Silent := true
	wb.Navigate("file://" A_ScriptDir "\dialog.html")
	while wb.ReadyState != 4
		Sleep, 10
	doc := getDocument()
	doc.getElementById("versionTag").innerText := "version " programVer
	doc.getElementById("yearTag1").innerText := A_Year
	doc.getElementById("yearTag2").innerText := A_Year
	if (A_ScreenDPI != 96)
		wb.document.body.style.zoom := A_ScreenDPI/96
}

; Fix keyboard shortcuts in WebBrowser control.
; References:
; http://www.autohotkey.com/community/viewtopic.php?p=186254#p186254
; http://msdn.microsoft.com/en-us/library/ms693360
gui_KeyDown(wParam, lParam, nMsg, hWnd)
{
	global wb
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

Lnk_CompileAhk()
{
	Run, http://www.autohotkey.com/community/viewtopic.php?t=22975
}

Btn_Exit()
{
	gosub GuiClose
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
	
	if FileExist(ahkPath "\SciTE\$VER")
	{
		FileRead, ov, %ahkPath%\SciTE\$VER
		if ov = 3.0.00
		{
			; We're upgrading from S4AHK v3.0.00 (which used a different installer)
			v3Upgrade := true
			RegRead, ov, HKCR, AutoHotkeyScript\Shell\Edit\command
			defEdit := InStr(ov, "SciTE.exe")
			defSS := FileExist(A_ProgramsCommon "\SciTE4AutoHotkey\")
			defDS := FileExist(A_DesktopCommon "\SciTE4AutoHotkey.lnk")
			previousInstallDir := ahkPath "\SciTE"
		}
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
	Run, http://www.ahkscript.org/
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
	if ErrorLevel
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
	
	UninstallOldBetas(0)
	
	if v3Upgrade
		RemoveDir(ahkPath "\SciTE\")
	
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
	sourceFolderObj := oShell.Namespace(A_ScriptDir "\$DATA")
	targetFolderObj.CopyHere(sourceFolderObj.Items, 16 | 2048)
	FileCopy, %A_AhkPath%, %installDir%\, 1
	FileCopy, %A_ScriptFullPath%, %installDir%\, 1
	if (winVer < 6)
	{
		; Fix up Windows XP/2003's lack of Consolas font
		_tmpf := installDir "\newuser\_config.properties"
		FileRead, _tmp, %_tmpf%
		StringReplace, _tmp, _tmp, VisualStudio, Classic
		FileDelete, %_tmpf%
		FileAppend, % _tmp, %_tmpf%
	}
	
	uninstallProg = %installDir%\%intlAhkName%
	uninstallArgs = /CP65001 "%installDir%\%A_ScriptName%"
	key = Software\Microsoft\Windows\CurrentVersion\Uninstall\SciTE4AutoHotkey
	RegWrite, REG_SZ, HKLM, %key%, DisplayName, SciTE4AutoHotkey v%programVer%
	RegWrite, REG_SZ, HKLM, %key%, DisplayVersion, v%programVer%
	RegWrite, REG_SZ, HKLM, %key%, Publisher, fincs
	RegWrite, REG_SZ, HKLM, %key%, DisplayIcon, %installDir%\SciTE.exe
	RegWrite, REG_SZ, HKLM, %key%, URLInfoAbout, http://www.autohotkey.net/~fincs/SciTE4AutoHotkey_3/web/
	RegWrite, REG_SZ, HKLM, %key%, UninstallString, "%uninstallProg%" %uninstallArgs%
	
	; COM registering
	RegWrite, REG_SZ, HKLM, Software\Classes\SciTE4AHK.Application,, SciTE4AHK.Application
	RegWrite, REG_SZ, HKLM, Software\Classes\SciTE4AHK.Application\CLSID,, {D7334085-22FB-416E-B398-B5038A5A0784}
	RegWrite, REG_SZ, HKLM, Software\Classes\CLSID\{D7334085-22FB-416E-B398-B5038A5A0784},, SciTE4AHK.Application
	
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
