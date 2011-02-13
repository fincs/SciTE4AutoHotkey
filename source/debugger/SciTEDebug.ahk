;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SciTE4AutoHotkey v3 Script Debugger ;
; 1.2 - by fincs                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Ignore
#NoTrayIcon
#Include %A_ScriptDir%\SciControl.ahk
#Include %A_ScriptDir%\DBGp.ahk
;#Include %A_ScriptDir%\ObjHibernation.ahk
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
DetectHiddenWindows, On

ADM_SCITE := 0x1010
ATM_OFFSET := 0x1000
ATM_STARTDEBUG := ATM_OFFSET+0
ATM_STOPDEBUG  := ATM_OFFSET+1

if A_IsCompiled
{
	MsgBox, 16, SciTE4AutoHotkey Debugger, This program *must* be a uncompiled script!
	ExitApp
}

; Check if SciTE is running 
IfWinNotExist, ahk_class SciTEWindow
{
	MsgBox, 16, SciTE4AutoHotkey Debugger, Can't find a SciTE window!
	ExitApp
}

IsAttach = %1%
IsAttach := IsAttach = "/attach"

; Get the HWND of SciTE and its Scintilla control
scitehwnd := WinExist("")
ControlGet, scintillahwnd, Hwnd,, Scintilla1, ahk_id %scitehwnd%

/*
; Get the title and check if it's invalid
WinGetTitle, scitetitle, ahk_id %scitehwnd%
if !RegExMatch(scitetitle, "^(.+) [-*] SciTE4AutoHotkey", o)
{
	MsgBox, 16, SciTE4AutoHotkey Debugger, Bad SciTE window!
	ExitApp
}
if InStr(scitetitle, "?") && !A_IsUnicode
{
	MsgBox, 16, SciTE4AutoHotkey Debugger, A Unicode build of AutoHotkey_L is necessary!
	ExitApp
}
*/

; Get the COM SciTE object
ComObjError(false)
oSciTE := ComObjActive("SciTE4AHK.Application")
if A_LastError < 0
{
	MsgBox, 16, SciTE4AutoHotkey Debugger, Can't find SciTE COM object!
	ExitApp
}
ComObjError(true)

; Get the script to debug
szFilename := oSciTE.CurrentFile
IfInString, szFilename, ?
{
	MsgBox, 16, SciTE4AutoHotkey Debugger, A Unicode build of AutoHotkey_L is necessary!
	ExitApp
}

; Avoid the mistake of trying to debug the debugger (lol :P)
if (szFilename = A_ScriptFullPath)
{
	MsgBox, 48, SciTE4AutoHotkey Debugger, You can't debug the debugger or else bad things will happen :P
	ExitApp
}

; Check if the toolbar is running
ControlGet, toolbarhwnd, Hwnd,, AutoHotkeyGUI1, ahk_id %scitehwnd%
if toolbarhwnd =
{
	MsgBox, 16, SciTE4AutoHotkey Debugger, Can't find the toolbar window!
	ExitApp
}

; Check for the existence of the script
if IsAttach && !(AttachWin := WinExist(szFileName " ahk_class AutoHotkey"))
{
	MsgBox, 16, SciTE4AutoHotkey Debugger, Can't find running script! The debugger will exit.
	ExitApp
}

OnExit, GuiClose ; activate an OnExit trap
Gui, Show, Hide, SciTEDebugStub ; create a dummy GUI that SciTE will speak to

