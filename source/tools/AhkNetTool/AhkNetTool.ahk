;;;;;;;;;;;;;;;;;;;;;;;;;;
; autohotkey.net Utility ;
; Version 1.0 - by fincs ;
;;;;;;;;;;;;;;;;;;;;;;;;;;

#NoTrayIcon
#NoEnv
#SingleInstance Ignore
SetWorkingDir, %A_ScriptDir%
DetectHiddenWindows, On

#Include %A_ScriptDir%
#Include crypt.ahk ; contains crypting and decrypting routines

Menu, Tray, Icon, ..\..\toolicon.icl, 9

IsPortable := FileExist(A_ScriptDir "\..\$PORTABLE")
if !IsPortable
	LocalSciTEPath = %A_MyDocuments%\AutoHotkey\SciTE
else
	LocalSciTEPath = %A_ScriptDir%\..\user

inifile = %LocalSciTEPath%\Settings\ahknet.ini

; Command data
_CommandList = ChangeDirectory,UploadScript,UploadFile
_Command_ChangeDirectory_NParams = 1
_Command_UploadScript_NParams = 1
_Command_UploadFile_NParams = 2

hasSciTE := false
InFile := ""

InitCrypt()

; Find a SciTE window.
IfWinExist, ahk_class SciTEWindow
{
	hasSciTE := true
	SciTE_HWND := WinExist()
	WinGetTitle, TempVar, ahk_id %SciTE_HWND%
	If(!RegExMatch(TempVar, "^(.+) ([-*]) SciTE4AutoHotkey", Tempy)){
		MsgBox Bad SciTE window!
		ExitApp
	}else{
		InFile = %Tempy1%
		InFile_IsScratch := Tempy2 = "*" ? true : false
		InFile_IsUntitled := false
		IfNotExist, %InFile%
			InFile_IsUntitled := true ; probabily an Untitled window
		ControlGet, Scintilla_HWND, HWND,, Scintilla1, ahk_id %SciTE_HWND%
		Gosub, ConfigWorkingDir
	}
}

If hasSciTE
	alltext := ScintillaGetText(Scintilla_HWND)
Else
	Goto, SettingsGUI

Goto, LoginAHKNet
;----------------

LoginAHKNet:
Gui, Add, Text, x12 y12 w170 h20, Login to autohotkey.net
Gui, Add, Text, x12 y32 w60 h20, Username:
Gui, Add, Edit, x82 y32 w100 h20 vAHKNetUser
Gui, Add, Text, x12 y52 w60 h20, Password:
Gui, Add, Edit, x82 y52 w100 h20 +Password Limit128 vAHKNetPassword
Gui, Add, Button, x12 y112 w60 h20 gAHKNetExecute, Execute
Gui, Add, Button, x82 y112 w40 h20 gExit, Exit
Gui, Add, Button, x132 y112 w50 h20 gSettingsGUIOpenFromLogin, Settings
Gui, Add, CheckBox, x12 y82 w170 h20 Checked vAHKNetRemember, Remember me
Gui, Show, w196 h145, autohotkey.net Tool
Gosub, ReadAndShowRecordedData
Return

AHKNetExecute:
Gui, Submit
If AHKNetRemember
{
	IniWrite, %AHKNetUser%, %inifile%, LoginData, User
	IniWrite, % CryptData(AHKNetPassword), %inifile%, LoginData, Password
}
Gui, Destroy
; <--- Connect to autohotkey.net --->
LittleSplashOn("Connecting to`nautohotkey.net...")
hFTPConnection := FTP_Open("autohotkey.net", 21, AHKNetUser, AHKNetPassword)
If !hFTPConnection
{
	LittleSplashOff()
	MsgBox, 16, autohotkey.net Tool,
	(LTrim
	Failed to connect to autohotkey.net!
	Possible causes:
	· Your Internet connection may be inactive or wrongly set-up
	· Bad username and/or password
	· The autohotkey.net server may be down
	)
	ExitApp
}

