;
; File encoding:  UTF-8
;
; COM interface for SciTE4AutoHotkey
;     version 1.0 - fincs
;

;------------------------------------------------------------------------------
; COM interface methods
;------------------------------------------------------------------------------

class InvalidUsage
{
	__Get(m, p*)
	{
		throw Exception("Property does not exist", m)
	}
	
	__Set(m, p*)
	{
		throw Exception("Property does not exist", m)
	}
	
	__Call(m, p*)
	{
		throw Exception("Method does not exist", m)
	}
}

CoI_CallEvent(event, args*)
{
	badEvts := {}
	for cookie, handler in CoI.EventHandlers
	{
		try
			handler[event](args*)
		catch
			badEvts[cookie] := 1
	}
	for cookie in badEvts
		CoI.EventHandlers.Delete(cookie)
}

class CoI extends InvalidUsage
{
	static EventHandlers := {}
	
	ConnectEvent(handler)
	{
		if !IsObject(handler)
			throw Exception("Invalid event handler")
		this.EventHandlers[&handler] := handler
		return &handler
	}
	
	DisconnectEvent(cookie)
	{
		this.EventHandlers.Delete(cookie)
	}
	
	Message(msg, wParam := 0, lParam := 0)
	{
		global _msg, _wParam, _lParam, scitehwnd, hwndgui, ATM_OFFSET
		if (_msg := msg+0) = "" || (_wParam := wParam+0) = "" || (_lParam := lParam+0) = ""
			return
		if (msg >= ATM_OFFSET)
		{
			; Send message in a different thread in order to not crap out whilst exiting
			Critical
			SetTimer, SelfMessage, -10
		}else
			SendMessage, _msg, _wParam, _lParam,, ahk_id %scitehwnd%
		return ErrorLevel
		
		SelfMessage:
		PostMessage, _msg, _wParam, _lParam,, ahk_id %hwndgui%
		return
	}

	ReloadProps()
	{
		global scitehwnd
		SendMessage, 1024+1, 0, 0,, ahk_id %scitehwnd%
	}

	SciTEDir[]
	{
		get
		{
			global SciTEDir
			return SciTEDir
		}
	}

	IsPortable[]
	{
		get
		{
			global IsPortable
			return IsPortable
		}
	}

	UserDir[]
	{
		get
		{
			global LocalSciTEPath
			return LocalSciTEPath
		}
	}

	Tabs[]
	{
		get
		{
			obj := Director_Send("ask_bufferlist:", true, true)
			tabs := ComObjArray(VT_BSTR := 8, obj.Length())
			for each, msg in obj
				tabs[each - 1] := msg.value

			; Return the Tabs object
			return new CoI.__Tabs(tabs)
		}
	}
	
	class __Tabs
	{
		__New(p)
		{
			this.p := p
		}
		
		Array[]
		{
			get
			{
				return this.p
			}
		}

		List[]
		{
			get
			{
				for item in this.p
					list .= item "`n"
				StringTrimRight, list, list, 1
				return list
			}
		}

		Count[]
		{
			get
			{
				return this.p.MaxIndex() + 1
			}
		}
	}
	
	SwitchToTab(idx)
	{
		global scitehwnd
		
		if IsObject(idx) || (idx+0) = ""
			return
		
		PostMessage, 0x111, 1200+idx, 0,, ahk_id %scitehwnd%
	}

	Document[]
	{
		get
		{
			return Director_Send("ask_fulldocument:", true).Value
		}
		set
		{
			throw Exception("Not implemented yet")
		}
	}

	InsertText(text, pos := -1)
	{
		if !IsObject(text) && text && !IsObject(pos) && (pos+0) >= -1
		{
			if (pos >= 0)
				Director_Send("goto_raw:" pos)
			Director_Send("insert:" CEscape(text))
		}
	}

	Selection[]
	{
		get
		{
			return this.ResolveProp("CurrentSelection")
		}
	}