; Run SciTE
WinActivate, ahk_id %scitehwnd%
Hotkey, ^!z, CancelSciTE
Progress, m2 b zh0, Waiting for SciTE to connect...`nPress Ctrl-Alt-Z to cancel
SciTEConnected := false
OnMessage(ADM_SCITE, "SciTEMsgHandler")
SciTE_Connect()
Hotkey, ^!z, Off

AhkExecutable = %A_AhkPath%

if A_PtrSize = 8
	DbgBitIndicator := " (64-bit)"
else if Util_Is64bitOS()
	DbgBitIndicator := " (32-bit)"

DbgTitle := " - Debugging" DbgBitIndicator

; Run AutoHotkey_L and wait for it to connect
Progress, m2 b zh0, Waiting for AutoHotkey_L to connect...

; Initialize variables
Dbg_OnBreak := true
Dbg_HasStarted := false
Dbg_IsClosing := false
Dbg_ExitByDisconnect := false
Dbg_ExitByGuiClose := false
Dbg_WaitClose := false
Dbg_StackTraceWin := false
Dbg_VarWin := false
Dbg_StreamWin := false
Dbg_BkList := Object() ; TODO: load breakpoints from file
; Set the DBGp event handlers
DBGp_OnBegin("OnDebuggerConnection")
DBGp_OnBreak("OnDebuggerBreak")
DBGp_OnStream("OnDebuggerStream")
DBGp_OnEnd("OnDebuggerDisconnection")
; Now really run AutoHotkey_L and wait for it to connect
Dbg_Socket := DBGp_StartListening() ; start listening
SplitPath, szFilename,, szDir

IfNotExist, %AhkExecutable%
{
	MsgBox, 16, SciTE4AutoHotkey Debugger, Can't find AutoHotkey_L executable!
	ExitApp
}

if !IsAttach
	Run, "%AhkExecutable%" /Debug "%szFilename%", %szDir%,, Dbg_PID ; run AutoHotkey_L and store its process ID
else
{
	; Set the Last Found Window
	WinWait, ahk_id %AttachWin%
	; Get PID of the AutoHotkey_L window
	WinGet, Dbg_PID, PID
	; Tell AutoHotkey_L to debug
	PostMessage, DllCall("RegisterWindowMessage", "str", "AHK_ATTACH_DEBUGGER")
}
while (Dbg_AHKLExists := Util_ProcessExist(Dbg_PID)) && Dbg_Session = "" ; wait for AutoHotkey_L to connect or exit
	Sleep, 100 ; avoid smashing the CPU
DBGp_StopListening(Dbg_Socket) ; stop listening

if IsAttach
{
	Dbg_GetStack()
	SciTE_UpdateCurLineOfCode()
}

if !Dbg_AHKLExists
{
	Dbg_ExitByDisconnect := true ; tell our message handler to just return true without attempting to exit
	SciTE_Disconnect()
	;while !Dbg_WaitClose ; wait until we process that command
	;	Sleep, 100 ; avoid smashing the CPU
	OnMessage(ADM_SCITE, "") ; disable the SciTE message handler
	OnExit ; disable the OnExit trap
	ExitApp ; exit
}

if Dbg_Lang != AutoHotkey
{
	; Oops, wrong language, we've got to exit again
	Progress, Off
	MsgBox, 16, SciTE4AutoHotkey Debugger, Invalid language: %Dbg_Lang%.

	Dbg_ExitByDisconnect := true ; tell our message handler to just return true without attempting to exit
	SciTE_Disconnect()
	OnMessage(ADM_SCITE, "") ; disable the SciTE message handler
	OnExit ; disable the OnExit trap
	ExitApp ; exit
}

; Show the splash
SetTimer, ReadyToDebugSplash, -1

; Main loop
while !Dbg_IsClosing ; while the debugger is active
{
	Sleep, 100 ; do I really need to repeat the smashing comment over and over?
	IfWinNotExist, ahk_id %scitehwnd% ; oops, the user closed the SciTE window
	{
		if !Dbg_ExitByDisconnect
			DBGp_CloseDebugger(true) ; force closing
		break ; get off the loop
	}
	if !Util_ProcessExist(Dbg_PID)
	{
		Dbg_ExitByDisconnect := true
		SciTE_Disconnect()
		break
	}
}
if Dbg_ExitByGuiClose ; we've got to tell SciTE that we are leaving
{
	Dbg_ExitByDisconnect := true ; tell our message handler to just return true without attempting to exit
	SciTE_Disconnect()
}
OnMessage(ADM_SCITE, "") ; disable the SciTE message handler
OnExit ; disable the OnExit trap
;Hibernate(Dbg_BkList, szFilename ".dbk")
ExitApp

CancelSciTE:
OnExit
ExitApp

ReadyToDebugSplash:
; Just a lil' splash
Progress, m2 b zh0, Ready to debug
Sleep, 250 ; sleep 1/4 of a second
Progress, Off
return

; ====================
; | Toolbar commands |
; ====================

F5::
cmd_run:
if !Dbg_OnBreak
	return
SciTE_DeleteCurLineMarkers()
DBGp_CmdRun(Dbg_Session)
return

cmd_stop:
; Let the OnExit function take care of this
ExitApp

F10::
cmd_stepinto:
if !Dbg_OnBreak
	return
SciTE_DeleteCurLineMarkers()
DBGp_CmdStepInto(Dbg_Session)
return

F11::
cmd_stepover:
if !Dbg_OnBreak
	return
SciTE_DeleteCurLineMarkers()
DBGp_CmdStepOver(Dbg_Session)
return

+F11::
cmd_stepout:
if !Dbg_OnBreak
	return
SciTE_DeleteCurLineMarkers()
DBGp_CmdStepOut(Dbg_Session)
return

cmd_stacktrace:
;if !Dbg_OnBreak || !Dbg_HasStarted || Dbg_StackTraceWin
if !Dbg_OnBreak || Dbg_StackTraceWin
	return
ST_Create()
return

cmd_varlist:
if !Dbg_OnBreak || Dbg_VarWin
	return
VL_Create()
return

; =========================
; | SciTE message handler |
; =========================

SciTEMsgHandler(wParam, lParam, msg, hwnd)
{
	Critical
	global scintillahwnd, SciTEConnected, Dbg_ExitByDisconnect, Dbg_Session, Dbg_IsClosing, Dbg_WaitClose, Dbg_OnBreak
	
	; This code used to be a big if/else if block. I've changed it to this pseudo-switch structure.
	if IsLabel("_wP" wParam)
		goto _wP%wParam%
	else
		return false

_wP0: ; SciTE handshake
	SciTEConnected := true
	return true

_wP1: ; Breakpoint setting
	if !Dbg_OnBreak
		return true
	
	lParam ++ ; from 0-based to 1-based, that's what DBGp uses
	
	DBGp(Dbg_Session, "breakpoint_list", "", Dbg_BkList)
	file := "file:///" (uri := DBGp_EncodeFileURI(SciTE_GetFile()))
	
	RegExMatch(Dbg_BkList, "<breakpoint id=""(\d+)"" .+? state=""(.+?)"" filename=""" Util_EscapeRegEx(file) """ .+>", o)
	bkID := Trim(o1)
	bkStatus := Trim(o2)
	if bkStatus = enabled
	{
		DBGp(Dbg_Session, "breakpoint_remove", "-d " bkID)
		SciTE_BPSymbolRemove(lParam)
		Util_RemoveBk(uri, lParam)
	}else
	{
		DBGp(Dbg_Session, "breakpoint_set", "-t line -n " lParam " -f " file, Dbg_Response)
		IfInString, Dbg_Response, <error ; Check if AutoHotkey_L actually inserted the breakpoint.
			return false ; Let SciTE handle this situation...
		dom := loadXML(Dbg_Response)
		bkID := dom.selectSingleNode("/response/@id").text
		DBGp(Dbg_Session, "breakpoint_get", "-d " bkID, Dbg_Response)
		dom := loadXML(Dbg_Response)
		lParam := dom.selectSingleNode("/response/breakpoint[@id=" bkID "]/@lineno").text
		SciTE_BPSymbol(lParam)
		Util_AddBkToList(uri, lParam)
	}
	
	return true

_wP2: ; Variable inspection
	if !Dbg_OnBreak
	{
		MsgBox, 48, SciTE4AutoHotkey Debugger, You can't inspect a variable whilst the script is running!
		return false
	}
	
	Dbg_VarName := Trim(StrGet(lParam, "UTF-8"), " `t`r`n=")
	DBGp(Dbg_Session, "property_get", "-n " Dbg_VarName, Dbg_Response)
	dom := loadXML(Dbg_Response)
	
	Dbg_NewVarName := dom.selectSingleNode("/response/property/@name").text
	if Dbg_NewVarName = (invalid)
	{
		MsgBox, 48, SciTE4AutoHotkey Debugger, Invalid variable name: %Dbg_VarName%
		return false
	}
	if dom.selectSingleNode("/response/property/@type").text != "Object"
	{
		Dbg_VarIsReadOnly := dom.selectSingleNode("/response/property/@facet").text = "Builtin"
		Dbg_VarData := DBGp_Base64UTF8Decode(dom.selectSingleNode("/response/property").text)
		VE_Create(Dbg_VarName, Dbg_VarData, Dbg_VarIsReadOnly)
	}else
		OE_Create(dom)
	
	return true

