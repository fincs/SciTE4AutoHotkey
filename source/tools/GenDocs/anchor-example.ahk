#Include Anchor.ahk

DllCall("QueryPerformanceFrequency", "Int64P", freq)
Gui, +Resize +MinSize
Gui, Add, Edit, vMyEdit w400 h150, Resize this window
Gui, Add, Button, vMyButton x300 y160 Default gWin2, Open Window 2
Gui, Add, GroupBox, vMyGroup Section xm h10 w250, Relative positions are also supported ...
Gui, Add, ComboBox, vMyCombo Section xs+50 ys+25, Item 1|Item 2||Item 3
Gui, Add, Text, vMyText ys, Select
GuiControl, Focus, MyButton
Gui, Show, , Anchor Example
Gui, 2:Default
Gui, +Resize +MinSize
Gui, Add, Text, , More sizing...
Gui, Add, ListBox, vLB Section xm r8, Item 1|Item 2||Item 3
Gui, Add, Edit, vEdit ys r8
Gui, Add, Button, vCloseButton w50 gGuiClose, Close

Gui, 1:Default
Return

F10:: ; reset control position
GuiControl, Move, MyEdit, w100 h100 ; move control to a size relative to current Gui dimensions
Anchor("MyEdit") ; reset by passing only the first parameter
GuiWidth++
Gui, Show, w%GuiWidth% ; move the GUI to evoke GuiSize method
Return

Win2:
Gui, 2:Show, , Window
Return

GuiSize:
DllCall("QueryPerformanceCounter", "Int64P", t0)
Anchor("MyEdit", "wh")
Anchor("MyButton", "xy")
Anchor("MyGroup", "yw")
Anchor("MyCombo", "y")
Anchor("MyText", "y")
GuiWidth := A_GuiWidth
DllCall("QueryPerformanceCounter", "Int64P", t1)
Return

2GuiSize:
Anchor("LB", "w0.5 h")
Anchor("Edit", "x0.5 w0.5 h")
Anchor("CloseButton", "x0.75 y")
Return

GuiEscape:
GuiClose:
ExitApp
