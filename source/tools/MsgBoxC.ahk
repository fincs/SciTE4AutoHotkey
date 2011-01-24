#SingleInstance Ignore
#NoTrayIcon
#NoEnv
SetWorkingDir, %A_ScriptDir%

scitehwnd := WinExist("ahk_class SciTEWindow")
/*IfWinNotExist, ahk_id %scitehwnd%
{
	MsgBox, 16, MsgBox Creator, SciTE window not found
	ExitApp
}
*/

;Tray-Menu
Menu, Tray, Icon, ..\toolicon.icl, 10
Menu, Tray, Add, Open, Open
Menu, Tray, Add, Reset Settings, Reset
Menu, Tray, Add, Close, GuiClose
Menu, Tray, Click, 1
Menu, Tray, Default, Open
Menu, Tray, NoStandard

;GUI
Gui, Add, Text, x10 y10 section, Title
Gui, Add, Edit, xs+0 ys+15 section w400 vTitle gCreate_Msgbox_Command,
Gui, Add, Text, xs+0 ys+25 section, Text:
Gui, Add, Edit, xs+0 ys+15 section r3 w400 vText gCreate_Msgbox_Command WantTab,

Gui, Add, Groupbox, x10 y130 h215 w190 section, Buttons
Gui, Add, Radio, xs+10 ys+20 section vButton_Selection1 Checked gCreate_Msgbox_Command, OK
Gui, Add, Radio, xs+0 ys+25 section vButton_Selection2 gCreate_Msgbox_Command, OK/Cancel
Gui, Add, Radio, xs+0 ys+25 section vButton_Selection3 gCreate_Msgbox_Command, Abort/Retry/Ignore
Gui, Add, Radio, xs+0 ys+25 section vButton_Selection4 gCreate_Msgbox_Command, Yes/No/Cancel
Gui, Add, Radio, xs+0 ys+25 section vButton_Selection5 gCreate_Msgbox_Command, Yes/No
Gui, Add, Radio, xs+0 ys+25 section vButton_Selection6 gCreate_Msgbox_Command, Retry/Cancel
Gui, Add, Radio, xs+0 ys+25 section vButton_Selection7 gCreate_Msgbox_Command, Cancel/Try Again/Continue
Gui, Add, Checkbox, xs+0 ys+25 vButton_Selection_Help gCreate_Msgbox_Command, Help button

Gui, Add, Groupbox, x220 y130 h215 w190 section, Icons
Gui, Add, Radio, xs+10 ys+25 section vIcon1 Checked gCreate_Msgbox_Command, No Icon
Gui, Add, Radio, xs+0 ys+40 vIcon2 gCreate_Msgbox_Command, Stop/Error
Gui, Add, Radio, xs+0 ys+80 vIcon3 gCreate_Msgbox_Command, Question
Gui, Add, Radio, xs+0 ys+120 vIcon4 gCreate_Msgbox_Command, Exclamation
Gui, Add, Radio, xs+0 ys+160 vIcon5 gCreate_Msgbox_Command, Info
;Gui, Add, Picture, xs+90 ys-10 gSelect_NoIcon icon1, %A_WinDir%\system32\user32.dll
Gui, Add, Picture, xs+90 ys-10 gSelect_NoIcon h30 w20
Gui, Add, Picture, xs+90 ys+30 gSelect_ErrorIcon icon4 , %A_WinDir%\system32\user32.dll
Gui, Add, Picture, xs+90 ys+70 gSelect_Question icon3 , %A_WinDir%\system32\user32.dll
Gui, Add, Picture, xs+90 ys+110 gSelect_Exclamation icon2, %A_WinDir%\system32\user32.dll
Gui, Add, Picture, xs+90 ys+150 gSelect_Info icon5 , %A_WinDir%\system32\user32.dll

