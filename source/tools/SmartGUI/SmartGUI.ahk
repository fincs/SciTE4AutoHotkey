
/*

___________________________________________
______SmartGUI Creator   - Rajat___________
___________________________________________
_ fincs' version
_ modified for SciTE4AutoHotkey

     GUI creation tool for AutoHotkey
            (www.autohotkey.com)


___________________________________________


GUI1 = Main window
GUI2 = About window
GUI3 = Move group window
GUI4 = Font window
GUI5 = GUI Helper window
GUI6 = Set Position
GUI7 = Custom Control Option
GUI8 = Save Options
GUI9 = ToolBar

ToolTip1 = Toolbar help
ToolTip2 = Move Group selection

Support for new controls to be added in:
	-Main Menu
	-CreateCtrl
	-EditGUI
	-GUIStealer
	-Justify options

___________________________________________

Misc Notes:

Controls = Button,Checkbox,ComboBox,DateTime,DropDownList,Edit,GroupBox,ListBox,ListView,MonthCal,Progress,Picture,Radio,Slider,Tab,Text,UpDown,Hotkey

___________________________________________

*/

;___________________________________________
; Variable Declarations

;Release version
Rel = 4.0

MainWnd = Untitled GUI
MenuWnd = SmartGUI Creator for SciTE4AutoHotkey v3
GeneratedWnd = Untitled GUI
CustomOptions = -16|BackgroundTrans|Border|Buttons|Center|Checked|Disabled|Hidden|Horz|HScroll|Invert|Left|Limit|Lowercase|Multi|NoTicks|Number|Password|Range|ReadOnly|Right|Smooth|Theme|ToolTip|Uppercase|Vertical|VScroll|WantReturn|Wrap

scite := GetSciTEInstance()
if !scite
{
	MsgBox, 16, SmartGUI Creator, Cannot find SciTE!
	ExitApp
}

SettingsPath := scite.UserDir "\Settings"

;___________________________________________


#ErrorStdOut
#InstallKeybdHook
#InstallMouseHook
#SingleInstance Ignore
#NoTrayIcon

SetTitleMatchMode, Slow
SetControlDelay, 0
SetWinDelay, 0
SetWorkingDir, %A_ScriptDir%
SetFormat, floatfast, 1.1
DetectHiddenWindows, On
FileEncoding, UTF-8
Menu, Tray, Tip, SmartGUI Creator
Menu, Tray, Icon, ..\..\toolicon.icl, 13

/*
;Include source with comments
StringCaseSense, On
IfEqual, 1, GiveMeSource
{
	FileInstall, SmartGUI.ahk, %A_ScriptDir%\SmartGUI.ahk
	ExitApp
}
StringCaseSense, Off



;Not to run on Win9x
IfEqual, A_OSType, WIN32_WINDOWS
{
	MsgBox,, Unsupported Windows Version, Your version of MS Windows is not supported by this SmartGUI Creator release.`nThe supported versions are Windows NT / 2000 / XP / 2003 and beyond.
	ExitApp
}
*/

