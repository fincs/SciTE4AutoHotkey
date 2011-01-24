;===============================================================================================
;===============================================================================================


;Origional FTP Functions by Olfen & Andreone
;See the following post:
; http://www.autohotkey.com/forum/viewtopic.php?t=10393
;Modified by ahklerner
/*
FTP_Init(){
}
*/
FTP_CreateDirectory(hConnect,DirName){
	;global ic_hInternet
	r := DllCall("wininet\FtpCreateDirectory", "uint", hConnect, "str", DirName)
	If (ErrorLevel or !r)
		Return 0
	Else
		Return 1
}

FTP_RemoveDirectory(hConnect,DirName){
	;global ic_hInternet
	r := DllCall("wininet\FtpRemoveDirectory", "uint", hConnect, "str", DirName)
	If (ErrorLevel or !r)
		Return 0
	Else
		Return 1
}

FTP_SetCurrentDirectory(hConnect,DirName){
	;global ic_hInternet
	r := DllCall("wininet\FtpSetCurrentDirectory", "uint", hConnect, "str", DirName)
	If (ErrorLevel or !r)
		Return 0
	Else
		Return 1
}

FTP_PutFile(hConnect,LocalFile, NewRemoteFile="", Flags=0){
	;Flags:
	;FTP_TRANSFER_TYPE_UNKNOWN = 0 (Defaults to FTP_TRANSFER_TYPE_BINARY)
	;FTP_TRANSFER_TYPE_ASCII = 1
	;FTP_TRANSFER_TYPE_BINARY = 2
	If NewRemoteFile=
		NewRemoteFile := localFile
	;global ic_hInternet
	r := DllCall("wininet\FtpPutFile"
					, "uint", hConnect
					, "str", LocalFile
					, "str", NewRemoteFile
					, "uint", Flags
					, "uint", 0) ;dwContext
	If (ErrorLevel or !r)
		Return 0
	Else
		Return 1
}

FTP_GetFile(hConnect,RemoteFile, NewFile="", Flags=0){
	;Flags:
	;FTP_TRANSFER_TYPE_UNKNOWN = 0 (Defaults to FTP_TRANSFER_TYPE_BINARY)
	;FTP_TRANSFER_TYPE_ASCII = 1
	;FTP_TRANSFER_TYPE_BINARY = 2
	If NewFile=
		NewFile := RemoteFile
	;global ic_hInternet
	r := DllCall("wininet\FtpGetFile"
					, "uint", hConnect
					, "str", RemoteFile
					, "str", NewFile
					, "int", 1 ;do not overwrite existing files
					, "uint", 0 ;dwFlagsAndAttributes
					, "uint", Flags
					, "uint", 0) ;dwContext
	If (ErrorLevel or !r)
		Return 0
	Else
		Return 1
}

FTP_GetFileSize(hConnect,FileName, Flags=0){
	;Flags:
	;FTP_TRANSFER_TYPE_UNKNOWN = 0 (Defaults to FTP_TRANSFER_TYPE_BINARY)
	;FTP_TRANSFER_TYPE_ASCII = 1
	;FTP_TRANSFER_TYPE_BINARY = 2
	;global ic_hInternet
	fof_hInternet := DllCall("wininet\FtpOpenFile"
								, "uint", hConnect
								, "str", FileName
							, "uint", 0x80000000 ;dwAccess: GENERIC_READ
							, "uint", Flags
							, "uint", 0) ;dwContext
	If (ErrorLevel or !fof_hInternet)
		Return -1
	FileSize := DllCall("wininet\FtpGetFileSize", "uint", fof_hInternet, "uint", 0)
	DllCall("wininet\InternetCloseHandle",  "UInt", fof_hInternet)
	Return, FileSize
}

FTP_DeleteFile(hConnect,FileName){
	;global ic_hInternet
	r :=  DllCall("wininet\FtpDeleteFile", "uint", hConnect, "str", FileName)
	If (ErrorLevel or !r)
		Return 0
	Else
		Return 1
}