Gui, Add, Groupbox, x430 y20 h140 w190 section, Modality
Gui, Add, Radio, xs+10 ys+20 section Checked vModality1 gCreate_Msgbox_Command, Normal
Gui, Add, Radio, xs+0 ys+25 section vModality2 gCreate_Msgbox_Command, Task Modal
Gui, Add, Radio, xs+0 ys+25 section vModality3 gCreate_Msgbox_Command, System Modal (always on top)
Gui, Add, Radio, xs+0 ys+25 section vModality4 gCreate_Msgbox_Command, Always on top
Gui, Add, Radio, xs+0 ys+25 section vModality5 gCreate_Msgbox_Command, Default desktop

Gui, Add, Groupbox, x430 y170 h45 w190 section, Default-Button
Gui, Add, Radio, xs+10 ys+20 section Checked vDefault1 gCreate_Msgbox_Command, 1st
Gui, Add, Radio, xs+65 ys+0 section vDefault2 gCreate_Msgbox_Command, 2nd
Gui, Add, Radio, xs+65 ys+0 section vDefault3 gCreate_Msgbox_Command, 3rd

Gui, Add, Groupbox, x435 y220 h45 w190 section, Allignment
Gui, Add, Checkbox, xs+10 ys+20 vAllignment1 section gCreate_Msgbox_Command, Right-justified
Gui, Add, Checkbox, xs+100 ys+0 vAllignment2 gCreate_Msgbox_Command, Right-to-left

Gui, Add, Groupbox, x430 y270 h45 w90 section, Timeout
Gui, Add, Edit, xs+10 ys+17 w70 vTimeout gCreate_Msgbox_Command
Gui, Add, UpDown, Range-1-2147483, -1

Gui, Add, Button, x530 y280 h30 w90 vTest gTest, &Test
if(scitehwnd)
	Gui, Add, Button, x430 y320 h30 w90 Default gSciTEInsert, &Insert in SciTE
else
	Gui, Add, Button, x430 y320 h30 w90 Default gClipboardCopy, &Copy to clipboard
Gui, Add, Button, x530 y320 h30 w90 gReset, &Reset

Gui, Add, Groupbox, x10 y350 w610 h75 section, Result
Gui, Add, Edit, xs+10 ys+20 w590 r3 vMsgbox_Command,

Gui, Show, , MsgBox Creator for SciTE4AutoHotkey v3
GoSub, Reset      ;Initalize GUI from Ini
return

Select_NoIcon:
GuiControl, , Icon1, 1
GoSub, Create_Msgbox_Command
return

Select_ErrorIcon:
GuiControl, , Icon2, 1
GoSub, Create_Msgbox_Command
return

Select_Question:
GuiControl, , Icon3, 1
GoSub, Create_Msgbox_Command
return

Select_Exclamation:
GuiControl, , Icon4, 1
GoSub, Create_Msgbox_Command
return

Select_Info:
GuiControl, , Icon5, 1
GoSub, Create_Msgbox_Command
return

Create_Msgbox_Command:
Gui, Submit, NoHide
;Get types of used buttons
Loop, 7
{
	if Button_Selection%A_Index% = 1
	{
		ButtonSelection := A_Index -1
		if Button_Selection_Help = 1
			ButtonSelection += 16384
		break
   }
}

;Get used Icon
Loop, 5
{
	if Icon%A_Index% = 1
	{
		if A_Index = 1
			Icon = 0
		else if A_Index = 2
			Icon = 16
		else if A_Index = 3
			Icon = 32
		else if A_Index = 4
			Icon = 48
		else if A_Index = 5
			Icon = 64
		break
	}
}

;Get Modality-State
Loop, 5
{
	if Modality%A_Index% = 1
	{
		if A_Index = 1
			Modality = 0
		else if A_Index = 2
			Modality = 8192
		else if A_Index = 3
			Modality = 4096
		else if A_Index = 4
			Modality = 262144
		else if A_Index = 5
			Modality = 131072
		break
	}
}

;Get Default-Button
Loop, 3
{
	if Default%A_Index% = 1
	{
		if A_Index = 1
			Default = 0
		else if A_Index = 2
			Default = 256
		else if A_Index = 3
			Default = 512
		break
	}
}

;Check Allignment
Allignment = 0
if Allignment1 = 1
	Allignment += 524288
if Allignment2 = 1
	Allignment += 1048576

