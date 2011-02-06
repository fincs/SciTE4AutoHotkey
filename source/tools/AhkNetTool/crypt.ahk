; No longer a ultra-secret source file
; Contains a retouched version of MCode and a TEA algorithm from the same thread

InitCrypt(){
	Global
	MCode(TEA_Crypt, "5589E55383EC148B450C8B008945F88B450C83C0048B008945F4C745EC00000000C745E8B979379EC7"
	. "45F0000000008B45F03B4508737D8B45F489C2C1E2048B45F4C1E80531D089C3035DF48B45EC83E0038D0C85000000008"
	. "B55108B45EC03041189DA31C28D45F801108B55E88D45EC01108B45F889C2C1E2048B45F8C1E80531D089C3035DF88B45"
	. "ECC1E80B83E0038D0C85000000008B55108B45EC03041189DA31C28D45F401108D45F0FF00E97BFFFFFF8B550C8B45F88"
	. "9028B550C83C2048B45F4890283C4145B5DC3")

	MCode(TEA_Decrypt, "5589E55383EC148B450C8B008945F88B450C83C0048B008945F4C745ECB979379E8B45EC0FAF450889"
	. "45E8C745F0000000008B45F03B4508737D8B45F889C2C1E2048B45F8C1E80531D089C3035DF88B45E8C1E80B83E0038D0"
	. "C85000000008B55108B45E803041189DA31C28D45F429108B55EC8D45E829108B45F489C2C1E2048B45F4C1E80531D089"
	. "C3035DF48B45E883E0038D0C85000000008B55108B45E803041189DA31C28D45F829108D45F0FF00E97BFFFFFF8B550C8"
	. "B45F889028B550C83C2048B45F4890283C4145B5DC3")
	MCode(TEA_Key, "FE1290BC" "A893BC17" "DD1BF1ED" "AABBCCDD") ; this is the encryption key
}

CryptData(data){
	Global TEA_Encrypt, TEA_Decrypt, TEA_Key
	; prepare the data to fit in 128 bytes
	VarSetCapacity(datap, 128, 0)
	while StrPut(data, "UTF-8") > 128
		StringTrimRight, data, data, 1
	StrPut(data, &datap, "UTF-8")
	/*
	loop 128
	{
		q := SubStr(data, A_Index, 1)
		if q =
			n := 0
		Else
			n := asc(q)
		numput(n, datap, A_Index-1, "UChar")
	}
	*/
	loop, 16
		DllCall(&TEA_Encrypt, "int", 64, "uint", (&datap)+((A_Index-1)*16), "uint", &TEA_Key)
	
	return Bin2Hex(&datap,128)
}

DecryptData(data){
	Global TEA_Encrypt, TEA_Decrypt, TEA_Key
	MCode(datap, data)
	loop, 32
		DllCall(&TEA_Encrypt, int, 64, uint, (&datap)+((A_Index-1)*16), uint,&TEA_Key)
	datap := StrGet(&datap, "UTF-8")
	return datap
	/*
	;VarSetCapacity(datap, -1)
	really := SubStr(datap, 1, 128)
	if(really != SubStr(A_OSType A_OSVersion A_UserName A_ComputerName, 1, 128)){
		return ""
	}
	return DllCall("MulDiv", int, (&datap)+128, int, 1, int, 1, str)
	*/
}

MCode(ByRef code, hex) { ; allocate memory and write Machine Code there
	VarSetCapacity(code,StrLen(hex)//2)
	Loop % StrLen(hex)//2
		NumPut("0x" SubStr(hex,2*A_Index-1,2), code, A_Index-1, "UChar")
}

Bin2Hex(addr,len) {
	Static fun
	If (fun = "") {
		h=8B4C2404578B7C241085FF7E2F568B7424108A06C0E8042C0A8AD0C0EA052AC2044188018A06240F2C0A8AD0C0EA052AC2410441468801414F75D75EC601005FC3
		VarSetCapacity(fun,StrLen(h)//2)
		Loop % StrLen(h)//2
			NumPut("0x" SubStr(h,2*A_Index-1,2), fun, A_Index-1, "UChar")
	}
	VarSetCapacity(hex,2*len+1)
	dllcall(&fun, "uint",&hex, "uint",addr, "uint",len, "cdecl")
	if A_IsUnicode
		hex := StrGet(&hex, "UTF-8")
	else
		VarSetCapacity(hex,-1) ; update StrLen
	Return hex
}
