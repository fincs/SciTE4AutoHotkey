
WipeProfile(profile)
{
	RemoveDir(profile)
	; Only remove these two if they're empty
	FileRemoveDir, %A_MyDocuments%\AutoHotkey\Lib
	FileRemoveDir, %A_MyDocuments%\AutoHotkey
}