_wP3: ; Command
	; Command
	p := "cmd_" StrGet(lParam, "UTF-8")
	if IsLabel(p)
		gosub %p%
	return true

_wP4: ; Hovering
	Dbg_VarName := Trim(SubStr(StrGet(lParam, "UTF-8"), 2), " `t`r`n")
	if Dbg_VarName =
		ToolTip
	else
	{
		DBGp(Dbg_Session, "property_get", "-m 200 -n " Dbg_VarName, Dbg_Response)
		dom := loadXML(Dbg_Response)
		check := dom.selectSingleNode("/response/property/@name").text
		if check = (invalid)
			return true
		if dom.selectSingleNode("/response/property/@type").text != "Object"
		{
			Dbg_VarData := DBGp_Base64UTF8Decode(dom.selectSingleNode("/response/property").text)
			Dbg_VarSize := dom.selectSingleNode("/response/property/@size").text
			if Dbg_VarSize > 200
				Dbg_VarData .= "..."
			ToolTip, %Dbg_VarName% = %Dbg_VarData%
		}else
			ToolTip, %Dbg_VarName% is an object
	}
	return true

_wP255: ; Disconnect
	if !Dbg_ExitByDisconnect
	{ ; this code is executed if the debugger is still present
		rc := DBGp_CloseDebugger()
		if !rc ; cancel the deattach if we are in run mode
			return false ; tell SciTE to not unload the debugging features
		Dbg_IsClosing := true
	}
	Dbg_WaitClose := true ; the main thread can finish waiting now
	Sleep, 10
	return true
}

; ================
; | Exit routine |
; ================

