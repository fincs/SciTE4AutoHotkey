;
; FTP Functions
; Original FTP Functions by Olfen & Andreone
; See the following post:
;     http://www.autohotkey.com/forum/viewtopic.php?t=10393
; Modified by ahklerner
; Heavily modified by fincs
;

FTP_CreateDirectory(hConnect, DirName)
{
	r := DllCall("wininet\FtpCreateDirectory", "ptr", hConnect, "str", DirName)
	return !ErrorLevel && r
}

FTP_RemoveDirectory(hConnect, DirName)
{
	r := DllCall("wininet\FtpRemoveDirectory", "ptr", hConnect, "str", DirName)
	return !ErrorLevel && r
}

FTP_SetCurrentDirectory(hConnect,DirName)
{
	r := DllCall("wininet\FtpSetCurrentDirectory", "ptr", hConnect, "str", DirName)
	return !ErrorLevel && r
}

FTP_PutFile(hConnect, LocalFile, NewRemoteFile := "", Flags := 0)
{
	; Flags:
	; FTP_TRANSFER_TYPE_UNKNOWN = 0 (Defaults to FTP_TRANSFER_TYPE_BINARY)
	; FTP_TRANSFER_TYPE_ASCII = 1
	; FTP_TRANSFER_TYPE_BINARY = 2
	
	if NewRemoteFile =
		NewRemoteFile := localFile
	
	r := DllCall("wininet\FtpPutFile", "ptr", hConnect, "str", LocalFile, "str", NewRemoteFile, "uint", Flags, "uint", 0) ;dwContext
	return !ErrorLevel && r
}

FTP_GetFile(hConnect, RemoteFile, NewFile := "", Flags := 0)
{
	; Flags:
	; FTP_TRANSFER_TYPE_UNKNOWN = 0 (Defaults to FTP_TRANSFER_TYPE_BINARY)
	; FTP_TRANSFER_TYPE_ASCII = 1
	; FTP_TRANSFER_TYPE_BINARY = 2
	if NewFile =
		NewFile := RemoteFile
	
	r := DllCall("wininet\FtpGetFile", "ptr", hConnect, "str", RemoteFile, "str", NewFile
		, "int", 1 ;do not overwrite existing files
		, "uint", 0 ;dwFlagsAndAttributes
		, "uint", Flags, "uint", 0) ;dwContext
	return !ErrorLevel && r
}

FTP_GetFileSize(hConnect, FileName, Flags := 0)
{
	; Flags:
	; FTP_TRANSFER_TYPE_UNKNOWN = 0 (Defaults to FTP_TRANSFER_TYPE_BINARY)
	; FTP_TRANSFER_TYPE_ASCII = 1
	; FTP_TRANSFER_TYPE_BINARY = 2
	
	fof_hInternet := DllCall("wininet\FtpOpenFile", "ptr", hConnect, "str", FileName
		, "uint", 0x80000000 ; dwAccess: GENERIC_READ
		, "uint", Flags, "uint", 0, "ptr") ;dwContext
	if ErrorLevel || !fof_hInternet
		return -1
	FileSize := DllCall("wininet\FtpGetFileSize", "ptr", fof_hInternet, "uint", 0)
	DllCall("wininet\InternetCloseHandle", "ptr", fof_hInternet)
	return FileSize
}

FTP_DeleteFile(hConnect,FileName)
{
	r :=  DllCall("wininet\FtpDeleteFile", "ptr", hConnect, "str", FileName)
	return !ErrorLevel && r
}

FTP_RenameFile(hConnect, Existing, New)
{
	r := DllCall("wininet\FtpRenameFile", "ptr", hConnect, "str", Existing, "str", New)
	return !ErrorLevel && r
}

