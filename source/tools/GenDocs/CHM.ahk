/* * * * * * * * * * * * * * * * * * * * * *
 *                                         *
 *   GenDocs 2.1 SciTE version             *
 *      CHM.ahk - This file contains       *
 *        routines to handle CHM projects. *
 *   This file is part of GenDocs 2.1      *
 * * * * * * * * * * * * * * * * * * * * * *
 */

IsChmCompilerPresent(){
	a := FileExist(A_ScriptDir "\hhc.exe") != ""
	a &= FileExist(A_ScriptDir "\hha.dll") != ""
	return a
}

CreateProj(name, title, filelist, topics, ignore=0){
	Global CHM_Error
	
	If filelist =
		return ""
	IfExist, %A_Temp%\%name%
		FileRemoveDir, %A_Temp%\%name%, 1
	FileCreateDir, %A_Temp%\%name%
	projhandle = %A_Temp%\%name%\project.hhp
	Loop, Parse, filelist, `n, `r
	{
		firstfile = %A_LoopField%
		Break
	}
	projtpt =
	(LTrim Join`r`n
[OPTIONS]
Compiled file=%A_Temp%\%name%\compiled.chm
Contents file=%A_Temp%\%name%\conttbl.hhc
Default topic=%firstfile%
Title=%title%

[FILES]
%filelist%

[INFOTYPES]
	)
	if(errOffset:=ContainsUnicode(projtpt)){
		CHM_Error := "Invalid path character: '" SubStr(projtpt,errOffset,1) "'"
		return ""
	}
	FileWriteEncoding(projhandle, projtpt)
	conthandle = %A_Temp%\%name%\conttbl.hhc
	cttable =
	(LTrim Join`r`n
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<BODY>
<OBJECT type="text/site properties">
<param name="ImageType" value="Folder">
</OBJECT>
<UL>
	)
	filedecla = 
	(LTrim Join`r`n
<LI> <OBJECT type="text/sitemap">
<param name="Name" value="?Name?">
<param name="Local" value="?File?">
</OBJECT>
	)
	StringSplit, top, topics, `n, `r
	StringReplace, filelist, filelist, `n, `n, UseErrorLevel
	limit := ErrorLevel + 2 - ignore
	Loop, Parse, filelist, `n, `r
	{
		ffile = %A_LoopField%
		fname := top%A_Index%
		fname = %fname%
		cfd := filedecla
		SplitPath, ffile, ffile
		StringReplace, cfd, cfd, ?Name?, %fname%
		StringReplace, cfd, cfd, ?File?, %ffile%
		if(A_Index = limit)
			break
		cttable .= "`r`n" cfd
	}
	endtpt =
	(LTrim Join`r`n
</UL>
</BODY></HTML>
	)
	cttable .= "`r`n" endtpt
	if(errOffset:=ContainsUnicode(cttable)){
		CHM_Error := "Invalid function character: '" SubStr(cttable,errOffset,1) "'"
		return ""
	}
	FileWriteEncoding(conthandle, cttable)
	return A_Temp "\" name
}

CompileProj(projhandle, output){
	fileproj = %projhandle%\project.hhp
	compiled = %projhandle%\compiled.chm
	RunWait, "%A_ScriptDir%\hhc.exe" "%fileproj%",, Hide
	IfNotExist, %compiled%
		return False
	FileDelete, %output%
	FileMove, %compiled%, %output%
	return 1
}

FreeProj(projhandle){
	FileRemoveDir, %projhandle%, 1
}
