_ScriptEdited(files:="",option:="RF",clean:=0){
	if (files="")
		files:=A_ScriptFullPath

	Loop, Files, % files, % option
	{
		if A_LoopFileAttrib contains H,S
			continue
		else if clean
			FileSetAttrib, -A, % A_LoopFileLongPath, % inStr(option,"D")?(inStr(option,"F")?2:1):0, % InStr(option,"R")?1:0
		else if A_LoopFileAttrib contains A
		{
			FileSetAttrib, -A, % A_LoopFileLongPath
			return A_LoopFileLongPath
		}
	}
	return 0
}

ReloadScriptOnEdit(files,clean:=0){	;clean=2 reloads also
	static fName
	if !fName {
		SplitPath, A_ScriptFullPath, , , , fName, ;fName = Name of file without extension
		clean:=1 ;Clean on first run
	}
	if clean {
		for _,f in files
			_ScriptEdited(f,,True)
		if (clean=2)
			Reload
		return 1
	}

	for _,f in files
		if changed:=_ScriptEdited(f) {
			MsgBox, 0x24, % fName, A file related to the script %fName% has changed:`n`nScript file:%A_ScriptFullPath%`nChanged file:%changed%`n`nReload this script?
			IfMsgBox, Yes
				ReloadScriptOnEdit(files,2)
			else
				ReloadScriptOnEdit(files,1)
		}
	return
}