FTP_RenameFile(hConnect,Existing, New){
	;global ic_hInternet
	r := DllCall("wininet\FtpRenameFile", "uint", hConnect, "str", Existing, "str", New)
	If (ErrorLevel or !r)
		Return 0
	Else
		Return 1
}

FTP_Open(Server, Port=21, Username=0, Password=0 ,Proxy="", ProxyBypass=""){
	IfEqual, Username, 0, SetEnv, Username, anonymous
	IfEqual, Password, 0, SetEnv, Password, anonymous
	If (Proxy != "")
		AccessType=3
	Else
		AccessType=1
	;#define INTERNET_OPEN_TYPE_PRECONFIG                    0   // use registry configuration
	;#define INTERNET_OPEN_TYPE_DIRECT                       1   // direct to net
	;#define INTERNET_OPEN_TYPE_PROXY                        3   // via named proxy
	;#define INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY  4   // prevent using java/script/INS
	;global ic_hInternet
	global ic_hInternet,io_hInternet, hModule
	hModule := DllCall("LoadLibrary", "str", "wininet.dll")
	io_hInternet := DllCall("wininet\InternetOpen"
								, "str", A_ScriptName ;lpszAgent
							, "UInt", AccessType
							, "str", Proxy
							, "str", ProxyBypass
							, "UInt", 0) ;dwFlags
	If (ErrorLevel != 0 or io_hInternet = 0) {
		FTP_Close()
		Return 0
	}
	ic_hInternet := DllCall("wininet\InternetConnect"
							, "uint", io_hInternet
							, "str", Server
							, "uint", Port
							, "str", Username
							, "str", Password
							, "uint" , 1 ;dwService (INTERNET_SERVICE_FTP = 1)
							, "uint", 0 ;dwFlags
							, "uint", 0) ;dwContext
	If (ErrorLevel or !ic_hInternet)
		Return 0
	Else
		Return ic_hInternet
}

FTP_CloseSocket(hConnect){
	DllCall("wininet\InternetCloseHandle",  "UInt", hConnect)
}

FTP_Close(){
	global ic_hInternet, io_hInternet, hModule
	DllCall("wininet\InternetCloseHandle",  "UInt", ic_hInternet)
	DllCall("wininet\InternetCloseHandle",  "UInt", io_hInternet)
	DllCall("FreeLibrary", "UInt", hModule)
}

