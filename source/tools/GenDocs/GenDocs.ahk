/* * * * * * * * * * * * * * * * * * * * * *
 *                                         *
 *   GenDocs 2.1 SciTE version             *
 *      GenDocs.ahk - This file contains   *
 *         the main program.               *
 *   This file is part of GenDocs 2.1      *
 *                                         *
 * Changelog:                              *
 *  Version 2.1:                           *
 *      + Unicode support.                 *
 *      + Added support for "properties".  *
 *      * Speed improvements.              *
 *  Version 2.0:                           *
 *       I want to thank animeaime for     *
 *       having contributed a lot to this  *
 *       project. Thank you, animeaime!    *
 *      + Added "Press ESC to exit"        *
 *          feature. (animeaime change)    *
 *      + Added the ability to drop an AHK *
 *          file to the window to select   *
 *          it. (animeaime change)         *
 *      + Added a "Related" tag to select  *
 *          the functions shown in the     *
 *          "Related" section. (animeaime  *
 *          change)                        *
 *      * You can use three or more spaces *
 *          instead of tabs. (animeaime    *
 *          change)                        *
 *      * Some inefficencies were fixed    *
 *          (thx animeaime).               *
 *      * Each windows is now always       *
 *          on top. (animeaime change)     *
 *  Version 1.2 beta:                      *
 *      + Added a prototype of the GUI for *
 *          documentation writing and some *
 *          beta rutines.                  *
 *      + Added status bar that replaces   *
 *          those ugly "Making documenta-  *
 *          tion" dialogs.                 *
 *      * Packed Microsoft's CHM creation  *
 *          utility with UPX               *
 *      * Speeded up utility               *
 *      * Some bug fixes in comment high-  *
 *          lighting                       *
 *      * Fixed CHM creation support which *
 *          creates CHM files that depends *
 *          on some files in my USB drive  *
 *      * Fixed a typo on example.ahk      *
 *      * Fixed some grammatical errors    *
 *  Version 1.2 alpha:                     *
 *      + Added CHM creation support       *
 *      + Added metadata system            *
 *  Version 1.1:                           *
 *      + Simplified documentation format  *
 *      + Changed output directory to      *
 *        %ScriptDir%\%ScriptName%         *
 *      + Added a good-looking GUI         *
 *      + Added command line support       *
 *      * Fixed parameter table generation,*
 *          the program causes an infinite *
 *          loop when no parameters        *
 *          specified.                     *
 *      - Removed hard-to-use XML format.  *
 * * * * * * * * * * * * * * * * * * * * * *
 */

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
#Include %A_ScriptDir%
#Include Util.ahk
#Include BBCode.ahk
#Include AHKCode.ahk
#Include Template.ahk
#Include CHM.ahk
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

progname = GenDocs
version = 2.1
vstatus = for SciTE4AutoHotkey v3
Menu, Tray, Icon, ..\..\toolicon.icl, 15

; Icon constants
ICON_READY := 1
ICON_ERROR := 2
ICON_PARSE := 3
ICON_WRITE := 4
ICON_COPY  := 5
ICON_CHM   := 6

; Set RegEx constants
twoTabsW3 := "(?:\t| {2})(?:\t| {3})"
twoTabsW4 := "(?:\t| {3})(?:\t| {4})"
twoTabsW5 := "(?:\t| {4})(?:\t| {5})"

twoTabs := "(?:"
			. "(?:" twoTabsW3 ")|"
			. "(?:" twoTabsW4 ")|"
			. "(?:" twoTabsW5 ")"
			. ")"

threeTabsW3 := "(?:\t| {2})(?:\t| {3})(?:\t| {3})"
threeTabsW4 := "(?:\t| {3})(?:\t| {4})(?:\t| {4})"
threeTabsW5 := "(?:\t| {4})(?:\t| {5})(?:\t| {5})"

threeTabs := "(?:"
			. "(?:" threeTabsW3 ")|"
			. "(?:" threeTabsW4 ")|"
			. "(?:" threeTabsW5 ")"
			. ")"

; Check command line