GuiClose:
IfWinExist, ahk_id %scitehwnd%
{ ; SciTE is present
	rc := DBGp_CloseDebugger() ; attempt to close the debugger
	if !rc ; if we failed...
		return ; ... just return and don't exit
	; (We succeeded)
	; As we might be the OnExit thread (uninterruptible)
	; we have to pass control to the main thread
	Dbg_ExitByGuiClose := true ; exit by GuiClose
	Dbg_IsClosing := true      ; we're closing, indeed
	return ; just return and let the main thread exit (we set some variables earlier)
}else ; SciTE was closed
	DBGp_CloseDebugger(true) ; force the debugger to close itself

OnMessage(ADM_SCITE, "") ; disable the SciTE message handler
OnExit ; disable the OnExit trap
ExitApp ; exit

; DBGp_CloseDebugger() - used to close the debugger
DBGp_CloseDebugger(force=0)
{
	Global
	if !force && !Dbg_OnBreak
	{
		MsgBox, 52, SciTE4AutoHotkey Debugger, The script is running. Stopping it would mean loss of data. Proceed?
		IfMsgBox, No
			return 0 ; fail
	}
	DBGp_OnEnd("") ; disable the DBGp OnEnd handler
	if Dbg_OnBreak
	{ ; if we're on a break we don't need to force the debugger to terminate
		DBGp(Dbg_Session, "stop")
		DBGp_CloseSession(Dbg_Session)
	}else ; nope, we're not on a break, kill the process
	{
		DBGp_CloseSession(Dbg_Session)
		Process, Close, %Dbg_PID%
	}
	return 1 ; success
}

; ===================
; | SciTE functions |
; ===================

SciTE_Connect()
{
	global
	SendMessage, 0x111, 1124, 0,, ahk_id %scitehwnd% ; call the "Debug with AutoHotkey_L" command
	while !SciTEConnected ; wait for SciTE to connect
		Sleep, 100 ; sleep a delay to avoid smashing the CPU
	SendMessage, ATM_STARTDEBUG, 0, 0,, ahk_id %toolbarhwnd% ; Enable the debugging buttons in the toolbar
	SetTimer, SciTEDebugTitle, On
}

SciTE_Disconnect()
{
	global
	SetTimer, SciTEDebugTitle, Off
	
	Dbg_WaitClose := false
	d := A_TickCount
	SendMessage, 0x111, 1125, 0,, ahk_id %scitehwnd% ; call the "Close active debugging connection" command
	while !Dbg_WaitClose && (A_TickCount - d) < 1000 ; wait until we process that command
		Sleep, 100 ; sleep a delay to avoid smashing the CPU
	SendMessage, ATM_STOPDEBUG, 0, 0,, ahk_id %toolbarhwnd% ; Disable the debugging buttons in the toolbar
	
	WinGetTitle, temp, ahk_id %scitehwnd%
	StringReplace, temp, temp, %DbgTitle%,, All
	WinSetTitle, ahk_id %scitehwnd%,, %temp%
}

SciTEDebugTitle:
ListLines, Off
if !_waiting
{
	WinGetTitle, SciTETitle, ahk_id %scitehwnd%
	IfNotInString, SciTETitle, %DbgTitle%
		WinSetTitle, ahk_id %scitehwnd%,, %SciTETitle%%DbgTitle%
}
ListLines, On
return

; =======================
; | DBGp Event Handlers |
; =======================

; OnDebuggerConnection() - fired when we receive a connection
OnDebuggerConnection(session, init)
{
	global
	Dbg_Session := session ; store the session ID in a global variable
	dom := loadXML(init)
	Dbg_Lang := dom.selectSingleNode("/init/@language").text
	DBGp(session, "property_set", "-n A_DebuggerName -- " DBGp_Base64UTF8Encode("SciTE4AutoHotkey"))
	DBGp(session, "feature_set", "-n max_children -v 100")
	DBGp(session, "feature_set", "-n max_data -v " (Dbg_MemLimit := 128*1024)) ; Requested by Lexikos
	DBGp(session, "feature_set", "-n max_depth -v 10")
	DBGp(session, "stdout", "-c 2")
	DBGp(session, "stderr", "-c 2")
	; Really nothing more to do
}

; OnDebuggerBreak() - fired when we receive an asyncronous response from the debugger - most of the time a break response.
OnDebuggerBreak(session, ByRef response)
{
	global Dbg_OnBreak, Dbg_Stack, Dbg_LocalContext, Dbg_GlobalContext, Dbg_VarWin
	dom := loadXML(response) ; load the XML document that the variable response is
	status := dom.selectSingleNode("/response/@status").text ; get the status
	if status = break
	{ ; this is a break response
		Dbg_OnBreak := true ; set the Dbg_OnBreak variable
		; Get info about the script currently running
		Dbg_GetStack()
		SciTE_UpdateCurLineOfCode()
		ST_Update()
		VL_Update()
	}
}

; OnDebuggerStream() - fired when we receive a stream packet.
OnDebuggerStream(session, ByRef stream)
{
	dom := loadXML(stream)
	type := dom.selectSingleNode("/stream/@type").text
	data := DBGp_Base64UTF8Decode(dom.selectSingleNode("/stream").text)
	SP_Output(type, data)
}

