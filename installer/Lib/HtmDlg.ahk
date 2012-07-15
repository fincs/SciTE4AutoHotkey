HtmDlg( _URL="", _Owner=0, _Options="", _ODL="," ) {     ; HTML DialogBox v0.57 -- by SKAN
; Topic: www.autohotkey.com/forum/viewtopic.php?t=60215    CD:09-Jul-2010 | LM:05-Aug-2010
; Credit: WebControl Demo by Sean - www.autohotkey.com/forum/viewtopic.php?p=103987#103987

Static _hInst,_hDLG,_DlgP,_B$,_B$L,_pIWEB,_pV,_DlgT,CliC,HtmF=0,_Brush=0,Pntr,PtrS,BDef=1,BEsc=0

 ;ListLines, Off
 If ( A_EventInfo = 0xCBF ) {                                   ; nested Callback Function
   hWnd := _URL,  uMsg := _Owner,  wP := _Options,  lP := _ODL

   If ( uMsg=0x112 && wP=0xF060 )                               ; WM_SYSCOMMAND & SC_ClOSE
     Return DllCall( "DestroyWindow", Pntr,_hDLG ) | ( BDEf:=BEsc )

   If ( uMsg=0x111 && (wP>>16)=0 )                              ; WM_COMMAND & BN_CLICKED
     Return DllCall( "DestroyWindow", Pntr,_hDLG ) | ( BDef := (wP=2) ? BEsc : wP-100  )

   If ( uMsg=0x007 && HtmF=0 )                                  ; WM_SETFOCUS
     Return DllCall( "SetFocus", Pntr,DllCall( "GetDlgItem", Pntr,_hDLG, UInt,100+BDEF, Pntr ) )

   If ( uMsg=0x201 && CliC )                                    ; WM_LBUTTONDOWN
     Return DllCall( "DestroyWindow", Pntr,_hDLG ) |  ( BDEf := 1 )

   If ( uMsg=0x136 && _Brush<>0 )                               ; WM_CTLCOLORDLG
     Return _Brush

   if ( uMsg=0x002 && hWnd=_hDLG )                              ; WM_DESTROY
     Return _Brush := DllCall( "DeleteObject", Pntr,_Brush, UInt ) >> 32

 Return False
 }

 If ! ( _hInst ) {
 Pntr := A_PtrSize ? "Ptr" : "UInt", PtrS := A_PtrSize ? A_PtrSize : 4
 _hInst := DllCall( "GetModuleHandle", Str,A_IsCompiled ? A_ScriptFullpath : A_AhkPath, Pntr )

 _DT := "61160CD3AFCDD0118A3EGC04FC9E26EZQ1GFFFFUCHC88GAZO9G9G1I4DG53G2H53G68G65G6CG6CG2H"
 . "44G6CG67ZL5V64K41G74G6CG41G78G57G69G6EK7BG38G38G35G36G46G39G36G31G2DG33G34G3H41G2DG31"
 . "G31G44G3H2DG41G39G36G42G2DG3H3H43G3H34G46G44G37G3H35G41G32G7DZS14V65KFFFF8ZP14V66KFFF"
 . "F8ZP14V67KFFFF8ZP14V68KFFFF8ZP14V69KFFFF8ZP14V6AKFFFF8ZP14V6BKFFFF8ZP14V6CKFFFF8ZP14V"
 . "6DKFFFF8P"

 Loop 20   ;  Decompressing Nulls : www.autohotkey.com/forum/viewtopic.php?p=198560#198560
  StringReplace,_DT,_DT,% Chr(70+21-A_Index),% SubStr("000000000000000000000",A_Index),All

 Loop % _B$L := VarSetCapacity( _B$, ( _DTLEN := StrLen(_DT) // 2 ), 0 )
  NumPut( "0x" . SubStr(_DT, 2*A_Index-1,2),_B$,A_Index-1,"Char" )  ; Creating Structure
 _pIWEB := &_B$, _pV := &_B$+16, _DlgT := &_B$+32   ; Relevant pointers to Structure

 DllCall( "GetModuleHandle", Str,"atl.dll" ) ? 0 : DllCall( "LoadLibrary", Str,"atl.dll" )
 DllCall( "atl\AtlAxWinInit" ),          _DlgP := RegisterCallback( A_ThisFunc,0,4,0xCBF )
 }

 VarSetCapacity( _W$,_B$L,0 ), DllCall( "RtlMoveMemory", Pntr,&_W$, Pntr,&_B$, Pntr,_B$L )
 _pIWEB := &_W$, _pV := &_W$+16, _DlgT := &_W$+32         ; Relevant pointers to Structure

 Butt:="OK", BWid:=75, BHei:=23, BSpH:=5, BSpV:=8, BAli:=1, Slee:=-1, HtmC:=0, CliC:=0
 HtmD:=0, DlgT:=0, DlgN:=0, DlgX:="", DlgY:="", HtmW:=240, HtmH:=140, Left:=0, TopM:=0
 Loop, Parse, _Options, =%_ODL%, %A_Space%        ; Override Variables with user 'Options'
   A_Index & 1  ? (  __  := (SubStr(A_LoopField,1,1)="_") ? "_" : SubStr(A_LoopField,1,4))
                : ( %__% := A_LoopField )
 
 Cap  := DllCall( "GetSystemMetrics", UInt,4  ) ; SM_CYCAPTION    = Window Caption
 Frm  := DllCall( "GetSystemMetrics", UInt,7  ) ; SM_CXFIXEDFRAME = Window Frame

 NumPut( HtmC<>0 ? 0x200 : 0x0, _W$, 32+68, "UInt" ), DlgD := DlgD ? 0x8000000 : 0x0
 FonS ? NumPut( FonS < 8 ? 8 : ( FonS > 14 ? 14 : FonS ), _W$, 64, "UShort" ) : 0

 If (  ( DlgS := SubStr( DlgS,1,1 ) ) <> ""  )
  _ := ( DlgS = "F" ) ? NumPut( 0x800000C0 | DlgD, _W$, 44, "UInt" ) | ( Cap := 0 )
    :  ( DlgS = "N" ) ? NumPut( 0x80000040 | DlgD, _W$, 44, "UInt" ) | ( Frm := Cap := 0 )
    :  ( DlgS = "B" ) ? NumPut( 0x80800040 | DlgD, _W$, 44, "UInt" ) | ( Cap := 0 ) | ( Frm := 1 )
    :                   NumPut( 0x80C800C0 | DlgD, _W$, 44, "UInt" )

 IfNotEqual,DlgB,, SetEnv,_Brush,% DllCall( "CreateSolidBrush", UInt,DlgB, Pntr )
      
 _hDLG  := DllCall( "CreateDialogIndirectParam", Pntr,_hInst, Pntr,_DlgT, Pntr
,_Owner := ( _Owner <> "" ) ? _Owner : DllCall( "GetShellWindow", Pntr ), Pntr,_DlgP, Pntr,0 )

 VarSetCapacity( _WU, StrLen(_URL) * ( A_IsUnicode ? 1 : 2 ) + 2, 0 )
 A_IsUnicode ? _WU := _URL : DllCall( "MultiByteToWideChar", UInt,0, UInt,0, Pntr,&_URL
                                     , Int,-1, Pntr,&_WU, Int,StrLen(_URL)+1 )

 _hHTM := DllCall( "GetDlgItem", Pntr,_hDLG, UInt,100, Pntr )
 DllCall( "atl\AtlAxGetControl", Pntr,_hHTM, Pntr "P",_ppunk )
 DllCall( NumGet( NumGet( _ppunk+0 )+PtrS*0 ), Pntr,_ppunk, Pntr,_pIWEB, Pntr "P",_ppwb )
 DllCall( NumGet( NumGet( _ppunk+0 )+PtrS*2 ), Pntr,_ppunk ),_pwb := NumGet( _ppwb+0 )
 DllCall( NumGet(_pwb+PtrS*11),Pntr,_ppwb, Pntr,&_WU, Pntr,_pV,Pntr,_pV,Pntr,_pV,Pntr,_pV )
 DllCall( NumGet(_pwb+PtrS*2), Pntr,_ppwb )
 
 DllCall( "SetWindowPos", Pntr,_hHTM,Pntr,0,Int,Left,Int,TopM,Int,HtmW,Int,HtmH,UInt,0x14 )
 IfNotEqual,HtmD,0, Control,Disable,,,ahk_id %_hHTM%

 DlgW := Frm + Left + HtmW + Frm + Left,       ClAW := DlgW - Frm - Frm ; ClientArea Width
 DlgH := Frm + Cap + TopM + HtmH + BSpV + BHei + BSpV + Frm
 DlgX := ( DlgX <> "" ) ? DlgX : ( A_ScreenWidth - DlgW ) // 2
 DlgY := ( DlgY <> "" ) ? DlgY : ( A_ScreenHeight - DlgH ) // 2

 StringReplace, Butt,Butt, /,/, UseErrorLevel
 bCount := ErrorLevel+1
 BY := TopM + HtmH + BSpV
 BX := ( Bali=1 ? ( ( ClAW - (BSpH*(bCount-1)) - (BWid*bCount) ) / 2 )
    :  ( Bali=0 ? ( ( BSpH * 2 ) + ( HtmD ? 0 : Left ) )
    :  ( ClAW - (BSpH*(bCount+1)) - (BWid*bCount) - ( HtmD ? 0 : Left ) ) ) )

 Loop, Parse, Butt, /   ;  SetWindowPos flags = SWP_SHOWWINDOW|SWP_NOACTIVATE|SWP_NOZORDER
   DllCall( "SetWindowPos", Pntr,BH:=DllCall( "GetDlgItem", Pntr,_hDLG, UInt,100+A_Index, Pntr )
                        , Pntr,0, Int,BX, Int,BY, Int,BWid, Int,BHei, UInt,0x40|0x10|0x4 )
 , DllCall( "SetWindowText", Pntr,BH, Str,A_LoopField ),   BX := BX + BSpH + BWid
 , _ := ( BNoT<>"" ) ? DllCall( "uxtheme\SetWindowTheme", Pntr,BH, Pntr,0, Pntr "P",0 ) : 0
 , _ := ( BSFl<>"" ) ? DllCall( "SetWindowLong", Pntr,BH, Int,-16, UInt,0x50018000 ) : 0

 BDef := ( BDef < 1 || BDef > bCount ) ? 1 : BDef ; Force Default Button
 DllCall( "SendMessage", Pntr,_hDLG, UInt,0x401, Pntr,100+BDef, Pntr,0 )    ;  DM_SETDEFID
 
 DllCall( "SetWindowText", Pntr,_hDLG, Str,Titl ? Titl : A_ScriptName ) ; Set Dialog Title
 DllCall( "SetWindowPos", Pntr,_hDLG, Pntr,DlgT ? -1 : 1, Int,DlgX, Int,DlgY, Int,DlgW, Int
                        , DlgH, UInt,0x10 )         ; DlgTopmost ? HWND_TOPMOST : HWND_TOP

 While ( nReady <> 4 && DlgW<>"" )  ;  wait until webpage-load adapted from Seans's IE.ahk
   Sleep % 1 + ( DllCall( NumGet(NumGet(1*_ppwb)+PtrS*56 ), Pntr,_ppwb, UintP,nReady ) >> 32 )
 Sleep, %Slee%

 DllCall( "ShowWindow", Pntr,_hDLG, Int,DlgN ? 8 : 5 ) ; DlgNA ? SW_SHOWNA : SW_SHOW
 IfNotEqual,HtmF,0, ControlFocus,, ahk_ID %_hDLG%
 WinWaitClose, ahk_id %_hDLG%,, %Time%
 TimedOut := Errorlevel  ? DllCall( "EndDialog", Pntr,_hDLG, Pntr,0 ) : 0
 IfNotEqual,AltR,, IfGreater,BDef,0, StringSplit,B,Butt,/
 DllCall( "SetLastError", UInt,TimedOut ? 1 : 0 )
 ListLines, On
Return AltR ? B%BDef% : BDef
}

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \
>-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  O P T I O N S  -  -<
\- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - /

Usage: HtmDlg( URL, hwndOwner, Options, OptionsDelimiter )

Parameters :

URL              - A valid URL supported by Internet Explorer including Res:// and File://

hWndOwner        - Handle to the parent window. If invalid handle or 0 ( zero ) is passed,
                   the dialog will have a taskbar button. Passing "" as a parameter will
                   set 'Progman' the owner, thereby supressing the 'Taskbar Button'.

Options          - A series of 'variable overrides' delimited with character specified in
                   'Optionsdelimiter'. Please refer 'VARIABLE OVERRIDES' below.

OptionsDelimiter - The delimiter used in seperating 'variable overrides'


;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;  * * *   V A R I A B L E   O V E R R I D E S   * * *
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


Important Note: leading 4 characters of a variable will be sufficient.
                for eg.: Instead of 'AltReturn=1' you may use 'AltR=1'


DlgXpos         = X coordinate in pixels, relative to screen
                  Dialog is horizontally centered by default

DlgYpos         = Y coordinate in pixels, relative to screen
                  Dialog is vertically centered by default

DlgTopmost      = 1 will set the Dialog 'Always-on-Top'
                  0 is default

DlgDisable      = 1 will disable the Dialog window
                  No default value

                  Caution:
                  Since there is no way to interact, you may opt to TimeOut the Dialog

DlgStyle        = Frame or NoFrame or Border. Leading character is sufficient, like: F-N-B
                  Default is Caption

                  Note on Styles used:

                  Frame   = WS_POPUP | DS_MODALFRAME
                  NoFrame = WS_POPUP | DS_SETFONT
                  Border  = WS_POPUP | DS_SETFONT | WS_BORDER
                  Caption = WS_POPUP | DS_MODALFRAME | WS_CAPTION | WS_SYSMENU

                  WS_DISABLED is additionally set when DlgDisable=1

DlgNoActivate   = 1 will Show the Dialog without activating it
                  0 is default

DlgBgColor      = ColorRef.  eg: 0x0000FF is Red / Invalid ColorRef will result in Black.

DlgWait         = 1 will delay Dialog from being shown - until HTM is fully loaded
                  
Sleep           = MilliSeconds ( Will be used just before Dialog is shown )
                  Default value is -1, 'No sleep'

Title           = Captionbar Text
                  Default is A_ScriptName

AltReturn       = 1 will return Button-text
                  0 is default and Button-instance will be returned

TimeOut         = Seconds
                  No default value

                  Note: A_LastError will be true when a TimeOut occurs

ClickClose      = 1
                  Default value is 0
                  
                  Note:
                  Mouse L-Click on window's unoccupied clientarea' will close the dialog

                  Tip: Use following to simulate a unobtrusive message ( like TrayTip )
                  DlgTopmost=1, HtmD=1, DlgNA=1, DlgStyle=Border, BHei=0, BSpV=0, Clic=1
                  
LeftMargin      = Spacing in Pixels ( on the left/right sides of WebControl )
                  Default value is 0

TopMargin       = Spacing in Pixels ( above the WebControl )
                  Default value is 0

FonName           ( Not implemented yet )
                  Default is 'MS Shell Dlg' and equivalent

FonSize         = Pointsize ( text size of Button-labels - restricted to 8,10,12,14 )
                  Default value is 8
                  
HtmClientEdge   = 1 to set WS_EX_CLIENTEDGE
                  Default value is 0

HtmDisable      = 1 to disable
                  Default value is 0

HtmWidth        = Width of WebControl in Pixels
                  Default value is 240

HtmHeight       = Height of WebControl in pixels
                  Default value is 140

HtmFocus        = 1 will activate the dialog and WebControl will have input focus
                  Default value is 0

                  Note: DlgNoActivate option will lose effect.
                        For best result, use this option along with DlgWait=1

Buttons         = Button labels seperated with "/"  eg: Buttons=Yes/No/Cancel
                  Default Button is "OK"

BDefault        = Instance of Default Button. eg: To make 3rd Button default, use BDef=3
                  Default forced value is 1

BEscape         = Instance of Button to return when dialog is closed or {Esc} is pressed
                  Default is 0

BWidth          = Button Width in Pixels
                  Default Value is 75

BHeight         = Button Height in Pixels
                  Default value is 23

BSpHorizontal   = Pixels ( affects the spacing on the sides of a button )

BSpVertical     = Pixels ( affects the spacing above/below a button )

BAlign          = 0 or 1 or 2  ( for Left, Center, Right alignment of buttons )
                  Default is 1

BNoTheme        = 1 will remove theme from buttons ( XP & greater )
                  No default value

BSFlat          = 1 will flatten the button by removing the 3D edge - requires BNoTheme=1
                  No default value
                  
;< - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - >

*/
