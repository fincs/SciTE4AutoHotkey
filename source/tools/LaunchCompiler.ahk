;
; SciTE4AutoHotkey Compiler Launching Stub
;

#NoEnv
#NoTrayIcon
SendMode Input
SetWorkingDir, %A_ScriptDir%

if 0 = 0
	ExitApp

v2 = %2%
if v2
	v2 = /bin "%v2%"

ahkDir := GetSciTEInstance().ResolveProp("AutoHotkeyDir")

compiler = %ahkDir%\Compiler\Ahk2Exe.exe

IfExist, %ahkDir%\Compiler\Compile_AHK.exe
	RunWait, "%ahkDir%\Compiler\Compile_AHK.exe" "%1%"
else
	RunWait, "%compiler%" /in "%1%" %v2%