; OnDebuggerDisconnection() - fired when the debugger disconnects
OnDebuggerDisconnection(session)
{
	Global
	Critical

	Dbg_ExitByDisconnect := true ; tell our message handler to just return true without attempting to exit
	Dbg_ExitByGuiClose := true
	Dbg_IsClosing := true
	Dbg_OnBreak := true
	SetTimer, SciTEDebugTitle, Off
}

; ================================
; | Wrappers for those commands  |
; | that have to set Dbg_OnBreak |
; ================================

DBGp_CmdRun(a)
{
	Global
	ErrorLevel = 0
	Dbg_OnBreak := false
	Dbg_HasStarted := true
	DBGp(a, "run")
	VE_Close()
	OE_Close()
	ST_Clear()
}

DBGp_CmdStepInto(a)
{
	Global
	ErrorLevel = 0
	Dbg_OnBreak := false
	Dbg_HasStarted := true
	DBGp(a, "step_into")
	VE_Close()
	OE_Close()
	ST_Clear()
}

DBGp_CmdStepOver(a)
{
	Global
	ErrorLevel = 0
	Dbg_OnBreak := false
	Dbg_HasStarted := true
	DBGp(a, "step_over")
	VE_Close()
	OE_Close()
	ST_Clear()
}

DBGp_CmdStepOut(a)
{
	Global
	ErrorLevel = 0
	Dbg_OnBreak := false
	Dbg_HasStarted := true
	DBGp(a, "step_out")
	VE_Close()
	OE_Close()
	ST_Clear()
}

; ==============
; | Stacktrace |
; ==============

ST_Create()
{
	Global
	
	ST_Destroy()
	Dbg_StackTraceWin := true
	Gui 2:+ToolWindow +AlwaysOnTop +LabelSTGui +Resize +MinSize -MaximizeBox
	Gui 2:Add, ListView, x0 y0 w320 h240 +NoSortHdr -LV0x10 gST_Go vST_ListView, Script filename|Line|Stack entry
	ST_Update()
	Gui 2:Show, w320 h240, Callstack
}

ST_Clear()
{
	Global
	
	if !Dbg_StackTraceWin
		return
	
	Gui 2:Default
	LV_Delete()
}

ST_Update()
{
	Global
	if !Dbg_StackTraceWin
		return
	; These are useless, assigning a new object to a var frees the previous one
	;~ aStackWhere=
	;~ aStackFile=
	;~ aStackLine=
	aStackWhere := Util_UnpackNodes(Dbg_Stack.selectNodes("/response/stack/@where"))
	aStackFile  := Util_UnpackNodes(Dbg_Stack.selectNodes("/response/stack/@filename"))
	aStackLine  := Util_UnpackNodes(Dbg_Stack.selectNodes("/response/stack/@lineno"))
	Loop, % aStackFile._MaxIndex()
		aStackFile[A_Index] := DBGp_DecodeFileURI(aStackFile[A_Index])
	
	Gui 2:Default
	LV_Delete()
	Loop, % aStackWhere._MaxIndex()
		LV_Add("", ST_ShortName(aStackFile[A_Index]), aStackLine[A_Index], aStackWhere[A_Index])
	LV_ModifyCol(1, "AutoHdr")
	LV_ModifyCol(2, "AutoHdr")
	LV_ModifyCol(3, "AutoHdr")
}

ST_ShortName(a)
{
	SplitPath, a, b
	return b
}

ST_Destroy()
{
	global
	aStackWhere=
	aStackFile=
	aStackLine=
	Gui 2:Destroy
	Dbg_StackTraceWin := False
}

ST_Go:
if A_GuiEvent != DoubleClick
	return
SciTE_EnsureFileIsOpen(aStackFile[A_EventInfo])
SciTE_SetCurrentLine(aStackLine[A_EventInfo], 0)
WinActivate, ahk_id %scitehwnd%
return

STGuiClose:
ST_Destroy()
return

STGuiSize:
GuiControl, Move, ST_ListView, w%A_GuiWidth% h%A_GuiHeight%
return

Dbg_GetStack()
{
	Global
	if !Dbg_OnBreak
		return
	DBGp(Dbg_Session, "stack_get", "", Dbg_Stack := "")
	Dbg_Stack := loadXML(Dbg_Stack)
}

; =======================
; | Variable inspection |
; =======================

