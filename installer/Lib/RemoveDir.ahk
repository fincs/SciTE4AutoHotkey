
RemoveDir(dir)
{
	IfExist, %dir%
	{
		FileRemoveDir, %dir%, 1
		return 1
	}else
		return 0
}