Msgbox_Number := ButtonSelection + Icon + Modality + Default + Allignment   ;Generate type of messagebox

Escape_Characters(Title)
Escape_Characters(Text)

;Timeout "-1" = no timeout
if Timeout = -1
	Timeout =
else
{
	StringReplace, Timeout, Timeout, `,, .      ;Allows "," as decimal-point
	Timeout = , %Timeout%
}

;Create command and set it to Edit-Control
Msgbox_Command = MsgBox, %Msgbox_Number%, %Title%, %Text%%Timeout%
GuiControl, , Msgbox_Command, %Msgbox_Command%
return

;Creates a Temp-File to show actual configuration
Test:
GoSub, Create_Msgbox_Command
GuiControl, Disable, Test
FileDelete, %A_Temp%\MsgboxTemp.ahk
FileAppend, #NoTrayIcon`n%Msgbox_Command%, %A_Temp%\MsgboxTemp.ahk, UTF-8
RunWait, %A_AhkPath% "%A_Temp%\MsgboxTemp.ahk"
FileDelete, %A_Temp%\MsgboxTemp.ahk
GuiControl, Enable, Test
return

;Escapes Characters like ","
Escape_Characters(byref Var)
{
	StringReplace, Var, Var, `n, ``n, All      ;Translate line breaks in entered text
	StringReplace, Var, Var, `,, ```,, All      ;Escapes ","
	StringReplace, Var, Var, `;, ```;, All      ;Escapes ";"
}

SciTEInsert:
IfWinNotExist, ahk_id %scitehwnd%
	goto ClipboardCopy
WinActivate, ahk_id %scitehwnd%
WinWaitActive
scite := GetSciTEInstance()
if !scite
{
	MsgBox, 16, MsgBox Creator, Can't retrieve SciTE COM object!
	ExitApp
}
scite.InsertText(Msgbox_Command)
ExitApp

ClipboardCopy:
Clipboard := Msgbox_Command
ExitApp

GuiClose:
ExitApp

Open:
Gui, Show
return

Reset:
IfExist %A_ScriptDir%\Msgbox.ini
{
	IniRead, Title, %A_ScriptDir%\Msgbox.ini, Reset, Title, %A_Space%
	IniRead, Text, %A_ScriptDir%\Msgbox.ini, Reset, Text, %A_Space%
	IniRead, Modality, %A_ScriptDir%\Msgbox.ini, Reset, Modality, 1
	IniRead, Icon, %A_ScriptDir%\Msgbox.ini, Reset, Icon, 1
	IniRead, Button_Selection, %A_ScriptDir%\Msgbox.ini, Reset, Button, 1
	IniRead, Button_Selection_Help, %A_ScriptDir%\Msgbox.ini, Reset, Help Button, 0
	IniRead, Default, %A_ScriptDir%\Msgbox.ini, Reset, Default Button, 1
	IniRead, Timeout, %A_ScriptDir%\Msgbox.ini, Reset, Timeout, -1
	IniRead, Allignment1, %A_ScriptDir%\Msgbox.ini, Reset, Allignment_Right, 0
	IniRead, Allignment2, %A_ScriptDir%\Msgbox.ini, Reset, Allignment_RtL, 0
}
else
{
	Title =
	Text =
	Modality = 1
	Icon = 1
	Button_Selection = 1
	Button_Selection_Help = 0
	Default = 1
	Timeout = -1
	Allignment1 = 0
	Allignment2 = 0
}

GuiControl, , Title, %Title%
GuiControl, , Text, %Text%
GuiControl, , Modality%Modality%, 1
GuiControl, , Icon%Icon%, 1
GuiControl, , Button_Selection%Button_Selection%, 1
GuiControl, , Button_Selection_Help, %Button_Selection_Help%
GuiControl, , Default%Default%, 1
GuiControl, , Timeout, %Timeout%
GuiControl, , Allignment1, %Allignment1%
GuiControl, , Allignment2, %Allignment2%
return

GuiSize:
if A_EventInfo = 1
	Gui, Show, Hide
return
