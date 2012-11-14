
UninstallOldBetas(user := "ask")
{
	inst := RemoveDir(ahkPath "\SciTE_beta1")
	inst |= RemoveDir(ahkPath "\SciTE_beta2")
	inst |= RemoveDir(ahkPath "\SciTE_beta3")
	oldAHKL := inst
	inst |= RemoveDir(ahkPath "\SciTE_beta4")
	inst |= RemoveDir(ahkPath "\SciTE_beta5")
	inst |= RemoveDir(ahkPath "\SciTE_rc1")
	if inst
	{
		if oldAHKL
		{
			FileDelete, %ahkPath%\AutoHotkey_La.exe
			FileDelete, %ahkPath%\AutoHotkey_Lw.exe
			FileDelete, %ahkPath%\AutoHotkey_L64.exe
			FileDelete, %ahkPath%\AutoHotkey_L.chm
			FileDelete, %ahkPath%\AutoHotkey_L.chw
		}
		RegDelete, HKCR, AutoHotkeyScript\Shell\EditSciTEBeta
		profile = %A_MyDocuments%\AutoHotkey\SciTE
		IfExist, %profile%
		{
			if user = ask
			{
				MsgBox, 52, %uititle%, Do you want to remove the user profile?
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
