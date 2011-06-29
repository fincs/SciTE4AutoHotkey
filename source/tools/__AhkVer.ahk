FileDelete, %A_Temp%\__AhkVer.txt
FileAppend, % "AutoHotkey v" A_AhkVersion (A_PtrSize ? A_PtrSize = 8 ? " (64-bit)" : " (32-bit " (A_IsUnicode ? "Unicode)" : "ANSI)") : " (Basic)"), %A_Temp%\__AhkVer.txt
