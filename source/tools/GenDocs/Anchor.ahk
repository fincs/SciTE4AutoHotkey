;: Title: Anchor 4.1 - by Titan

; This is an example.
; I'm using 3 spaces as a tab, but
; you can use a real tab or 4/5 spaces.

;
; Function: Anchor
; Description:
;      Defines how controls should be automatically positioned relatively to the new dimensions of a GUI when resized.
; Syntax: Anchor(cl[, a = "", r = 0])
; Parameters:
;      cl - a control HWND, associated variable name or ClassNN to operate on
;      a - (optional) one or more of the anchors: 'x', 'y', 'w' (width) and 'h' (height),
;         optionally followed by a relative factor, e.g. x h0.5
;      r - (OptIoNal) any SetWindowPos ([url]http://msdn2.microsoft.com/en-us/library/ms633545.aspx[/url]) flags,
;         SWP_NOZORDER is automatically applied to retain the current Z order
; Remarks:
;      I think none...
; Related: [bbcode]None.
; Example:
;      file:anchor-example.ahk
;

Anchor(cl, a = "", r = 0) {
	static d, g, sd = 12, sg := 13, sc = 0, k = 0xffff, iz = 0, bx, by
	If !iz
		iz := 1, VarSetCapacity(g, sg * 99, 0), VarSetCapacity(d, sd * 200, 0)
	If cl is xdigit
		c = %cl%
	Else {
		GuiControlGet, c, Hwnd, %cl%
		If ErrorLevel {
			Gui, %A_Gui%:+LastFound
			ControlGet, c, Hwnd, , %cl%
		}
	}
	If !(A_Gui or c) and a
		Return
	cg := (A_Gui - 1) * sg
	Loop, %sc%
		If NumGet(d, z := (A_Index - 1) * sd) = c {
			p := NumGet(d, z + 4, "UInt64"), l := 1
				, x := p >> 48, y := p >> 32 & k, w := p >> 16 & k, h := p & k
				, gw := (gh := NumGet(g, cg + 1)) >> 16, gh &= k
			If a =
				Break
			Loop, Parse, a, xywh
				If A_Index > 1
				{
					v := SubStr(a, l, 1)
					If v in y,h
						n := A_GuiHeight - gh
					Else n := A_GuiWidth - gw
					b = %A_LoopField%
					%v% += n * (b + 0 ? b : 1), l += StrLen(A_LoopField) + 1
				}
				Return, DllCall("SetWindowPos", "UInt", c, "Int", 0
					, "Int", x, "Int", y, "Int", w, "Int", h, "Int", r | 4)
		}
	ControlGetPos, x, y, w, h, , ahk_id %c%
	If !p {
		If NumGet(g, cg, "UChar") != A_Gui {
			Gui, %A_Gui%:+LastFound
			WinGetPos, , , , gh
			gh -= A_GuiHeight
			VarSetCapacity(bdr, 63, 0)
				, DllCall("GetWindowInfo", "UInt", WinExist(), "UInt", &bdr)
				, NumPut(A_Gui, g, cg, "UChar")
				, NumPut(A_GuiWidth << 16 | A_GuiHeight, g, cg + 1, "UInt")
				,  NumPut((bx := NumGet(bdr, 48)) << 32
				| (by := gh - NumGet(bdr, 52)), g, cg + 5, "UInt64")
		}
		Else b := NumGet(g, cg + 5, "UInt64"), bx := b >> 32, by := b & 0xffffffff
	}
	s := x - bx << 48 | y - by << 32 | w << 16 | h
	If p
		NumPut(s, d, z + 4, "UInt64")
	Else NumPut(c, d, sc * 12), NumPut(s, d, sc * 12 + 4, "UInt64"), sc++
}