FTP_Open(Server, Port := 21, Username := 0, Password := 0, Proxy := "", ProxyBypass := "")
{
	IfEqual, Username, 0, SetEnv, Username, anonymous
	IfEqual, Password, 0, SetEnv, Password, anonymous
	AccessType := Proxy != "" ? 3 : 1
	
	; #define INTERNET_OPEN_TYPE_PRECONFIG                   0 // use registry configuration
	; #define INTERNET_OPEN_TYPE_DIRECT                      1 // direct to net
	; #define INTERNET_OPEN_TYPE_PROXY                       3 // via named proxy
	; #define INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY 4 // prevent using java/script/INS
	
	global ic_hInternet, io_hInternet, hModule
	hModule := DllCall("LoadLibrary", "str", "wininet.dll", "ptr")
	io_hInternet := DllCall("wininet\InternetOpen", "str", A_ScriptName, "UInt", AccessType, "str", Proxy, "str", ProxyBypass, "UInt", 0, "ptr") ;dwFlags
	if ErrorLevel || !io_hInternet
	{
		FTP_Close()
		return 0
	}
	
	ic_hInternet := DllCall("wininet\InternetConnect", "ptr", io_hInternet, "str", Server, "uint", Port, "str", Username, "str", Password
		, "uint", 1 ;dwService (INTERNET_SERVICE_FTP = 1)
		, "uint", 0 ;dwFlags
		, "uint", 0, "ptr") ;dwContext
	return ErrorLevel ? 0 : ic_hInternet
}

FTP_CloseSocket(hConnect)
{
	DllCall("wininet\InternetCloseHandle", "ptr", hConnect)
}

FTP_Close()
{
	global ic_hInternet, io_hInternet, hModule
	DllCall("wininet\InternetCloseHandle", "ptr", ic_hInternet)
	DllCall("wininet\InternetCloseHandle", "ptr", io_hInternet)
	DllCall("FreeLibrary", "ptr", hModule)
}

FTP_GetFileInfo(ByRef @FindData, InfoName)
{
	if InfoName = Name
	{
		VarSetCapacity(value, 1040, 0)
		DllCall("RtlMoveMemory", "str", value, "ptr", &@FindData + 44, "uint", 1040)
		VarSetCapacity(value, -1)
	}else if InfoName = CreationTime
	{
		value := NumGet(@FindData, 4, "UInt") << 32 | NumGet(@FindData, 8, "UInt")
		value := FileTimeToStr(value)
	}else if InfoName = LastAccessTime
	{
		value := NumGet(@FindData, 12, "UInt") << 32 | NumGet(@FindData, 16, "UInt")
		value := FileTimeToStr(value)
	}else if InfoName = LastWriteTime
	{
		value := NumGet(@FindData, 20, "UInt") << 32 | NumGet(@FindData, 24, "UInt")
		value := FileTimeToStr(value)
	}else if InfoName = Size
		value := NumGet(@FindData, 28, "UInt") << 32 | NumGet(@FindData, 32, "UInt")
	else if InfoName = Attrib
	{
		if FTP_GetFileInfo(@FindData, "IsNormal")
			value .= "N"
		if FTP_GetFileInfo(@FindData, "IsDirectory")
			value .= "D"
		if FTP_GetFileInfo(@FindData, "IsReadOnly")
			value .= "R"
		if FTP_GetFileInfo(@FindData, "IsHidden")
			value .= "H"
		if FTP_GetFileInfo(@FindData, "IsSystem")
			value .= "S"
		if FTP_GetFileInfo(@FindData, "IsArchive")
			value .= "A"
		if FTP_GetFileInfo(@FindData, "IsTemp")
			value .= "T"
		if FTP_GetFileInfo(@FindData, "IsEncrypted")
			value .= "E"
		if FTP_GetFileInfo(@FindData, "IsCompressed")
			value .= "C"
		if FTP_GetFileInfo(@FindData, "IsVirtual")
			value .= "V"
	}else if InfoName = IsReadOnly
		value := (NumGet(@FindData, 0, "UInt") & 1) != 0 ; FILE_ATTRIBUTE_ReadOnly
	else if InfoName = IsHidden
		value := (NumGet(@FindData, 0, "UInt") & 2) != 0 ; FILE_ATTRIBUTE_Hidden
	else if InfoName = IsSystem
		value := (NumGet(@FindData, 0, "UInt") & 4) != 0 ; FILE_ATTRIBUTE_SYSTEM
	else if InfoName = IsDirectory
		value := (NumGet(@FindData, 0, "UInt") & 16) != 0 ; FILE_ATTRIBUTE_DIRECTORY
	else if InfoName = IsArchive
		value := (NumGet(@FindData, 0, "UInt") & 32) != 0 ; FILE_ATTRIBUTE_ARCHIVE
	else if InfoName = IsNormal
		value := (NumGet(@FindData, 0, "UInt") & 128) != 0 ; FILE_ATTRIBUTE_Normal
	else if InfoName = IsTemp
		value := (NumGet(@FindData, 0, "UInt") & 256) != 0 ; FILE_ATTRIBUTE_TEMPORARY
	else if InfoName = IsEncrypted
		value := (NumGet(@FindData, 0, "UInt") & 2048) != 0 ; FILE_ATTRIBUTE_OFFLINE
	else if InfoName = IsOffline
		value := (NumGet(@FindData, 0, "UInt") & 4096) != 0 ; FILE_ATTRIBUTE_ENCRYPTED
	else if InfoName = IsCompressed
		value := (NumGet(@FindData, 0, "UInt") & 16384) != 0 ; FILE_ATTRIBUTE_COMPRESSED
	else if InfoName = IsVirtual
		value := (NumGet(@FindData, 0, "UInt") & 65536) != 0 ; FILE_ATTRIBUTE_VIRTUAL
	
	return value
}

