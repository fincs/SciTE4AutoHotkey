
GetAutoHotkeyDir()
{
	if A_AhkPath =
		return
	SplitPath, A_AhkPath,, ahkdir
	return ahkdir
}