FTP_GetFileInfo(ByRef @FindData, InfoName){
	If(InfoName == "Name") {
		VarSetCapacity(value, 1040, 0)
		DllCall("RtlMoveMemory", "str", value, "uint", &@FindData + 44, "uint", 1040)
		VarSetCapacity(value, -1)
	}Else If(InfoName == "CreationTime") {
		value := NumGet(@FindData, 4) << 32 | NumGet(@FindData, 8)
		value := FileTimeToStr(value)
	}Else If(InfoName == "LastAccessTime") {
		value := NumGet(@FindData, 12) << 32 | NumGet(@FindData, 16)
		value := FileTimeToStr(value)
	}Else If(InfoName == "LastWriteTime") {
		value := NumGet(@FindData, 20) << 32 | NumGet(@FindData, 24)
		value := FileTimeToStr(value)
	}Else If(InfoName == "Size") {
		value := NumGet(@FindData, 28) << 32 | NumGet(@FindData, 32)
	}Else If(InfoName == "Attrib") {
		If(FTP_GetFileInfo(@FindData, "IsNormal"))
		value .= "N"
		If(FTP_GetFileInfo(@FindData, "IsDirectory"))
		value .= "D"
		If(FTP_GetFileInfo(@FindData, "IsReadOnly"))
		value .= "R"
		If(FTP_GetFileInfo(@FindData, "IsHidden"))
		value .= "H"
		If(FTP_GetFileInfo(@FindData, "IsSystem"))
		value .= "S"
		If(FTP_GetFileInfo(@FindData, "IsArchive"))
		value .= "A"
		If(FTP_GetFileInfo(@FindData, "IsTemp"))
		value .= "T"
		If(FTP_GetFileInfo(@FindData, "IsEncrypted"))
		value .= "E"
		If(FTP_GetFileInfo(@FindData, "IsCompressed"))
		value .= "C"
		If(FTP_GetFileInfo(@FindData, "IsVirtual"))
		value .= "V"
	}Else If(InfoName == "IsReadOnly") {
		value := (NumGet(@FindData, 0) & 1) != 0 ; FILE_ATTRIBUTE_ReadOnly
	}Else If(InfoName == "IsHidden") {
		value := (NumGet(@FindData, 0) & 2) != 0 ; FILE_ATTRIBUTE_Hidden
	}Else If(InfoName == "IsSystem") {
		value := (NumGet(@FindData, 0) & 4) != 0 ; FILE_ATTRIBUTE_SYSTEM
	}Else If(InfoName == "IsDirectory") {
		value := (NumGet(@FindData, 0) & 16) != 0 ; FILE_ATTRIBUTE_DIRECTORY
	}Else If(InfoName == "IsArchive") {
		value := (NumGet(@FindData, 0) & 32) != 0 ; FILE_ATTRIBUTE_ARCHIVE
	}Else If(InfoName == "IsNormal") {
		value := (NumGet(@FindData, 0) & 128) != 0 ; FILE_ATTRIBUTE_Normal
	}Else If(InfoName == "IsTemp") {
		value := (NumGet(@FindData, 0) & 256) != 0 ; FILE_ATTRIBUTE_TEMPORARY
	}Else If(InfoName == "IsEncrypted") {
		value := (NumGet(@FindData, 0) & 2048) != 0 ; FILE_ATTRIBUTE_OFFLINE
	}Else If(InfoName == "IsOffline") {
		value := (NumGet(@FindData, 0) & 4096) != 0 ; FILE_ATTRIBUTE_ENCRYPTED
	}Else If(InfoName == "IsCompressed") {
		value := (NumGet(@FindData, 0) & 16384) != 0 ; FILE_ATTRIBUTE_COMPRESSED
	}Else If(InfoName == "IsVirtual") {
		value := (NumGet(@FindData, 0) & 65536) != 0 ; FILE_ATTRIBUTE_VIRTUAL
	}
	Return value
}

FileTimeToStr(FileTime){
	VarSetCapacity(SystemTime, 16, 0)
	DllCall("FileTimeToSystemTime", "uint", &FileTime, "uint", &SystemTime)
	Return NumGet(SystemTime,2,"short")
	. "/" . NumGet(SystemTime,6,"short")
	. "/" . NumGet(SystemTime,0,"short")
	. " " . NumGet(SystemTime,8,"short")
	. ":" . NumGet(SystemTime,10,"short")
	. ":" . NumGet(SystemTime,12,"short")
	. "." . NumGet(SystemTime,14,"short")
}

FTP_FindFirstFile(hConnect, SearchFile, ByRef @FindData){
	; WIN32_FIND_DATA structure size is 4 + 3*8 + 4*4 + 260*4 + 14*4 = 1140
	VarSetCapacity(@FindData, 1140, 0)
	;MsgBox % "FFF:= " .
	hEnum := DllCall("wininet\FtpFindFirstFile"
						, "uint", hConnect
						, "str", SearchFile
						, "uint", &@FindData
						, "uint", 0
						, "uint", 0)
	If(!hEnum)
	VarSetCapacity(@FindData, 0)
	Return hEnum
}

FTP_FindNextFile(hEnum, ByRef @FindData){
	Return DllCall("wininet\InternetFindNextFile"
							, "uint", hEnum
							, "uint", &@FindData)
}
