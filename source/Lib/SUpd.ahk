;
; File encoding:  UTF-8
;
; Script description:
;	SUpd - SciTE4AutoHotkey update routines
;

#NoEnv

global SciTEDir

SUpd_Main()
{
	SendMode Input
	SetWorkingDir, %A_ScriptDir%
	SplitPath, A_AhkPath,, SciTEDir
	;msgbox %SciTEDir%
	UpdateMain()
	ExitApp
}

SUpd_File(id, out)
{
	fname := A_ScriptDir "\" id ".bin"
	IfNotExist, %fname%
		throw Exception("Unknown file ID", -1, id)
	FileCopy, %fname%, %out%, 1
}
