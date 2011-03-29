;
; File encoding:  UTF-8
; Author: fincs
;
; ComTable: Creates a dispatch table for use with ComDispatch()
;

ComDispTable(methods)
{
	id2method := {}, method2id := {}
	Loop, Parse, methods, `, ;, %A_Space%%A_Tab%
	{
		dispid := A_Index - 1
		StringLower, method, A_LoopField
		if q := InStr(method := Trim(method), "=")
		{
			 aliaslist := Trim(SubStr(method, 1, q-1))
			,ahkmethod := Trim(SubStr(method, q+1))
			Loop, Parse, aliaslist, &
				method2id[Trim(A_LoopField)] := dispid
		}else
			 method2id[method] := dispid
			,ahkmethod := method
		if !(q := IsFunc(ahkmethod)) || q < 2
			return
		id2method[dispid] := ahkmethod
	}
	return [id2method, method2id]
}
