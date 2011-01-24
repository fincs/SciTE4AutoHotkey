;http://www.autohotkey.com/forum/viewtopic.php?p=184468#184468 by Skan
; Modified to be able to specify the title of the progress window
NiceDownloader(url, file, customName="") {
	static _init
	global _cu
	SplitPath, file, _dFile
	if !init
	{	;RegRead,SysNot,HKCU,AppEvents\Schemes\Apps\.Default\SystemNotification\.Current 
		;Transform, SysNot, deref, %sysnot% 
		SysGet, m, MonitorWorkArea, 1
		y:=(mBottom-52-2),x:=(mRight-330-2),init:=1,VarSetCapacity(vt,4*11),nPar:="31132253353"
		Loop, Parse, nPar
			NumPut(RegisterCallback("DL_Progress","Fast",A_LoopField,A_Index-1),vt,4*(A_Index-1))
	} VarSetCapacity(_cu,255*(!!A_IsUnicode+1)),DllCall("shlwapi\PathCompactPathEx","Str",_cu,"Str",url,"UInt",50,"UInt",0) 
	if customName !=
		_cu := customName
	Progress, Hide CWFAFAF7 CT000020 CB445566 x%x% y%y% w330 h52 B1 FS8 WM700 WS700 FM8 ZH12 ZY3 C11,,%_cu%,$?SciTE4AutoHotkeyv2Install_Progress,Tahoma
	;WinSet, Transparent, 180, $?SciTE4AutoHotkeyv2Install_Progress
	;SoundPlay, %SysNot%
	re := DllCall("urlmon\URLDownloadToFile", "Uint", 0, "Str", url, "Str", file, "Uint", 0, "Uint*", &vt)
	;SoundPlay, %SysNot%
	Progress, Off
	Return re=0 ? 1 : 0
}

DL_Progress( pthis, nP=0, nPMax=0, nSC=0, pST=0 ) {
	global _cu
	If (A_EventInfo=6) 
	{	Progress, Show
		Progress, % (P:=100*nP//nPMax),% "Downloading:     " Round(np/1024,1) " kB / " 
			.  Round(npmax/1024) " kB    [ " p "`% ]",%_cu%
	} Return 0
}