	Output(text)
	{
		Director_Send("output:" CEscape(text))
	}

	SciTEHandle[]
	{
		get
		{
			global scitehwnd
			return scitehwnd
		}
	}

	ActivePlatform[]
	{
		get
		{
			global curplatform
			return curplatform
		}
		set
		{
			global platforms, curplatform
			if !platforms[value]
				throw Exception("Invalid platform",, value)
			else
			{
				curplatform := value
				gosub platswitch2
				return value
			}
		}
	}
	
	; Backwards compatibility
	SetPlatform(plat)
	{
		try
		{
			this.ActivePlatform := plat
			return 1
		} catch
			return 0
	}

	CurrentFile[]
	{
		get
		{
			return GetSciTEOpenedFile()
		}
		set
		{
			this.OpenFile(file)
			return file
		}
	}

	Version[]
	{
		get
		{
			global CurrentSciTEVersion
			return CurrentSciTEVersion
		}
	}

	OpenFile(file)
	{
		global scitehwnd
		
		WinActivate, ahk_id %scitehwnd%
		
		if this.CurrentFile = file
			return
		
		Director_Send("open:" CEscape(file))
	}

	DebugFile(file)
	{
		this.OpenFile(file)
		Cmd_Debug()
	}

	SendDirectorMsg(msg)
	{
		return Director_Send(msg)
	}

	SendDirectorMsgRet(msg)
	{
		return Director_Send(msg, true)
	}

	SendDirectorMsgRetArray(msg)
	{
		obj := Director_Send(msg, true, true)
		array := ComObjArray(VT_VARIANT:=12, obj.Length()), ComObjFlags(array, -1)
		for each, msg in obj
			array[each - 1] := msg
		return array
	}

	ResolveProp(propname)
	{
		propVal := Director_Send("askproperty:" propname, true).value
		if SubStr(propVal, 1, 11) != "stringinfo:"
			return
		propVal := SubStr(propVal, 12)
		while RegExMatch(propVal, "O)\$\((.+?)\)", o)
			propVal := SubStr(propVal, 1, o.Pos-1) this.ResolveProp(o.1) SubStr(propVal, o.Pos+o.Len)
		return propVal
	}

}

;------------------------------------------------------------------------------
; Initialization code
;------------------------------------------------------------------------------

InitComInterface()
{
	global CLSID_SciTE4AHK, APPID_SciTE4AHK, oSciTE, hSciTE_Remote, IsPortable
	
	if IsPortable
		; Register our CLSID and APPID
		RegisterIDs(CLSID_SciTE4AHK, APPID_SciTE4AHK)
	
	; Expose it
	if !(hSciTE_Remote := ComRemote(ComObject(9, &CoI), CLSID_SciTE4AHK))
	{
		MsgBox, 16, SciTE4AutoHotkey, Can't create COM interface!`nSome program functions may not work.
		if IsPortable
			RevokeIDs(CLSID_SciTE4AHK, APPID_SciTE4AHK)
	} else if IsPortable
		; Revoke our CLSID and APPID on exit
		OnExit(Func("RevokeIDs").Bind(CLSID_SciTE4AHK, APPID_SciTE4AHK))
}

RegisterIDs(CLSID, APPID)
{
	RegWrite, REG_SZ, HKCU, Software\Classes\%APPID%,, %APPID%
	RegWrite, REG_SZ, HKCU, Software\Classes\%APPID%\CLSID,, %CLSID%
	RegWrite, REG_SZ, HKCU, Software\Classes\CLSID\%CLSID%,, %APPID%
}

RevokeIDs(CLSID, APPID)
{
	RegDelete, HKCU, Software\Classes\%APPID%
	RegDelete, HKCU, Software\Classes\CLSID\%CLSID%
}

Str2GUID(ByRef var, str)
{
	VarSetCapacity(var, 16)
	DllCall("ole32\CLSIDFromString", "wstr", str, "ptr", &var)
	return &var
}
