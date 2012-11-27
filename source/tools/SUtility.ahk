#NoEnv
#NoTrayIcon
#SingleInstance Ignore
DetectHiddenWindows, On
FileEncoding, UTF-8
Menu, Tray, Icon, %A_ScriptDir%\..\toolicon.icl, 11

scite := GetSciTEInstance()
if !scite
{
	MsgBox, 16, Scriptlet Utility, SciTE COM object not found!
	ExitApp
}

LocalSciTEPath := scite.UserDir
scitehwnd := scite.SciTEHandle

sdir = %LocalSciTEPath%\Scriptlets
IfNotExist, %sdir%
{
	MsgBox, 16, Scriptlet Utility, Scriptlet folder doesn't exist!
	ExitApp
}

FileEncoding, UTF-8

; Check command line
if 1 = /insert
{
	if 2 =
	{
		MsgBox, 64, Scriptlet Utility, Usage: %A_ScriptName% /insert scriptletName
		ExitApp
	}
	IfNotExist, %sdir%\%2%.scriptlet
	{
		MsgBox, 52, Scriptlet Utility,
		(LTrim
		Invalid scriptlet name: "%2%".
		Perhaps you have clicked on a toolbar icon whose scriptlet attached no longer exists?
		Press OK to edit the toolbar properties file.
		)
		IfMsgBox, Yes
			scite.OpenFile(LocalSciTEPath "\UserToolbar.properties")
		ExitApp
	}
	FileRead, text2insert, %sdir%\%2%.scriptlet
	gosub InsertDirect
	ExitApp
}

if 1 = /addScriptlet
{
	defaultScriptlet := scite.Selection
	if defaultScriptlet =
	{
		MsgBox, 16, Scriptlet Utility, Nothing is selected!
		ExitApp
	}
	gosub AddBut ; that does it all
	if !_RC
		ExitApp ; Maybe the user has cancelled the action.
	MsgBox, 68, Scriptlet Utility, Scriptlet added sucessfully. Do you want to open the scriptlet manager?
	IfMsgBox, Yes
		Reload ; no parameters are passed to script
	ExitApp
}

Gui, Add, ListBox, x2 y2 w160 h240 vMainListbox gSelectLB
Gui, Font, S9, Courier New
Gui, Add, Edit, x172 y2 w290 h240 vScriptPane -Wrap +WantTab +HScroll
Gui, Font
Gui, Add, Button, x2 y242 w20 h20 gAddBut, +
Gui, Add, Button, x22 y242 w20 h20 gSubBut, -
Gui, Add, Button, x42 y242 w20 h20 gRenBut, *
Gui, Add, Button, x72 y242 w80 h20 gToolbarBut, Add to toolbar
Gui, Add, Button, x172 y242 w90 h20 gInsertBut, Insert into SciTE
Gui, Add, Button, x262 y242 w40 h20 gSaveBut, Save
Gui, Add, Button, x312 y242 w120 h20 gOpenInSciTE, Open scriptlet in SciTE
Gui, Add, Button, x442 y242 w20 h20 gGuiClose, X
Gui, Show, w478 h270, Scriptlet Utility
selectQ =
defaultScriptlet =
gosub ListboxUpdate
return

GuiClose:
ExitApp

SelectLB:
GuiControlGet, fname2open,, MainListbox
FileRead, scriptletText, %sdir%\%fname2open%.scriptlet
GuiControl,, ScriptPane, % scriptletText
Return

AddBut:
InputBox, fname2create, Scriptlet Utility, Input the name of the scriptlet to create
if ErrorLevel
	return
if !fname2create
	return
fname2create := ValidateFilename(fname2create)
IfExist, %sdir%\%fname2create%.scriptlet
{
	gosub CompleteUpdate
	return
}
FileAppend, % defaultScriptlet, %sdir%\%fname2create%.scriptlet
gosub CompleteUpdate
_RC = 1
Return

CompleteUpdate:
selectQ = %fname2create%
gosub ListboxUpdate
selectQ =
if defaultScriptlet =
	gosub SelectLB
return

SubBut:
GuiControlGet, selected,, MainListbox
if selected =
	return
FileDelete, %sdir%\%selected%.scriptlet
fname2create =
gosub CompleteUpdate
return

RenBut:
GuiControlGet, selected,, MainListbox
if selected =
	return
InputBox, fname2create, Scriptlet Utility, Input the new name of the scriptlet,,,,,,,, %selected%
if ErrorLevel
	return
if !fname2create
	return
if (fname2create = selected)
	return
fname2create := ValidateFilename(fname2create)
IfExist, %sdir%\%fname2create%.scriptlet
{
	MsgBox, 48, Scriptlet Utility, That name already exists!`nChoose another name please.
	return
}
FileMove, %sdir%\%selected%.scriptlet, %sdir%\%fname2create%.scriptlet
gosub CompleteUpdate
return

ToolbarBut:
GuiControlGet, selected,, MainListbox
if selected =
	return

FileAppend, `n=Scriptlet: %selected%|`%LOCALAHK`% tools\SUtility.ahk /insert "%selected%"||`%ICONRES`%`,12, %LocalSciTEPath%\UserToolbar.properties
scite.Message(0x1000+2)
return

InsertBut:
GuiControlGet, text2insert,, ScriptPane
InsertDirect:
if text2insert =
	return
WinActivate, ahk_id %scitehwnd%
scite.InsertText(text2insert)
return

SaveBut:
GuiControlGet, fname2save,, MainListbox
GuiControlGet, text2save,, ScriptPane
FileDelete, %sdir%\%fname2save%.scriptlet
FileAppend, % text2save, %sdir%\%fname2save%.scriptlet
return

OpenInSciTE:
GuiControlGet, fname2open,, MainListbox
if fname2open =
	return
scite.OpenFile(sdir "\" fname2open ".scriptlet")
return

ListboxUpdate:
te =
Loop, %sdir%\*.scriptlet
{
	SplitPath, A_LoopFileName,,,, sn
	if sn =
		continue
	te = %te%|%sn%
	if selectQ = %sn%
		te .= "|"
}
GuiControl,, MainListbox, % te
return

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