VE_Create(name, ByRef cont, readonly=0)
{
	Global
	Local VE_LF, VE_CRLF
	
	VE_Contents=
	if readonly
	{
		readonly = +Disabled
		readonly2 = +ReadOnly
	}else
	{
		readonly =
		readonly2 =
	}
	Gui 3:Destroy
	Gui 3:Default
	VE_BestChoice(VE_LF, VE_CRLF, cont)
	Gui 3:+ToolWindow +AlwaysOnTop +LabelVEGui +Resize +MinSize -MaximizeBox
	Gui 3:Add, Text, x8 y8 w80 h16 +Right, Variable name:
	Gui 3:Add, Text, x92 y8 w236 h16 +Border vVE_VarName, %name%
	Gui 3:Font, s9 bold, Courier New
	Gui 3:Add, Edit, x8 y32 w320 h240 vVE_Contents hwndVE_Cont_HWND +HScroll %readonly2%, % cont
	Gui 3:Font
	Gui 3:Add, Button, x94 y280 w80 h32 gVE_Update %readonly%, Update
	Gui 3:Add, Radio, x268 y280 w60 h16 Group vVE_LineEnd %VE_LF%, LF
	Gui 3:Add, Radio, x268 y296 w60 h16 %VE_CRLF%, CR+LF
	Gui 3:Show, w336 h320, Variable inspection
	
	; Don't select all the text when the window is shown
	SendMessage, 0xB1, 0, 0,, ahk_id %VE_Cont_HWND%
}

VE_BestChoice(ByRef lf, ByRef crlf, ByRef a)
{
	if !InStr(a, "`r`n")
	{
		lf = Checked
		crlf =
	}else
	{
		lf =
		crlf = Checked
	}
}

VE_Update:
GuiControlGet, VE_VarName,, VE_VarName
Gui, Submit
VE_Close()
if VE_LineEnd = 2
	StringReplace, VE_Contents, VE_Contents, `n, `r`n, All
DBGp(Dbg_Session, "property_set", "-n " VE_VarName " -- " (VE_C2 := DBGp_Base64UTF8Encode(VE_Contents)))
VarSetCapacity(VE_Contents, 0)
VL_Update()
if InStr(VE_VarName, ".") || InStr("VE_VarName", "[")
	OE_Update(VE_C2)
VarSetCapacity(VE_C2, 0)
return

VEGuiClose:
VE_Close()
return

VE_Close()
{
	Gui 3:Destroy
}

VEGuiSize:
VE_neww := A_GuiWidth - 16
VE_newh := A_GuiHeight - 80
VE_initx := A_GuiWidth - 68
VE_inity := VE_newh + 40
GuiControl, Move, VE_Contents, w%VE_neww% h%VE_newh%
GuiControl, Move, Update, % "x" (8+Floor((A_GuiWidth-84)/2)-40) " y" VE_inity
GuiControl, MoveDraw, LF, x%VE_initx% y%VE_inity%
GuiControl, MoveDraw, CR+LF, % "x" VE_initx " y" (VE_inity+16)
return

; =================
; | Variable list |
; =================

VL_Create()
{
	Global
	
	VL_Destroy()
	Dbg_VarWin := true
	Gui 4:+ToolWindow +AlwaysOnTop +LabelVLGui +Resize +MinSize -MaximizeBox
	Gui 4:Add, ListView, x0 y0 w320 h240 gVL_Inspect vVL_Listview, Scope|Variable name|Contents (partial)
	VL_Update()
	Gui 4:Show, w320 h240, Variable list
}

VL_Update()
{
	Global
	if !Dbg_VarWin
		return
	; read
	ToolTip, Updating variable list...
	Dbg_GetContexts()
	VL_Local := Util_UnpackNodes(Dbg_LocalContext.selectNodes("/response/property/@name"))
	VL_Global := Util_UnpackNodes(Dbg_GlobalContext.selectNodes("/response/property/@name"))
	VL_NVars := VL_Local._MaxIndex() + VL_Global._MaxIndex()
	; Requested by Lexikos:
	;~ if VL_NVars > 100
	;~ {
		;~ MsgBox, 36, SciTE4AutoHotkey Debugger, There are %VL_NVars% variables.`nUpdating the variable list window may take some time. Continue?
		;~ IfMsgBox, No
			;~ return
	;~ }
	VL_LocalCont := Util_UnpackContNodes(Dbg_LocalContext.selectNodes("/response/property"))
	VL_GlobalCont := Util_UnpackContNodes(Dbg_GlobalContext.selectNodes("/response/property"))
	; update
	Gui 4:Default
	LV_Delete()
	Loop, % VL_Local._MaxIndex()
		LV_Add("", "Local", VL_Local[A_Index], VL_LocalCont[A_Index])
	Loop, % VL_Global._MaxIndex()
		LV_Add("", "Global", VL_Global[A_Index], VL_GlobalCont[A_Index])
	ToolTip
}

VL_ShortCont(a)
{
	if pos := InStr(a, "`n")
		a := Trim(SubStr(a, 1, pos-1), "`r") "..."
	if StrLen(a) = 65
		a .= "..."
	return a
}

VL_Destroy()
{
	Global
	Gui 4:Destroy
	Dbg_VarWin := false
}

VL_Inspect:
if !Dbg_OnBreak
{
	MsgBox, 48, SciTE4AutoHotkey Debugger, You can't inspect a variable while the script is running!
	return
}
if A_GuiEvent != DoubleClick
	return