;Only one instance allowed
WinGetClass, SelfClass, %MainWnd%
IfEqual, SelfClass, AutoHotkeyGUI
{
	MsgBox,, SmartGUI Creator already running, Another instance of SmartGUI Creator found.`nOnly one instance is supported.
	ExitApp
}


;ask to read manual
IfNotExist, %SettingsPath%\SmartGUI.ini
{
	Msgbox, 4, WELCOME, Welcome to SmartGUI Creator`n`nIf you are using it for the first time, then it's recommended that you read the help manual, especially the 'Guidelines' section.`n`nWould you like to open it now?
	IfMsgbox, Yes
	{
		IfExist, %A_ScriptDir%\SmartGUI.html, run, %A_ScriptDir%\SmartGUI.html
		IfNotExist, %A_ScriptDir%\SmartGUI.html, MsgBox,, Error, SmartGUI.html not found!
	}
	Gosub, ShowHelp
}


;IfExist, %A_ScriptDir%\Grid.gif
	GridFile = %A_ScriptDir%\Grid.gif
/*Else
{
	FileInstall, BlockGrid.gif, %Temp%\Grid.gif, 1
	GridFile = %Temp%\Grid.gif
}
*/
;FileInstall, splash.gif, %Temp%\splash.gif, 1
;FileInstall, smartgui.icl, %Temp%\smartgui.icl, 1
FileDelete, %Temp%\SGUIControls.ini

SplashImage, splash.gif, B1 FS10 WS500

MenuGenerate:

Menu, Options, Add, Show Grid, Grid
Menu, Options, Check, Show Grid
;Menu, Options, Add, Show GUI Helper, Helper
;Menu, Options, Check, Show GUI Helper
Menu, Options, Add, Ask Control Label, CtrlText
Menu, Options, Add, MicroEditing, MicroEditing
Menu, Options, Add, Shift + Move Group, ShiftMove
Menu, Options, Add, Ask GUI Count, AskGUICount


Menu, Tray, NoStandard
Menu, Tray, UseErrorLevel

Menu, FileMenu, Add, `:`: SmartGUI Creator by Rajat `:`:, About
Menu, FileMenu, Default, `:`: SmartGUI Creator by Rajat `:`:
Menu, FileMenu, Add
;Menu, FileMenu, Add, &Open Script, EditGUI
Menu, FileMenu, Add, &Test Script`t[F9], TestGUI
Menu, FileMenu, Add, &Save Script and exit, GuiClose
;Menu, FileMenu, Add, &Save Script, SaveGUI2
;Menu, FileMenu, Add, Save Script &As, SaveGUI
Menu, FileMenu, Add
Menu, FileMenu, Add, GUI St&ealer, Stealer
Menu, FileMenu, Add, Set GUI Count in Script, SetGUICount
Menu, FileMenu, Add
Menu, FileMenu, Add, &Reload, Reload
Menu, FileMenu, Add, E&xit, GuiClose


Menu, HelpMenu, Add, Help Manual, OpenManual
Menu, HelpMenu, Add, Keyboard Help, ShowHelp


Menu, ControlMenu, Add, Duplicate Control, Duplicate
Menu, ControlMenu, Add, Move Control, Modify
Menu, ControlMenu, Add, Set Position, SetPos
Menu, ControlMenu, Add, Delete Control, Delete
Menu, ControlMenu, Add, Change Label, ChangeLabel
Menu, ControlMenu, Add, Center Horizontally, CenterH
Menu, ControlMenu, Add, Center Vertically, CenterV
Menu, ControlMenu, Add, Custom Option, CustomOption


Menu, JustifyMenu, Add, Left, Justify
Menu, JustifyMenu, Add, Center, Justify
Menu, JustifyMenu, Add, Right, Justify


Menu, ControlMenu, add, Justify, :JustifyMenu


;Original Window settings
GuiW = 475
GuiH = 375

;For grid, label & microedit settings
G = 1
L = 0
M = 0


PosFields = XYWH
;___________________________________________
; Reading/Writing settings

IniRead, SaveDir, %SettingsPath%\SmartGUI.ini, Folders, SaveDir
IniRead, LoadDir, %SettingsPath%\SmartGUI.ini, Folders, LoadDir

IfEqual, SaveDir, ERROR, SetEnv, SaveDir,
IfEqual, LoadDir, ERROR, SetEnv, LoadDir,

IniRead, ShiftMove, %SettingsPath%\SmartGUI.ini, Settings, ShiftMove
IfEqual, ShiftMove, ERROR, IniWrite, No, %SettingsPath%\SmartGUI.ini, Settings, ShiftMove

;___________________________________________



Hotkey, *~LButton, LeftButton
Hotkey, RButton, RightButton




ToolBarGenerate:

Gui, 9:+Resize
;Gui, 9:Color, ECEADC
Menu, ToolBarMenu, Add, &File, :FileMenu
Menu, ToolBarMenu, Add, &Options, :Options
Menu, ToolBarMenu, Add, &Help, :HelpMenu
Gui, 9:Menu, ToolBarMenu
Gui, 9:Add, Text, -99 -99 1 1 +Border Hidden vButtonBorder,
Gui, 9:Add, Picture, x6 y7 w32 h32 gPreCreateCtrl vTBButton Icon1, smartgui.icl
Gui, 9:Add, Picture, x46 y7 w32 h32 gPreCreateCtrl vTBCheckBox Icon2, smartgui.icl
Gui, 9:Add, Picture, x286 y7 w32 h32 gPreCreateCtrl vTBDropDownList Icon5, smartgui.icl
Gui, 9:Add, Picture, x166 y7 w32 h32 gPreCreateCtrl vTBText Icon17, smartgui.icl
Gui, 9:Add, Picture, x366 y7 w32 h32 gPreCreateCtrl vTBListBox Icon9, smartgui.icl
Gui, 9:Add, Picture, x486 y7 w32 h32 gPreCreateCtrl vTBMonthCal Icon11, smartgui.icl
Gui, 9:Add, Picture, x526 y7 w32 h32 gPreCreateCtrl vTBProgress Icon13, smartgui.icl
Gui, 9:Add, Picture, x206 y7 w32 h32 gPreCreateCtrl vTBGroupBox Icon7, smartgui.icl
Gui, 9:Add, Picture, x606 y7 w32 h32 gPreCreateCtrl vTBHotkey Icon8, smartgui.icl
Gui, 9:Add, Picture, x126 y7 w32 h32 gPreCreateCtrl vTBEdit Icon6, smartgui.icl
Gui, 9:Add, Picture, x86 y7 w32 h32 gPreCreateCtrl vTBRadio Icon14, smartgui.icl
Gui, 9:Add, Picture, x326 y7 w32 h32 gPreCreateCtrl vTBComboBox Icon3, smartgui.icl
Gui, 9:Add, Picture, x246 y7 w32 h32 gPreCreateCtrl vTBPicture Icon12, smartgui.icl
Gui, 9:Add, Picture, x406 y7 w32 h32 gPreCreateCtrl vTBListView Icon10, smartgui.icl
Gui, 9:Add, Picture, x446 y7 w32 h32 gPreCreateCtrl vTBDateTime Icon4, smartgui.icl
Gui, 9:Add, Picture, x566 y7 w32 h32 gPreCreateCtrl vTBSlider Icon15, smartgui.icl
Gui, 9:Add, Picture, x646 y7 w32 h32 gPreCreateCtrl vTBTab Icon16, smartgui.icl
Gui, 9:Add, Picture, x686 y7 w32 h32 gPreCreateCtrl vTBUpDown Icon18, smartgui.icl
Gui, 9:Add, Picture, x726 y7 w32 h32 gChangeFont vTBFont Icon19, smartgui.icl

;darker background for non-toolbar area
Gui, 9:Add, text, x1 y45 w3200 h2400 +0x4

;Gui, 9:Add, Text, x1 y1 h40 w%A_ScreenWidth%
WinHeight := A_ScreenHeight - DPIScale(150)
WinWidth := A_ScreenWidth - DPIScale(100)

Gui, 9:Show, h%WinHeight% w%WinWidth%, %MenuWnd%
Gui, 9:Maximize



WinGet, MenuWndID, ID, %MenuWnd%

WinGetPos, MenuWX, MenuWY, MenuWW, MenuWH, %MenuWnd%
MainWX := MenuWX + DPIScale(135)
MainWY := MenuWY + DPIScale(95)

Gui, 1:+Resize +Owner9
Gui, 1:Show, w%GuiW% h%GuiH% x%MainWX% y%MainWY%, %MainWnd%


WinGet, MainWndID, ID, %MainWnd%

;WinDiffW contains 1 border
;WinDiffH contains titlebar + bottom border
WinGetPos,,, WinW, WinH, ahk_id %MainWndID%
WinDiffW = %WinW%
WinDiffW -= DPIScale(GuiW)
WinDiffW /= 2
WinDiffH = %WinH%
WinDiffH -= DPIScale(GuiH)


;adjusting grid to adapt to different visual themes
GridY = %WinDiffH%
GridY -= %WinDiffW%

Gui, 1:add, Picture, x-%WinDiffW% y-%GridY% w2048 h1536, %GridFile%
IfEqual, G, 0
{
	Control, hide,, Static1, ahk_id %MainWndID%
	Menu, Options, ToggleCheck, Show Grid
}

StaticCount = 1


IfEqual, ShiftMove, Yes, Menu, Options, Check, Shift + Move Group

HelperStatus = 1
SetTimer, GuiHelper, 500


Sleep, 500
SplashImage, Off


;dropped file on SmartGUI icon
IfExist, %1%
{
	GUIScript = %1%
	Goto, EditGUI
}

WinActivate, ahk_id %MenuWndID%
Return



;helps in debugging
^+D::
	Run, %Temp%\SGUIControls.ini,,UseErrorLevel
Return


Grid:
	IfEqual, G, 1
	{
		Menu, Options, ToggleCheck, Show Grid
		Control, hide,, Static1, ahk_id %MainWndID%
		G = 0
	}
	Else
	{
		Menu, Options, ToggleCheck, Show Grid
		Control, show,, Static1, ahk_id %MainWndID%
		G = 1
	}	   
Return



;Ask Control Label
CtrlText:
	IfEqual, L, 1
	{
		Menu, Options, ToggleCheck, Ask Control Label
		L = 0
	}
	Else
	{
		Menu, Options, ToggleCheck, Ask Control Label
		L = 1
	}	   
Return
	


MicroEditing:
	IfEqual, M, 1
	{
		Menu, Options, ToggleCheck, MicroEditing
		M = 0
	}
	Else
	{
		Menu, Options, ToggleCheck, MicroEditing
		M = 1
	}
Return



AskGUICount:
	IfEqual, AG, 1
	{
		Menu, Options, ToggleCheck, Ask GUI Count
		AG = 0
	}
	Else
	{
		Menu, Options, ToggleCheck, Ask GUI Count
		AG = 1
	}	   
Return



;Gui Helper
Helper:
	;status
	; 0 = not shown
	; 1 = created
	; 2 = showing
	IfEqual, HelperStatus, 0
		HelperStatus = 1
	
	Else
		HelperStatus = 0
Return



;little help   
~F1::
	IfWinNotActive, ahk_id %MainWndID%,, Return

ShowHelp:
	Gui, 9:+OwnDialogs
	
	MsgBox,, Command Help,
	(LTrim
		This Help`t`t`t`tHelp Menu / Press F1
		Create Control`t`t`tUse Toolbar Buttons
		Control Commands`t`t`tRight Mouse Click on target control
		Undo Last Removed Control`t`tPress Ctrl-Z
		Move Group of Controls`t`tDrag Left Mouse Button (Down-Right)
		Preview GUI`t`t`tFile Menu / Press F9
	)
Return


OpenManual:
	IfExist, %A_ScriptDir%\SmartGUI.html, run, %A_ScriptDir%\SmartGUI.html
	IfNotExist, %A_ScriptDir%\SmartGUI.html, MsgBox,, Error, SmartGUI.html not found!
Return



ShiftMove:
	IfEqual, ShiftMove, Yes
	{
		Menu, Options, ToggleCheck, Shift + Move Group
		ShiftMove = No
		IniWrite, %ShiftMove%, %SettingsPath%\SmartGUI.ini, Settings, ShiftMove
	}
	
	Else
	{
		Menu, Options, ToggleCheck, Shift + Move Group
		ShiftMove = Yes
		IniWrite, %ShiftMove%, %SettingsPath%\SmartGUI.ini, Settings, ShiftMove
	}	   
Return



Reload:
	IfNotExist, %Temp%\SGUIControls.ini, Reload
	Else
	{
		Msgbox, 4, RELOAD?, All unsaved data will be lost. Proceed?
		IfMsgBox, Yes, Reload
	}
Return




AddControl:
	StringTrimLeft, Ctrl2Add, A_ThisMenuItem, 4
	CtrlLabel =
	Goto, CreateCtrl
Return  



AddControl2:
	Ctrl2Add = %A_GuiControl%
	CtrlLabel =
	Goto, CreateCtrl
Return  



ChangeFont:
	MouseGetPos,,,, GuiCtrl
	ControlGetPos, cX, cY, cW, cH, %GuiCtrl%, %MenuWnd%
	cX2 := cX - 1
	cY2 := cY - 1
	cW2 := cW + 2
	cH2 := cH + 2
	ControlMove, Static1, %cX2%, %CY2%, %cW2%, %cH2%, %MenuWnd%
	GuiControl, 9:Show, ButtonBorder
	KeyWait, LButton
	GuiControl, 9:Hide, ButtonBorder

	IfNotEqual, FirstTimeF, No
	{
		Gui, 4:+owner1 +ToolWindow
		Gui, 4:Add, Text, x7 y21 w110 h20, Enter valid font name
		Gui, 4:Add, Text, x7 y51 w110 h20, Font size
		Gui, 4:Add, Text, x7 y81 w110 h20, Font Color
		Gui, 4:Add, Edit, x127 y21 w110 h20 vFName, Verdana
		Gui, 4:Add, Edit, x127 y51 w110 h20 vFSize, 8
		Gui, 4:Add, Edit, x127 y81 w110 h20 vFColor, Default
		Gui, 4:Add, Checkbox, x17 y113 w110 h20 vFBold, Bold
		Gui, 4:Add, Checkbox, x137 y113 w110 h20 vFItalic, Italic
		Gui, 4:Add, Checkbox, x17 y143 w110 h20 vFUnderline, Underline
		Gui, 4:Add, Checkbox, x137 y143 w110 h20 vFStrike, Strikeout
		Gui, 4:Add, Button, 0x8000 x26 y182 w60 h20, OK
		Gui, 4:Add, Button, 0x8000 x96 y182 w60 h20, Default
		Gui, 4:Add, Button, 0x8000 x166 y182 w60 h20, Cancel
		FirstTimeF = No
	}
	
	WinGetPos, MenuWX, MenuWY, MenuWW, MenuWH, %MenuWnd%
	FontWX := MenuWX + 630
	FontWY := MenuWY + 95

	
	Gui, 4:Show, h220 w245 x%FontWX% y%FontWY%, Enter Font Settings
Return



4ButtonCancel:
	GUI, 4:Cancel
Return



4ButtonDefault:
	ControlSetText, Edit1,, Enter Font Settings, Enter valid
	ControlSetText, Edit2,, Enter Font Settings, Enter valid
	ControlSetText, Edit3,, Enter Font Settings, Enter valid
	
	Control, Uncheck,, Button1, Enter Font Settings, Enter valid
	Control, Uncheck,, Button2, Enter Font Settings, Enter valid
	Control, Uncheck,, Button3, Enter Font Settings, Enter valid
	Control, Uncheck,, Button4, Enter Font Settings, Enter valid
Return



4ButtonOK:
	FSet =
	GUI, 4:Submit

	IfNotEqual, FSize,, SetEnv, FSet, %FSet% S%FSize%
	IfNotEqual, FColor,, SetEnv, FSet, %FSet% C%FColor%
	
	IfEqual, FBold, 1, SetEnv, FSet, %FSet% Bold
	IfEqual, FItalic, 1, SetEnv, FSet, %FSet% Italic
	IfEqual, FUnderline, 1, SetEnv, FSet, %FSet% Underline
	IfEqual, FStrike, 1, SetEnv, FSet, %FSet% Strike

	Gui, 1:Font, %FSet%, %FName%
	
	FontCount ++

	IniRead, ItemList, %Temp%\SGUIControls.ini, Main, ItemList, |
	IniWrite, %ItemList%Font%FontCount%|, %Temp%\SGUIControls.ini, Main, ItemList
	IniWrite, %FName%, %Temp%\SGUIControls.ini, Font%FontCount%, Label
	IniWrite, %FSet%, %Temp%\SGUIControls.ini, Font%FontCount%, Options
Return



SetPos:
	ControlGetPos, CtrlX, CtrlY, CtrlW, CtrlH, %CtrlNameCount%, ahk_id %MainWndID%
	IfNotEqual, FirstTimeSP, No
	{
		Gui, 6:+owner1 +ToolWindow
		Gui, 6:Add, Text, x6 y17 w20 h20, X :
		Gui, 6:Add, Edit, x26 y12 w40 h20 vCtrlSetX, 
		Gui, 6:Add, UpDown, Range-2147483648-2147483647
		Gui, 6:Add, Text, x81 y17 w20 h20, Y :
		Gui, 6:Add, Edit, x101 y12 w40 h20 vCtrlSetY, 
		Gui, 6:Add, UpDown, Range-2147483648-2147483647
		Gui, 6:Add, Text, x6 y47 w20 h20, W :
		Gui, 6:Add, Edit, x26 y42 w40 h20 vCtrlSetW, 
		Gui, 6:Add, UpDown, Range-2147483648-2147483647
		Gui, 6:Add, Text, x81 y47 w20 h20, H :
		Gui, 6:Add, Edit, x101 y42 w40 h20 vCtrlSetH, 
		Gui, 6:Add, UpDown, Range-2147483648-2147483647
		Gui, 6:Add, Button, x21 y77 w50 h20 Default, OK
		Gui, 6:Add, Button, x81 y77 w50 h20, Cancel
		Gui, 6:Add, GroupBox, x2 y-1 w144 h74,  
		FirstTimeSP = No
	}
	
	Gui, 6:Show, h102 w148, Set Position
	
	GuiControl, 6:, CtrlSetX, %CtrlX%
	GuiControl, 6:, CtrlSetY, %CtrlY%
	GuiControl, 6:, CtrlSetW, %CtrlW%
	GuiControl, 6:, CtrlSetH, %CtrlH%
Return



6ButtonCancel:
	Gui, 6:Cancel
Return



6ButtonOk:
	Gui, 6:Submit
	ControlMove, %CtrlNameCount%, %CtrlSetX%, %CtrlSetY%, %CtrlSetW%, %CtrlSetH%, ahk_id %MainWndID%

	Control, Hide,, %CtrlNameCount%, ahk_id %MainWndID%
	Control, Show,, %CtrlNameCount%, ahk_id %MainWndID%
	
	;fix for title bar & border 
	CtrlSetX -= %WinDiffW%
	CtrlSetY -= %WinDiffH%
	CtrlSetY += %WinDiffW%
	

	;here we get Ctrl2Add (ahk name)
	IniRead, Ctrl2Add, %Temp%\SGUIControls.ini, %CtrlNameCount%, Name

	;Here we get correct Ctrl text after modification
	IniRead, CtrlText, %Temp%\SGUIControls.ini, %CtrlNameCount%, Label

	Loop, Parse, PosFields
	{
		CurrPos := DPIUnscale(CtrlSet%A_LoopField%)
		IniWrite, %CurrPos%, %Temp%\SGUIControls.ini, %CtrlNameCount%, %A_LoopField%
	}
Return



ChangeLabel:
	IniRead, OLabel, %Temp%\SGUIControls.ini, %CtrlNameCount%, Label
	
	StringReplace, OLabel, OLabel, ```,, `,, A
	StringReplace, OLabel, OLabel, ````, ``, A
	StringReplace, OLabel, OLabel, ```%, `%, A
	InputBox, CtrlText, Label, Enter Control Label,, 250, 125,,,,,%OLabel%  
	IfEqual, ErrorLevel, 1, Return
	
	StringReplace, TmpCtrlText, CtrlText, ``n, `n, A

	;replacing earlier contents of ctrl label
	If CtrlNameCount Contains SysTabControl,ListBox,ComBoBox
		GuiControl, 1:, %CtrlNameCount%, |%TmpCtrlText%
	Else
		GuiControl, 1:, %CtrlNameCount%, %TmpCtrlText%

	Gosub, FixText
	
	;leading pipe removed from controltext
	;this pipe is added to control labels to clear previous contents
	;eg. for listbox and tabs
	StringLeft, Test, CtrlText, 1
	IfEqual, Test, |, StringTrimLeft, CtrlText, CtrlText, 1 
	
	IniWrite, %CtrlText%, %Temp%\SGUIControls.ini, %CtrlNameCount%, Label
Return




Modify:
	ControlGetPos, cX, cY,,, %CtrlNameCount%, ahk_id %MainWndID%
	IniRead, Ctrl2Add, %Temp%\SGUIControls.ini, %CtrlNameCount%, Name
	IniRead, CtrlText, %Temp%\SGUIControls.ini, %CtrlNameCount%, Label

	If Ctrl2Add Not In Button,Checkbox,ComboBox,DateTime,DropDownList,Edit,GroupBox,ListBox,ListView,MonthCal,Progress,Picture,Radio,Slider,Tab,Text,UpDown,Hotkey
		Return
	
	;get CtrlName & CtrlCount
	Loop
	{
		StringRight, check, CtrlNameCount, %a_index%
		if check is integer
		{
			CtrlCount = %check%
			StringTrimRight, CtrlName, CtrlNameCount, %a_index%
		}
		Else Break
	}

	;here we get Ctrl2Add (ahk name)
	IniRead, Ctrl2Add, %Temp%\SGUIControls.ini, %CtrlNameCount%, Name
	
	;Here we get correct Ctrl text after modification
	IniRead, CtrlText, %Temp%\SGUIControls.ini, %CtrlNameCount%, Label

	Goto, Alter
return



Duplicate:
	ControlGetPos, cX, cY, cW, cH, %CtrlNameCount%, ahk_id %MainWndID%
	
	;get separate CtrlName and CtrlCount from CtrlNameCount
	Loop
	{
		StringRight, check, CtrlNameCount, %a_index%
		if check is integer
		{
			CtrlCount = %check%
			StringTrimRight, CtrlName, CtrlNameCount, %a_index%
		}
		Else Break
	}

	;No Tab duplication
	IfEqual, CtrlName, SysTabControl, Return
		
	;read from ini the Ctrl data
	IniRead, Ctrl2Add, %Temp%\SGUIControls.ini, %CtrlNameCount%, Name
	IniRead, CtrlLabel, %Temp%\SGUIControls.ini, %CtrlNameCount%, Label

	JustCopy = Y
	Goto, CreateCtrl
Return



Delete:
	;get and store undo information and then hide control
	IniRead, ItemList, %Temp%\SGUIControls.ini, Main, ItemList
	StringReplace, ItemList, ItemList, |%CtrlNameCount%|, |^DELETED^%CtrlNameCount%|, A
	IniWrite, %ItemList%, %Temp%\SGUIControls.ini, Main, ItemList

	Control, hide,, %CtrlNameCount%, ahk_id %MainWndID%
	LastDel = %CtrlNameCount%|%lastDel%
Return


~^Z::
	IfWinNotActive, ahk_id %MainWndID%,,Return
	
	;Showing the last hidden control
	StringGetPos, PPos, LastDel, |, R
	StringLeft, CtrlNameCount, LastDel, %PPos%
	PPos ++
	StringTrimLeft, LastDel, LastDel, %PPos%
	Control, Show,, %CtrlNameCount%, ahk_id %MainWndID%
	
	IniRead, ItemList, %Temp%\SGUIControls.ini, Main, ItemList
	StringReplace, ItemList, ItemList, |^DELETED^%CtrlNameCount%|, |%CtrlNameCount%|, A
	IniWrite, %ItemList%, %Temp%\SGUIControls.ini, Main, ItemList
Return



CenterH:
	ControlGetPos,,, cW,, %CtrlNameCount%, ahk_id %MainWndID%
	WinGetPos,,, wW,, ahk_id %MainWndID%
	
	wW -= %cW%
	wW /= 2
	
	ControlMove, %CtrlNameCount%, %wW%,,,, ahk_id %MainWndID%
	ControlGetPos, cX, cY, cW, cH, %CtrlNameCount%, ahk_id %MainWndID%
	
	;get CtrlText
	IniRead, CtrlText, %Temp%\SGUIControls.ini, %CtrlNameCount%, Label
	
	;fix for title bar & border 
	cX -= %WinDiffW%
	cY -= %WinDiffH%
	cY += %WinDiffW%

	Loop, Parse, PosFields
	{
		CurrPos := DPIUnscale(c%A_LoopField%)
		IniWrite, %CurrPos%, %Temp%\SGUIControls.ini, %CtrlNameCount%, %A_LoopField%
	}
Return




CenterV:
	ControlGetPos,,,, cH, %CtrlNameCount%, ahk_id %MainWndID%
	WinGetPos,,,, wH, ahk_id %MainWndID%
	
	wH += %WinDiffH%
	wH -= %cH%
	wH /= 2
	wH -= %WinDiffW%
	
	ControlMove, %CtrlNameCount%,, %wH%,,, ahk_id %MainWndID%
	ControlGetPos, cX, cY, cW, cH, %CtrlNameCount%, ahk_id %MainWndID%
	
	;get CtrlText
	IniRead, CtrlText, %Temp%\SGUIControls.ini, %CtrlNameCount%, Label
	
	;fix for title bar & border 
	cX -= %WinDiffW%
	cY -= %WinDiffH%
	cY += %WinDiffW%

	Loop, Parse, PosFields
	{
		CurrPos := DPIUnscale(c%A_LoopField%)
		IniWrite, %CurrPos%, %Temp%\SGUIControls.ini, %CtrlNameCount%, %A_LoopField%
	}
Return



CustomOption:
	IfNotEqual, COptionGUIShown, 1
	{
		Gui, 7:+Border -Caption +Owner1
		Gui, 7:Add, ComboBox, x6 y7 w220 h190 vNewOption, %CustomOptions%
		Gui, 7:Add, Button, x-10 y-10 w5 h5 Default , OK
		COptionGUIShown = 1
	}
	Gui, 7:Show, h37 w236, Custom Control Option
	Send, !{Down}
Return


7GuiClose:
7GuiEscape:
	Gui, 7:Cancel
Return


7ButtonOK:
	Gui, 7:Submit
	
	StringLeft, Test, NewOption, 1
	IfNotEqual, Test, -
	IfNotEqual, Test, +
		NewOption = +%NewOption%
	
	IniRead, Options, %Temp%\SGUIControls.ini, %CtrlNameCount%, Options, %A_Space%
	GuiControl, 1:%NewOption%, %CtrlNameCount%
	Options = %Options% %NewOption%
	IniWrite, %Options%, %Temp%\SGUIControls.ini, %CtrlNameCount%, Options
Return


PreCreateCtrl:
	;so that one doesn't select another control to create before placing the previous one
	;this requires all sections to set 'Ctrl2Add =' otherwise the toolbar will get disabled
	IfNotEqual, Ctrl2Add,, Return

	MouseGetPos,,,, GuiCtrl
	ControlGetPos, cX, cY, cW, cH, %GuiCtrl%, %MenuWnd%
	cX2 := cX - DPIScale(1)
	cY2 := cY - DPIScale(1)
	cW2 := cW + DPIScale(2)
	cH2 := cH + DPIScale(2)
	ControlMove, Static1, %cX2%, %CY2%, %cW2%, %cH2%, %MenuWnd%
	GuiControl, 9:Show, ButtonBorder
	KeyWait, LButton
	GuiControl, 9:Hide, ButtonBorder
	
	StringTrimLeft, Ctrl2Add, A_GuiControl, 2
	Goto, CreateCtrl
Return



CreateCtrl:
	Gui, 9:+OwnDialogs
	;only one tab allowed
	IfEqual, Ctrl2Add, Tab
	IfEqual, TabCreated, 1
	{
		Ctrl2Add =
		Return
	}

	;default labels
	CtrlText = %Ctrl2Add%
	IfEqual, Ctrl2Add, Tab
		CtrlText = Tab1|Tab2
	IfEqual, Ctrl2Add, Tab
		CtrlText = Tab1|Tab2
	If Ctrl2Add In Progress,Slider
		CtrlText = 25
	If Ctrl2Add In Hotkey,MonthCal,DateTime
		CtrlText =

	;preset width & height if not copying control
	IfNotEqual, JustCopy, Y
	{
		;so that control label is always asked if option is on
		IfEqual, L, 1, InputBox, CtrlText, Label, Enter Control Label,, 250, 125,,,,,%CtrlText%
		IfEqual, ErrorLevel, 1, Return
		StringReplace, CtrlText, CtrlText, ``n, `n, A

		cW = 100
		cH = 30

		IfEqual, Ctrl2Add, MonthCal
		{
			cW = 190
			cH = 160
		}
	}
	
	WinActivate, ahk_id %MainWndID%
	
	;select picture
	IfEqual, Ctrl2Add, Picture
	{
		;For duplication, file selection isn't reqd
		IfNotEqual, JustCopy, Y
		{
			Hotkey, *~LButton, Off
			FileSelectFile, PicFile,, %A_ScriptDir%, Select Picture File, Picture Files (*.jpg; *.gif; *.bmp; *.png; *.tif; *.ico; *.ani; *.cur; *.wmf; *.emf)
			Hotkey, *~LButton, On
			
			CtrlText = %PicFile%
		}
		Else
			CtrlText = %CtrlLabel%

		IfNotExist, %PicFile%
		{
			Ctrl2Add =
			Return
		}
		
		MouseGetPos, mX, mY
		;fix for title bar & border 
		mX -= %WinDiffW%
		mY -= %WinDiffH%
		mY += %WinDiffW%

		;no width & height specified to get it at original size initially
		Gui, 1:Add, %Ctrl2Add%, x%mX% y%mY%, %PicFile%
	}

	IfEqual, Ctrl2Add, Tab
	{
		MouseGetPos, mX, mY
		;fix for title bar & border 
		mX -= %WinDiffW%
		mY -= %WinDiffH%
		mY += %WinDiffW%

		Gui, 1:Add, %Ctrl2Add%, x%mX% y%mY% w250 h100 vTabName gTabGroup, %CtrlText%
		
		TabCreated = 1
	}
	
	;other controls
	If Ctrl2Add In Button,Checkbox,ComboBox,DateTime,DropDownList,Edit,GroupBox,ListBox,ListView,MonthCal,Progress,Radio,Slider,Text,UpDown,Hotkey
	{
		;duplicate has same label
		IfEqual, JustCopy, Y, SetEnv, CtrlText, %CtrlLabel%
		
		MouseGetPos, mX, mY
		;fix for title bar & border 
		mX -= %WinDiffW%
		mY -= %WinDiffH%
		mY += %WinDiffW%

		;create border for controls on Tab
		IfNotEqual, TabCreated, 1
			Gui, 1:Add, %Ctrl2Add%, x%mX% y%mY% w%cW% h%cH%, %CtrlText%
		Else
			Gui, 1:Add, %Ctrl2Add%, x%mX% y%mY% w%cW% h%cH% Border, %CtrlText%
			
		;blanking for next duplication
		CtrlLabel =
	}
	
	Sleep, 100
	
	;Ctrl2Add contains AHK naming of controls
	;CtrlName contains real (win spy) names without the count suffix
	;CtrlCount contains real names with count
	
	CtrlName = %Ctrl2Add%
	IfEqual, Ctrl2Add, ListBox, SetEnv, CtrlName, ListBox
	IfEqual, Ctrl2Add, ListView, SetEnv, CtrlName, SysListView32
	IfEqual, Ctrl2Add, ComboBox, SetEnv, CtrlName, ComboBox
	IfEqual, Ctrl2Add, DateTime, SetEnv, CtrlName, SysDateTimePick32
	IfEqual, Ctrl2Add, DropDownList, SetEnv, CtrlName, ComboBox
	IfEqual, Ctrl2Add, CheckBox, SetEnv, CtrlName, Button
	IfEqual, Ctrl2Add, GroupBox, SetEnv, CtrlName, Button
	IfEqual, Ctrl2Add, Hotkey, SetEnv, CtrlName, msctls_hotkey32
	IfEqual, Ctrl2Add, MonthCal, SetEnv, CtrlName, SysMonthCal32
	IfEqual, Ctrl2Add, Picture, SetEnv, CtrlName, Static
	IfEqual, Ctrl2Add, Progress, SetEnv, CtrlName, msctls_progress32
	IfEqual, Ctrl2Add, Radio, SetEnv, CtrlName, Button
	IfEqual, Ctrl2Add, Slider, SetEnv, CtrlName, msctls_trackbar32
	IfEqual, Ctrl2Add, Tab, SetEnv, CtrlName, SysTabControl32
	IfEqual, Ctrl2Add, Text, SetEnv, CtrlName, Static
	IfEqual, Ctrl2Add, UpDown, SetEnv, CtrlName, msctls_UpDown32
	%CtrlName%Count ++
	
	;fix for combobox
	IfEqual, Ctrl2Add, ComboBox
		EditCount ++
	
	StringTrimLeft, CtrlCount, %CtrlName%Count, 0

	;Fix to prevent Listview from hiding behind the grid
	IfEqual, Ctrl2Add, ListView
	IfNotEqual, TabCreated, 1
		GuiControl, 1:-0x4000000, %CtrlName%%CtrlCount%
	
	;fix for grid
	;remove WS_CLIPSIBLINGS 
	IfEqual, Ctrl2Add, Tab
		GuiControl, 1:-0x4000000, %CtrlName%%CtrlCount%

	Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
	Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%

	Menu, FileMenu, Disable, GUI Stealer
	Menu, FileMenu, Disable, Edit GUI script

	Goto, Alter
Return




Alter:
	WinActivate, ahk_id %MainWndID%
	Hotkey, *~LButton, Off
	KeyWait, LButton
	Loop
	{
		GetKeyState, LB, LButton
		IfEqual, LB, U
		{
			MouseGetPos, mX, mY
			
			IfEqual, M, 0
			{
				; Crappy fix is crappy
				fact := DPIScale(10)
				mX := fact*(mX // fact)
				mY := fact*(mY // fact)
			}

			;if mouse position not changed then no need to do anything
			ControlGetPos, tempX, tempY,,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
			IfEqual, tempX, %mX%
				IfEqual, tempY, %mY%
					Continue

			;move control to upper left corner of mouse
			ControlMove, %CtrlName%%CtrlCount%, %mX%, %mY%,,, ahk_id %MainWndID%
			
			
			;update Gui Helper window
			ControlGetPos, ScX, ScY, ScW, ScH, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
			ScX := DPIUnscale(ScX)
			ScY := DPIUnscale(ScY)
			ScW := DPIUnscale(ScW)
			ScH := DPIUnscale(ScH)
			CtrlInfo = X:%ScX%`tY:%ScY%`t`nW:%ScW%`tH:%ScH%`t`n%CtrlName%%CtrlCount%
			ControlSetText, Static5, %CtrlInfo%, GUI Helper
			
			
			Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
			Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%

			Sleep, 50
		}
		IfEqual, LB, D, Break
	}
	

	Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
	Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
	
	ControlGetPos, cX, cY, cW, cH, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
	
	;move mouse to control's lower right corner
	cX += %cW%
	cY += %cH%
	IfNotEqual, JustCopy, Y
		MouseMove, %cX%, %cY%
	
	
	;wait for mouse button to press to get lower right corner
	KeyWait, LButton

	;do this only if not duplicating
	IfNotEqual, JustCopy, Y
	Loop
	{
		GetKeyState, LB, LButton
		IfEqual, LB, U
		{
			MouseGetPos, mX2, mY2

			IfEqual, M, 0
			{
				; Crappy fix is crappy
				fact := DPIScale(10)
				mX2 := fact*(mX2 // fact)
				mY2 := fact*(mY2 // fact)
			}

			cW = %mX2%
			cH = %mY2%
			cW -= %mX%
			cH -= %mY%

			;if mouse position not changed then no need to do anything
			ControlGetPos,,, tempW, tempH, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
			IfEqual, cW, %tempW%
				IfEqual, cH, %tempH%
					Continue

	
			;change controls width/height
			ControlMove, %CtrlName%%CtrlCount%,,, %cW%, %cH%, ahk_id %MainWndID%
			
			;update Gui Helper window
			ControlGetPos, ScX, ScY, ScW, ScH, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
			ScX := DPIUnscale(ScX)
			ScY := DPIUnscale(ScY)
			ScW := DPIUnscale(ScW)
			ScH := DPIUnscale(ScH)
			CtrlInfo = X:%ScX%`tY:%ScY%`t`nW:%ScW%`tH:%ScH%`t`n%CtrlName%%CtrlCount%
			ControlSetText, Static5, %CtrlInfo%, GUI Helper
			

			Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
			Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
				
			Sleep, 50
		}
		IfEqual, LB, D, Break
	}
	
	Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
	Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
	
	JustCopy = N
	
	;fix for title bar & border 
	mX -= %WinDiffW%
	mY -= %WinDiffH%
	mY += %WinDiffW%
	
	cX = %mX%
	cY = %mY%
	

	IniRead, ItemList, %Temp%\SGUIControls.ini, Main, ItemList, |

	;write these settings if creating a new control
	IfNotInString, ItemList, |%CtrlName%%CtrlCount%|
	{
		StringReplace, ItemList, ItemList, |%CtrlName%%CtrlCount%|, |, A
		IniWrite, %ItemList%%CtrlName%%CtrlCount%|, %Temp%\SGUIControls.ini, Main, ItemList
		IniWrite, %Ctrl2Add%, %Temp%\SGUIControls.ini, %CtrlName%%CtrlCount%, Name
		IniWrite, %CtrlText%, %Temp%\SGUIControls.ini, %CtrlName%%CtrlCount%, Label
	}

	Loop, Parse, PosFields
	{
		CurrPos := DPIUnscale(c%A_LoopField%)
		IniWrite, %CurrPos%, %Temp%\SGUIControls.ini, %CtrlName%%CtrlCount%, %A_LoopField%
	}

	Hotkey, *~LButton, On
	
	CtrlText =
	CtrlName =
	Ctrl2Add =
	CtrlLabel =
	CtrlNameCount =
Return



GuiClose:
9GuiClose:
	ExitAfterSave = 1
	Gosub, SaveGUI
Return



FinalExit:
	;FileDelete, %Temp%\Grid.gif
	;FileDelete, %Temp%\Splash.gif
	FileDelete, %Temp%\Generated.ahk
	FileDelete, %Temp%\SGUIControls.ini
	;FileDelete, %Temp%\smartgui.icl
	
	;Some stylish exit
	;DllCall( "AnimateWindow", "Int", MainWndID, "Int", 500, "Int", 0x00010010 )

	ExitApp
Return
	

SaveGUI:
	IfNotEqual, SaveGUIShown, 1
	{
		Gui, 8:+Owner1
		IfWinExist, ahk_class SciTEWindow
			__TEMPTEXT = Insert New GUI into SciTE
		else
			__TEMPTEXT = Save New GUI to Clipboard
		Gui, 8:Add, Radio, x16 y7 w180 h30 Checked vSaveGUI, %__TEMPTEXT%
		Gui, 8:Add, Radio, x16 y37 w180 h30 , Save New GUI to File
		Gui, 8:Add, Radio, x16 y67 w180 h30 , Save Modified GUI Info to File
		Gui, 8:Add, Button, x16 y107 w50 h20 Default, &Yes
		Gui, 8:Add, Button, x76 y107 w50 h20, &No
		Gui, 8:Add, Button, x136 y107 w50 h20, &Cancel

		SaveGUIShown = 1
	}
	
	Gui, 8:Show, h134 w212, Save Options
Return


SaveGUI2:
	IfExist, %SaveAsFile%
			Gosub, GenerateGUI
	Else
		Goto, SaveGUI
Return


8GuiClose:
8ButtonCancel:
	Gui, 8:Submit
Return


8GuiEscape:
8ButtonNo:
	Gui, 8:Submit
	IfEqual, ExitAfterSave, 1
		Goto, FinalExit
Return


8ButtonYes:
	Gui, 8:Submit
	Gui, 9:+OwnDialogs
	SaveAsFile =

	IfNotEqual, SaveGUI, 1
	{
		Hotkey, *~LButton, Off
		FileSelectFile, SaveAsFile, S16, %SaveDir%, Save generated GUI script as:, AutoHotkey Script (*.ahk)
		Hotkey, *~LButton, On
	}
	
	IfNotEqual, SaveAsFile,
	{
		StringGetPos, Spos, SaveAsFile, \, R
		StringLeft, SaveDir, SaveAsFile, %Spos%
		IniWrite, %SaveDir%, %SettingsPath%\SmartGUI.ini, Folders, SaveDir
		
		StringRight, Ext, SaveAsFile, 4
		IfNotEqual, Ext, .ahk, SetEnv, SaveAsFile, %SaveAsFile%.ahk
	}
	Gosub, GenerateGUI
	
	IfEqual, ExitAfterSave, 1
		Goto, FinalExit
Return


~F9::
	IfWinNotActive, ahk_id %MainWndID%,,Return
TestGUI:
	SaveGUI = 2
	SaveAsFile = %Temp%\Generated.ahk
	RunSaved = 1
	Gosub, GenerateGUI
Return



GenerateGUI:
	;SaveGui
	;1 = clipboard
	;2 = gui script
	;3 = complete script

	IfNotEqual, SaveGUI, 1
		FileDelete, %SaveAsFile%

	TabGenerated = 0
	
	IniRead, ItemList, %Temp%\SGUIControls.ini, Main, ItemList, |
	IfEqual, ItemList,, Return
	
	;recording that Tab is generated
	IfInString, ItemList, |SysTabControl
		TabGenerated = 1

	;Ask gui count
	IfEqual, AG, 1
	IfNotEqual, SaveAsFile, %Temp%\Generated.ahk
		InputBox, GUICount, GUI Count, Enter GUI Count (upto 99). Blank for none.,,,,,,,, 1
	
	IfNotEqual, GUICount,
		GUICountA = %GUICount%:

	FinalScript =

	IfEqual, SaveGUI, 3
		FinalScript = %BeforeScript%`n

	Loop, Parse, ItemList, |
	{
		IfEqual, A_LoopField,, Continue
		IfInString, A_LoopField, ^DELETED^, Continue
		
		Buffer = %A_LoopField%

		;Multiple tab selections removal
		IfInString, Buffer, TabChange
		{
			TabFound = 1
			LastBuffer = %Buffer%
			Continue
		}

		IfEqual, TabFound, 1
		{
			TabFound = 0
			IfEqual, TabGenerated, 1
				Buffer = %LastBuffer%`n%Buffer%
			LastBuffer =
		}


		Loop, Parse, Buffer, `n
		{
			CtrlNameCount = %A_LoopField%

			IniRead, Ctrl2Add, %Temp%\SGUIControls.ini, %CtrlNameCount%, Name
			IniRead, CtrlText, %Temp%\SGUIControls.ini, %CtrlNameCount%, Label
			;show % in labels as literal text
			StringReplace, CtrlText, CtrlText, ````, ``, A

			Loop, Parse, PosFields
				IniRead, c%A_LoopField%, %Temp%\SGUIControls.ini, %CtrlNameCount%, %A_LoopField%
			
			IniRead, Options, %Temp%\SGUIControls.ini, %A_LoopField%, Options, %A_Space%
			Options = %Options%
			
			
			IfInString, CtrlNameCount, TabChange
			{
				StringReplace, Count, CtrlNameCount, TabChange,, A
				FinalScript = %FinalScript%Gui`, %GUICountA%Tab`, %Count%`n
				Continue
			}

			IfInString, CtrlNameCount, Font
			{
				FinalScript = %FinalScript%Gui`, Font`, %Options%`, %CtrlText%`n
				Continue
			}
			
			FinalScript = %FinalScript%Gui`, %GUICountA%Add`, %Ctrl2Add%`, x%cX% y%cY% w%cW% h%cH% %Options%`, %CtrlText%`n
		}
	}
	
	;fixes for title bar & border   
	WinGetPos, wX, wY, wW, wH, ahk_id %MainWndID%
	
	tmpW = %WinDiffW%
	tmpW /= 2
	
	wH -= %WinDiffH%
	wH += %tmpW%
	wW -= %WinDiffW%
	wW -= %tmpW%
	
	wH := DPIUnscale(wH)
	wW := DPIUnscale(wW)

	IfEqual, SaveGUI, 3
	{
		IniRead, Title, %Temp%\SGUIControls.ini, Main, Title, %A_Space%

		FinalScript = %FinalScript%`; Generated using SmartGUI Creator %Rel%`n
		FinalScript = %FinalScript%Gui`, %GUICountA%Show`, w%wW% h%wH%`, %Title%`n
		FinalScript = %FinalScript%%AfterScript%`n
	}
	
	Else
	{
		FinalScript = %FinalScript%`; Generated using SmartGUI Creator for SciTE`n
		FinalScript = %FinalScript%Gui`, %GUICountA%Show`, w%wW% h%wH%`, %GeneratedWnd%`n
		FinalScript = %FinalScript%return`n`n
		FinalScript = %FinalScript%%GUICount%GuiClose`:`nExitApp
	}
	StringReplace, FinalScript, FinalScript, % "Add, Tab,", % "Add, Tab2,", All ; Use Tab2 controls
	StringReplace, FinalScript, FinalScript, `n, `r`n, All ; Use Windows line endings
	
	IfEqual, SaveGUI, 1
		scite.InsertText(FinalScript)
	
	IfNotEqual, SaveGUI, 1
		FileAppend, #NoTrayIcon`n`n%FinalScript%, %SaveAsFile%
	
	IfEqual, RunSaved, 1
	{
		RunSaved =
		Run, "%A_AhkPath%" %SaveAsFile%,, UseErrorLevel
	}
	Ctrl2Add =
	/*
	if(scitehwnd := WinExist("ahk_class SciTEWindow"))
	{
		if SaveGUI = 1
		{
			Gui 1:Destroy
			Gui 2:Destroy
			Gui 3:Destroy
			Gui 4:Destroy
			Gui 5:Destroy
			Gui 6:Destroy
			Gui 7:Destroy
			Gui 8:Destroy
			Gui 9:Destroy
		}
	}
*/
Return


About:
	IfNotEqual, FirstTimeA, No
	{
		Gui, 2:+owner1 -Caption +Border
		Gui, 2:Font, S10 CA03410,verdana
		Gui, 2:Add, Text, x260 y27 w170 h20 Center, Release %rel% for SciTE
		Gui, 2:Add, Button, 0x8000 x316 y237 w70 h21, Close
		;Gui, 2:Add, Button, 0x8000 x46 y237 w220 h21 gRelCheck Disabled,  Check Latest Release
		Gui, 2:Add, Button, 0x8000 x46 y237 w220 h21 gRelCheck Disabled, SciTE4AutoHotkey Version
		Gui, 2:Add, Picture, 0x1000 x17 y16 w230 h130, splash.gif
		Gui, 2:Font, Underline C3571AC,verdana
		Gui, 2:Add, Text, x260 y57 w170 h20 gSguiHome Center, SmartGUI homepage
		Gui, 2:Add, Text, x260 y87 w170 h20 gAhkHome Center, AutoHotkey homepage
		Gui, 2:Add, Text, x260 y117 w170 h20 gSciteHome Center, SciTE4AutoHotkey v3
		Gui, 2:Font, Underline C154D85 S7,verdana
		Gui, 2:Add, Text, 0x8000 x326 y147 w100 h20 gEMail, SmartGUI © Rajat
		Gui, 2:Font, S7 CDefault normal, Verdana
		;Gui, 2:Add, Text, x16 y165 w410 h60, SmartGUI Creator is freeware, if you use it regularly and would like the project to be kept active`, please visit the homepage and post your comments, suggestions and bug reports.`nA few words of encouragement are always welcome.
		Gui, 2:Add, Text, x16 y165 w410 h60,
		(LTrim
		(Modified version adapted for SciTE4AutoHotkey v3 by fincs)
		SmartGUI Creator is freeware, if you use it regularly and would like the project to
		be kept active, please visit the homepage and post your comments, suggestions and bug reports.
		A few words of encouragement are always welcome.
		)
		
		FirstTimeA = No
	}
	
	Gui, 2:Show, h280 w435, About..
	
	;nice release counter
	tmpH = 0
	Loop, 20
	{
		tmpH += 1
		ControlMove, Static1,,,, %tmpH%, About..
		Sleep, 100
	}
Return



AhkHome:
	Run, http://www.autohotkey.com/
Return



SGUIHome:
	Run, http://www.autohotkey.com/docs/SmartGUI/
Return



SciteHome:
	Run, http://fincs.ahk4.net/scite4ahk/
Return


EMail:
	Run, mailto:mr.rajat@gmail.com?subject=Comments on SmartGUI Creator,, UseErrorLevel
	IfNotEqual, ErrorLevel, 0
		MsgBox,, eMail me at :, meet_rajat@gawab.com
Return


RelCheck:
Return ; thwart clicking
	GuiControl, 2:, Button2, Please Wait..
	FileDelete, %Temp%\RelCheck.htmll
	RelInfo =
	
	UrlDownloadToFile, http://www.autohotkey.com/forum/viewtopic.php?t=775, %Temp%\RelCheck.htmll

	Loop, Read, %Temp%\RelCheck.htmll
	{
		IfNotInString, A_LoopReadLine, Latest : Release, Continue

		StringGetPos, Pos1, A_LoopReadLine, >
		StringGetPos, Pos2, A_LoopReadLine, <, R
		Pos1++

		Stringleft, RelInfo, A_LoopReadLine, %Pos2%
		StringTrimLeft, RelInfo, RelInfo, %Pos1%

		Break	
	}

	IfNotInString, RelInfo, Latest
		RelInfo = Error Reading Web Resource
	
	GuiControl, 2:, Button2, %RelInfo%
	
	FileDelete, %Temp%\RelCheck.htmll
Return



2ButtonClose:
2GuiClose:
	WinGet, AbtWndID, ID, About..
	DllCall( "AnimateWindow", "Int", AbtWndID, "Int", 500, "Int", 0x00090010 )
	WinActivate, ahk_id %MainWndID%
Return


;___________________________________________


;dropped a script to edit
GuiDropFiles:
	
	;edit only one script per session
	IfNotEqual, InputScript,, Return
		
	IfInString, A_GuiControlEvent, `n
		StringGetPos, CRPos, A_GuiControlEvent, `n
	
	IfNotEqual, CRPos,
		StringLeft, InputScript, A_GuiControlEvent, %CRPos%
	
	Else
		InputScript = %A_GuiControlEvent%
	
	CRPos =
	
	StringRight, AhkChk, InputScript, 4
	
	IfNotEqual, AhkChk, .ahk
	{
		InputScript =
		Return
	}


EditGUI:
	Gui, 9:+OwnDialogs
	IfExist, %1%
		InputScript = %1%
	
	Hotkey, *~LButton, Off
	IfNotExist, %InputScript%, FileSelectFile, InputScript, 1, %LoadDir%, Select GUI script to edit, AutoHotkey GUI script (*.ahk)
	Hotkey, *~LButton, On
	
	IfNotExist, %InputScript%
	{
		InputScript =
		Return
	}
	
	SaveAsFile = %InputScript%

	Menu, FileMenu, Disable, Edit GUI script
	Menu, FileMenu, Disable, GUI Stealer
	
	StringGetPos, Spos, InputScript, \, R
	StringLeft, LoadDir, InputScript, %Spos%
	IniWrite, %LoadDir%, %SettingsPath%\SmartGUI.ini, Folders, LoadDir
	
	
	Gui_Status = 0
	; 0 gui not started
	; 1 gui add going on
	; 2 gui show
	; 3 gui show passed

	Loop, Read, %InputScript%
	{
		CurrLine = %A_LoopReadLine%

		;Get script cmd till 2nd comma
		StringGetPos, cpos, CurrLine, `,, L2
		StringLeft, GuiCheck, CurrLine, %cpos%

		;Check for commented line
		Check = %GuiCheck%
		Check = %Check%
		StringLeft, CmtCheck, Check, 1
		
		IfNotEqual, CmtCheck, `;
		IfInString, GuiCheck, Gui`,
		IfNotEqual, Gui_Status, 2
		IfNotEqual, Gui_Status, 3
		{
			;gui script started
			IfNotEqual, Gui_Status, 2
				Gui_Status = 1
			
			IfInString, GuiCheck, Show
				Gui_Status = 2
		}
		
		IfEqual, Gui_Status, 0
			BeforeScript = %BeforeScript%`n%A_LoopReadLine%

		IfEqual, Gui_Status, 1
			GuiScript = %GuiScript%`n%A_LoopReadLine%

		IfEqual, Gui_Status, 2
		{
			GuiScript = %GuiScript%`n%A_LoopReadLine%
			Gui_Status = 3
			Continue
		}

		IfEqual, Gui_Status, 3
			AfterScript = %AfterScript%`n%A_LoopReadLine%
	}

	StringTrimLeft, BeforeScript, BeforeScript, 1
	StringTrimLeft, AfterScript, AfterScript, 1
	
	Loop, Parse, GuiScript, `n
	{
		IfEqual, A_LoopField,, Continue

		CurrLine = %A_LoopField%
		;Check for commented line
		CmtCheck =
		ToStrip = %CurrLine%
		ToStrip = %ToStrip%
		
		StringLeft, CmtCheck, ToStrip, 1
		IfEqual, CmtCheck, `;, Continue

		;Get script cmd till 2nd comma
		StringGetPos, cpos, CurrLine, `,, L2
		StringLeft, check, CurrLine, %cpos%
		
		
		;to take care of out of tab controls
		;spl treatment because this cmd doesn't have 2 commas
		IfEqual, Check,
			IfInString, CurrLine, Gui
				IfInString, CurrLine, Tab
				{
					Gui, 1:Tab
					TabCount ++
					Gui, 1:Tab, %TabCount%
				}



		;For Gui, Tab_______________________________
		IfInString, check, GUI
			IfInString, check, Tab
			{
				IfNotEqual, TabCreated, 1, Continue
				
				StringGetPos, fpos, check, Tab
				fpos += 3
				StringTrimLeft, data, CurrLine, %fpos%
				
				Param2 =
				
				StringSplit, param, data, `,
				IfInString, param2, `:, Continue

				StringReplace, check, param2, %a_space%,, All
				IfEqual, check,, SetEnv, param2,

				;literal spaces around Tab name can create problems
				param2 = %param2%
				
				Gui, 1:Tab, %param2%
				TabCount ++
				Gui, 1:Submit, NoHide
				IniRead, ItemList, %Temp%\SGUIControls.ini, Main, ItemList, |
				IniWrite, %ItemList%TabChange%param2%|, %Temp%\SGUIControls.ini, Main, ItemList
			}



			
		;For Gui, Font______________________________
		IfInString, check, GUI
			IfInString, check, Font
			{
				StringGetPos, fpos, check, Font
				fpos += 4
				StringTrimLeft, data, CurrLine, %fpos%
				
				Param2 =
				Param3 =
				
				StringSplit, param, data, `,
				IfInString, param2, `:, Continue

				StringReplace, check, param2, %a_space%,, All
				IfEqual, check,, SetEnv, param2,

				StringReplace, check, param3, %a_space%,, All
				IfEqual, check,, SetEnv, param3,
				
				;literal spaces around font name create problems
				param3 = %param3%
				
				GUI, 1:Font, %param2%, %param3%
				FontCount ++

				IniRead, ItemList, %Temp%\SGUIControls.ini, Main, ItemList, |
				IniWrite, %ItemList%Font%FontCount%|, %Temp%\SGUIControls.ini, Main, ItemList
				IniWrite, %param3%, %Temp%\SGUIControls.ini, Font%FontCount%, Label
				IniWrite, %param2%, %Temp%\SGUIControls.ini, Font%FontCount%, Options
			}



		;For Gui, Add_______________________________
		IfInString, check, GUI
			IfInString, check, Add
			{
				StringGetPos, apos, check, Add
				apos += 3
				StringTrimLeft, data, CurrLine, %apos%

				
				;check to see if the cmd has atleast 2 params and make the rest blank
				StringSplit, param, data, `,
				IfLess, param0, 4, SetEnv, param4,
				IfLess, param0, 3, SetEnv, param3,
				IfLess, param0, 2, Continue
				IfInString, param2, `:, Continue
				
				;to take care of commas in control labels
				IfGreater, param0, 4
				Loop, %param0%
				{
					IfLess, A_Index, 5, Continue
					StringTrimRight, currparam, param%A_Index%, 0
					param4 = %param4%`,%currparam%
				}
				
				;formatting control labels
				StringReplace, CtrlText, param4, ```,, `,, A
				StringReplace, CtrlText, CtrlText, ``n, `n, A
				StringReplace, CtrlText, CtrlText, ```%, `%, A
				
				
				;getting CtrlName & CtrlCount
				Ctrl2Add = %param2%
				CtrlName = %param2%
				IfEqual, Ctrl2Add, ListBox, SetEnv, CtrlName, ListBox
				IfEqual, Ctrl2Add, ListView, SetEnv, CtrlName, SysListView32
				IfEqual, Ctrl2Add, ComboBox, SetEnv, CtrlName, ComboBox
				IfEqual, Ctrl2Add, DateTime, SetEnv, CtrlName, SysDateTimePick32
				IfEqual, Ctrl2Add, DropDownList, SetEnv, CtrlName, ComboBox
				IfEqual, Ctrl2Add, CheckBox, SetEnv, CtrlName, Button
				IfEqual, Ctrl2Add, GroupBox, SetEnv, CtrlName, Button
				IfEqual, Ctrl2Add, Hotkey, SetEnv, CtrlName, msctls_hotkey32
				IfEqual, Ctrl2Add, MonthCal, SetEnv, CtrlName, SysMonthCal32
				IfEqual, Ctrl2Add, Picture, SetEnv, CtrlName, Static
				IfEqual, Ctrl2Add, Progress, SetEnv, CtrlName, msctls_progress32
				IfEqual, Ctrl2Add, Radio, SetEnv, CtrlName, Button
				IfEqual, Ctrl2Add, Slider, SetEnv, CtrlName, msctls_trackbar32
				IfEqual, Ctrl2Add, Tab, SetEnv, CtrlName, SysTabControl32
				IfEqual, Ctrl2Add, Text, SetEnv, CtrlName, Static
				IfEqual, Ctrl2Add, UpDown, SetEnv, CtrlName, msctls_UpDown32
				%CtrlName%Count ++
				StringTrimLeft, CtrlCount, %CtrlName%Count, 0
				
				;analysing various options
				Options =
				OptionsA =
				Loop, Parse, param3, %A_Space%
				{
					IfEqual, A_LoopField,, Continue
					StringLeft, Opt1, A_LoopField, 1
					StringTrimLeft, Opt2, A_LoopField, 1
					
					;position
					Done = 0
					Loop, Parse, PosFields
					{
						IfEqual, Opt1, %A_LoopField%
						{
							c%A_LoopField% := Opt2
							IniWrite, %Opt2%, %Temp%\SGUIControls.ini, %CtrlName%%CtrlCount%, %A_LoopField%
							Done = 1
						}
					}
					IfEqual, Done, 1, Continue

					;all options are saved and processed
					;Group and Var options are just saved
					Options = %Options% %Opt1%%Opt2%
					
					If Opt1 Not In G,V
						OptionsA = %OptionsA% %Opt1%%Opt2%
				}
				
				param2 = %param2%
				param3 = %param3% 
				param4 = %param4% 
				CtrlText = %CtrlText% 
				Options = %Options%

				;remember that tab is created
				;and disable further tab support
				IfEqual, param2, Tab
				{
					IfEqual, TabCreated, 1, Continue
					
					GUI, 1:Add, %param2%, x%cX% y%cY% w%cW% h%cH% vTabName gTabGroup %OptionsA%, %CtrlText%
					TabCreated = 1
				}
				Else
				{
					;create border for controls on Tab
					IfNotEqual, TabCreated, 1
						GUI, 1:Add, %param2%, x%cX% y%cY% w%cW% h%cH% %OptionsA%, %CtrlText%
					Else
						GUI, 1:Add, %param2%, x%cX% y%cY% w%cW% h%cH% Border %OptionsA%, %CtrlText%
				}

				IniRead, ItemList, %Temp%\SGUIControls.ini, Main, ItemList, |
				IniWrite, %ItemList%%CtrlName%%CtrlCount%|, %Temp%\SGUIControls.ini, Main, ItemList
				IniWrite, %param2%, %Temp%\SGUIControls.ini, %CtrlName%%CtrlCount%, Name
				IniWrite, %param4%, %Temp%\SGUIControls.ini, %CtrlName%%CtrlCount%, Label
				IniWrite, %Options%, %Temp%\SGUIControls.ini, %CtrlName%%CtrlCount%, Options
			
				Loop, Parse, PosFields
				{
					CurrPos := DPIUnscale(c%A_LoopField%)
					IniWrite, %CurrPos%, %Temp%\SGUIControls.ini, %CtrlName%%CtrlCount%, %A_LoopField%
				}

				;fix for grid for Tabs
				;remove WS_CLIPSIBLINGS 
				If Ctrl2Add In Tab,ListView
					GuiControl, 1:-0x4000000, %CtrlName%%CtrlCount%

				Control, Hide,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
				Control, Show,, %CtrlName%%CtrlCount%, ahk_id %MainWndID%
			}



		;For Gui, Show______________________________
		IfInString, check, GUI
			IfInString, check, Show
			{
				StringGetPos, spos, check, Show
				spos += 4
				StringTrimLeft, data, CurrLine, %spos%
				
				param2 =
				param3 =
				StringSplit, param, data, `,
				IfLess, param0, 2, SetEnv, param2,
				IfInString, param2, `:, Continue
				
				param2 = %param2%
				param3 = %param3%

				IfNotEqual, param2,, GUI, 1:Show, %param2%
				IniWrite, %param3%, %Temp%\SGUIControls.ini, Main, Title
				Break
			}		
	}
	Ctrl2Add =
Return



GuiHelper:
	WinGetPos, MenuWX, MenuWY, MenuWW, MenuWH, %MenuWnd%
	HlprWX := MenuWX + DPIScale(5)
	HlprWY := MenuWY + DPIScale(95)

	IfEqual, HelperStatus, 0
	{
		Gui, 5:Destroy
		Menu, Options, ToggleCheck, Show GUI Helper
		SetTimer, GuiHelper, Off
		Return
	}
	
	IfEqual, HelperStatus, 1
	{
		Gui, 5:+Owner9 +ToolWindow +Border
		Gui, 5:Font, CMaroon, 
		Gui, 5:Add, Text, x7 y3 w50 h20, Window
		Gui, 5:Add, Text, x7 y63 w50 h20, Control
		Gui, 5:Add, Text, x6 y127 w50 h20, Mouse
		Gui, 5:Font
		Gui, 5:Add, Text, x7 y23 w110 h30,	  
		Gui, 5:Add, Text, x7 y83 w110 h40,	  
		Gui, 5:Add, Text, x6 y147 w110 h20,
		Gui, 5:Show, x%HlprWX% y%HlprWY% h174 w120, GUI Helper
		WinActivate, ahk_id %MenuWndID%
		
		SetTimer, GuiHelper, 500
		HelperStatus = 2
		Menu, Options, ToggleCheck, Show GUI Helper
	}

	
	;report mouse position
	CoordMode, Mouse, Client
	MouseGetPos, MouseX, MouseY, CurrID, MCtrl
	MouseX := DPIUnscale(MouseX)
	MouseY := DPIUnscale(MouseY)
	ControlSetText, Static6, X: %MouseX%  Y:%MouseY%, GUI Helper

	;Only return control info from SGUI main window
	IfEqual, CurrID, %MainWndID%
	{
		ControlGetPos, ScX, ScY, ScW, ScH, %MCtrl%, ahk_id %MainWndID%
		WinGetActiveStats, SwT, SwW, SwH, SwX, SwY
		
		SwW := DPIUnscale(SwW)
		SwH := DPIUnscale(SwH)
		ScX := DPIUnscale(ScX)
		ScY := DPIUnscale(ScY)
		ScW := DPIUnscale(ScW)
		ScH := DPIUnscale(ScH)
		
		WinInfo = X:%SwX%`tY:%SwY%`t`nW:%SwW%`tH:%SwH%`t
		CtrlInfo = %MCtrl%`nX:%ScX%`tY:%ScY%`t`nW:%ScW%`tH:%ScH%`t
	
		ControlSetText, Static4, %WinInfo%, GUI Helper
		IfNotEqual, MCtrl, Static1, ControlSetText, Static5, %CtrlInfo%, GUI Helper
	}
	
	;Tooltip for toolbar
	IfEqual, CurrID, %MenuWndID%
	IfNotEqual, MCtrl, %LastCtrl%
	{
		IfEqual, MCtrl, Static2
			ToolTip, Button

		IfEqual, MCtrl, Static3
			ToolTip, CheckBox
		
		IfEqual, MCtrl, Static12
			ToolTip, Radio

		IfEqual, MCtrl, Static11
			ToolTip, Edit

		IfEqual, MCtrl, Static5
			ToolTip, Text

		IfEqual, MCtrl, Static9
			ToolTip, GroupBox

		IfEqual, MCtrl, Static14
			ToolTip, Picture

		IfEqual, MCtrl, Static4
			ToolTip, DropDownList

		IfEqual, MCtrl, Static13
			ToolTip, ComboBox

		IfEqual, MCtrl, Static6
			ToolTip, ListBox

		IfEqual, MCtrl, Static15
			ToolTip, ListView

		IfEqual, MCtrl, Static16
			ToolTip, DateTime

		IfEqual, MCtrl, Static7
			ToolTip, MonthCal

		IfEqual, MCtrl, Static8
			ToolTip, Progress

		IfEqual, MCtrl, Static17
			ToolTip, Slider

		IfEqual, MCtrl, Static10
			ToolTip, Hotkey

		IfEqual, MCtrl, Static18
			ToolTip, Tab

		IfEqual, MCtrl, Static19
			ToolTip, UpDown

		IfEqual, MCtrl, Static20
			ToolTip, Change Font
		
		LastCtrl = %MCtrl%
	}
	
	IfNotEqual, CurrID, %MenuWndID%
		ToolTip

	IfNotInString, MCtrl, Static
		ToolTip
Return



MoveGroup:
	IfWinNotActive, ahk_id %MainWndID%,,Return
	CoordMode, ToolTip, Relative
	ToolTip, %a_space%%a_space%, %sX%, %sY%, 2
	WinSet, Trans, 100, %a_space%%a_space%
	WinActivate, %a_space%%a_space%
	Hotkey, *~LButton, Off
	Loop
	{
		GetKeyState, RB, Lbutton
		IfEqual, RB, D
		{
			MouseGetPos, eX, eY
			WinMove, %a_space%%a_space%,,,, %eX%, %eY%
			Sleep, 50
		}
		IfEqual, RB, U, Break
	}
	ToolTip,,,, 2
	Hotkey, *~LButton, On
	
	;check if mouse not moved at all
	TestX = %eX%
	TestY = %eY%
	TestX -= %sX%
	TestX -= %sX%
	IfLess, TestX, 5
		IfLess, TestY, 5
			Return
	
	;fix for title bar & border 
	sX -= %WinDiffW%
	sY += %WinDiffW%
	sY -= %WinDiffH%
	
	eX += %sX%
	eY += %sY%
	
	Controls2Modify =

	;getting all the controls within selection
	IniRead, ItemList, %Temp%\SGUIControls.ini, Main, ItemList, |

	Loop, Parse, ItemList, |
	{
		IfEqual, A_LoopField,, Continue
		IfInString, A_LoopField, ^DELETED^, Continue
		CtrlNameCount = %A_LoopField%

		Loop, Parse, PosFields
		{
			IniRead, CurrPos, %Temp%\SGUIControls.ini, %CtrlNameCount%, %A_LoopField%
			Ctrl%A_LoopField% = %CurrPos%
		}

				
		;now check if it lies in selection
		;if yes add to string
		CtrlW += %CtrlX%
		CtrlH += %CtrlY%
		
		;Finally checking if the control is visible
		ControlGet, CtrlVis, Visible,, %CtrlNameCount%, ahk_id %MainWndID%
		IfEqual, CtrlVis, 0, Continue

		IfGreaterOrEqual, CtrlX, %sX%
		IfGreaterOrEqual, CtrlY, %sY%
		IfLessOrEqual, CtrlW, %eX%
		IfLessOrEqual, CtrlH, %eY%
			;Controls2Modify contains real (win spy) names 
			Controls2Modify = %Controls2Modify%|%CtrlNameCount%
	}

	;remove leading |
	StringTrimLeft, Controls2Modify, Controls2Modify, 1
	
	;proceed even if no ctrls selected
	;IfEqual, Controls2Modify,, Return
	
	;create gui for first time
	IfNotEqual, FirstTimeM, No
	{
		Gui, 3:+owner1 +ToolWindow
		Gui, 3:Add, Edit, x36 y34 w30 h20 vToMove Center, 10
		Gui, 3:Add, Checkbox, 0x1000 x16 y85 w70 h20 vShowAdv gMoveAdv, Advanced
		Gui, 3:Add, ListBox, 0x0008 x8 y113 w90 h134 vControls2Modify,
		Gui, 3:Font, S12, WingDings
		Gui, 3:Add, Button, 0x8000 x11 y9 w20 h20 g3UL, õ
		Gui, 3:Add, Button, 0x8000 x41 y9 w20 h20 g3U , ñ
		Gui, 3:Add, Button, 0x8000 x71 y9 w20 h20 g3UR, ö
		Gui, 3:Add, Button, 0x8000 x11 y34 w20 h20 g3L , ï
		Gui, 3:Add, Button, 0x8000 x11 y59 w20 h20 g3DL, ÷
		Gui, 3:Add, Button, 0x8000 x41 y59 w20 h20 g3D, ò
		Gui, 3:Add, Button, 0x8000 x71 y59 w20 h20 g3DR, ø
		Gui, 3:Add, Button, 0x8000 x71 y34 w20 h20 g3R, ð
		
		FirstTimeM = No
	}

	;get complete list of controls and delimit them by |
	WinGet, CtrlList0, ControlList, ahk_id %MainWndID%
	CtrlList =
	LastCtrlCombo = 0
	
	Loop, Parse, CtrlList0, `n
	{
		;don't add grid to listbox
		IfEqual, A_LoopField, Static1, Continue
		
		;checking if the control is visible
		ControlGet, CtrlVis, Visible,, %A_LoopField%, ahk_id %MainWndID%
		IfEqual, CtrlVis, 0, Continue

		;check for false edit field generated by combobox
		IfEqual, LastCtrlCombo, 1
			IfInString, A_LoopField, Edit
			{
				LastCtrlCombo = 0
				Continue
			}
		
		IfInString, A_LoopField, ComboBox
		{
			ControlGet, CtrlStyle, Style,, %A_LoopField%, ahk_id %MainWndID%
			Transform, ControlType, BitAnd, %Ctrlstyle%, 0xF
			IfNotEqual, ControlType, 3, SetEnv, LastCtrlCombo, 1
		}
		
		CtrlList = %CtrlList%|%A_LoopField%
	}
	
	;now set the list in listbox and select the reqd items
	GuiControl, 3:, ListBox1, %CtrlList%
	
	WinGetPos, MenuWX, MenuWY, MenuWW, MenuWH, %MenuWnd%
	MoveWX := MenuWX + 5
	MoveWY := MenuWY + 300

	
	Loop, Parse, Controls2Modify, |
	{
		GuiControl, 3:ChooseString, ListBox1, %A_LoopField%
	}
	IfEqual, ShowAdv, 1, Gui, 3:Show, x%MoveWX% y%MoveWY% h255 w106, Move Group
	Else
		Gui, 3:Show, x%MoveWX% y%MoveWY% h110 w106, Move Group
Return


MoveAdv:
	Gui, 3:Submit
	IfEqual, ShowAdv, 1, Gui, 3:Show, h255 w106, Move Group
	Else
		Gui, 3:Show, h110 w106, Move Group
Return


;AddX and AddY can be negative depending on direction of movement
	
3UL:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX -= %ToMove%
	AddY -= %ToMove%
	Goto, 3Move


3U:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddY -= %ToMove%
	Goto, 3Move


3UR:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX += %ToMove%
	AddY -= %ToMove%
	Goto, 3Move


3L:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX -= %ToMove%
	Goto, 3Move


3DL:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX -= %ToMove%
	AddY += %ToMove%
	Goto, 3Move


3D:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddY += %ToMove%
	Goto, 3Move


3DR:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX += %ToMove%
	AddY += %ToMove%
	Goto, 3Move


3R:
	Gui, 3:Submit, NoHide
	AddX = 0
	AddY = 0
	AddX += %ToMove%
	Goto, 3Move


3Move:
	IfEqual, AddX, 0, IfEqual, AddY, 0, Return
	
	;Controls2Modify contains real names (win spy) so read
	;ahk names and position data
	Loop, Parse, Controls2Modify, |
	{
		;Though it isn't possible but if still somebody (with a BIG desktop)
		;selects the grid then don't move it.
		IfEqual, A_LoopField, Static1, Continue
		
		CtrlNameCount = %A_LoopField%
		
		IniRead, Ctrl2Add, %Temp%\SGUIControls.ini, %CtrlNameCount%, Name

		;get original position
		;adjust it for reqd change
		;move controls to desired place
		ControlGetPos, TempX, TempY, TempW, TempH, %CtrlNameCount%, ahk_id %MainWndID%
		TempX += DPIScale(AddX)
		TempY += DPIScale(AddY)
		ControlMove, %CtrlNameCount%, %TempX%, %TempY%,,, ahk_id %MainWndID%
		Control, Hide,, %CtrlNameCount%, ahk_id %MainWndID%
		Control, Show,, %CtrlNameCount%, ahk_id %MainWndID%
		
		;fix for title bar & border 
		TempX -= %WinDiffW%
		TempY -= %WinDiffH%
		TempY += %WinDiffW%
		

		
		Loop, Parse, PosFields
		{
			CurrPos := DPIUnscale(Temp%A_LoopField%)
			IniWrite, %CurrPos%, %Temp%\SGUIControls.ini, %CtrlNameCount%, %A_LoopField%
		}
	}
	Ctrl2Add =
Return


3ButtonClose:
	Gui, 3:Cancel
Return



SetGUIcount:
	Gui, 9:+OwnDialogs
	AutoTrim, off
	Hotkey, *~LButton, Off
	FileSelectFile, GUICountScript, 1, %LoadDir%, Select GUI script to modify, AutoHotkey GUI script (*.ahk)
	Hotkey, *~LButton, On
	IfNotExist, %GUICountScript%, Return
	
	
	InputBox, GUICount, Count, Enter Count to Add (Upto 99),, 250, 125,,,,, 2
	IfEqual, ErrorLevel, 1, Return
	IfGreater, GUICount, 99, Return
	
	FileCopy, %GUICountScript%, %GUICountScript%.Txt, 1
	FileDelete, %GUICountScript%

	
	Loop, Read, %GUICountScript%.Txt, %GUICountScript%
	{
		ToAppend = %A_LoopReadLine% 
		
		StringSplit, param, ToAppend, `,
		StringReplace, guitest, param1, %a_space%,, All
		StringReplace, guitest, guitest, %a_tab%,, All
		
		IfEqual, guitest, Gui	   
		{
			;This strips gui count
			IfEqual, GUICount,
			{
				StringGetPos, cpos, param2, `:
				cpos ++
				StringTrimLeft, TempVar, param2, %cpos%
				StringReplace, TempVar, TempVar, %a_space%,, All
				StringReplace, ToAppend, ToAppend, %param2%, %A_Space%%TempVar%, All
			}


			;this sets gui count
			Else
			{
				;if earlier gui count exists
				IfInString, param2, `:
				{
					StringGetPos, cpos, param2, `:
					cpos ++
					StringTrimLeft, TempVar, param2, %cpos%
					StringReplace, ToAppend, ToAppend, %param2%, %A_Space%%GUICount%`:%TempVar%, All
				}

				;if earlier gui count does not exist
				Else
				{
					StringReplace, TempVar, param2, %a_space%,, All
					StringReplace, ToAppend, ToAppend, %TempVar%, %GUICount%`:%TempVar%, All
				}
			}

		}
		
		FileAppend, %ToAppend%`n	
	}
	AutoTrim, on
	GUICountScript =
Return


LeftButton:
	IfWinNotActive, ahk_id %MainWndID%,,Return
	
	MouseGetPos, sX, sY, DragStW
	GetKeyState, ShiftState, Shift
	KeyWait, LButton, T.25
	
	;lbutton was not kept pressed
	IfNotEqual, ErrorLevel, 1
	{
		KeyWait, LButton, D T.25
		
		;lbutton was not pressed again
		IfEqual, ErrorLevel, 1, Return
		
		;lbutton was pressed again so its a dbl click
		MouseGetPos, TestX, TestY,, CtrlNameCount
		
		;Don't Move Grid
		If CtrlNameCount Not In ,Static1

		IfEqual, TestX, %sX%
			IfEqual, TestY, %sY%
				Goto, Modify
		
		Return
	}

	GetKeyState, CheckLB, LButton
	
	;If shift is up and is reqd to be down for move group
	;then return
	IfEqual, ShiftState, U
	IfEqual, ShiftMove, Yes
		Return
	
	IfEqual, CheckLB, D
	IfEqual, DragStW, %MainWndID%
		Goto, MoveGroup
Return


RightButton:
	MouseGetPos,,, AWID
	IfNotEqual, AWID, %MainWndID%
	{
		Send, {RButton}
		Return
	}
		
	MouseGetPos,,,, CtrlNameCount
	
	;to show tray menu whether grid is or or off
	IfNotEqual, CtrlNameCount, Static1
		Menu, ControlMenu, Show
Return


Stealer:
	siW := DPIScale(300), siH := DPIScale(75)
	SplashImage,, W%siW% H%siH% B1, Activate Target Window and press F12 or press Escape to Cancel., Select Target Window, 

	Loop
	{
		Input, UserKey, V, {Esc}{F12}
		IfEqual, ErrorLevel, Endkey:Escape
		{
			SplashImage, Off
			Return
		}
		
		IfEqual, ErrorLevel, Endkey:F12
		{
			SplashImage, Off
			WinGet, WinID, ID, A
			Break
		}
		
		Sleep, 50
	}
	
	Menu, FileMenu, Disable, GUI Stealer
	Menu, FileMenu, Disable, Edit GUI script
	
	WinGet, CtrlList, ControlList, ahk_id %WinID%
	LastCtrlCombo = 0
	
	Loop, Parse, CtrlList, `n
	{
		CtrlNameCount = %A_LoopField%
		
		;only process visible conrols
		ControlGet, CtrlVis, Visible,, %CtrlNameCount%, ahk_id %WinID%
		IfEqual, CtrlVis, 0, Continue
		
		;get CtrlName & Count (complete real name)
		Loop
		{
			StringRight, check, CtrlNameCount, %a_index%
			if check is integer
			{
				CtrlCount = %check%
				StringTrimRight, CtrlName, CtrlNameCount, %a_index%
			}
			Else Break
		}

		
		;check for false edit field generated by combobox
		IfEqual, LastCtrlCombo, 1
			IfEqual, CtrlName, Edit
			{
				LastCtrlCombo = 0
				Continue
			}
		
		
		ControlGetPos, TempX, TempY, TempW, TempH, %CtrlNameCount%, ahk_id %WinID%
		;MsgBox %TempX% %TempY% %WinDiffW% %WinDiffH%
		
		;fix for title bar & border 
		TempX -= %WinDiffW%
		TempY -= %WinDiffH%
		TempY += %WinDiffW%
		
		TempX := DPIUnscale(TempX)
		TempY := DPIUnscale(TempY)
		TempW := DPIUnscale(TempW)
		TempH := DPIUnscale(TempH)

		ControlGetText, CtrlText, %CtrlNameCount%, ahk_id %WinID%
		ControlGet, CtrlStyle, Style,, %CtrlNameCount%, ahk_id %WinID%
		ControlGet, CtrlExStyle, ExStyle,, %CtrlNameCount%, ahk_id %WinID%

		
		; Set control's ahk name here   <<----
		Ctrl2Add = %CtrlName%
		IfEqual, CtrlName, Static, SetEnv, Ctrl2Add, Text
		IfEqual, CtrlName, msctls_hotkey, SetEnv, Ctrl2Add, Hotkey
		IfEqual, CtrlName, msctls_progress, SetEnv, Ctrl2Add, Progress
		IfEqual, CtrlName, msctls_trackbar, SetEnv, Ctrl2Add, Slider
		IfEqual, CtrlName, SysTabControl, SetEnv, Ctrl2Add, Tab
		IfEqual, CtrlName, SysDateTimePick, SetEnv, Ctrl2Add, DateTime
		IfEqual, CtrlName, SysListView, SetEnv, Ctrl2Add, ListView
		IfEqual, CtrlName, SysMonthCal, SetEnv, Ctrl2Add, MonthCal
		IfEqual, CtrlName, msctls_UpDown, SetEnv, Ctrl2Add, UpDown
		
		AhkStyle =

		;differentiate buttons
		IfEqual, CtrlName, Button 
		{ 
		   ControlType =  ; Set default to be blank. 

		   Transform, ControlType, BitAnd, %CtrlStyle%, 0xF  ; Get the last four bits. 
		   
		   if ControlType in 2,3,5,6  ; check, autocheck, 3state, auto3state (respectively) 
			  Ctrl2Add = Checkbox 
		   else if ControlType in 4,9  ; radio, autoradio (respectively) 
			  Ctrl2Add = Radio 
		   else if ControlType = 7  ; GroupBox 
			  Ctrl2Add = GroupBox 
		   else ; Normal button, default button, picture button, etc. 
			  Ctrl2Add = Button 
		} 

		;differentiate comboboxes
		IfEqual, CtrlName, ComboBox
		{ 
		   ControlType =  ; Set default to be blank. 

		   Transform, ControlType, BitAnd, %Ctrlstyle%, 0xF  ; Get the last four bits. 
		   
		   if ControlType = 3  ; DropDownList
			  Ctrl2Add = DropDownList
		   else
			  Ctrl2Add = ComboBox
		   
		   IfEqual, Ctrl2Add, ComboBox, SetEnv, LastCtrlCombo, 1
		} 
		
		;differentiate sliders
		IfEqual, CtrlName, msctls_trackbar
		{ 
		   ControlType =  ; Set default to be blank. 

		   Transform, ControlType, BitAnd, %Ctrlstyle%, 0xF  ; Get the last four bits. 
		   
		   if ControlType = 2
			  AhkStyle = Left
		   
		   if ControlType = 4
			  AhkStyle = Vertical
		   
		   if ControlType = 8
			  AhkStyle = Center
		   
		   if ControlType = 10
			  AhkStyle = Vertical Center

		   if ControlType = 11
			  AhkStyle = Vertical Center
		} 

		StringRight, PicCheck, CtrlText, 4
		If PicCheck In .jpg,.gif,.bmp,.png,.tif,.ico,.ani,.cur,.wmf,.emf
			SetEnv, Ctrl2Add, Picture
		
		;Only process supported controls
		If Ctrl2Add Not In Button,Checkbox,ComboBox,DateTime,DropDownList,Edit,GroupBox,ListBox,ListView,MonthCal,Progress,Radio,Slider,Text,UpDown,Hotkey
			Continue

		%CtrlName%Count ++
		
		StringTrimLeft, ThisCtrlCount, %CtrlName%Count, 0
		CtrlNameCount = %CtrlName%%ThisCtrlCount%
		
		IfNotEqual, Ctrl2Add, Tab
			Gui, 1:Add, %Ctrl2Add%, x%TempX% y%TempY% w%TempW% h%TempH% %AhkStyle%, %CtrlText%
		
		
		;Special treatment for tab again :(
		;Create only one tab
		IfNotEqual, TabCreated, 1
			IfEqual, Ctrl2Add, Tab
			{
				CtrlText = TabNameHere
				TabCreated = 1
				Gui, 1:Add, %Ctrl2Add%, x%TempX% y%TempY% w%TempW% h%TempH% vTabName gTabGroup, %CtrlText%
				;fix for grid
				;remove WS_CLIPSIBLINGS 
				GuiControl, -0x4000000, SysTabControl321
			}
		
		;for fixing spl chars
		Gosub, FixText

		IniRead, ItemList, %Temp%\SGUIControls.ini, Main, ItemList, |
		IniWrite, %ItemList%%CtrlNameCount%|, %Temp%\SGUIControls.ini, Main, ItemList
		IniWrite, %Ctrl2Add%, %Temp%\SGUIControls.ini, %CtrlNameCount%, Name
		IniWrite, %CtrlText%, %Temp%\SGUIControls.ini, %CtrlNameCount%, Label
	
		Loop, Parse, PosFields
		{
			CurrPos := Temp%A_LoopField%
			IniWrite, %CurrPos%, %Temp%\SGUIControls.ini, %CtrlNameCount%, %A_LoopField%
		}

		IniRead, Options, %Temp%\SGUIControls.ini, %CtrlNameCount%, Options, %A_Space%
		IniWrite, %Options% %AhkStyle%, %Temp%\SGUIControls.ini, %CtrlNameCount%, Options
	}
	
	WinGetPos, wX, wY, wW, wH, ahk_id %WinID%
	;GetClientSize(wW, wH, "ahk_id " WinID)
	
	WinMove, ahk_id %MainWndID%,, %wX%, %wY%, %wW%, %wH%
	WinActivate, ahk_id %MainWndID%
	Ctrl2Add =
Return

DPIScale(x)
{
	return (x * A_ScreenDPI) // 96
}

DPIUnscale(x)
{
	return (x * 96) // A_ScreenDPI
}

; SciTE4AutoHotkey Version fix: get client size
GetClientSize(ByRef w, ByRef h, Title="", Text="", ExcludeTitle="", ExcludeText=""){
	hwnd := WinExist(Title, Text, ExcludeTitle, ExcludeText)
	VarSetCapacity(rect, 16)
	If(!DllCall("GetClientRect", "uint", hwnd, "str", rect))
		Return "", w := "", h := ""
	w := NumGet(rect, 8, "Int")
	h := NumGet(rect, 12, "Int")
}

FixText:
	StringReplace, CtrlText, CtrlText, `n, ``n, A
	StringReplace, CtrlText, CtrlText, `%, ```%, A
	StringReplace, CtrlText, CtrlText, `;, ```;, A
	StringReplace, CtrlText, CtrlText, `,, ```,, A
Return




TabGroup:
	TabCount ++
	Gui, 1:Submit, NoHide
	Gui, Tab, %TabName%

	IniRead, ItemList, %Temp%\SGUIControls.ini, Main, ItemList, |
	IniWrite, %ItemList%TabChange%TabName%|, %Temp%\SGUIControls.ini, Main, ItemList
Return



Justify:
	IniRead, WhichCtrl, %Temp%\SGUIControls.ini, %CtrlNameCount%, Name
	IfEqual, WhichCtrl, ERROR, Return
	
	;remove earlier justifications
	IniRead, Options, %Temp%\SGUIControls.ini, %CtrlNameCount%, Options, %A_Space%

	StringReplace, Options, Options, +Left,, All
	StringReplace, Options, Options, +Center,, All
	StringReplace, Options, Options, +Right,, All
	
	IniWrite, %Options% +%A_ThisMenuItem%, %Temp%\SGUIControls.ini, %CtrlNameCount%, Options

	GuiControl, 1:+%A_ThisMenuItem%, %CtrlNameCount%
	Control, Hide,, %CtrlNameCount%, ahk_id %MainWndID%
	Control, Show,, %CtrlNameCount%, ahk_id %MainWndID%
Return

#include %A_ScriptDir%\..\Lib\GetSciTEInstance.ahk
