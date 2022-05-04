;
; SciTE4AutoHotkey Style Editor
;

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
ListLines, Off

Menu Tray, Icon, ..\toolicon.icl, 17

if 0 != 1
{
	MsgBox, 48, SciTE Style Editor, This script is not designed to be launched directly.
	ExitApp
}

StyleFileName = %1%

scite := GetSciTEInstance()
if !scite
{
	MsgBox 16, SciTE Style Editor, Can't find SciTE!
	ExitApp
}

scite_hwnd := scite.SciTEHandle

FileEncoding UTF-8-RAW
FileRead StyleText, *t %StyleFileName%

if !RegExMatch(StyleText, "`am)^s4ahk\.style=(\d+)$", o)
{
	; Legacy style file which cannot be edited by this program.
	scite.OpenFile(StyleFilename)
	ExitApp
}

styleVersion := o1+0
if (styleVersion > 2)
{
	MsgBox 16, SciTE Style Editor, Unrecognised style version: %styleVersion%
	ExitApp
}

if (styleVersion < 2)
{
	; Convert style1 into style2
	StyleText := RegExReplace(StyleText, "`am)^(s4ahk\.style=)(\d+)", "${1}2")
	StyleText := RegExReplace(StyleText, "`am)^(default\.text\.font=.*)$", "# Disabled: $1")
	StyleText := RegExReplace(StyleText, "`am)^style\.\*\.32=.*(back:[#0-9a-fA-F]+,fore:[#0-9a-fA-F]+).*$", "s4ahk.style.base=${1}")
	StyleText := RegExReplace(StyleText, "`am)^s4ahk\.style\.var", "s4ahk.style.ident.top")
	StyleText := RegExReplace(StyleText, "`am)^s4ahk\.style\.objprop", "s4ahk.style.ident.obj")
	StyleText := RegExReplace(StyleText, "`am)^s4ahk\.style\.wordop", "s4ahk.style.ident.reserved")
	StyleText := RegExReplace(StyleText, "`am)^s4ahk\.style\.biv", "s4ahk.style.known.var")
	StyleText := RegExReplace(StyleText, "`am)^s4ahk\.style\.bif", "s4ahk.style.known.func")
	StyleText := RegExReplace(StyleText, "`am)^s4ahk\.style\.func", "s4ahk.style.known.class")
	StyleText := RegExReplace(StyleText, "`am)^s4ahk\.style\.biobjprop", "s4ahk.style.known.obj.prop")
	StyleText := RegExReplace(StyleText, "`am)^s4ahk\.style\.biobjmethod", "s4ahk.style.known.obj.method")
}

isv2 := InStr(scite.ResolveProp("ahk.platform"), "v2") = 1

styles := [{prop: "s4ahk.style.base", name: "Base style" }
, "Syntax features"
, {prop: "s4ahk.style.default", name: "Default" }
, {prop: "s4ahk.style.error", name: "Syntax error" }
, {prop: "s4ahk.style.comment.line", name: "Line comment" }
, {prop: "s4ahk.style.comment.block", name: "Block comment" }
, {prop: "s4ahk.style.directive", name: "Directive" }
, {prop: "s4ahk.style.label", name: "Label && Hotkey" }
, {prop: "s4ahk.style.flow", name: "Control Flow" }
, {prop: "s4ahk.style.number", name: "Number" }
, {prop: "s4ahk.style.string", name: "String && Hotstring" }
, {prop: "s4ahk.style.escape", name: "Escaped char." }
, {prop: "s4ahk.style.operator", name: "Operator" }
, {prop: "s4ahk.style.ident.top", name: "Identifier" }
, {prop: "s4ahk.style.ident.obj", name: "Object syntax" }
, {prop: "s4ahk.style.ident.reserved", name: "Reserved word" }
, "AutoHotkey built-ins"
, {prop: "s4ahk.style.known.var", name: "Variable" }
, {prop: "s4ahk.style.known.func", name: isv2 ? "Function" : "Command" }
, {prop: "s4ahk.style.known.class", name: isv2 ? "Class" : "Function" }
, {prop: "s4ahk.style.known.obj.prop", name: isv2 ? "Object property" : "(v2) Obj. property" }
, {prop: "s4ahk.style.known.obj.method", name: isv2 ? "Object method" : "(v2) Obj. method" }]

