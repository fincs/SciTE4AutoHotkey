;
; File encoding:  UTF-8
;

goto _aaa_skip

UpdateProfile:
StringReplace, lblname, SciTEVersion, %A_Space%, _, All
if IsLabel(lblname := "Update_" lblname)
{
	gosub Update_common
	goto %lblname%
}
SciTEVersion := ""
return

Update_3_beta3:
Update_3_beta4:
gosub Update_old_settings
gosub Create_macro_folder
Update_3_beta5:
gosub Create_extensions
gosub Copy_new_styles
Update_3_rc1:
Update_3.0.00:
Update_3.0.01:
return

Update_common:
FileDelete, %LocalSciTEPath%\_platform.properties
FileDelete, %LocalSciTEPath%\$VER
FileAppend, %CurrentSciTEVersion%, %LocalSciTEPath%\$VER
SciTEVersion := CurrentSciTEVersion
return

Update_old_settings:
FileRead, ov, %LocalSciTEPath%\SciTEUser.properties
if pos := RegExMatch(ov, "sP)# The following settings.+?\R# \[\[.+?locale\.properties=locales\\(.+?)\.locale.+?make\.backup=([01]).+?import Styles\\(.+?)\.style.+?# \]\]", o)
{
	new := SubStr(ov, 1, pos-1)
	locale := SubStr(ov, oPos1, oLen1)
	backup := SubStr(ov, oPos2, oLen2)
	style := SubStr(ov, oPos3, oLen3)
	newheader =
	(LTrim
	# Import the settings that can be edited by the bundled properties editor
	import _config
	)
	new .= newheader SubStr(ov, pos+o)
	FileDelete, %LocalSciTEPath%\SciTEUser.properties
	FileAppend, % new, %LocalSciTEPath%\SciTEUser.properties
	new =
	(LTrim
	# THIS FILE IS SCRIPT-GENERATED - DON'T TOUCH
	locale.properties=locales\%locale%.locale.properties
	make.backup=%backup%
	code.page=0
	output.code.page=0
	save.position=1
	magnification=-1
	import Styles\%style%.style
	)
	FileDelete, %LocalSciTEPath%\_config.properties ; better be safe
	FileAppend, % new, %LocalSciTEPath%\_config.properties
	VarSetCapacity(new, 0), VarSetCapacity(ov, 0)
}else MsgBox RegEx fail`nErrorLevel: %ErrorLevel%`n`nReport this immediately to fincs along with your SciTEUser.properties file
return

Create_macro_folder:
FileCreateDir, %LocalSciTEPath%\Macros
FileCopy, %SciTEDir%\newuser\Macros\*.macros, %LocalSciTEPath%\Macros, 1
return

Create_extensions:
FileAppend, `nimport _extensions, %LocalSciTEPath%\_config.properties
FileMove, %LocalSciTEPath%\_extensions.properties, %LocalSciTEPath%\_extensions%A_TickCount%.properties
FileAppend, # THIS FILE IS SCRIPT-GENERATED - DON'T TOUCH, %LocalSciTEPath%\_extensions.properties
extfolder := LocalSciTEPath "\Extensions"
IfExist, %extfolder%
	FileMoveDir, %extfolder%, %extfolder%%A_TickCount%
FileCreateDir, %extfolder%
return

Copy_new_styles:
stylepath = %LocalSciTEPath%\Styles
defstyles = %A_ScriptDir%\newuser\Styles
IfNotExist, %stylepath%\HatOfGod.style.properties
	FileCopy, %defstyles%\HatOfGod.style.properties, %stylepath%\HatOfGod.style.properties
IfNotExist, %stylepath%\tidRich_Zenburn.style.properties
	FileCopy, %defstyles%\tidRich_Zenburn.style.properties, %stylepath%\tidRich_Zenburn.style.properties
return

_aaa_skip:
_=_
