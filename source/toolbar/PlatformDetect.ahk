
Plat_DetectAll() {
	global AhkDir

	plats := {}

	Plat_OnBoardDefault(plats, AhkDir, "Automatic")
	Plat_OnBoardV1(plats, AhkDir, "Latest v1.1")

	if InStr(FileExist(AhkDir "\v2"), "D") {
		Plat_OnBoardV2(plats, AhkDir "\v2", "Latest v2")
	}

	Loop Files, %AhkDir%\*.*, D
	{
		if RegExMatch(A_LoopFileName, "^v([12])\.", o) {
			if (o1 == "1")
				Plat_OnBoardV1(plats, A_LoopFileLongPath, A_LoopFileName)
			else if (o1 == "2")
				Plat_OnBoardV2(plats, A_LoopFileLongPath, A_LoopFileName)
		}
	}

	return plats
}

Plat_ParsePlatformName(name) {
	if RegExMatch(name, "^(.+?)\s*\((.+?)\)$", o) {
		return [ o1, StrSplit(Trim(o2), ";", " `t") ]
	} else {
		return [ name, "" ]
	}
}

Plat_MapToDDL(map) {
	ddl := ""
	for key in map
		ddl .= "|" key
	return ddl ; Leave out initial | in order to overwrite previous list
}

Plat_GroupByVersion(plats) {
	versions := {}
	for plat in plats {
		plat := Plat_ParsePlatformName(plat)
		curver := plat[1]
		if IsObject(variant := plat[2]) {
			if not IsObject(vervar := versions[curver]) {
				vervar := versions[curver] := {}
			}
			vervar[variant[1]] := true
		} else {
			versions[curver] := ""
		}
	}
	return versions
}

Plat_OnBoardDefault(plats, path, name) {
	ahkver := 1

	if Util_FileExistProperly(exe := path "\UX\AutoHotkeyUX.exe") {
		ahkver := 2
	}

	platdata := "# THIS FILE IS SCRIPT-GENERATED - DON'T TOUCH`n"
	platdata .= "ahk.platform=" name "`n"
	platdata .= "ahk.version=" ahkver "`n"
	platdata .= "file.patterns.ahk" ahkver "=$(file.patterns.ahk)`n"

	if (ahkver == 2) {
		platdata .= "ahk.version.autodetect=1`n"
		platdata .= "ahk.launcher=""" exe """ """ path "\UX\launcher.ahk""`n"

		if Util_FileExistProperly(helpfile := path "\v2\AutoHotkey.chm")
			platdata .= "ahk.help.file=" helpfile "`n"
	}

	plats[name] := platdata
}

Plat_OnBoardV1(plats, path, name) {
	if A_Is64bitOS {
		Plat_TryAdd(plats, path "\AutoHotkeyU64.exe",     name " (64-bit Unicode)", 1)
		Plat_TryAdd(plats, path "\AutoHotkeyU64_UIA.exe", name " (64-bit Unicode; UI access)", 1)
	}
	Plat_TryAdd(plats, path "\AutoHotkeyU32.exe",     name " (32-bit Unicode)", 1)
	Plat_TryAdd(plats, path "\AutoHotkeyU32_UIA.exe", name " (32-bit Unicode; UI access)", 1)
	Plat_TryAdd(plats, path "\AutoHotkeyA32.exe",     name " (32-bit ANSI)", 1)
	Plat_TryAdd(plats, path "\AutoHotkeyA32_UIA.exe", name " (32-bit ANSI; UI access)", 1)
}

Plat_OnBoardV2(plats, path, name) {
	if A_Is64bitOS {
		Plat_TryAdd(plats, path "\AutoHotkey64.exe",     name " (64-bit)", 2)
		Plat_TryAdd(plats, path "\AutoHotkey64_UIA.exe", name " (64-bit; UI access)", 2)
	}
	Plat_TryAdd(plats, path "\AutoHotkey32.exe",     name " (32-bit)", 2)
	Plat_TryAdd(plats, path "\AutoHotkey32_UIA.exe", name " (32-bit; UI access)", 2)
}

Util_FileExistProperly(path) {
	attrib := DllCall("GetFileAttributes", "str", path, "uint")
	return !(attrib == 0xffffffff) and !(attrib & 0x410)
}

Plat_TryAdd(plats, exe, name, ahkver) {
	if not Util_FileExistProperly(exe)
		return

	verSize := DllCall("version\GetFileVersionInfoSize", "str", exe, "uint*", 0, "uint")
	if not verSize
		return

	VarSetCapacity(verInfo, verSize)
	if not DllCall("version\GetFileVersionInfo", "str", exe, "uint", 0, "uint", verSize, "ptr", &verInfo)
		return

	platdata := "# THIS FILE IS SCRIPT-GENERATED - DON'T TOUCH`n"
	platdata .= "ahk.platform=" name "`n"
	platdata .= "ahk.version=" ahkver "`n"
	platdata .= "file.patterns.ahk" ahkver "=$(file.patterns.ahk)`n"
	platdata .= "AutoHotkey=" exe "`n"

	SplitPath path,, pathdir
	if Util_FileExistProperly(helpfile := pathdir "\AutoHotkey.chm")
		platdata .= "ahk.help.file=" helpfile "`n"

	plats[name] := platdata
}
