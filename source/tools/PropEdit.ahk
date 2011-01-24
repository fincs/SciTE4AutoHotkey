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
SendMode Input
SetWorkingDir, %A_ScriptDir%

Menu, Tray, Icon, ..\toolicon.icl, 17

IsPortable := FileExist(A_ScriptDir "\..\$PORTABLE")
if !IsPortable
	LocalSciTEPath = %A_MyDocuments%\AutoHotkey\SciTE
else
	LocalSciTEPath = %A_ScriptDir%\..\user

scite := GetSciTEInstance()
if !scite
{
	MsgBox, 16, SciTE properties editor, Can't find SciTE!
	ExitApp
}

UserPropsFile = %LocalSciTEPath%\SciTEUser.properties

IfNotExist, %UserPropsFile%
{
	MsgBox, 16, SciTE properties editor, Can't find user properties file!
	ExitApp
}

FileEncoding, UTF-8
FileRead, UserProps, %UserPropsFile%

p_style  := FindPropOrDie("import Styles\\(.*)\.style", "style")
p_locale := FindPropOrDie("locale\.properties=locales\\(.*)\.locale\.properties", "locale")
p_backup := FindPropOrDie("make\.backup=([01])", "backup")

org_locale := p_locale

stylelist := CountStylesAndChoose(ch1)
localelist := CountLocalesAndChoose(ch2)

Gui, +ToolWindow +AlwaysOnTop
Gui, Add, Text, x12 y13 w80 h20 R10 +Right, Language:
Gui, Add, DropDownList, x102 y10 w100 h20 R10 Choose%ch2% vp_locale, %localelist%
Gui, Add, Text, x12 y43 w80 h20 +Right, Style:
Gui, Add, DropDownList, x102 y40 w100 h20 R10 Choose%ch1% vp_style, %stylelist%
Gui, Add, Text, x12 y72 w80 h20 +Right, Auto-backups:
Gui, Add, CheckBox, x102 y70 w15 h20 Checked%p_backup% vp_backup
Gui, Add, Button, x72 y100 w70 h20 gUpdate, Update
Gui, Show, w211 h129, SciTE settings
return

GuiClose:
ExitApp

Update:
Gui, Submit, NoHide
ReplaceProp("import Styles\\.*\.style", "import Styles\" p_style ".style")
ReplaceProp("locale\.properties=locales\\.*\.locale\.properties", "locale.properties=locales\" p_locale ".locale.properties")
ReplaceProp("make\.backup=[01]", "make.backup=" p_backup)

FileDelete, %UserPropsFile%
FileAppend, %UserProps%, *%UserPropsFile%

; Reload properties
scite.ReloadProps()

if(scite && p_locale != org_locale)
{
	MsgBox, 52, SciTE properties editor, Changing language requires restart.`nReopen SciTE?
	IfMsgBox, Yes
	{
		Gui, Destroy
		;WinClose, ahk_id %scite%
		WinClose, % "ahk_id " scite.GetSciTEHandle()
		WinWaitClose,,, 10
		if !ErrorLevel
			Run, %A_ScriptDir%\..\SciTE.exe
		ExitApp
	}
}

return

FindPropOrDie(regex, name)
{
	global UserProps
	if !RegExMatch(UserProps, "`am)^" regex "$", o)
	{
		MsgBox, 16, SciTE properties editor, Can't find %name% property!
		ExitApp
	}
	return o1
}

ReplaceProp(regex, repl)
{
	global UserProps
	UserProps := RegExReplace(UserProps, "`am)^" regex "$", repl)
}

CountStylesAndChoose(ByRef choosenum)
{
	global p_style, LocalSciTEPath
	i := 1
	
	Loop, %LocalSciTEPath%\Styles\*.properties
	{
		if !RegExMatch(A_LoopFileName, "\.style\.properties$")
			continue
		style := RegExReplace(A_LoopFileName, "\.style\.properties$")
		if(style = p_style)
			choosenum := i
		list .= "|" Style
		i ++
	}
	StringTrimLeft, list, list, 1
	return list
}

CountLocalesAndChoose(ByRef choosenum)
{
	global p_locale
	i := 1
	
	Loop, %A_ScriptDir%\..\locales\*.properties
	{
		if !RegExMatch(A_LoopFileName, "\.locale\.properties$")
			continue
		locale := RegExReplace(A_LoopFileName, "\.locale\.properties$")
		if (locale = p_locale)
			choosenum := i
		list .= "|" locale
		i ++
	}
	StringTrimLeft, list, list, 1
	return list
}

Util_Is64bitWindows()
{
	DllCall("IsWow64Process", "ptr", DllCall("GetCurrentProcess", "ptr"), "uint*", retval)
	if ErrorLevel
		return 0
	else
		return retval
}

Util_Is64bitProcess(pid)
{
	if !Util_Is64bitWindows()
		return 0
	
	proc := DllCall("OpenProcess", "uint", 0x0400, "uint", 0, "uint", pid, "ptr")
	DllCall("IsWow64Process", "ptr", proc, "uint*", retval)
	DllCall("CloseHandle", "ptr", proc)
	return retval ? 0 : 1
}
