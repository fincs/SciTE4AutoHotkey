;
; autohotkey.net Utility
;     v1.1 - by fincs
;

#NoTrayIcon
#NoEnv
#SingleInstance Ignore
SetWorkingDir, %A_ScriptDir%
DetectHiddenWindows, On

Menu, Tray, Icon, ..\toolicon.icl, 9

oSciTE := GetSciTEInstance()
if !oSciTE
{
	MsgBox, 16, autohotkey.net Tool, Cannot find SciTE!
	ExitApp
}

inifile := oSciTE.UserDir "\Settings\ahknet.ini"

; Command data
_CommandList = ChangeDirectory,UploadScript,UploadFile
_Command_ChangeDirectory_NParams = 1
_Command_UploadScript_NParams = 1
_Command_UploadFile_NParams = 2

InFile := oSciTE.CurrentFile
alltext := oSciTE.Document

Gui, Add, Text,, Login to autohotkey.net
Gui, Add, Text, Section +Right w60, Username:
Gui, Add, Edit, ys w100 vAHKNetUser
Gui, Add, Text, xs Section +Right w60, Password:
Gui, Add, Edit, ys w100 vAHKNetPassword +Password Limit128
Gui, Add, CheckBox, xs Section Checked vAHKNetRemember, Remember me
Gui, Add, Button, xs+50 Section gAHKNetExecute, Execute
Gui, Show,, autohotkey.net Tool

gosub ReadAndShowRecordedData
return

AHKNetExecute:
Gui, Submit
if AHKNetRemember
{
	IniWrite, %AHKNetUser%, %inifile%, LoginData, User
	IniWrite, % crypt_Encrypt(AHKNetPassword), %inifile%, LoginData, Password
}

Gui, Destroy

; Connect to autohotkey.net
LittleSplashOn("Connecting to`nautohotkey.net...")
hFTPConnection := FTP_Open("autohotkey.net", 21, AHKNetUser "@autohotkey.net", AHKNetPassword)
if !hFTPConnection
{
	LittleSplashOff()
	MsgBox, 16, autohotkey.net Tool,
	(LTrim
	Failed to connect to autohotkey.net!
	Possible causes:
	- Bad username and/or password
	- Your Internet connection may be inactive or wrongly set-up
	- The autohotkey.net server may be down
	)
	ExitApp
}

; Process the AHK script for FTP commands
ncmds = 0
Loop, Parse, alltext, `n, `r
{
	cline := Trim(A_LoopField)
	
	if SubStr(cline, 1, 9) = ";#AHKNet_"
	{
		curcmd := SubStr(cline, 10)
		if !RegExMatch(curcmd, "^(.+?) (.+?)$", Tempy)
		{
			MsgBox, 16, autohotkey.net Tool, Syntax error at line %A_Index%.
			ExitApp
		}
		
		cmd := Trim(Tempy1), params := Trim(Tempy2)
		
		if cmd not in %_CommandList%
		{
			MsgBox, 16, autohotkey.net Tool, Invalid command at line %A_Index%.
			ExitApp
		}
		
		if !ParseParams("params", _Command_%cmd%_NParams)
		{
			MsgBox, 16, autohotkey.net Tool, % "Too few parameters at line " A_Index ", should be " _Command_%cmd%_NParams "."
			ExitApp
		}
		
		if !ExecCmd(cmd, params1, params2, params3, params4)
		{
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

GuiClose:
ExitApp

ReadAndShowRecordedData:
IniRead, usr, %inifile%, LoginData, User, %A_Space%
IniRead, pwd, %inifile%, LoginData, Password, %A_Space%

; Decrypt the password
pwd := StrLen(pwd) >= 256 ? crypt_Decrypt(pwd) : ""
GuiControl,, AHKNetUser, % usr
GuiControl,, AHKNetPassword, % pwd
pwd := ""
return

LittleSplashOn(t)
{
	global LS_Text
	Gui 99:Add, Text, vLS_Text w300 h225 +Border, % t
	Gui 99:-Caption +ToolWindow +AlwaysOnTop +Border
	Gui 99:Show, NoActivate
}

LittleSplashText(t)
{
	GuiControl 99:, LS_Text, % t
}

LittleSplashOff()
{
	Gui 99:Destroy
}

ParseParams(outVar, nParams)
{
	global
	local plist, pattern
	
	plist := %outVar%
	if nParams = 0
		return true
	if nParams = 1
	{
		%outVar%1 := plist
		return true
	}
	
	pattern =
	Loop, %nParams%
		pattern .= "\s*\x22(.+?)\x22"
	
	return RegExMatch(plist, pattern, %outVar%) != 0
}

ExecCmd(cmd, param1 := "", param2 := "", param3 := "", param4 := "")
{
	global hFTPConnection, InFile, LastError
	
	if cmd = ChangeDirectory
	{
		LittleSplashText("Going to`n" param1 "...")
		LastError = Couldn't go to "%param1%"!
		return FTP_SetCurrentDirectory(hFTPConnection, param1)
	}else If cmd = UploadScript
	{
		LittleSplashText("Uploading the script to`n" param1 "...")
		; Run the prologue for file uploading
		if !_CMDHelper_UploadPrologue(hFTPConnection, param1)
			return false
		; Upload the script.
		return _CMDHelper_Upload(hFTPConnection, InFile, param1)
	}else If cmd = UploadFile
	{
		LittleSplashText("Uploading file:`n" param1 "`nto:`n" param2 "...")
		; Run the prologue for file uploading
		if !_CMDHelper_UploadPrologue(hFTPConnection, param2)
			return false
		; Upload the script.
		return _CMDHelper_Upload(hFTPConnection, param1, param2)
	}else
		return false
}

_CMDHelper_UploadPrologue(hFTPConnection, path)
{
	global LastError
	; First parse it into a series of directories.
	StringSplit, DirArray, path, /
	if DirArray0 != 0
	{
		dirname =
		Loop, % DirArray0 - 1
		{
			dirname .= DirArray%A_Index% "/"
			
			; The classic cd test
			if !FTP_GetCurrentDirectory(hFTPConnection, TempDir)
			{
				LastError = Couldn't get current directory!
				return false
			}
			
			if !FTP_SetCurrentDirectory(hFTPConnection, SubStr(dirname, 1, StrLen(dirname)-1))
			{
				if !FTP_CreateDirectory(hFTPConnection, SubStr(dirname, 1, StrLen(dirname)-1)) ; ... so we create it.
				{
					LastError := "Couldn't create folder " SubStr(dirname, 1, StrLen(dirname)-1) "!"
					return false
				}
			}
			; The test was succesful, but now we have to return to the directory
			else if !FTP_SetCurrentDirectory(hFTPConnection, TempDir)
			{
				LastError = Couldn't go to "%TempDir%"!
				return false
			}
		}
	}
	
	return true
}

_CMDHelper_Upload(hFTPConnection, from, to)
{
	global LastError
	; Check the existance of the file
	if FTP_GetFileSize(hFTPConnection, to, 2) != -1
	  && !FTP_DeleteFile(hFTPConnection, to)
	{
		LastError = Couldn't delete file %to%!
		return false
	}
	; Upload the file.
	LastError = Couldn't upload "%from%" to "%to%"!
	return FTP_PutFile(hFTPConnection, from, to, 2)
}
