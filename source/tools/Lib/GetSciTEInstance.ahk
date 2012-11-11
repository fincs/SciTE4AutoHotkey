;
; File encoding:  UTF-8
; Author: fincs
;
; Get the current SciTE instance
;

GetSciTEInstance()
{
	olderr := ComObjError()
	ComObjError(false)
	scite := ComObjActive("SciTE4AHK.Application")
	ComObjError(olderr)
	return IsObject(scite) ? scite : ""
}
