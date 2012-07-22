
GetWinVer()
{
	pack := DllCall("GetVersion", "uint") & 0xFFFF
	pack := (pack & 0xFF) "." (pack >> 8)
	pack += 0
	return pack
}