comm_n = %0%
if comm_n >= 1
{
	CUI = 1
	file = %1%
	usechm = 0
	if(Lower(file) = "/chm"){
		file = %2%
		usechm = 1
	}
	Gosub Document
	ExitApp
}

; Quick and dirty look for SciTE to grab initial filename.
_DefaultFName =
_SciTE := GetSciTEInstance()
if _SciTE
	_DefaultFName := _SciTE.CurrentFile, _SciTE := ""
/*
; Quick and dirty look for a SciTE window to grab initial filename.
IfWinExist, ahk_class SciTEWindow
{
	scitehwnd := WinExist("")
	WinGetTitle, __SciTETitle, ahk_id %scitehwnd%
	if(RegExMatch(__SciTETitle, "^(.+?) [-*] SciTE4AutoHotkey", __o))
		_DefaultFName = %__o1%
	IfNotExist, %_DefaultFName%
		_DefaultFName =
}
*/

; Generate the GUI

Gui +LabelMain +AlwaysOnTop
Gui, Add, Text, x6 y10 w310 h20, Select your script and click Document.
Gui, Add, Edit, x6 y30 w280 h20 vfile, %_DefaultFName%
Gui, Add, CheckBox, x26 y60 w260 h20 vusechm Checked, Generate CHM documentation
Gui, Add, Button, x286 y30 w30 h20 gSelectFile, ...
Gui, Add, Button, x26 y90 w100 h30 gDocument, &Document
Gui, Add, Button, x186 y90 w100 h30 gExit, Exit
Gui, Add, StatusBar
echo("Ready.", ICON_READY)

if vstatus =
	windowtitle = %progname% v%version%
else
	windowtitle = %progname% v%version% %vstatus%
Gui, Show, w325 h149, %windowtitle%
Send {Right}

Return

SelectFile:
Gui +OwnDialogs
FileSelectFile, selected, 1,, Select file you want to document, AutoHotkey scripts (*.ahk)

if selected =
	return
GuiControl,, file, %selected%
return

MainDropFiles:
selected =
; Use the dropped file (the first *.ahk file)
Loop, Parse, A_GuiEvent, `n
{
    SplitPath, A_LoopField, , , OutExtension
    if(OutExtension = "ahk"){
        selected = %A_LoopField%
        break
    }
}
If selected =
    return
GuiControl,, file, %selected%
return

Document:
if !CUI
{
	Gui, Submit, NoHide
	Gui +OwnDialogs
}

if file =
{
	echo("File error #1: You haven't specified a filename!", ICON_ERROR)
	fanfare2()
	return
}

IfNotExist, %file%
{
	echo("File error #2: File doesn't exist!", ICON_ERROR)
	error_fanfare()
	return
}

; Split the path
SplitPath, file,, filedir,, foldername

; Read the file and extract documentation from it
conts := FileContents(file)

conts := "`n" conts ; Add a new line at top of file for compatibility for putting doc at begin of file
pos := InStr(conts, "`n;`n") ; Get the position of the beginning line
if !pos
{
	; Line not found, tell the user the error and exit
	echo("File error #3: Could not find documentation in code!", ICON_ERROR)
	error_fanfare()
	;MsgBox, 16, GenDocs, Could not find documentation in code!
	return
}

echo("Parsing file...", ICON_PARSE)

StringTrimLeft, conts, conts, 1
nfuncs := 0 ; Number of functions
OnFunc := False
OnSection := False
code = 0 ; Current section