if RegExMatch(StyleText, "`am)^s4ahk\.style\.old\.")
{
	styles.Insert("AutoHotkey v1.x deprecated styles")
	styles.Insert({prop: "s4ahk.style.old.synop", name: "Syntax operator"})
	styles.Insert({prop: "s4ahk.style.old.deref", name: "%Dereference%"})
	styles.Insert({prop: "s4ahk.style.old.key", name: "Keys && Buttons"})
	styles.Insert({prop: "s4ahk.style.old.user", name: "User identifier"})
	styles.Insert({prop: "s4ahk.style.old.bivderef", name: "%A_Dereference%"})
}

data := {}

Menu, TheMenu, Add, Set Color, SetColor
Menu, TheMenu, Add, Inherit Color, InheritColor

Gui +Owner%scite_hwnd% +ToolWindow +HwndMainWin
OnMessage(0x0138, "WM_CTLCOLORSTATIC")
Gui Add, Text, Section w90 Center
Gui Add, Text, ys w80 Center, Text color
Gui Add, Text, ys w80 Center, Back color
Gui Font, Bold
Gui Add, Text, ys w25, B
Gui Font
Gui Font, Italic
Gui Add, Text, ys w25, I
Gui Font
Gui Font, Underline
Gui Add, Text, ys w25, U
Gui Font
Gui Add, Text, ys w30, Eol
for _,style in styles
{
	isSpecial := IsBaseStyle(style.prop), Check3 := isSpecial ? "" : "Check3"
	if !IsObject(style)
	{
		Gui Font, Bold s10
		Gui Add, Text, xs, % style
		Gui Font
		continue
	}
	data[style.prop] := StrSplit(GetTheProp(style.prop), ",", " `t")
	Gui Add, Text, xs Section w90 Right, % style.name
	Gui Add, Text, ys Border w80 Center vtxtFgClr%A_Index% gChooseColor, % GetStyleParam(style.prop, "fore:")
	Gui Add, Text, ys Border w80 Center vtxtBgClr%A_Index% gChooseColor, % GetStyleParam(style.prop, "back:")
	cB := GetStyleCheck(style.prop, "bold", isSpecial)
	cI := GetStyleCheck(style.prop, "italics", isSpecial)
	cU := GetStyleCheck(style.prop, "underlined", isSpecial)
	cE := GetStyleCheck(style.prop, "eolfilled", isSpecial)
	Gui Add, CheckBox, ys %Check3% w25 vchkB%A_Index% Checked%cB%
	Gui Add, CheckBox, ys %Check3% w25 vchkI%A_Index% Checked%cI%
	Gui Add, CheckBox, ys %Check3% w25 vchkU%A_Index% Checked%cU%
	Gui Add, CheckBox, ys %Check3% w25 vchkE%A_Index% Checked%cE%
}
GuiControl,, editFontSize, % GetStyleParam(styles[1].prop, "size:")
Gui Add, Button, xs+160 Section gSaveStyle, Save Style
Gui Show,, SciTE4AutoHotkey Style Editor
WinSet, Redraw,, ahk_id %MainWin%
return

WM_CTLCOLORSTATIC(wParam, lParam, msg, hwnd)
{
	Critical
	static brushes := []
	Gui +OwnDialogs
	GuiControlGet varName, Name, %lParam%
	if InStr(varName, "txt") != 1
		return
	if (brush := brushes[lParam]) && brush >= 0
		DllCall("DeleteObject", "ptr", brush)
	GuiControlGet tt,, %varName%
	if (tt = "Inherited")
		return
	clr := ClrSwap(ColorUnpretty(tt))
	brush := DllCall("CreateSolidBrush", "uint", clr, "ptr")
	DllCall("SetBkMode", "uint", wParam, "int", 1)
	DllCall("SetTextColor", "uint", wParam, "int", clr)
	DllCall("SetBkColor", "uint", wParam, "int", clr)
	return brush
}

GuiClose:
ExitApp

