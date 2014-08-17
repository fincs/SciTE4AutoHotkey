;
; SciTE4AutoHotkey Script Debugger
;
;TillaGoto.iIncludeMode = 0x10111111

;{ Auto-Execute Section

#SingleInstance Ignore
#NoTrayIcon
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
DetectHiddenWindows, On

global g_appTitle := "SciTE4AutoHotkey Debugger"
ADM_SCITE := 0x1010
ATM_OFFSET := 0x1000
ATM_STARTDEBUG := ATM_OFFSET+0
ATM_STOPDEBUG  := ATM_OFFSET+1
ATM_DRUNTOGGLE := ATM_OFFSET+4
SciControl_InitConstants()

if A_IsCompiled
{
	MsgBox, 16, %g_appTitle%, This program *must* be a uncompiled script!
	ExitApp
}

if 0 = 0
{
	MsgBox, 16, %g_appTitle%, You mustn't run this script directly!
	ExitApp
}

; Get the COM SciTE object
oSciTE := GetSciTEInstance()
if !oSciTE
{
	MsgBox, 16, %g_appTitle%, SciTE must be running!
	ExitApp
}

global dbgTextFont := oSciTE.ResolveProp("default.text.font")
dbgAddr := oSciTE.ResolveProp("ahk.debugger.address")
dbgPort := oSciTE.ResolveProp("ahk.debugger.port")+0
dbgCaptureStreams := !!oSciTE.ResolveProp("ahk.debugger.capture.streams")

global dbgMaxChildren := oSciTE.ResolveProp("ahk.debugger.max.obj.children")+0
global dbgMaxData := oSciTE.ResolveProp("ahk.debugger.max.data")+0

if 1 = /attach
	bIsAttach := true
else
{
	AhkExecutable = %1%
	IfNotExist, %AhkExecutable%
	{
		MsgBox, 16, %g_appTitle%, The AutoHotkey executable doesn't exist!
		ExitApp
	}

	Loop, %AhkExecutable%
	{
		AhkExecutable := A_LoopFileLongPath
		break
	}
	
	ahkType := AHKType(AhkExecutable)
	
	if ahkType = FAIL
	{
		MsgBox, 16, %g_appTitle%, Invalid AutoHotkey executable!
		ExitApp
	}
	
	if ahkType = Legacy
	{
		MsgBox, 16, %g_appTitle%, Debugging is not supported in legacy versions of AutoHotkey (prior to v1.1).
		ExitApp
	}
}

; Get the HWND of SciTE and its Scintilla control
scitehwnd := oSciTE.SciTEHandle
ControlGet, scintillahwnd, Hwnd,, Scintilla1, ahk_id %scitehwnd%

; Get the SciTE path
SciTEPath := oSciTE.SciTEDir

; Get the script to debug
szFilename := !bIsAttach ? oSciTE.CurrentFile : SelectAttachScript(AttachWin, Dbg_PID)
if szFilename =
	ExitApp

; Do not allow debugging neither the toolbar nor the debugger itself
if InStr(szFilename, SciTEPath "\toolbar\") = 1 || (szFilename = A_ScriptFullPath)
{
	MsgBox, 48, %g_appTitle%, Debuging SciTE4AutoHotkey's debugger and toolbar scripts is not supported.
	ExitApp
}

; Check if the toolbar is running
ControlGet, toolbarhwnd, Hwnd,, AutoHotkeyGUI1, ahk_id %scitehwnd%
if toolbarhwnd =
{
	MsgBox, 16, %g_appTitle%, Can't find the toolbar window!
	ExitApp
}

OnExit, GuiClose ; activate an OnExit trap
Gui, Show, Hide, SciTEDebugStub ; create a dummy GUI that SciTE will speak to

; Run SciTE
WinActivate, ahk_id %scitehwnd%
Hotkey, ^!z, CancelSciTE
ToolTip, Waiting for SciTE to connect...`nPress Ctrl-Alt-Z to cancel
SciTEConnected := false
OnMessage(ADM_SCITE, "SciTEMsgHandler")
SciTE_Connect()
Hotkey, ^!z, Off

; Run AutoHotkey and wait for it to connect
ToolTip, Waiting for AutoHotkey to connect...

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
Dbg_BkList := []

; Set the DBGp event handlers
DBGp_OnBegin("OnDebuggerConnection")
DBGp_OnBreak("OnDebuggerBreak")
DBGp_OnStream("OnDebuggerStream")
DBGp_OnEnd("OnDebuggerDisconnection")

; Now really run AutoHotkey and wait for it to connect
Dbg_Socket := DBGp_StartListening(dbgAddr, dbgPort) ; start listening
SplitPath, szFilename,, szDir

if !bIsAttach
	Run, "%AhkExecutable%" /Debug=%dbgAddr%:%dbgPort% "%szFilename%", %szDir%,, Dbg_PID ; run AutoHotkey and store its process ID
else
{
	; Set the Last Found Window
	WinWait, ahk_id %AttachWin%
	; Get PID of the AutoHotkey window
	WinGet, Dbg_PID, PID
	; Tell AutoHotkey to debug
	PostMessage, DllCall("RegisterWindowMessage", "str", "AHK_ATTACH_DEBUGGER"), DllCall("ws2_32\inet_addr", "astr", dbgAddr), dbgPort
}

while (Dbg_AHKExists := Util_ProcessExist(Dbg_PID)) && Dbg_Session = "" ; wait for AutoHotkey to connect or exit
	Sleep, 100 ; avoid smashing the CPU
DBGp_StopListening(Dbg_Socket) ; stop listening

if bIsAttach
{
	Dbg_GetStack()
	SciTE_UpdateCurLineOfCode()
}

if !Dbg_AHKExists
{
	Dbg_ExitByDisconnect := true ; tell our message handler to just return true without attempting to exit
	SciTE_Disconnect()
	OnMessage(ADM_SCITE, "") ; disable the SciTE message handler
	OnExit ; disable the OnExit trap
	ExitApp ; exit
}

if Dbg_Lang != AutoHotkey
{
	; Oops, wrong language, we've got to exit again
	ToolTip
	MsgBox, 16, %g_appTitle%, Invalid language: %Dbg_Lang%.

	Dbg_ExitByDisconnect := true ; tell our message handler to just return true without attempting to exit
	SciTE_Disconnect()
	OnMessage(ADM_SCITE, "") ; disable the SciTE message handler
	OnExit ; disable the OnExit trap
	ExitApp ; exit
}

; Show the splash
ToolTip, Ready to debug!
SetTimer, RemoveTooltip, -250

; Reset saved breakpoints
PostMessage, 0x111, 1135, 0,, ahk_id %scitehwnd%

; Main loop
while !Dbg_IsClosing ; while the debugger is active
{
	Sleep, 100 ; do I really need to repeat the smashing comment over and over?
	IfWinNotExist, ahk_id %scitehwnd% ; oops, the user closed the SciTE window
	{
		if !Dbg_ExitByDisconnect
			DBGp_CloseDebugger(true) ; force closing
		break
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
ExitApp

CancelSciTE:
OnExit
ExitApp

RemoveTooltip:
ToolTip
return

;}

;{ Script Attaching

SelectAttachScript(ByRef outwin, ByRef outpid)
{
	global SciTEPath
	
	oldTM := A_TitleMatchMode, oldHW := A_DetectHiddenWindows
	SetTitleMatchMode, 2
	DetectHiddenWindows, On
	
	WinGet, w, List, - AutoHotkey ahk_class AutoHotkey,, %A_ScriptFullPath%
	
	Gui, +LabelAttGui +ToolWindow +AlwaysOnTop
	Gui, Add, ListView, x0 y0 w640 h240 +NoSortHdr -LV0x10 gAttGuiSelect, HWND|Name
	
	i := 0
	Loop, % w
	{
		hwnd := w%A_Index%
		WinGetTitle, ov, ahk_id %hwnd%
		if InStr(ov, SciTEPath) ; Do not allow debugging SciTE4AutoHotkey itself
			continue
		if !RegExMatch(ov, "v([0-9.]+)(-\S+)?$", q) ; Make sure it has a correctly-formed version number
			continue
		if q1 < 1.1.00.00 ; Make sure it is NOT a legacy AutoHotkey version
			continue
		LV_Add("", hwnd, ov)
		i ++
	}
	
	if i = 0
	{
		MsgBox, 48, %g_appTitle%, There are no currently running debuggable AutoHotkey scripts!
		return ""
	}
	
	LV_ModifyCol(1, "AutoHdr")
	LV_ModifyCol(2, "AutoHdr")
	
	Gui, Show, w640 h240, Select running script to debug
	
	global attSelection, attWin
	while !attSelection
		Sleep, 100
	
	if attSelection = -1
		filename := "", outwin := "", outpid := ""
	else
	{
		LV_GetText(filename, attSelection, 2)
		LV_GetText(outwin, attSelection, 1)
		WinGet, outpid, PID, ahk_id %outwin%
	}
	
	Gui, Destroy
	
	DetectHiddenWindows, %oldTM%
	SetTitleMatchMode, %oldTM%
	return filename
}

AttGuiClose:
attSelection := -1
return

AttGuiSelect:
if A_GuiEvent != DoubleClick
	return
attSelection := A_EventInfo
return

;}

;{ Toolbar Commands

F5::
if Dbg_OnBreak
	goto cmd_run
else
	goto cmd_pause

cmd_run:
if !Dbg_OnBreak
	return
SciTE_DeleteCurLineMarkers()
DBGp_CmdRun(Dbg_Session)
return

cmd_pause:
if !bIsAsync
{
	MsgBox, 48, %g_appTitle%, Script pausing is not supported in this AutoHotkey version!
	return
}

; We want to send AutoHotkey a break command.
; It must be sent asynchronously because we want to discard its
; response as fast as possible, otherwise OnBreak misbehaves due
; to the use of synchronous commands.
Dbg_Session.Send("break", "", Func("DummyCallback"))
return

DummyCallback(session, ByRef response)
{
}

cmd_stop:
if bIsAttach
{
	MsgBox, 35, %g_appTitle%, Do you wish to stop the script (YES) or just stop debugging (NO)?
	IfMsgBox, Cancel
		return
	IfMsgBox, No
	{
		Dbg_Session.property_set("-n A_DebuggerName --")
		Dbg_Session.detach()
		return
	}
}

; Let the OnExit handler take care of this
OnExit
goto GuiClose

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
if Dbg_StackTraceWin
	return
if !Dbg_OnBreak
{
	if !bIsAsync
		return
	Dbg_GetStack()
}
ST_Create()
return

cmd_varlist:
if Dbg_VarWin || (!Dbg_OnBreak && !bIsAsync)
	return
VL_Create()
return

;}

;{ SciTE Message Handler

SciTEMsgHandler(wParam, lParam, msg, hwnd)
{
	Critical
	global scintillahwnd, SciTEConnected, Dbg_ExitByDisconnect, Dbg_Session, Dbg_IsClosing, Dbg_WaitClose, Dbg_OnBreak, bIsAsync, bInitBk, InitBkList
	
	; This code used to be a big if/else if block. I've changed it to this pseudo-switch structure.
	if IsLabel("_wP" wParam)
		goto _wP%wParam%
	else
		return false

_wP0: ; SciTE handshake
	SciTEConnected := true
	return true

_wP1: ; Breakpoint setting
	if !bIsAsync && !Dbg_OnBreak
		return true
	
	if !bInitBk
	{
		; We need to launch the breakpoint setting code in a separate thread due to usage of COM
		global _temp := lParam + 1 ; convert line number from 0-based to 1-based
		SetTimer, SetBreakpointHelper, -10
	} else
		InitBkList.Insert(lParam + 1)
	return true
	
_wP2: ; Variable inspection
	if !bIsAsync && !Dbg_OnBreak
	{
		MsgBox, 48, %g_appTitle%, You can't inspect a variable whilst the script is running!
		return false
	}
	
	Dbg_VarName := Trim(StrGet(lParam, "UTF-8"), " `t`r`n=")
	
	; Allow retrieving immediate children for object values
	SetEnableChildren(true)
	Dbg_Session.property_get("-n " Dbg_VarName, Dbg_Response)
	SetEnableChildren(false)
	dom := loadXML(Dbg_Response)
	
	Dbg_NewVarName := dom.selectSingleNode("/response/property/@name").text
	if Dbg_NewVarName = (invalid)
	{
		MsgBox, 48, %g_appTitle%, Invalid variable name: %Dbg_VarName%
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
	static _ := [ "run", "stop", "pause", "stepinto", "stepover", "stepout", "stacktrace", "varlist" ]
	p := "cmd_" _[lParam]
	if IsLabel(p)
		gosub %p%
	return true

_wP4: ; Hovering
	if !bIsAsync && !Dbg_OnBreak
		return true
	
	Dbg_VarName := Trim(StrGet(lParam, "UTF-8"), " `t`r`n")
	if Dbg_VarName =
		ToolTip
	else
	{
		Dbg_Session.property_get("-m 200 -n " Dbg_VarName, Dbg_Response)
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
	
_wP5: ; Breakpoint initialization
	bInitBk := lParam
	if !bInitBk
		SetTimer, InitBreakpoints, -10
	else
		InitBkList := []
	return true

_wP255: ; Disconnect
	if !Dbg_ExitByDisconnect
	{
		; This code is executed if the debugger is still present
		rc := DBGp_CloseDebugger()
		if !rc ; cancel the deattach if we are in run mode
			return false ; tell SciTE to not unload the debugging features
		Dbg_IsClosing := true
	}
	Dbg_WaitClose := true ; the main thread can finish waiting now
	Sleep, 10
	return true
}

SetEnableChildren(v)
{
	global Dbg_Session
	if v
	{
		Dbg_Session.feature_set("-n max_children -v " dbgMaxChildren)
		Dbg_Session.feature_set("-n max_depth -v 1")
	}else
	{
		Dbg_Session.feature_set("-n max_children -v 0")
		Dbg_Session.feature_set("-n max_depth -v 0")
	}
}

SetBreakpointHelper:
SetBreakpoint(_temp)
return

InitBreakpoints:
for _, line in InitBkList
	SetBreakpoint(line)
InitBkList := ""
return

SetBreakpoint(lParam)
{
	global Dbg_Session, bInBkProcess
	
	uri := DBGp_EncodeFileURI(file := SciTE_GetFile())
	bk := Util_GetBk(uri, lParam)
	if bk
	{
		Dbg_Session.breakpoint_remove("-d " bk.id)
		SciTE_BPSymbolRemove(lParam)
		Util_RemoveBk(uri, lParam)
	}else
	{
		bInBkProcess := true
		Dbg_Session.breakpoint_set("-t line -n " lParam " -f " uri, Dbg_Response)
		IfInString, Dbg_Response, <error ; Check if AutoHotkey actually inserted the breakpoint.
		{
			bInBkProcess := false
			return
		}
		dom := loadXML(Dbg_Response)
		bkID := dom.selectSingleNode("/response/@id").text
		Dbg_Session.breakpoint_get("-d " bkID, Dbg_Response)
		dom := loadXML(Dbg_Response)
		lParam := dom.selectSingleNode("/response/breakpoint[@id=" bkID "]/@lineno").text
		SciTE_BPSymbol(lParam)
		Util_AddBkToList(uri, lParam, bkID)
		bInBkProcess := false
	}
}

;}

;{ Exit Routine

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
DBGp_CloseDebugger(force := 0)
{
	global
	if !bIsAsync && !force && !Dbg_OnBreak
	{
		MsgBox, 52, %g_appTitle%, The script is running. Stopping it would mean loss of data. Proceed?
		IfMsgBox, No
			return 0 ; fail
	}
	DBGp_OnEnd("") ; disable the DBGp OnEnd handler
	if bIsAsync || Dbg_OnBreak
	{
		; If we're on a break or the debugger is async we don't need to force the debugger to terminate
		Dbg_Session.stop()
		Dbg_Session.Close()
	}else ; nope, we're not on a break, kill the process
	{
		Dbg_Session.Close()
		Process, Close, %Dbg_PID%
	}
	Dbg_Session := ""
	return 1 ; success
}

;}

;{ SciTE Kitchen Sink Functions

SciTE_Connect()
{
	global
	SendMessage, 0x111, 1124, 0,, ahk_id %scitehwnd% ; call the internal "Debug with AutoHotkey" command
	while !SciTEConnected ; wait for SciTE to connect
		Sleep, 100 ; sleep a delay to avoid smashing the CPU
	SendMessage, ATM_STARTDEBUG, 0, 0,, ahk_id %toolbarhwnd% ; Enable the debugging buttons in the toolbar
	SendMessage, 1026, 1, 0,, ahk_id %scitehwnd% ; Enable [Debugging] mark in SciTE's window title
}

SciTE_ToggleRunButton()
{
	global
	SendMessage, ATM_DRUNTOGGLE, 0, 0,, ahk_id %toolbarhwnd%
}

SciTE_Disconnect()
{
	global
	
	Dbg_WaitClose := false
	d := A_TickCount
	SendMessage, 0x111, 1125, 0,, ahk_id %scitehwnd% ; call the "Close active debugging connection" command
	SendMessage, 1026, 0, 0,, ahk_id %scitehwnd% ; call the "Delete debugging title" command
	while !Dbg_WaitClose && (A_TickCount - d) < 1000 ; wait until we process that command
		Sleep, 100 ; sleep a delay to avoid smashing the CPU
	SendMessage, ATM_STOPDEBUG, 0, 0,, ahk_id %toolbarhwnd% ; Disable [Debugging] mark in SciTE's window title
}

;}

;{ DBGp Event Handlers

; OnDebuggerConnection() - fired when we receive a connection.
OnDebuggerConnection(session, init)
{
	global
	local response, dom
	if bIsAttach
		szFilename := session.File
	Dbg_Session := session ; store the session ID in a global variable
	dom := loadXML(init)
	Dbg_Lang := dom.selectSingleNode("/init/@language").text
	session.property_set("-n A_DebuggerName -- " DBGp_Base64UTF8Encode("SciTE4AutoHotkey"))
	session.feature_set("-n max_data -v " dbgMaxData)
	SetEnableChildren(false)
	if dbgCaptureStreams
	{
		session.stdout("-c 2")
		session.stderr("-c 2")
	}
	session.feature_get("-n supports_async", response)
	bIsAsync := !!InStr(response, ">1<")
	; Really nothing more to do
}

; OnDebuggerBreak() - fired when we receive an asynchronous response from the debugger (including break responses).
OnDebuggerBreak(session, ByRef response)
{
	global Dbg_OnBreak, Dbg_Stack, Dbg_LocalContext, Dbg_GlobalContext, Dbg_VarWin, bInBkProcess, _tempResponse
	if bInBkProcess
	{
		; A breakpoint was hit while the script running and the SciTE OnMessage thread is
		; still running. In order to avoid crashing, we must delay this function's processing
		; until the OnMessage thread is finished.
		_tempResponse := response
		SetTimer, TryHandlingBreakAgain, -100
		return
	}
	dom := loadXML(response) ; load the XML document that the variable response is
	status := dom.selectSingleNode("/response/@status").text ; get the status
	if status = break
	{ ; this is a break response
		SciTE_ToggleRunButton()
		Dbg_OnBreak := true ; set the Dbg_OnBreak variable
		; Get info about the script currently running
		Dbg_GetStack()
		SciTE_UpdateCurLineOfCode()
		ST_Update()
		VL_Update()
	}
}

TryHandlingBreakAgain:
OnDebuggerBreak(Dbg_Session, _tempResponse)
return

; OnDebuggerStream() - fired when we receive a stream packet.
OnDebuggerStream(session, ByRef stream)
{
	dom := loadXML(stream)
	type := dom.selectSingleNode("/stream/@type").text
	data := DBGp_Base64UTF8Decode(dom.selectSingleNode("/stream").text)
	SP_Output(type, data)
}

; OnDebuggerDisconnection() - fired when the debugger disconnects.
OnDebuggerDisconnection(session)
{
	global
	Critical

	Dbg_ExitByDisconnect := true ; tell our message handler to just return true without attempting to exit
	Dbg_ExitByGuiClose := true
	Dbg_IsClosing := true
	Dbg_OnBreak := true
	SendMessage, 1026, 0, 0,, ahk_id %scitehwnd% ; Disable [Debugging] mark in SciTE's window title
}

;}

;{ Wrappers for DBGp Commands that set Dbg_OnBreak

DBGp_CmdRun(a)
{
	global
	ErrorLevel = 0
	Dbg_OnBreak := false
	Dbg_HasStarted := true
	a.run()
	SciTE_ToggleRunButton()
	VE_Close()
	OE_Close()
	ST_Clear()
}

DBGp_CmdStepInto(a)
{
	global
	ErrorLevel = 0
	Dbg_OnBreak := false
	Dbg_HasStarted := true
	a.step_into()
	SciTE_ToggleRunButton()
	VE_Close()
	OE_Close()
	ST_Clear()
}

DBGp_CmdStepOver(a)
{
	global
	ErrorLevel = 0
	Dbg_OnBreak := false
	Dbg_HasStarted := true
	a.step_over()
	SciTE_ToggleRunButton()
	VE_Close()
	OE_Close()
	ST_Clear()
}

DBGp_CmdStepOut(a)
{
	global
	ErrorLevel = 0
	Dbg_OnBreak := false
	Dbg_HasStarted := true
	a.step_out()
	SciTE_ToggleRunButton()
	VE_Close()
	OE_Close()
	ST_Clear()
}

;}

;{ Stacktrace Window

ST_Create()
{
	global
	
	ST_Destroy()
	Dbg_StackTraceWin := true
	Gui 2:+ToolWindow +AlwaysOnTop +LabelSTGui +Resize +MinSize -MaximizeBox
	Gui 2:Add, ListView, x0 y0 w320 h240 +NoSortHdr -LV0x10 gST_Go vST_ListView, Script filename|Line|Stack entry
	ST_Update()
	Gui 2:Show, w320 h240, Callstack
}

ST_Clear()
{
	global
	
	if !Dbg_StackTraceWin
		return
	
	Gui 2:Default
	LV_Delete()
}

ST_Update()
{
	global
	if !Dbg_StackTraceWin
		return
	aStackWhere := Util_UnpackNodes(Dbg_Stack.selectNodes("/response/stack/@where"))
	aStackFile  := Util_UnpackNodes(Dbg_Stack.selectNodes("/response/stack/@filename"))
	aStackLine  := Util_UnpackNodes(Dbg_Stack.selectNodes("/response/stack/@lineno"))
	Loop, % aStackFile.MaxIndex()
		aStackFile[A_Index] := DBGp_DecodeFileURI(aStackFile[A_Index])
	
	Gui 2:Default
	LV_Delete()
	Loop, % aStackWhere.MaxIndex()
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
	global
	if !Dbg_OnBreak && !bIsAsync
		return
	Dbg_Session.stack_get("", Dbg_Stack := "")
	Dbg_Stack := loadXML(Dbg_Stack)
}

;}

;{ Variable Inspection Window

VE_Create(name, ByRef cont, readonly := 0)
{
	global
	local VE_LF, VE_CRLF
	
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
	Gui 3:Font, s9, %dbgTextFont%
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
Dbg_Session.property_set("-n " VE_VarName " -- " (VE_C2 := DBGp_Base64UTF8Encode(VE_Contents)))
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

;}

;{ Variable List Window

VL_Create()
{
	global
	
	VL_Destroy()
	Dbg_VarWin := true
	Gui 4:+ToolWindow +AlwaysOnTop +LabelVLGui +Resize +MinSize -MaximizeBox
	Gui 4:Add, ListView, x0 y0 w320 h240 gVL_Inspect vVL_Listview, Scope|Variable name|Contents (partial)
	VL_Update()
	Gui 4:Show, w320 h240, Variable list
}

VL_Update()
{
	global
	if !Dbg_VarWin
		return
	; read
	ToolTip, Updating variable list...
	Dbg_GetContexts()
	VL_Local := Util_UnpackNodes(Dbg_LocalContext.selectNodes("/response/property/@name"))
	VL_Global := Util_UnpackNodes(Dbg_GlobalContext.selectNodes("/response/property/@name"))
	VL_NVars := VL_Local.MaxIndex() + VL_Global.MaxIndex()
	VL_LocalCont := Util_UnpackContNodes(Dbg_LocalContext.selectNodes("/response/property"))
	VL_GlobalCont := Util_UnpackContNodes(Dbg_GlobalContext.selectNodes("/response/property"))
	; update
	Gui 4:Default
	LV_Delete()
	Loop, % VL_Local.MaxIndex()
		LV_Add("", "Local", VL_Local[A_Index], VL_LocalCont[A_Index])
	Loop, % VL_Global.MaxIndex()
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
	global
	Gui 4:Destroy
	Dbg_VarWin := false
}

VL_Inspect:
if !bIsAsync && !Dbg_OnBreak
{
	MsgBox, 48, %g_appTitle%, You can't inspect a variable while the script is running!
	return
}
if A_GuiEvent != DoubleClick
	return
LV_GetText(VL_Scope, A_EventInfo, 1)
VL_Scope := VL_Scope != "Local"
LV_GetText(VL_VarName, A_EventInfo, 2)
SetEnableChildren(true)
Dbg_Session.property_get("-c " VL_Scope " -n " VL_VarName, Dbg_Response)
SetEnableChildren(false)
dom := loadXML(Dbg_Response)

if dom.selectSingleNode("/response/property/@type").text != "Object"
{
	VL_VarIsReadOnly := dom.selectSingleNode("/response/property/@facet").text = "Builtin"
	VL_VarData := DBGp_Base64UTF8Decode(dom.selectSingleNode("/response/property").text)
	VE_Create(VL_VarName, VL_VarData, VL_VarIsReadOnly)
}else
	OE_Create(dom)
dom := ""
return

VLGuiClose:
VL_Destroy()
return

VLGuiSize:
GuiControl, Move, VL_Listview, w%A_GuiWidth% h%A_GuiHeight%
return

Dbg_GetContexts()
{
	global
	
	if !bIsAsync && !Dbg_OnBreak
		return
	Dbg_Session.feature_set("-n max_data -v 65")
	Dbg_Session.context_get("-c 0", Dbg_LocalContext)
	Dbg_Session.context_get("-c 1", Dbg_GlobalContext)
	Dbg_Session.feature_set("-n max_data -v " dbgMaxData)
	Dbg_LocalContext  := loadXML(Dbg_LocalContext)
	Dbg_GlobalContext := loadXML(Dbg_GlobalContext)
}

;}

;{ Stream Window

SP_Output(stream, data)
{
	global Dbg_StreamWin, SP_Console, SP_ConHWND
	
	if !Dbg_StreamWin
	{
		Gui 5:Font, s9, %dbgTextFont%
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

;}

;{ Object Inspection Window

OE_Create(ByRef objdom)
{
	global
	local root
	OE_Data := {}

	Gui 6:Destroy
	Gui 6:Default
	Gui 6:+ToolWindow +AlwaysOnTop +LabelOEGui +Resize +MinSize -MaximizeBox
	Gui 6:Add, TreeView, x0 y0 w336 h320 vOE_Tree gOE_Event AltSubmit
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
	global OE_Data
	Loop, % nodes.length
	{
		node := nodes.item[A_Index-1]
		ttnode := TV_Add(node.attributes.getNamedItem("name").text, tnode)
		needToLoadChildren := node.attributes.getNamedItem("children").text
		fullName := node.attributes.getNamedItem("fullname").text
		nType := node.attributes.getNamedItem("type").text
		if needToLoadChildren
			q := TV_Add("{FAIL}", ttnode)
		OE_Data[ttnode] := { loadC: needToLoadChildren, name: fullName, type: nType, text: node.text, dummyC: q }
	}
}

OE_Preview(node)
{
	; TODO
}

OE_Close()
{
	global OE_Data
	Gui 6:Destroy
	OE_Data := ""
}

OE_OnDoubleClick(itemId)
{
	global OE_Data
	node := OE_Data[itemId]
	fullname := node.name
	if fullname && node.type != "object"
	{
		cont := DBGp_Base64UTF8Decode(node.text)
		VE_Create(fullname, cont)
	}
}

OE_OnExpand(itemId)
{
	global OE_Data, Dbg_Session
	node := OE_Data[itemId]
	if !node.loadC
		return
	TV_Modify(A_EventInfo, "-Expand")
	SetEnableChildren(true)
	Dbg_Session.property_get("-n " node.name, Dbg_Response)
	SetEnableChildren(false)
	dom := loadXML(Dbg_Response)
	node.loadC := false
	OE_Add(dom.selectNodes("/response/property[1]/property"), itemId)
	TV_Delete(node.dummyC)
	TV_Modify(A_EventInfo, "+Expand")
}

OE_Event:
if A_GuiEvent = +
	OE_OnExpand(A_EventInfo)
else if A_GuiEvent = DoubleClick
	OE_OnDoubleClick(A_EventInfo)
return

OEGuiSize:
GuiControl, Move, OE_Tree, w%A_GuiWidth% h%A_GuiHeight%
return

OEGuiClose:
OE_Close()
return

;}

;{ Even More SciTE Kitchen Sink Functions

SciTE_UpdateCurLineOfCode()
{
	global Dbg_Stack, szFilename
	
	cLine := Dbg_Stack.selectSingleNode("/response/stack[1]/@lineno").text
	cFNameURI := Dbg_Stack.selectSingleNode("/response/stack[1]/@filename").text
	cFName := DBGp_DecodeFileURI(cFNameURI)
	
	if cLine =
	{
		SciTE_EnsureFileIsOpen(szFilename)
		return
	}
	
	SciTE_EnsureFileIsOpen(cFName)
	SciTE_SetCurrentLine(cLine)
}

SciTE_RedrawLine(hwnd, line)
{
	global
	
	IfWinNotActive, ahk_id %scitehwnd%
		WinActivate
	
	DllCall("SendMessage", "ptr", hwnd, "uint", SCI_ENSUREVISIBLEENFORCEPOLICY, "int", line, "int", 0)
	DllCall("SendMessage", "ptr", hwnd, "uint", SCI_GOTOLINE, "int", line, "int", 0)
}

SciTE_EnsureFileIsOpen(fname)
{
	global oSciTE, scitehwnd
	if SciTE_GetFile() != fname
		oSciTE.OpenFile(fname)
	IfWinNotActive, ahk_id %scitehwnd%
		WinActivate, ahk_id %scitehwnd%
}

SciTE_GetFile()
{	
	global oSciTE
	return oSciTE.CurrentFile
}

SciTE_SetCurrentLine(line, mode := 1) ; show the current line markers in SciTE
{
	global
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
	global
	line--
	; Delete current markers
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERDELETEALL, "int", 11, "int", 0)
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERDELETEALL, "int", 12, "int", 0)
}

SciTE_BPSymbol(line) ; show the current line markers in SciTE
{
	global
	line--
	; Add markers
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERADD, "int", line, "int", 10)
}

SciTE_BPSymbolRemove(line) ; show the current line markers in SciTE
{
	global
	line--
	; Add markers
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERDELETE, "int", line, "int", 10)
}

;}

;{ Sandbox

Util_UnpackNodes(nodes)
{
	o := []
	Loop, % nodes.length
		o.Insert(nodes.item[A_Index-1].text)
	return o
}

Util_UnpackContNodes(nodes)
{
	o := []
	Loop, % nodes.length
		node := nodes.item[A_Index-1]
		,o.Insert(node.attributes.getNamedItem("type").text != "object" ? VL_ShortCont(DBGp_Base64UTF8Decode(node.text)) : "(Object)")
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

Util_AddBkToList(uri, line, id, cond := "")
{
	global Dbg_BkList
	Dbg_BkList[uri, line] := { id: id, cond: cond }
}

Util_GetBk(uri, line)
{
	global Dbg_BkList
	return Dbg_BkList[uri, line]
}

Util_RemoveBk(uri, line)
{
	global Dbg_BkList
	Dbg_BkList[uri].Remove(line)
}

loadXML(ByRef data)
{
	o := ComObjCreate("MSXML2.DOMDocument")
	o.async := false
	o.setProperty("SelectionLanguage", "XPath")
	o.loadXML(data)
	return o
}

GetExeMachine(exepath)
{
	exe := FileOpen(exepath, "r")
	if !exe
		return
	
	exe.Seek(60), exe.Seek(exe.ReadUInt()+4)
	return exe.ReadUShort()
}

;}