; <--- Process the AHK script for FTP commands --->
ncmds = 0
Loop, Parse, alltext, `n, `r
{
	cline = %A_LoopField%
	If(SubStr(cline, 1, 9) == ";#AHKNet_"){
		curcmd := SubStr(cline, 10)
		If(!RegExMatch(curcmd, "^(.+?) (.+?)$", Tempy)){
			MsgBox, 16, autohotkey.net Tool, Syntax error at line %A_Index%.
			ExitApp
		}
		cmd = %Tempy1%
		params = %Tempy2%
		if cmd not in %_CommandList%
		{
			MsgBox, 16, autohotkey.net Tool, Invalid command at line %A_Index%.
			ExitApp
		}
		If(!ParseParams("params", _Command_%cmd%_NParams)){
			MsgBox, 16, autohotkey.net Tool, % "Too few parameters at line " A_Index ", should be " _Command_%cmd%_NParams "."
			ExitApp
		}
		If(!ExecCmd(cmd, params1, params2, params3, params4)){
			FTP_Close()
			LittleSplashOff()
			MsgBox, 16, autohotkey.net Tool, There was an error during the upload!`nCrashed at line number: %A_Index%`nError message:`n`n%LastError%
			ExitApp
		}
	}
}
FTP_Close()
LittleSplashOff()
MsgBox, 64, autohotkey.net Tool, Upload succesful!

goto GUIClose
Return

SettingsGUI:
FileSelectFile, InFile, 1,, Select AHK file to process and upload, AHK scripts (*.ahk)
if InFile =
	ExitApp
IfNotExist, %InFile%
{
	MsgBox, 16, autohotkey.net Tool, File does not exist.
	ExitApp
}
Gosub, ConfigWorkingDir
FileRead, alltext, %InFile%
goto LoginAHKNet
return

ConfigWorkingDir:
SplitPath, InFile,, __Dir
SetWorkingDir, %__Dir%
Return

SettingsGUIOpenFromLogin:
MsgBox, 64, autohotkey.net Tool, Sorry`, settings GUI is currently not available. [*EXITAPP ACTION*]
GuiClose:
Exit:
ExitApp

ReadAndShowRecordedData:
IniRead, usr, %inifile%, LoginData, User, %A_Space%
IniRead, pwd, %inifile%, LoginData, Password, %A_Space%
; decrypt the password
If(StrLen(pwd) >= 256)
	pwd := DecryptData(pwd)
Else
	pwd =
GuiControl,, AHKNetUser, % usr
GuiControl,, AHKNetPassword, % pwd
pwd = ; security reasons
Return

LittleSplashOn(t){
	Global LS_Text
	Gui 99:Add, Text, vLS_Text w300 h225 +Border, % t
	Gui 99:-Caption +ToolWindow +AlwaysOnTop +Border
	Gui 99:Show, NoActivate
}

LittleSplashText(t){
	GuiControl 99:, LS_Text, % t
}

LittleSplashOff(){
	Gui 99:Destroy
}

;SendMessageUser32(hwnd, msg, wParam=0, lParam=0, type1="int", type2="int"){
;	Return DllCall("SendMessageA", "UInt", hwnd, "int", msg, type1, wParam, type2, lParam)
;}

/*
ScintillaGetLength(hwnd){
	Global SCI_GETLENGTH
	SendMessage, SCI_GETLENGTH, 0, 0,, ahk_id %hwnd%
	Return ErrorLevel+1
}

ScintillaGetText(hwnd){
	Global SCI_GETLENGTH, SCI_GETTEXT
	SendMessage, SCI_GETLENGTH, 0, 0,, ahk_id %hwnd%
	length := ErrorLevel
	RemoteBuf_Open(hSBuf, hwnd, length + 2)
	SendMessage, SCI_GETTEXT, length + 1, RemoteBuf_Get(hSBuf),, ahk_id %hwnd%
	VarSetCapacity(sText, length + 2)
	RemoteBuf_Read(hSBuf, sText, length + 2)
	RemoteBuf_Close(hSBuf)
	Return sText
}
*/

ScintillaGetText(hSci) {
	
	;Retrieve text length. SCI_GETLENGTH
	SendMessage 2006, 0, 0,, ahk_id %hSci%
	iLength := ErrorLevel
	
	;Open remote buffer (add 1 for 0 at the end of the string)
	RemoteBuf_Open(hBuf, hSci, iLength + 1)
	
	;Fill buffer with text. SCI_GETTEXT
	SendMessage 2182, iLength + 1, RemoteBuf_Get(hBuf),, ahk_id %hSci%
	
	;Read buffer
	VarSetCapacity(sText, iLength)
	RemoteBuf_Read(hBuf, sText, iLength + 1)
	
	;We're done with the remote buffer
	RemoteBuf_Close(hBuf)
	
	Return A_IsUnicode ? StrGet(&sText, "UTF-8") : sText
}

ParseParams(outVar, nParams){
	Global
	Local plist, pattern
	plist := %outVar%
	if nParams = 0
		Return true
	if nParams = 1
	{
		%outVar%1 := plist
		Return true
	}
	pattern =
	Loop, %nParams%
		pattern .= "\s*\x22(.+?)\x22"
	Return RegExMatch(plist, pattern, %outVar%) != 0
}

ExecCmd(cmd, param1="", param2="", param3="", param4=""){
	Global hFTPConnection, InFile, LastError
	If cmd = ChangeDirectory
	{
		LittleSplashText("Going to`n" param1 "...")
		LastError = Couldn't go to "%param1%"!
		Return FTP_SetCurrentDirectory(hFTPConnection, param1)
	}Else If cmd = UploadScript
	{
		LittleSplashText("Uploading the script to`n" param1 "...")
		; Run the prologue for file uploading
		If(!_CMDHelper_UploadPrologue(hFTPConnection, param1))
			Return false
		; Upload the script.
		Return _CMDHelper_Upload(hFTPConnection, InFile, param1)
	}Else If cmd = UploadFile
	{
		LittleSplashText("Uploading file:`n" param1 "`nto:`n" param2 "...")
		; Run the prologue for file uploading
		If(!_CMDHelper_UploadPrologue(hFTPConnection, param2))
			Return false
		; Upload the script.
		Return _CMDHelper_Upload(hFTPConnection, param1, param2)
	}Else
		Return false
}