FileTimeToStr(FileTime)
{
	VarSetCapacity(SystemTime, 16, 0)
	DllCall("FileTimeToSystemTime", "ptr", &FileTime, "ptr", &SystemTime)
	return NumGet(SystemTime,  2, "short")
	. "/"  NumGet(SystemTime,  6, "short")
	. "/"  NumGet(SystemTime,  0, "short")
	. " "  NumGet(SystemTime,  8, "short")
	. ":"  NumGet(SystemTime, 10, "short")
	. ":"  NumGet(SystemTime, 12, "short")
	. "."  NumGet(SystemTime, 14, "short")
}

FTP_FindFirstFile(hConnect, SearchFile, ByRef @FindData)
{
	; WIN32_FIND_DATA structure size is 4 + 3*8 + 4*4 + 260*4 + 14*4 = 1140
	VarSetCapacity(@FindData, 1140, 0)
	
	hEnum := DllCall("wininet\FtpFindFirstFile", "ptr", hConnect, "str", SearchFile, "ptr", &@FindData, "uint", 0, "uint", 0)
	if !hEnum
		VarSetCapacity(@FindData, 0)
	return hEnum
}

FTP_FindNextFile(hEnum, ByRef @FindData)
{
	return DllCall("wininet\InternetFindNextFile", "ptr", hEnum, "ptr", &@FindData)
}

FTP_GetCurrentDirectory(hConnect, ByRef DirName)
{
	VarSetCapacity(DirName, 256)
	VarSetCapacity(MaxDirN, 4)
	NumPut(256, MaxDirN, "UInt")
	r := DllCall("wininet\FtpGetCurrentDirectory", "ptr", hConnect, "str", DirName, "str", MaxDirN)
	if ErrorLevel || !r
		return 0
	if NumGet(MaxDirN, "UInt") > 256
	{
		VarSetCapacity(DirName, NumGet(MaxDirN, "UInt"))
		r := DllCall("wininet\FtpGetCurrentDirectory", "ptr", hConnect, "str", DirName, "str", MaxDirN)
	}
	return ErrorLevel || !r
}
