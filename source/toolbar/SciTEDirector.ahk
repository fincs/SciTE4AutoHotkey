;
; File encoding:  UTF-8
;
; SciTE director wrapper
;     version 1.0 - fincs
;

Director_Init()
{
	global WM_COPYDATA, DirectorRecv, DirectorRetByArray, DirectorMsg, ATM_Director, scitehwnd, hwndgui, directorhwnd, DirectorReady
	WM_COPYDATA := 0x4a, DirectorRecv := false, DirectorMsg := ""
	
	_Director_CreateTempWin()
	OnMessage(ATM_DIRECTOR, "_Director_Ack")
	PostMessage, 0x111, 1134, 0,, ahk_id %scitehwnd%
	while directorhwnd = ""
	{
		if A_Index = 100
			break
		Sleep, 10
	}
	_Director_DestroyTempWin()
	
	if !directorhwnd
	{
		MsgBox, 16, Toolbar, Error trying to get the director interface!
		return
	}
	
	OnMessage(WM_COPYDATA, "_Director_Recv")
	Director_Send("identity:" (hwndgui+0))
	DirectorReady := true
}

Director_Send(msg, returns=false, onArray=false)
{
	global directorhwnd, WM_COPYDATA, DirectorMsg, DirectorRcv, DirectorRetByArray
	len := StrPutVar(msg, msg_utf8, "UTF-8")
	; This code was taken from the AHK help
	VarSetCapacity(COPYDATASTRUCT, 3*A_PtrSize, 0)
	NumPut(len, COPYDATASTRUCT, A_PtrSize, "UInt")
	NumPut(&msg_utf8, COPYDATASTRUCT, 2*A_PtrSize)
	if returns
	{
		DirectorRcv := true
		DirectorRetByArray := onArray
		if onArray
			DirectorMsg := []
	}
	SendMessage, WM_COPYDATA, 0, &COPYDATASTRUCT,, ahk_id %directorhwnd%
	if returns
	{
		DirectorRcv := false
		DirectorRetByArray := false
		return DirectorMsg
	}
}

_Director_CreateTempWin()
{
	Gui 99:+LastFound
	hwnd := WinExist("")
	DllCall("SetWindowText", "ptr", hwnd, "str", "scite4ahkToolbarTempWin")
}

_Director_DestroyTempWin()
{
	Gui 99:Destroy
}

_Director_Ack(wParam, lParam, msg, hwnd)
{
	global directorhwnd
	directorhwnd := lParam
}

_Director_Recv(wParam, lParam, msg, hwnd)
{
	Critical
	global DirectorMsg, DirectorRcv, DirectorRetByArray, lastfunc
	message := _Director_ParseResponse(StrGet(NumGet(lParam + 2*A_PtrSize), NumGet(lParam + A_PtrSize, "UInt"), "UTF-8"))
	if DirectorRcv
	{
		if !DirectorRetByArray
			DirectorMsg := message
		else
			DirectorMsg._Insert(message)
	}else
	{
		func := "SciTE_On" message.type
		if IsFunc(func)
		{
			Critical, Off
			%func%(message.value, message.type)
		}
	}
	return true
}

_Director_ParseResponse(resp)
{
	colon := InStr(resp, ":")
	return {type: SubStr(resp, 1, colon-1), value: CUnescape(SubStr(resp, colon+1))}
}
