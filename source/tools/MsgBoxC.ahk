;
; SciTE4AutoHotkey MsgBox Creator
;

#SingleInstance Ignore
#NoTrayIcon
#NoEnv
SetWorkingDir, %A_ScriptDir%

oSciTE := GetSciTEInstance()
if !oSciTE
{
	MsgBox, 16, MsgBox Creator, Cannot find SciTE!
	ExitApp
}

scHwnd := oSciTE.SciTEHandle

; Main icon
Menu, Tray, Icon, ..\toolicon.icl, 10

;GUI
Gui, +Owner%scHwnd%
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
Gui, Add, Picture, xs+90 ys+30 gSelect_ErrorIcon icon4 w32 h32, %A_WinDir%\system32\user32.dll
Gui, Add, Picture, xs+90 ys+70 gSelect_Question icon3 w32 h32, %A_WinDir%\system32\user32.dll
Gui, Add, Picture, xs+90 ys+110 gSelect_Exclamation icon2 w32 h32, %A_WinDir%\system32\user32.dll
Gui, Add, Picture, xs+90 ys+150 gSelect_Info icon5 w32 h32, %A_WinDir%\system32\user32.dll

Gui, Add, Groupbox, x430 y20 h140 w190 section, Modality
Gui, Add, Radio, xs+10 ys+20 section Checked vModality1 gCreate_Msgbox_Command, Normal
Gui, Add, Radio, xs+0 ys+25 section vModality2 gCreate_Msgbox_Command, Task Modal
Gui, Add, Radio, xs+0 ys+25 section vModality3 gCreate_Msgbox_Command, System Modal (always on top)
Gui, Add, Radio, xs+0 ys+25 section vModality4 gCreate_Msgbox_Command, Always on top
Gui, Add, Radio, xs+0 ys+25 section vModality5 gCreate_Msgbox_Command, Default desktop

Gui, Add, Groupbox, x430 y170 h45 w190 section, Default Button
Gui, Add, Radio, xs+10 ys+20 section Checked vDefault1 gCreate_Msgbox_Command, 1st
Gui, Add, Radio, xs+65 ys+0 section vDefault2 gCreate_Msgbox_Command, 2nd
Gui, Add, Radio, xs+65 ys+0 section vDefault3 gCreate_Msgbox_Command, 3rd

Gui, Add, Groupbox, x435 y220 h45 w190 section, Alignment
Gui, Add, Checkbox, xs+10 ys+20 vAlignment1 section gCreate_Msgbox_Command, Right-justified
Gui, Add, Checkbox, xs+100 ys+0 vAlignment2 gCreate_Msgbox_Command, Right-to-left

Gui, Add, Groupbox, x430 y270 h45 w90 section, Timeout
Gui, Add, Edit, xs+10 ys+17 w70 vTimeout gCreate_Msgbox_Command
Gui, Add, UpDown, Range-1-2147483, -1

Gui, Add, Button, x530 y280 h30 w90 vTest gTest, &Test
Gui, Add, Button, x430 y320 h30 w90 Default gSciTEInsert, &Insert in SciTE
Gui, Add, Button, x530 y320 h30 w90 gReset, &Reset

Gui, Add, Groupbox, x10 y350 w610 h75 section, Result
Gui, Add, Edit, xs+10 ys+20 w590 r3 vMsgbox_Command,

Gui, Show, , MsgBox Creator for SciTE4AutoHotkey v3
GoSub, Reset      ;Initalize GUI
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

;Check Alignment
Alignment = 0
if Alignment1 = 1
	Alignment += 524288
if Alignment2 = 1
	Alignment += 1048576

Msgbox_Number := ButtonSelection + Icon + Modality + Default + Alignment   ;Generate type of messagebox

if TestMode
	return

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

Test:
TestMode := true
GoSub, Create_Msgbox_Command
TestMode := false
Gui, +OwnDialogs
Title := Title ? Title : "%A_ScriptName%"
if Timeout != -1
	MsgBox, % Msgbox_Number, % Title, % Text, % Timeout
else
	MsgBox, % Msgbox_Number, % Title, % Text
return

;Escapes Characters like ","
Escape_Characters(byref Var)
{
	StringReplace, Var, Var, `n, ``n, All      ;Translate line breaks in entered text
	StringReplace, Var, Var, `,, ```,, All      ;Escapes ","
	StringReplace, Var, Var, `;, ```;, All      ;Escapes ";"
}

SciTEInsert:
oSciTE.InsertText(Msgbox_Command)
ExitApp

GuiClose:
ExitApp

Open:
Gui, Show
return

Reset:
GuiControl,, Title
GuiControl,, Text
GuiControl,, Modality1, 1
GuiControl,, Icon1, 1
GuiControl,, Button_Selection1, 1
GuiControl,, Button_Selection_Help, 0
GuiControl,, Default1, 1
GuiControl,, Timeout, -1
GuiControl,, Alignment1, 0
GuiControl,, Alignment2, 0
return

GuiSize:
if A_EventInfo = 1
	Gui, Show, Hide
return
