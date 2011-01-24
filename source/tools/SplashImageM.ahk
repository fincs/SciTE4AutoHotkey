#SingleInstance Ignore
#NoTrayIcon
#NoEnv
SetWorkingDir, %A_ScriptDir%

/*IfWinNotExist, ahk_class SciTEWindow
{
	MsgBox, 16, SplashImage Maker, SciTE window not found
	ExitApp
}
*/

Menu, Tray, Icon, ..\toolicon.icl, 14

;The step-size per change (in pixels) 
Step = 5 

Gui, Add, Text, x6 y5 w100 h20, Window Title 
Gui, Add, Text, x6 y55 w100 h20, Main Text 
Gui, Add, Text, x6 y125 w100 h20, Picture 
Gui, Add, Text, x6 y175 w100 h20, Sub Text 

Gui, Add, Edit, x6 y25 w220 h20 vSTitle, 
Gui, Add, Edit, x6 y75 w220 h40 vMText, 
Gui, Add, Edit, x6 y145 w180 h20 ReadOnly vPicFile, 
Gui, Add, Button, x196 y145 w30 h20, .. 
Gui, Add, Edit, x6 y195 w220 h40 vSText, 

Gui, Add, Button, x36 y245 w60 h20 Default, OK
Gui, Add, Button, x136 y245 w60 h20, Cancel 

Gui, Show, h276 w233, SplashImage Maker for SciTE4AutoHotkey v3
Return 

ButtonCancel: 
GuiClose: 
   ExitApp 


Button..: 
	FileSelectFile, SelFile,,, Select Picture File, Picture files (*.bmp; *.gif; *.jpg)
	GuiControl,, PicFile, %SelFile% 
Return 


ButtonOk: 
	Gui, Submit 
	SWidth = 500
	SHeight = 500 
	IfEqual, STitle, 
		Options = B1 
	SplashImage,%PicFile%, W%SWidth% H%SHeight% %Options%,%SText%,%MText%,%STitle% 
	Hotkey, Up, Up 
	Hotkey, Down, Down 
	Hotkey, Left, Left 
	Hotkey, Right, Right 
	Hotkey, Esc, Esc 
Return 


Up: 
	IfGreaterOrEqual, SHeight, %Step% 
		SHeight -= %Step% 
	SplashImage,%PicFile%, W%SWidth% H%SHeight% %Options%,%SText%,%MText%,%STitle% 
Return 


Down: 
	SHeight += %Step% 
	SplashImage,%PicFile%, W%SWidth% H%SHeight% %Options%,%SText%,%MText%,%STitle% 
Return 


Left: 
	IfGreaterOrEqual, SWidth, %Step% 
		SWidth -= %Step% 
	SplashImage,%PicFile%, W%SWidth% H%SHeight% %Options%,%SText%,%MText%,%STitle% 
Return 


Right: 
	SWidth += %Step% 
	SplashImage,%PicFile%, W%SWidth% H%SHeight% %Options%,%SText%,%MText%,%STitle% 
Return 


Esc:
	SplashImage, Off
	StringReplace, MText, MText, `n, ``n, A
	StringReplace, SText, SText, `n, ``n, A
	; Attempt to retrieve SciTE
	if scite := GetSciTEInstance()
		MsgBox, 36, Please Confirm, Do you want to insert the code into SciTE?
	else
		MsgBox, 36, Please Confirm, Do you want to copy the code to the Clipboard?
	IfMsgBox, Yes
	{
		if scite
			scite.InsertText("SplashImage, " PicFile ", w" SWidth " h" SHeight " " Options ", " SText ", " MText ", " STitle)
		else
			Clipboard = SplashImage, %PicFile%, w%SWidth% h%SHeight% %Options%, %SText%, %MText%, %STitle%
	}
	ExitApp 
Return 
