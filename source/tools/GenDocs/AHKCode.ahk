/* * * * * * * * * * * * * * * * * * * * * *
 *                                         *
 *   GenDocs 2.1 SciTE version             *
 *      AHKCode.ahk - This file contains   *
 *         routines to process AHK code.   *
 *   This file is part of GenDocs 2.1      *
 * * * * * * * * * * * * * * * * * * * * * *
 */

PrepareScript(script){
	return HighlightComments(AdaptHTML(GetSource(script)))
}

AdaptHTML(script){
	sp := "&#" Asc(A_Space) ";"
	replacement := sp sp sp sp
	Transform, script, HTML, % script
	script := RegExReplace(script, "([^&])#", "$1&#" Asc("#") ";")
	StringReplace, script, script, `r`n, `n, All
	script := RegExReplace(script, "<br>(</span>)?`n", "$1`n")
	script := RegExReplace(script, "<br>(</span>)?$", "$1")
	StringReplace, script, script, `n, `r`n, All
	StringReplace, script, script, % A_Tab, %replacement%, All
	return script
}

GetSource(script){
	Global filedir
	if RegExMatch(script, "^file:(.*)$", o){
		; File detected, read file
		w_back := A_WorkingDir
		SetWorkingDir, %filedir%
		script := FileContents(o1)
		SetWorkingDir, %w_back%
	}else if RegExMatch(script, "^url:(.*)$", o){
		; URL detected, download file, read it and delete it
		FileDelete, %A_Temp%\GenDocsTmpScript.ahk
		URLDownloadToFile, %o1%, %A_Temp%\GenDocsTmpScript.ahk
		script := FileContents(A_Temp "\GenDocsTmpScript.ahk")
		FileDelete, %A_Temp%\GenDocsTmpScript.ahk
	}else{
		; Normal script detected, nothing to do
	}
	return script
}

HighlightComments(script){
	script2 := ""
	at := A_AutoTrim
	AutoTrim, Off
	spat := "&#" Asc(A_Space) ";"
	Loop, 4
		tabpat .= spat
	StringReplace, script, script, % tabpat, % A_Tab, All
	script := RegExReplace(script, "[^&]#(.+?);", "&#$1" Chr(5))
	Loop, Parse, script, `n, `r
	{
		line := RegExReplace(A_LoopField, "^(;.*)$", "<span class=""CodeCom"">$1</span>")
		line := RegExReplace(line, "(\s+)(;.*)$", "$1<span class=""CodeCom"">$2</span>")
		if A_Index = 1
			script2 := line
		else
			script2 .= "`r`n" line
	}
	AutoTrim, %at%
	StringReplace, script2, script2, % Chr(5), `;, All
	StringReplace, script2, script2, % A_Tab, % tabpat, All
	return script2
}

Unescape(str){
	StringReplace, str, str, ````, % Chr(1), All
	StringReplace, str, str, ``n, `n, All
	StringReplace, str, str, % Chr(1), ``, All
	return str
}

/*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The below section is deprecated.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckIndentation(script){
	script2 := ""
	tabs := 0
	nextAumentTabs := False
	Loop, Parse, script, `n, `r
	{
		If nextAumentTabs
		{
			tabs ++
			nextAumentTabs := False
		}
		line = %A_LoopField%
		ctab := tabs
		If RegExMatch(line, "^}(.*){(\s+;.*)?$"){
			nextAumentTabs := true
			tabs --
		}Else If RegExMatch(line, "^.*{(\s+;.*)?$")
			nextAumentTabs := true
		Else If RegExMatch(line, "^}(.*)(\s+;.*)?$")
			tabs --
		tabpat := ""
		Loop, %tabs%
			tabpat .= "`t"
		If A_Index = 1
			script2 := tabpat line
		Else
			script2 .= "`r`n" tabpat line
	}
	Return script2
}
*/
