/* * * * * * * * * * * * * * * * * * * * * *
 *                                         *
 *   GenDocs 2.1 SciTE version             *
 *      BBCode.ahk - This file contains    *
 *         routines to handle BBCode.      *
 *   This file is part of GenDocs 2.1      *
 * * * * * * * * * * * * * * * * * * * * * *
 */

; Adapted from http://www.autohotkey.com/forum/viewtopic.php?t=3297
BBCode2HTML(code){
	atstate := A_AutoTrim
	htmlcode := ""
	AutoTrim, Off
	Loop, Parse, code, `n, `r
	{
		; Current line
		bbcode = %A_LoopField%
		
		IfInString, bbcode,[code]
			addSpaces = 1
		IfInString, bbcode,[/code]
			addSpaces = 2
		
		if addSpaces = 1
		{
			StringReplace, bbcode, bbcode, % A_Tab, &nbsp`;&nbsp`;&nbsp`;&nbsp`;, All
			IfInString, bbcode, % A_Space A_Space A_Space
				StringReplace, bbcode, bbcode, % A_Space A_Space A_Space, &nbsp`;&nbsp`;&nbsp`;, All
			else
				IfInString, bbcode, % A_Space A_Space
					StringReplace, bbcode, bbcode, % A_Space A_Space, &nbsp`;&nbsp`;, All
		}
		
		; Image tags
		StringReplace, bbcode, bbcode, [img], <img src=, All
		StringReplace, bbcode, bbcode, [/img], >, All
		
		;-----------------Font size tag-------------------------------------
		IfInString, bbcode, [size=
		{
			StringSplit, size_array, bbcode, ]
			Loop, %size_array0%
			{
				StringTrimLeft, this_size, size_array%a_index%, 0
				IfInString, this_size, [size
				{
					StringReplace, this_size, this_size, [size=
					StringRight, this_size, this_size, 2
					this_size = %this_size%
					StringReplace, bbcode, bbcode, %this_size%]
					if this_size between 0 and 8
						this_size = 1
					else if this_size between 9 and 10
						this_size = 2
					else if this_size between 11 and 12
						this_size = 3
					else if this_size between 13 and 14
						this_size = 4
					else if this_size between 15 and 18
						this_size = 5
					else if this_size between 19 and 24
						this_size = 6
					else
						this_size = 7
					StringReplace, bbcode, bbcode, [size=, <font size = "%this_size%">
				}
			}
		}
		
		;-------------------E-mail tag---------------------
		IfInString, bbcode, [email]
		{
			StringSplit, email_array, bbcode, ]
			Loop, %email_array0%
			{
				StringTrimLeft, this_email, email_array%a_index%, 0
				IfInString, this_email, [/email
				{
					StringReplace, this_email, this_email, [/email
					StringReplace, bbcode, bbcode, [email], <a href="mailto:%this_email%">
				}
			}
		}
		StringReplace, bbcode, bbcode, [email=, <a href=, All
		StringReplace, bbcode, bbcode,[/email], </a>, all
		
		;-----------------------Text alignment tags----------------------
		StringReplace, bbcode, bbcode, [Center], <div align="Center">, All
		StringReplace, bbcode, bbcode, [/Center], </div>, All
		StringReplace, bbcode, bbcode, [left], <div align="left">, All
		StringReplace, bbcode, bbcode, [/left], </div>, All
		StringReplace, bbcode, bbcode, [Right], <div align="Right">, All
		StringReplace, bbcode, bbcode, [/Right], </div>, All

		;---------------------URL and AutoHotkey help tags------------------------
		IfInString, bbcode, [url]
		{
			StringSplit, word_array, bbcode, ]
			Loop, %word_array0%
			{
				StringTrimLeft, this_word, word_array%a_index%, 0
				IfInString, this_word, [/url
				{
					StringReplace, this_word, this_word, [/url
					StringReplace, bbcode, bbcode, [url],<a href="%this_word%">
				}
			}
		}
		IfInString, bbcode, [ahk]
		{
			StringSplit, word_array, bbcode, ]
			Loop, %word_array0%
			{
				StringTrimLeft, this_word, word_array%a_index%, 0
				IfInString, this_word, [/ahk
				{
					StringReplace, this_word, this_word, [/ahk
					StringReplace, bbcode, bbcode, [ahk]
					, <a href="http://www.autohotkey.com/docs/commands/%this_word%.htm">
				}
			}
		}
		bbcode := RegExReplace(bbcode, "\[ahk=(.*?)\]"
			, "<a href=""http://www.autohotkey.com/docs/commands/$1.htm"">")
         
		StringReplace, bbcode, bbcode, [/ahk], </a>, All
		StringReplace, bbcode, bbcode, [url=, <a href=, All
		StringReplace, bbcode, bbcode, [/url], </a>, All
		
		;------------------------Font style tags---------------------------
		StringReplace, bbcode, bbcode, [s], <strike>, All
		StringReplace, bbcode, bbcode, [/s], </strike>, All
		StringReplace, bbcode, bbcode, [font=, <font face=, All
		StringReplace, bbcode, bbcode, [size=, <font size=, All
		StringReplace, bbcode, bbcode, [/size], </font>, All
		StringReplace, bbcode, bbcode, [Color=, <font Color=, All
		StringReplace, bbcode, bbcode, [/Color], </font>, All
		StringReplace, bbcode, bbcode, [b], <b>, All
		StringReplace, bbcode, bbcode, [/b], </b>, All
		StringReplace, bbcode, bbcode, [i], <i>, All
		StringReplace, bbcode, bbcode, [/i], </i>, All
		StringReplace, bbcode, bbcode, [u], <u>, All
		StringReplace, bbcode, bbcode, [/u], </u>, All
		StringReplace, bbcode, bbcode, [i], <i>, All
		StringReplace, bbcode, bbcode, [/i], </i>, All
		
		;-------------------------Lists------------------------------------
		StringReplace, bbcode, bbcode, [list], <ul>, All
		StringReplace, bbcode, bbcode, [list=1], <ol>, All
		StringReplace, bbcode, bbcode, [list=i], <ol type="I">, All
		StringReplace, bbcode, bbcode, [list=a], <ol type="a">, All
		StringReplace, bbcode, bbcode, [/list], </ul>, All
		StringReplace, bbcode, bbcode, [br], <br/>, All
		IfInString, bbcode, [*]
		{
			StringReplace, bbcode, bbcode, [*], <li>, All
			bbcode = %bbcode%</li>
		}
		
		;-----------------------Code tags--------------------------------
		StringReplace, bbcode, bbcode, [code], <pre class="NoIndent"><br>
		StringReplace, bbcode, bbcode, [/code], </pre>
		
		;-----------------------Finish-----------------------------------
		StringReplace, bbcode, bbcode, [, <, All
		StringReplace, bbcode, bbcode, ], >, All
		
		; Append the converted line to the final output
		if bbcode not contains <li>,</li>,<ul>,</ul>
			htmlcode .= ((A_Index = 1) ? bbcode : "`r`n" bbcode) "<br/>"
		else
			htmlcode .= (A_Index = 1) ? bbcode : "`r`n" bbcode
	}
	
	; Preprocess scripts in code tags
	Loop
	{
		if !InStr(htmlcode, "<pre class=""NoIndent""><br>")
			break
		d := InStr(htmlcode, "<pre class=""NoIndent""><br>")
		s := InStr(htmlcode, "<br>", d)
		u := InStr(htmlcode, "</pre>", s)
		posi := d + StrLen("<pre class=""NoIndent"">") - 1
		p1 := SubStr(htmlcode, 1, posi)
		code := SubStr(htmlcode, posi+1, u - posi - 1)
		p2 := SubStr(htmlcode, u)
		StringTrimLeft, code, code, 4
		code := PrepareScript(code)
		htmlcode := p1 code p2
	}
	
	; Remove trailing </br>
	StringTrimRight, htmlcode, htmlcode, 5
	
	; Return
	AutoTrim, %atstate%
	return htmlcode
}

GetTag(tag){
	StringTrimLeft, tag, tag, 1
	StringTrimRight, tag, tag, 1
	return tag
}

IsBBCodeTag(tag){
	StringTrimLeft, tag, tag, 1
	StringTrimRight, tag, tag, 1
	if(SubStr(tag, 1, 1) = "/")
		StringTrimLeft, tag, tag, 1
	StringLower, tag, tag
	if tag in b,i,u,s,quote,code,list,img,url,email,br,ahk
		return true
	if not InStr(tag, "=")
		return false
	pos := InStr(tag, "=")
	a := SubStr(tag, 1, pos-1)
	if a not in quote,list,url,email,font,size,color,ahk
		return false
	return true
}