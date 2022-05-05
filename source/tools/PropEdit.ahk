;
; SciTE4AutoHotkey Settings Editor
;

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
ListLines, Off
FileEncoding, UTF-8-RAW

Menu, Tray, Icon, ..\toolicon.icl, 17

scite := GetSciTEInstance()
if !scite
{
	MsgBox, 16, SciTE properties editor, Can't find SciTE!
	ExitApp
}

scite_hwnd := scite.SciTEHandle

LocalSciTEPath := scite.UserDir

UserPropsFile = %LocalSciTEPath%\_config.properties

IfExist, %UserPropsFile%
	FileRead, UserProps, %UserPropsFile%
else
	UserProps := ""

cplist_v := "0|65001|932|936|949|950|1361"
cplist_n := "System default|UTF-8|Shift-JIS|Chinese GBK|Korean Wansung|Chinese Big5|Korean Johab"

p_style  := FindProp("import Styles\\(.*)\.style", "SciTE4AutoHotkey Light")
p_locale := FindProp("locale\.properties=locales\\(.*)\.locale\.properties", "English")
p_encoding := FindProp("code\.page=(" cplist_v ")", 65001)
p_backup := FindProp("make\.backup=([01])", 1)
p_savepos := FindProp("save\.position=([01])", 1)
p_zoom := FindProp("magnification=(-?\d+)", 0)
p_font := FindProp("default\.text\.font=(.+)", "Consolas")
p_lineno := FindProp("line\.margin\.visible=([01])", 1)
p_autoupd := FindProp("automatic\.updates=([01])", 1)

if 1 = /regenerate
{
	; Upgrade old styles to comparable modern equivalents
	if p_style in Classic,PSPad,Light,VisualStudio
		p_style := "SciTE4AutoHotkey Light"
	else if p_style in HatOfGod,Noir,tidRich_Zenburn
		p_style := "SciTE4AutoHotkey Dark"

	regenMode := true
	gosub Update2
	ExitApp
}

org_locale := p_locale
org_zoom := p_zoom
org_lineno := p_lineno

stylelist := CountStylesAndChoose(ch1)
localelist := CountLocalesAndChoose(ch2)
p_encoding := FindInList(cplist_v, p_encoding)

Gui, New, +Owner%scite_hwnd% +ToolWindow, SciTE4AutoHotkey settings

Gui, Add, Text, Section +Right w70, Language:
Gui, Add, DDL, ys w150 R10 Choose%ch2% vp_locale, %localelist%

Gui, Add, Text, xs Section +Right w70, Style:
Gui, Add, DDL, ys w150 Choose%ch1% vp_style gDDL_Choose, %stylelist%|New...

Gui, Add, Text, xs Section +Right w70, Encoding:
Gui, Add, DDL, ys w150 +AltSubmit Choose%p_encoding% vp_encoding, %cplist_n%

Gui, Add, Text, xs Section +Right w70, Code font:
Gui, Add, DDL, ys w150 vp_font, % ListFonts()
GuiControl ChooseString, p_font, %p_font%

Gui, Add, Text, xs Section +Right w70, Text zoom:
Gui, Add, Edit, ys w50
Gui, Add, UpDown, vp_zoom Range-10-10, %p_zoom%
Gui, Add, Text, ys, (requires restart)

Gui, Add, CheckBox, xs+15 Checked%p_lineno% vp_lineno, Show line numbers (requires restart)
Gui, Add, CheckBox, xs+15 Checked%p_backup% vp_backup, Auto-backups
Gui, Add, CheckBox, xs+15 Checked%p_savepos% vp_savepos, Remember window position
Gui, Add, CheckBox, xs+15 Checked%p_autoupd% vp_autoupd, Automatically check for updates

Gui, Add, Button, xs+50 w60 Section gUpdate, Update
Gui, Add, Button, ys xs+90 w60 gEditStyle, Edit style
Gui, Show
return

DDL_Choose:
Gui, +OwnDialogs
GuiControlGet, n_style,, p_style
if (n_style != "New...")
{
	p_style := n_style
	return
}
GuiControl, ChooseString, p_style, %p_style%
FileRead, qvar, %LocalSciTEPath%\Styles\%p_style%.style.properties
if !RegExMatch(qvar, "`am)^s4ahk\.style=\d+$")
	p_style := "Blank" ; cannot fork an old-format style
InputBox, newStyleName, SciTE properties editor, Enter the name of the new style...,,,,,,,, %p_style%_Edited
if ErrorLevel
	return
if not newStyleName := ValidateFilename(Trim(newStyleName))
	return
IfExist, %LocalSciTEPath%\Styles\%newStyleName%.style.properties
{
	MsgBox, 48, SciTE properties editor, The style already exists.
	return
}
FileCopy, %LocalSciTEPath%\Styles\%p_style%.style.properties, %LocalSciTEPath%\Styles\%newStyleName%.style.properties
if ErrorLevel
{
	MsgBox, 16, SciTE properties editor, Error copying style.
	return
}
stylelist .= "|" newStyleName
GuiControl,, p_style, |%stylelist%|New...
GuiControl, ChooseString, p_style, %newStyleName%
p_style := newStyleName
goto EditStyle_