Loop, Parse, conts, `n, `r
{
	nline := A_Index
	line := Trim(A_LoopField)
	if OnFunc
	{
		if(line = ";"){
			; End of function reached
			OnFunc := False
			OnSection := False
			Continue
		}else if RegExMatch(line, "^; (Function|Property): (.*)$", o){
			; Function definition reached, store it
			if(A_IsUnicode && (errOffset:=ContainsUnicode(o2))){
				echo("File error #4: Invalid character '" SubStr(o2,errOffset,1) "' in " Lower(o1) " name " Trim(o2) ".", ICON_ERROR)
				error_fanfare()
				Goto cleanup
			}
			func%nfuncs%_name := Trim(o2)
			func%nfuncs%_isprop := (Lower(o1) = "Property")
			OnSection := False
		}else if RegExMatch(line, "^; Description:$"){
			; Description definition reached
			OnSection := True
			code = 1
		}else if RegExMatch(line, "^; Syntax: (.*)$", o){
			; Syntax definition reached
			func%nfuncs%_syntax := Unescape(Trim(o1))
			OnSection := False
		}else if RegExMatch(line, "^; Parameters:(.*)$", o){
			; Parameters definition reached
			func%nfuncs%_noparam := 0
			if(Lower(Trim(o1)) != "none"){
				OnSection := True
				code = 2
			}else
				OnSection := False
		}else if RegExMatch(line, "^; Return Value:$", o){
			OnSection := True
			code = 5
		}else if RegExMatch(line, "^; Remarks:(.*)$", o){
			; Remarks definition reached
			if(Lower(Trim(o1)) != "none"){
				OnSection := True
				code = 3
			}else
				OnSection := False
		}else if RegExMatch(line, "^; Related:(.*)$", o){
			; Related tag reached, store it
			func%nfuncs%_related := Trim(o1)
			OnSection := True
			code = 6
		}else if RegExMatch(line, "^; Example:(.*)$", o){
			; Example definition reached
			if(Lower(Trim(o1)) != "none"){
				OnSection := True
				code = 4
			}else
				OnSection := False
		}else if(OnSection){
			; This is processing continuations
			if(code != 2){
				RegExMatch(line, "^;" twoTabs "(.*)$", o)
				proc := Trim(o1)
			}
			if code = 1
			{
				description = %proc% ; This also trims the string.
				description_prev := func%nfuncs%_description
				if description_prev =
					description_prev := description
				else
					description_prev .= "`r`n" description
				func%nfuncs%_description := Trim(description_prev)
			}else if code = 2
			{
				;if RegExMatch(line, "^;" twoTabs "((?:\S.*?)?) - (.*)$", o){
				if RegExMatch(line, "^;" twoTabs "(.+?) - (.*)$", o){
					; Parameter reached
					func%nfuncs%_noparam ++
					nparam := func%nfuncs%_noparam
					func%nfuncs%_param%nparam%_name := Trim(o1)
					func%nfuncs%_param%nparam%_description := Trim(o2)
				}else if RegExMatch(line, "^;" threeTabs "(.*)$", o){
					; Continuation of a parameter reached
					np := func%nfuncs%_noparam
					func%nfuncs%_param%np%_description .= "`r`n" Trim(o1)
				}
			}else if code = 3
			{
				remarks = %proc%
				remarks_prev := func%nfuncs%_remarks
				if remarks_prev =
					remarks_prev := remarks
				else
					remarks_prev .= "`r`n" remarks
				func%nfuncs%_remarks := Trim(remarks_prev)
			}else if code = 4
			{
				example = %proc%
				example_prev := func%nfuncs%_example
				if example_prev =
					example_prev := example
				else
					example_prev .= "`r`n" example
				func%nfuncs%_example := Trim(example_prev)
			}else if code = 5
			{
				rval = %proc%
				rval_prev := func%nfuncs%_rval
				if rval_prev =
					rval_prev := rval
				else
					rval_prev .= "`r`n" rval
				func%nfuncs%_rval := Trim(rval_prev)
			}else if code = 6
			{
				related = %proc%
				related_prev := func%nfuncs%_related
				if related_prev =
					related_prev := related
				else
					related_prev .= "`r`n" related
				func%nfuncs%_related := Trim(related_prev)
			}
		}
	}else{
		if(line = ";"){ ; Start of function reached
			OnFunc := True
			nfuncs ++
		}else if RegExMatch(line, "^;: (.+?): (.+)$", o){
			key := Trim(o1)
			value := Trim(o2)
			If key = Title
				; Title definition
				doctitle := value
		}
	}
}

; Prepare directory to store the documentation
IfNotExist, %filedir%\%foldername%\
	FileCreateDir, %filedir%\%foldername%\

; Generate documentation
Loop, %nfuncs%
{ ; For each function
	
	i := A_Index
	
	; Base HTML file
	docu := template
	
	; Retrieve the function name
	funcname := FormatStr(func%i%_name)
	
	if(func%i%_isprop)
		dispname := funcname
	else
		dispname := funcname "()"
	
	echo("Generating documentation for " dispname "...", ICON_WRITE)
	
	; Set the title and header
	StringReplace, docu, docu, [FuncName], %dispname%
	StringReplace, docu, docu, [FuncName], %dispname%
	
	; Description
	description := FormatStr(func%i%_description, 1) ; BBCode allowed
	StringReplace, docu, docu, [Description], %description%
	
	; Syntax
	syntax := FormatStr(func%i%_syntax)
	StringReplace, docu, docu, [Syntax], %syntax%
	
	; Parameters
	noparams := func%i%_noparam ; Number of params
	paramtable := "" ; Parameter array
	if noparams =
		noparams = 0
	if noparams = 0 ; Check for zero parameters
		; In this case show a "None." message instead.
		StringReplace, docu, docu, [ParamTable], <p>None.</p>
	else{ ; Process each parameter
		Loop, %noparams%
		{
			j := A_Index
			
			; Get name and description
			pname := FormatStr(func%i%_param%j%_name)
			pdesc := FormatStr(func%i%_param%j%_description, 1) ; BBCode allowed
			
			; Check for optional parameter
			if(Lower(SubStr(pdesc, 1, 10)) = "(optional)"){
				; Style the "Optional" text
				StringTrimLeft, pdesc, pdesc, 10
				pdesc := "<i>(Optional)</i> " Trim(pdesc)
			}
			
			; Add the parameter
			table := tabletemplate
			StringReplace, table, table, [ParamName], %pname%
			StringReplace, table, table, [ParamDescription], %pdesc%
			paramtable .= (j != 1 ? "`r`n" : "") table ; Append the item to the array
		}
		
		; Add the parameter table
		StringReplace, ptable, ptemplate, [ParamTable], % paramtable
		StringReplace, docu, docu, [ParamTable], % ptable
	}
	
	; Return value
	rval := FormatStr(func%i%_rval, 1) ; BBcode allowed
	if rval =
		rval = <p>None.</p>
	StringReplace, docu, docu, [ReturnValue], % rval
	
	; Remarks and example
	remarks := FormatStr(func%i%_remarks, 1) ; BBCode allowed
	;example := PrepareScript(FormatStr(func%i%_example))
	example := PrepareScript(func%i%_example)
	if remarks =
		remarks = <p>None.</p>
	if example =
		example := PrepareScript("; None.")
	StringReplace, docu, docu, [Remarks], % remarks
	StringReplace, docu, docu, [Example], % example
	
	; Related section
	links := ""
	if func%i%_related =
	{
		; Autobuild a related section
		Loop, %nfuncs%
		{
			j := A_Index
			
			cf := FormatStr(func%j%_name)
			if(cf = funcname) ; Omit the current function
				continue
			
			cfdisp := func%j%_isprop ? cf : (cf "()")
			
			; Add the link
			link := "<a href="".\" cf ".htm"">" cfdisp "</a>"
			if links =
				links := link
			else
				links .= ", " link
		}
	}else{
		tempParse := func%i%_related
		StringReplace, tempParse, tempParse, ````, % Chr(3), All
		StringReplace, tempParse, tempParse, ```,, % Chr(4), All
		Loop, Parse, tempParse, `n, `r
		{
			curL := Trim(A_LoopField)
			StringSplit, RelaLinkTable, curL, `,
			Loop, %RelaLinkTable0%
			{
				j := A_Index
				cft := Trim(RelaLinkTable%j%)
				StringReplace, cft, cft, ``[, % Chr(1), All
				StringReplace, cft, cft, ``], % Chr(2), All
				StringReplace, cft, cft, [bbcode],, UseErrorLevel
				BBCodeTagPresent := ErrorLevel
				cf := FormatStr(cft, 1) ; Get the corresponding function name
				StringReplace, cf, cf, % Chr(1), [, All
				StringReplace, cf, cf, % Chr(2), ], All
				StringReplace, cf, cf, % Chr(3), ````, All
				StringReplace, cf, cf, % Chr(4), ```,, All
				if(cf = funcname) ; Same function reached
					continue ; Omit the current function
				if(!(InStr(cf, "<") || BBCodeTagPresent))
					link := "<a href="".\" cf ".htm"">" cf "()</a>" ; Generating link to function
				else ; BBCode
					link := cf
				; Append link to the link "array"
				if j = 1
					links .= link
				else
					links .= ", " link
			}
			links .= "<br/>`r`n"
		}
		; remove trailing line break
		StringTrimRight, links, links, 7
	}
	; Alternate text if no links.
	if links =
		links = None.
	StringReplace, docu, docu, [LinksToRelatedPages], % links

	; Write the resulting .htm file
	FileWriteEncoding(filedir "\" foldername "\" funcname ".htm", docu)
}

; Write the CSS files
echo("Making CSS files", ICON_COPY)

FileWriteEncoding(filedir "\" foldername "\commands.css", css_commands)
FileWriteEncoding(filedir "\" foldername "\print.css", css_print)

; Generate the CHM file if needed
if usechm
{
	If !IsChmCompilerPresent() ; Check for the CHM help compiler
	{
		echo("CHM Error #1: Could not find the CHM compiler files!", ICON_ERROR)
		error_fanfare()
		Goto cleanup
	}
	echo("Creating CHM file...", ICON_CHM)
	; Create list of files
	Loop, %nfuncs%
	{
		funciname := Trim(func%A_Index%_name)
		funcidisp := func%A_Index%_isprop ? funciname : (funciname "()")

		tfile := filedir "\" foldername "\" funciname ".htm"
		if A_Index = 1
		{
			list = %tfile%
			topics = %funcidisp%
		}else{
			list = %list%`r`n%tfile%
			topics = %topics%`n%funcidisp%
		}
	}
	
	; Add the CSS files
	list = %list%`r`n%filedir%\%foldername%\commands.css`r`n%filedir%\%foldername%\print.css
	Progress, Off
	while(Trim(doctitle) = "")
		InputBox, doctitle, GenDocs, Please type the window title for the CHM file,,,,,,,, %foldername%
	title = %doctitle%
	
	proj := CreateProj("GenDocs", title, list, topics, 2)
	if(!proj || !CompileProj(proj, filedir "\" foldername "\" foldername ".chm"))
	{
		echo("CHM Error #2: CHM creation error! " CHM_Error, ICON_ERROR)
		error_fanfare()
		FreeProj(proj)
		Goto cleanup
	}
	FreeProj(proj)
}

Progress, Off
echo("Documentation created succesfully!", ICON_READY)
fanfare()

; Clean-up

cleanup:

; Free the memory
Loop, %nfuncs%
{
	i := A_Index
	VarSetCapacity(func%i%_name, 0)
	VarSetCapacity(func%i%_isprop, 0)
	VarSetCapacity(func%i%_description, 0)
	VarSetCapacity(func%i%_syntax, 0)
	if(func%i%_noparam != 0)
		Loop % func%i%_noparam
		{
			j := A_Index
			VarSetCapacity(func%i%_param%j%_name, 0)
			VarSetCapacity(func%i%_param%j%_description, 0)
		}
	VarSetCapacity(func%i%_noparam, 0)
	VarSetCapacity(func%i%_rval, 0)
	VarSetCapacity(func%i%_remarks, 0)
	VarSetCapacity(func%i%_related, 0)
	VarSetCapacity(func%i%_example, 0)
}
i := ""
j := ""
doctitle =

return

Exit:
MainClose:
MainEscape:
ExitApp
return

Lower(string){
	StringLower, string, string
	return string
}

echo(txt, icon){
	SB_SetIcon(A_ScriptDir "\gendocs.icl", icon)
	SB_SetText(txt)
}

fanfare(){
	SoundPlay, *64
}

fanfare2(){
	SoundPlay, *-1
}

error_fanfare(){
	SoundPlay, *16
}