LV_GetText(VL_Scope, A_EventInfo, 1)
VL_Scope := VL_Scope != "Local"
LV_GetText(VL_VarName, A_EventInfo, 2)
DBGp(Dbg_Session, "property_get", "-c " VL_Scope " -n " VL_VarName, Dbg_Response)
dom := loadXML(Dbg_Response)

if dom.selectSingleNode("/response/property/@type").text != "Object"
{
	VL_VarIsReadOnly := dom.selectSingleNode("/response/property/@facet").text = "Builtin"
	VL_VarData := DBGp_Base64UTF8Decode(dom.selectSingleNode("/response/property").text)
	VE_Create(VL_VarName, VL_VarData, VL_VarIsReadOnly)
}else
	OE_Create(dom)
return

VLGuiClose:
VL_Destroy()
return

VLGuiSize:
GuiControl, Move, VL_Listview, w%A_GuiWidth% h%A_GuiHeight%
return

Dbg_GetContexts()
{
	Global
	
	if !Dbg_OnBreak
		return
	DBGp(Dbg_Session, "feature_set", "-n max_data -v 65")
	DBGp(Dbg_Session, "context_get", "-c 0", Dbg_LocalContext)
	DBGp(Dbg_Session, "context_get", "-c 1", Dbg_GlobalContext)
	DBGp(Dbg_Session, "feature_set", "-n max_data -v " Dbg_MemLimit) ; Requested by Lexikos
	Dbg_LocalContext  := loadXML(Dbg_LocalContext)
	Dbg_GlobalContext := loadXML(Dbg_GlobalContext)
}

; =================
; | Stream window |
; =================

SP_Output(stream, data)
{
	global Dbg_StreamWin, SP_Console, SP_ConHWND
	
	if !Dbg_StreamWin
	{
		Gui 5:Font, s9 bold, Courier New
		Gui 5:+ToolWindow +AlwaysOnTop +LabelSPGui +Resize +MinSize -MaximizeBox
		Gui 5:Add, Edit, x0 y0 w320 h240 +ReadOnly vSP_Console hwndSP_ConHWND
		Gui 5:Show, w320 h240, Stream viewer
		Dbg_StreamWin := true
	}
	
	GuiControlGet, ctext, 5:, SP_Console
	StringReplace, data, data, `r`n, `n, All
	IfNotInString, data, `n
		ctext .= "<" stream "> " data "`n"
	else
		ctext .= "<" stream ">:`n" data "`n"
	ctext := SubStr(ctext, -1023) ; Limit the output to 1 KB of data
	GuiControl 5:, SP_Console, % ctext
	SendMessage, 0xB6, 0, 999999,, ahk_id %SP_ConHWND%
}

SPGuiSize:
GuiControl, Move, SP_Console, w%A_GuiWidth% h%A_GuiHeight%
return

SPGuiClose:
Gui 5:Destroy
Dbg_StreamWin := false
return

; ============================
; | Object inspection window |
; ============================

OE_Create(ByRef objdom)
{
	Global
	local root
	OE_Data := Object()

	Gui 6:Destroy
	Gui 6:Default
	Gui 6:+ToolWindow +AlwaysOnTop +LabelOEGui +Resize +MinSize -MaximizeBox
	Gui 6:Add, TreeView, x0 y0 w336 h320 vOE_Tree gOE_Click
	root := TV_Add(objdom.selectSingleNode("/response/property/@name").text)
	OE_Add(objdom.selectNodes("/response/property[1]/property"), root)
	TV_Modify(root, "Expand")
	Gui 6:Show, w336 h320, Object inspection
}

OE_Update(ByRef cont)
{
	global OE_TempNode
	OE_TempNode.text := cont
}

OE_Add(nodes, tnode)
{
	Global OE_Data
	Loop, % nodes.length
	{
		node := nodes.item[A_Index-1]
		ttnode := TV_Add(node.attributes.getNamedItem("name").text, tnode)
		OE_Data[ttnode] := node
		OE_Add(node.selectNodes("property"), ttnode)
	}
}

OE_Preview(node)
{
	; TODO
}

OE_Close()
{
	Global OE_Data
	Gui 6:Destroy
	OE_Data := ""
}

OE_Click:
if A_GuiEvent != DoubleClick
	return
fullname := (OE_TempNode := OE_Data[A_EventInfo]).attributes.getNamedItem("fullname").text
if fullname && OE_TempNode.attributes.getNamedItem("type").text != "object"
{
	cont := DBGp_Base64UTF8Decode(OE_TempNode.text)
	VE_Create(fullname, cont)
}
return

OEGuiSize:
GuiControl, Move, OE_Tree, w%A_GuiWidth% h%A_GuiHeight%
return

OEGuiClose:
OE_Close()
return

; =====================
; | SciTE interaction |
; =====================

