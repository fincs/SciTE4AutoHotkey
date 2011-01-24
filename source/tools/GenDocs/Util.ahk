/* * * * * * * * * * * * * * * * * * * * * *
 *                                         *
 *   GenDocs 2.1 SciTE version             *
 *      Util.ahk - This file contains      *
 *         helper routines.                *
 *   This file is part of GenDocs 2.1      *
 * * * * * * * * * * * * * * * * * * * * * *
 */

; Format a string to be outputted to the generated HTML
FormatStr(str, bbcode = 0){
	d := Prepare(Trim(str))
	StringReplace, d, d, % "&#" Asc(",") ";", `,, All
	StringReplace, d, d, `n, <br>, All
	if bbcode
		return BBCode2HTML(d)
	else
		return d
}

; Prepare a string for BBCode processing
Prepare(string){
	open := "&#" Asc("[") ";"
	close := "&#" Asc("]") ";"
	StringReplace, string, string, #, % "&#" Asc("#") ";", All
	StringReplace, string, string, <, % "&#" Asc("<") ";", All
	StringReplace, string, string, >, % "&#" Asc(">") ";", All
	StringReplace, string, string, [FuncName], % open "FuncName" close, All
	StringReplace, string, string, [Description], % open "Description" close, All
	StringReplace, string, string, [Syntax], % open "Syntax" close, All
	StringReplace, string, string, [ParamTable], % open "ParamTable" close, All
	StringReplace, string, string, [ReturnValue], % open "ReturnValue" close, All
	StringReplace, string, string, [Remarks], % open "Remarks" close, All
	StringReplace, string, string, [LinksToRelatedPages], % open "LinksToRelatedPages" close, All
	StringReplace, string, string, [Example], % open "ExampleScript" close, All
	StringReplace, string, string, [ParamName], % open "ParamName" close, All
	StringReplace, string, string, [ParamDescription], % open "ParamDescription" close, All
	Loop
	{
		if InStr(string, "["){
			pos := InStr(string, "[")
			endpos := InStr(string, "]", 0, pos)
			tag := SubStr(string, pos, endpos-pos+1)
			a := SubStr(string, 1, pos-1)
			b := SubStr(string, endpos+1)
			replacement := (!IsBBCodeTag(tag)) ? (open GetTag(tag) close) : "&#01;" GetTag(tag) "&#02;"
			string := a replacement b
		}else
			break
	}
	StringReplace, string, string, &#01;, [, All
	StringReplace, string, string, &#02;, ], All
	return string
}

; Write a file with optional encoding
FileWriteEncoding(file, contents, encoding="UTF-8"){
	FileDelete, %file%
	if A_IsUnicode
		FileAppend, % contents, %file%, %encoding%
	else
		FileAppend, % contents, %file%
}

; Read a file
FileContents(file){
	FileRead, var, *t %file%
	if(!A_IsUnicode){
		; Encoding sanity checks
		if(SubStr(var, 1, 3) = "ï»¿") ; Remove UTF-8 BOM
			StringTrimLeft, var, var, 3
		else if(SubStr(var, 1, 2) = "ÿþ") ; Err on UTF-16 files
			return ""
	}
	return var
}

; Verify if a string contains Unicode characters (>127)
ContainsUnicode(name)
{
	Loop, % StrLen(name)
		if(Asc(SubStr(name, A_Index, 1)) > 127)
			return A_Index
	return 0
}