SaveStyle:
Gui Submit, NoHide
Gui +OwnDialogs
for id,which in styles
{
	if !IsObject(which)
		continue
	isSpecial := IsBaseStyle(which.prop)
	parts := data[which.prop]
	; Remove all style props
	parts2 := []
	for _, part in parts
	{
		if part in bold,notbold,italics,notitalics,underlined,notunderlined,eolfilled,noteolfilled
			continue
		if InStr(part, "fore:") = 1 || InStr(part, "back:") = 1
			continue
		parts2.Insert(part)
	}
	; Set colors
	GuiControlGet fore,, txtFgClr%id%
	GuiControlGet back,, txtBgClr%id%
	if (fore != "Inherited")
		parts2.Insert("fore:" fore)
	if (back != "Inherited")
		parts2.Insert("back:" back)
	; Set style
	(val:=chkB%A_Index%) = 1 ? parts2.Insert("bold")       : (!isSpecial&&!val) ? parts2.Insert("notbold")       : ""
	(val:=chkI%A_Index%) = 1 ? parts2.Insert("italics")    : (!isSpecial&&!val) ? parts2.Insert("notitalics")    : ""
	(val:=chkU%A_Index%) = 1 ? parts2.Insert("underlined") : (!isSpecial&&!val) ? parts2.Insert("notunderlined") : ""
	(val:=chkE%A_Index%) = 1 ? parts2.Insert("eolfilled")  : (!isSpecial&&!val) ? parts2.Insert("noteolfilled")  : ""
	; Build string
	str := ""
	for _,part in parts2
		str .= "," part
	StringTrimLeft str, str, 1
	SetTheProp(which.prop, str)
}
FileDelete, %StyleFileName%
FileAppend, % StyleText, %StyleFileName%
scite.ReloadProps()
return

ChooseColor:
Gui +OwnDialogs
lastCtrl := A_GuiControl, RegExMatch(lastCtrl, "(\d+)", o), styleId := o1
if (styleId = 1)
	goto SetColor
Menu, TheMenu, Show
return

SetColor:
GuiControlGet q,, %lastCtrl%
if (q = "Inherited")
	GuiControlGet q,, % InStr(lastCtrl, "bg") ? "txtBgClr1" : "txtFgClr1"
clr := ChooseColor(ColorUnpretty(q))
if (clr < 0)
	return
GuiControl,, %lastCtrl%, % ColorPretty(clr)
GuiControl, MoveDraw, %lastCtrl%
return

InheritColor:
GuiControl,, %lastCtrl%, Inherited
GuiControl, MoveDraw, %lastCtrl%
return

IsBaseStyle(name)
{
	return name == "s4ahk.style.base"
}

GetStyleParam(name, isit)
{
	global data
	for _,part in data[name]
		if InStr(part, isit) = 1
			return SubStr(part, StrLen(isit)+1)
	return "Inherited"
}

GetStyleCheck(name, isit, isFirst)
{
	global data
	for _,part in data[name]
		if (part = isit)
			return 1
		else if (part = "not" isit)
			return 0
	return isFirst ? 0 : "Gray"
}

GetTheProp(name)
{
	global StyleText
	StringReplace name, name, ., \., All
	StringReplace name, name, *, \*, All
	if !RegExMatch(StyleText, "`am)^" name "=(.*)$", o)
		return ""
	return o1
}

SetTheProp(nam_, val)
{
	global StyleText
	StringReplace name, nam_, ., \., All
	StringReplace name, name, *, \*, All
	if RegExMatch(StyleText, "`am)^" name "=")
		StyleText := RegExReplace(StyleText, "`am)^(" name ")=.*$", "$1=" val)
	else if (val != "")
		StyleText .= "`n" nam_ "=" val "`n"
}

ChooseColor(initColor := -1)
{
	static init := false, buf
	if !init
	{
		init := true
		VarSetCapacity(buf, 16*4)
	}
	VarSetCapacity(CHOOSECOLOR, 9*A_PtrSize, 0)
	NumPut(9*A_PtrSize, CHOOSECOLOR, 0, "UInt")
	Gui +HwndHwnd
	NumPut(Hwnd, CHOOSECOLOR, 1*A_PtrSize, "UInt")
	NumPut(&buf, CHOOSECOLOR, 4*A_PtrSize)
	flags := 0x100 | 2
	if (initColor >= 0)
	{
		NumPut(ClrSwap(initColor), CHOOSECOLOR, 3*A_PtrSize, "UInt")
		flags |= 1
	}
	NumPut(flags, CHOOSECOLOR, 5*A_PtrSize, "UInt")
	return DllCall("comdlg32\ChooseColor", "ptr", &CHOOSECOLOR) ? ClrSwap(NumGet(CHOOSECOLOR, 3*A_PtrSize, "UInt")) : -1
}

ColorPretty(a)
{
	oldf := A_FormatInteger
	SetFormat, IntegerFast, H
	a += 0
	a := "#" SubStr("000000" SubStr(a, 3), -5)
	SetFormat, IntegerFast, %oldf%
	return a
}

ColorUnpretty(a)
{
	return "0x" SubStr(a, 2)
}

ClrSwap(a)
{
	return (a & 0xFF00) | (a >> 16) | ((a&0xFF)<<16)
}
