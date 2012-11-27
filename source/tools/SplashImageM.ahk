#SingleInstance Ignore
#NoTrayIcon
#NoEnv
SetWorkingDir, %A_ScriptDir%

scite := GetSciTEInstance()
if !scite
{
	MsgBox, 16, SplashImage Maker, Cannot find SciTE!
	ExitApp
}

Menu, Tray, Icon, ..\toolicon.icl, 14

;The step-size per change (in pixels)
Step = 5

Gui, Add, Text, x6 y5 w100 h20, Window Title
Gui, Add, Text, x6 y55 w100 h20, Main Text
Gui, Add, Text, x6 y125 w100 h20, Picture
Gui, Add, Text, x6 y175 w100 h20, Sub Text

Gui, Add, Edit, x6 y25 w220 h20 vSTitle
Gui, Add, Edit, x6 y75 w220 h40 vMText
Gui, Add, Edit, x6 y145 w180 h20 ReadOnly vPicFile
Gui, Add, Button, x196 y145 w30 h20 gBrowse, ..
Gui, Add, Edit, x6 y195 w220 h40 vSText

Gui, Add, Button, x36 y245 w60 h20 Default gOk, OK
Gui, Add, Button, x136 y245 w60 h20 gGuiClose, Cancel

Gui, Show, h276 w233, SplashImage Maker for SciTE4AutoHotkey
return

GuiClose:
ExitApp

Browse:
FileSelectFile, SelFile,,, Select Picture File, Picture files (*.bmp; *.gif; *.jpg; *.png)
if !ErrorLevel
	GuiControl,, PicFile, %SelFile%
return

Ok:
Gui, Submit
SWidth = 500
SHeight = 500
if STitle =
	Options = B1
gosub doSplashImage
Hotkey, Up, Up
Hotkey, Down, Down
Hotkey, Left, Left
Hotkey, Right, Right
Hotkey, Esc, Esc
return

doSplashImage:
SplashImage, % PicFile, w%SWidth% h%SHeight% %Options%, % SText, % MText, % STitle 
return

Up:
if (SHeight >= Step)
	SHeight -= Step
goto doSplashImage

Down:
SHeight += Step
goto doSplashImage

Left:
if (SWidth >= Step)
	SWidth -= Step
goto doSplashImage

Right: 
SWidth += Step
goto doSplashImage

Esc:
SplashImage, Off
StringReplace, MText, MText, `n, ``n, All
StringReplace, SText, SText, `n, ``n, All
MsgBox, 36, SplashImage Maker, Do you want to insert the code into SciTE?
IfMsgBox, Yes
	scite.InsertText("SplashImage, " PicFile ", w" SWidth " h" SHeight " " Options ", " SText ", " MText ", " STitle)
ExitApp
