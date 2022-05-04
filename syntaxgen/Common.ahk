#Requires AutoHotkey v2-b+

FileRewrite(path, contents) {
	try FileDelete path
	FileAppend contents, path, "`n"
}

ControlFlowCasing(item) {
	if item == 'Loop' or item ~= "^If.+"
		return item
	else
		return StrLower(item)
}

CreateKeywordList(arr) {
	build := "", cline := ""
	for x in arr {
		x := StrLower(x)
		pline := cline " " x
		if StrLen(pline) > 78 {
			build .= cline " \`n"
			cline := x
		} else {
			cline .= " " x
		}
	}
	return SubStr(build cline, 2) "`n"
}

CreateApiList(arr, prefix := "", suffix := "") {
	build := ""
	for x in arr {
		build .= prefix x suffix "`n"
	}
	return build
}

class Set extends Map {
	__New(p*) {
		super.__New()
		super.CaseSense := "Off"
		for x in p {
			this.Add(x)
		}
	}

	Add(value) {
		super[value] := true
	}

	Filter(other) {
		for key in other {
			try this.Delete(key)
		}
	}

	static FilterAll(sets*) {
		for cur in sets {
			Loop A_Index-1 {
				cur.Filter(sets[A_Index])
			}
		}
	}
}