_CMDHelper_UploadPrologue(hFTPConnection, path){
	Global LastError
	; First parse it into a series of directories.
	StringSplit, DirArray, path, /
	If DirArray0 != 0
	{
		dirname =
		Loop, % DirArray0 - 1
		{
			dirname .= DirArray%A_Index% "/"
			; The classic cd test
			if(!FTP_GetCurrentDirectory(hFTPConnection, TempDir)){
				LastError = Couldn't get current directory!
				Return false
			}
			if(!FTP_SetCurrentDirectory(hFTPConnection, SubStr(dirname, 1, StrLen(dirname)-1))){
				if(!FTP_CreateDirectory(hFTPConnection, SubStr(dirname, 1, StrLen(dirname)-1))){ ; ... so we create it.
					LastError := "Couldn't create folder " SubStr(dirname, 1, StrLen(dirname)-1) "!"
					Return false
				}
			}else{
				; The test was succesful, but now we have to return to the directory
				if(!FTP_SetCurrentDirectory(hFTPConnection, TempDir)){
					LastError = Couldn't go to "%TempDir%"!
					Return false
				}
			}
		}
	}
	Return true
}

_CMDHelper_Upload(hFTPConnection, from, to){
	Global LastError
	; Check the existance of the file
	if(FTP_GetFileSize(hFTPConnection, to, 2) != -1){
		if(!FTP_DeleteFile(hFTPConnection, to)){
			LastError = Couldn't delete file %to%!
			Return false
		}
	}
	; Upload the file.
	LastError = Couldn't upload "%from%" to "%to%"!
	Return FTP_PutFile(hFTPConnection, from, to, 2)
}

FTP_GetCurrentDirectory(hConnect,ByRef DirName){
	VarSetCapacity(DirName, 256)
	VarSetCapacity(MaxDirN, 4)
	NumPut(256, MaxDirN)
	r := DllCall("wininet\FtpGetCurrentDirectory", "uint", hConnect, "str", DirName, "str", MaxDirN)
	If (ErrorLevel or !r)
		Return 0
	If(NumGet(MaxDirN) > 256){
		VarSetCapacity(DirName, NumGet(MaxDirN))
		r := DllCall("wininet\FtpGetCurrentDirectory", "uint", hConnect, "str", DirName, "str", MaxDirN)
	}
	If (ErrorLevel or !r)
		Return 0
	Else
		Return 1
}