SciTE_UpdateCurLineOfCode()
{
	global Dbg_Stack
	
	cLine := Dbg_Stack.selectSingleNode("/response/stack[1]/@lineno").text
	cFNameURI := Dbg_Stack.selectSingleNode("/response/stack[1]/@filename").text
	cFName := DBGp_DecodeFileURI(cFNameURI)
	SciTE_EnsureFileIsOpen(cFName)
	SciTE_SetCurrentLine(cLine)
}

SciTE_RedrawLine(hwnd, line)
{
	Global
	
	IfWinNotActive, ahk_id %scitehwnd%
		WinActivate
	
	DllCall("SendMessage", "ptr", hwnd, "uint", SCI_ENSUREVISIBLEENFORCEPOLICY, "int", line, "int", 0)
	DllCall("SendMessage", "ptr", hwnd, "uint", SCI_GOTOLINE, "int", line, "int", 0)
}

SciTE_EnsureFileIsOpen(fname)
{
	global _waiting, oSciTE
	if SciTE_GetFile() != fname
	{
		; Check if the file is already opened in another tab
		tabs := oSciTE.Tabs.Array
		Loop, % tabs.MaxIndex() + 1
			if tabs[A_Index - 1] = fname
			{
				needtab := A_Index - 1
				break
			}
		if needtab
			oSciTE.SwitchToTab(needtab)
		else
			; Open the file
			Run, "%A_ScriptDir%\..\SciTE.exe" "%fname%"
		
		; Wait for SciTE...
		t := A_TitleMatchMode
		SetTitleMatchMode, RegEx
		_waiting := true
		WinWait, % "^" Util_EscapeRegEx(fname) " [-*] SciTE4AutoHotkey"
		_waiting := false
		SetTitleMatchMode, %t%
	}
}

SciTE_GetFile()
{
	global scitehwnd
	
	WinGetTitle, scititle, ahk_id %scitehwnd%
	if !RegExMatch(scititle, "^(.+) [-*] SciTE4AutoHotkey", o)
		return
	
	return Trim(o1)
	
	;global oSciTE
	
	;return oSciTE.CurrentFile
}

SciTE_SetCurrentLine(line, mode=1) ; show the current line markers in SciTE
{
	Global
	line--
	if mode
	{
		; Delete current markers
		SciTE_DeleteCurLineMarkers()
		; Add markers
		DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERADD, "int", line, "int", 11)
		DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERADD, "int", line, "int", 12)
	}
	; Refresh the Scintilla control
	SciTE_RedrawLine(scintillahwnd, line)
}

SciTE_DeleteCurLineMarkers() ; delete the current line markers in SciTE
{
	Global
	line--
	; Delete current markers
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERDELETEALL, "int", 11, "int", 0)
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERDELETEALL, "int", 12, "int", 0)
}

SciTE_BPSymbol(line) ; show the current line markers in SciTE
{
	Global
	line--
	; Add markers
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERADD, "int", line, "int", 10)
}

SciTE_BPSymbolRemove(line) ; show the current line markers in SciTE
{
	Global
	line--
	; Add markers
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERDELETE, "int", line, "int", 10)
}

; ===========
; | Sandbox |
; ===========

Util_Is64bitOS()
{
	return (A_PtrSize = 8) || (DllCall("IsWow64Process", "ptr", DllCall("GetCurrentProcess"), "int*", isWow64) && isWow64)
}

Util_UnpackNodes(nodes)
{
	o := Object()
	Loop, % nodes.length
		o._Insert(nodes.item[A_Index-1].text)
	return o
}

Util_UnpackContNodes(nodes)
{
	o := Object()
	Loop, % nodes.length
		node := nodes.item[A_Index-1]
		,o._Insert(node.attributes.getNamedItem("type").text != "object" ? VL_ShortCont(DBGp_Base64UTF8Decode(node.text)) : "(Object)")
	return o
}

Util_EscapeRegEx(str)
{
	static tab := "\.*?+[{|()^$"
	Loop, % StrLen(tab)
		StringReplace, str, str, % SubStr(tab, A_Index, 1), % "\" SubStr(tab, A_Index, 1), All
	return str
}

Util_ProcessExist(a)
{
	t := ErrorLevel
	Process, Exist, %a%
	r := ErrorLevel
	ErrorLevel := t
	return r
}

Util_AddBkToList(uri, line, cond="")
{
	global Dbg_BkList
	Dbg_BkList[uri, line] := cond
	;IsObject(Dbg_BkList[uri]) ? "" : (Dbg_BkList[uri] := Object())
	;,Dbg_BkList[uri][line] := cond
}

Util_RemoveBk(uri, line)
{
	global Dbg_BkList
	Dbg_BkList[url]._Remove(line)
}

loadXML(ByRef data)
{
	o := ComObjCreate("MSXML2.DOMDocument")
	o.async := false
	o.setProperty("SelectionLanguage", "XPath")
	o.loadXML(data)
	return o
}
