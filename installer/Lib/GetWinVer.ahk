
GetWinVer()
{
	pack := DllCall("GetVersion", "uint")
	return ((pack >> 16) "." (pack & 0xFFFF)) + 0.0
}
