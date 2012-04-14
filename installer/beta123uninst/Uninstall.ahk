
UninstallOldBetas(user="ask")
{
	ahkdir := GetAutoHotkeyDir()
	if !ahkdir
	{
		MsgBox, 16, Uninstaller, Failed to find AutoHotkey folder!
		ExitApp
	}
	inst := _RemoveDir(ahkdir "\SciTE_beta1")
	inst |= _RemoveDir(ahkdir "\SciTE_beta2")
	inst |= _RemoveDir(ahkdir "\SciTE_beta3")
	oldAHKL := inst
	inst |= _RemoveDir(ahkdir "\SciTE_beta4")
	inst |= _RemoveDir(ahkdir "\SciTE_beta5")
	inst |= _RemoveDir(ahkdir "\SciTE_rc1")
	if inst
	{
		if oldAHKL
		{
			FileDelete, %ahkdir%\AutoHotkey_La.exe
			FileDelete, %ahkdir%\AutoHotkey_Lw.exe
			FileDelete, %ahkdir%\AutoHotkey_L64.exe
			FileDelete, %ahkdir%\AutoHotkey_L.chm
			FileDelete, %ahkdir%\AutoHotkey_L.chw
		}
		RegDelete, HKCR, AutoHotkeyScript\Shell\EditSciTEBeta
		profile = %A_MyDocuments%\AutoHotkey\SciTE
		IfExist, %profile%
		{
			if user = ask
			{
				MsgBox, 52, Uninstaller, Do you want to remove the user profile?
				IfMsgBox, Yes
					user := true
				else
					user := false
			}
			if user
				WipeProfile(profile)
		}
	}
	return inst
}

WipeProfile(profile)
{
	_RemoveDir(profile)
	; Only remove these two if they're empty
	FileRemoveDir, %A_MyDocuments%\AutoHotkey\Lib
	FileRemoveDir, %A_MyDocuments%\AutoHotkey
}

_RemoveDir(dir)
{
	IfExist, %dir%
	{
		FileRemoveDir, %dir%, 1
		return 1
	}else
		return 0
}
