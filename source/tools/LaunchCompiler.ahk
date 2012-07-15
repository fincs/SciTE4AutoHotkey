;
; File encoding:  UTF-8
; Platform:  Windows XP/Vista/7
; Author:    A.N.Other <myemail@nowhere.com>
;
; Script description:
;	Template script
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

compiler = ..\..\Compiler\Ahk2Exe.exe
;if v2 && FileExist("..\..\AutoHotkey_L\Compiler\Ahk2Exe.exe")
;	compiler = ..\..\AutoHotkey_L\Compiler\Ahk2Exe.exe

IfExist, ..\..\Compiler\Compile_AHK.exe
	RunWait, ..\..\Compiler\Compile_AHK.exe "%1%"
else
	RunWait, %compiler% /in "%1%" %v2%
