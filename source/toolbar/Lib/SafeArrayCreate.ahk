;
; File encoding: UTF-8
;

SafeArrayCreate(vt, bounds*)
{
	cDims := bounds._MaxIndex()
	if (cDims = "") || (cDims < 1) || (cDims > 8)
		return
	VarSetCapacity(rgsabound, 8*cDims, 0)
	Loop, %cDims%
		NumPut(bounds[A_Index], rgsabound, 8*(A_Index-1), "Int")
	return (psa:=DllCall("oleaut32\SafeArrayCreate", "ushort", vt, "uint", cDims, "ptr", &rgsabound, "ptr")) ? ComObjParameter(0x2000|vt,psa) : ""
}