EditStyle:
Gui, +OwnDialogs
GuiControlGet, n_style,, p_style
EditStyle_:
Run, "%A_AhkPath%" "%A_ScriptDir%\StyleEdit.ahk" "%LocalSciTEPath%\Styles\%p_style%.style.properties"
return

GuiClose:
ExitApp

Update:
Gui, Submit, NoHide

if (p_locale != org_locale || p_zoom != org_zoom || p_lineno != org_lineno)
{
	Gui, +OwnDialogs
	MsgBox, 52, SciTE properties editor, Changing the language or certain other settings requires restarting SciTE.`nReopen SciTE?
	IfMsgBox, No
		return
	restartSciTE := true
}

Update2:

p_encoding := GetItem(cplist_v, p_encoding)

FileRead, qvar, %LocalSciTEPath%\Styles\%p_style%.style.properties
p_extra := ""
/*
if RegExMatch(qvar, "`am)^s4ahk\.style=1$")
	p_extra =
	(LTrim
	style.ahk1.0=$(s4ahk.style.default)
	style.ahk1.1=$(s4ahk.style.comment.line)
	style.ahk1.2=$(s4ahk.style.comment.block)
	style.ahk1.3=$(s4ahk.style.escape)
	style.ahk1.4=$(s4ahk.style.operator)
	style.ahk1.5=$(s4ahk.style.operator)
	style.ahk1.6=$(s4ahk.style.string)
	style.ahk1.7=$(s4ahk.style.number)
	style.ahk1.8=$(s4ahk.style.var)
	style.ahk1.9=$(s4ahk.style.var)
	style.ahk1.10=$(s4ahk.style.label)
	style.ahk1.11=$(s4ahk.style.flow)
	style.ahk1.12=$(s4ahk.style.bif)
	style.ahk1.13=$(s4ahk.style.func)
	style.ahk1.14=$(s4ahk.style.directive)
	style.ahk1.15=$(s4ahk.style.old.key)
	style.ahk1.16=$(s4ahk.style.biv)
	style.ahk1.17=$(s4ahk.style.wordop)
	style.ahk1.18=$(s4ahk.style.old.user)
	style.ahk1.19=$(s4ahk.style.biv)
	style.ahk1.20=$(s4ahk.style.error)
	if s4ahk.style.old.synop
	`tstyle.ahk1.4=$(s4ahk.style.old.synop)
	if s4ahk.style.old.deref
	`tstyle.ahk1.9=$(s4ahk.style.old.deref)
	if s4ahk.style.old.bivderef
	`tstyle.ahk1.19=$(s4ahk.style.old.bivderef)

	)
*/

UserProps =
(
# THIS FILE IS SCRIPT-GENERATED - DON'T TOUCH
locale.properties=locales\%p_locale%.locale.properties
make.backup=%p_backup%
code.page=%p_encoding%
output.code.page=%p_encoding%
save.position=%p_savepos%
magnification=%p_zoom%
line.margin.visible=%p_lineno%
default.text.font=%p_font%
automatic.updates=%p_autoupd%
import Styles\%p_style%.style
%p_extra%import _extensions
)

FileDelete, %UserPropsFile%
FileAppend, %UserProps%, %UserPropsFile%

; Reload properties
scite.ReloadProps()

if restartSciTE
{
	Gui, Destroy
	WinClose, ahk_id %scite_hwnd%
	WinWaitClose,,, 10
	if !ErrorLevel
		Run, "%A_ScriptDir%\..\SciTE.exe"
	ExitApp
}

return

FindProp(regex, default := "")
{
	global UserProps
	return RegExMatch(UserProps, "`am)^" regex "$", o) ? o1 : default
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

ListFonts()
{
	VarSetCapacity(logfont, 128, 0), NumPut(1, logfont, 23, "UChar")
	obj := []
	DllCall("EnumFontFamiliesEx", "ptr", DllCall("GetDC", "ptr", 0), "ptr", &logfont, "ptr", RegisterCallback("EnumFontProc"), "ptr", &obj, "uint", 0)
	for font in obj
		list .= "|" font
	StringTrimLeft list, list, 1
	return list
}

EnumFontProc(lpFont, tm, fontType, lParam)
{
	obj := Object(lParam)
	obj[StrGet(lpFont+28)] := 1
	return 1
}

FindInList(ByRef list, item, delim := "|")
{
	Loop, Parse, list, %delim%
		if (A_LoopField = item)
			return A_Index
}

GetItem(ByRef list, id, delim := "|")
{
	Loop, Parse, list, %delim%
		if (A_Index = id)
			return A_LoopField
}

ValidateFilename(fn)
{
	StringReplace, fn, fn, \, _, All
	StringReplace, fn, fn, /, _, All
	StringReplace, fn, fn, :, _, All
	StringReplace, fn, fn, *, _, All
	StringReplace, fn, fn, ?, _, All
	StringReplace, fn, fn, ", _, All
	StringReplace, fn, fn, <, _, All
	StringReplace, fn, fn, >, _, All
	StringReplace, fn, fn, |, _, All
	return fn
}
