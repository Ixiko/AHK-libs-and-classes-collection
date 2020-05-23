/**
 * Function: EnumIncludes
 *     Enumerates all #Include files in the specified script by passing the
 *     the full path to each included file, in turn, to the specified callback
 *     function.
 * Syntax:
 *     count := EnumIncludes( AhkScript, callback [, AhkExe ] )
 * Parameter(s):
 *     count             [retval] - total number of identified #Include(s)
 *     AhkScript             [in] - AutoHotkey script file to scan
 *     callback              [in] - callback function, must be a "Function object"
 *     AhkExe           [in, opt] - if specified, must be the path to the AutoHotkey.exe
 *                                  to use as reference for the standard library
 *                                  folder location. Defaults to A_AhkPath
 *     IgnoreInclAgain  [in, opt] - Set to 'true' to ignore subsequently found
 *                                  #IncludeAgain(s) which were already processed
 *                                  previously. Default is 'false'.
 * Remarks:
 *     To continue enumeration, the callback function must return true(1); to stop
 *     enumeration, it must return false(0) or blank("").
 */
EnumIncludes(AhkScript, callback, AhkExe:="", IgnoreInclAgain:=false)
{
	if !IsObject(callback)
		throw Exception("Invalid parameter -> object expected", -1, callback)
	
	static FullPath
	if !VarSetCapacity(FullPath)
		VarSetCapacity(FullPath, 260 * (A_IsUnicode ? 2 : 1))

	if DllCall("GetFullPathName", "Str", AhkScript, "UInt", 260, "Str", FullPath, "Ptr", 0, "UInt")
		AhkScript := FullPath
	SplitPath, % AhkScript ,, AhkScriptDir

	if ((AhkExe != "") && DllCall("GetFullPathName", "Str", AhkExe, "UInt", 260, "Str", FullPath, "Ptr", 0, "UInt"))
		AhkExe := FullPath
	if ((AhkExe == "") || !FileExist(AhkExe))
		AhkExe := A_AhkPath
	
	cwd := A_WorkingDir
	SetWorkingDir, %AhkScriptDir%

	e := false ; Exception
	WshExec := "" ; for /iLib (auto-includes)
	includes := {}, count := 0
	queue := [ [AhkScript, AhkScript] ]
	while queue.Length() {
		args := queue.RemoveAt(1)
		if !(f := IsObject(args[1]) ? args.RemoveAt(1) : FileOpen(args.RemoveAt(1), 0|4)) {
			e := Exception((A_Index==1 ? "Script" : "#Include") . " file cannot be opened", -1, args[1])
			break
		}

		IsBlockComment := false
		IsContSection := false

		AtEOF := ComObjType(f) ? "AtEndOfStream" : "AtEOF"
		while !f[AtEOF] {
			line := Trim(f.ReadLine(), " `t`r`n")
			if (line == "")
				continue
			
			if (!IsBlockComment && !IsContSection)
				if !(IsBlockComment := InStr(line, "/*") == 1) && (InStr(line, "(") == 1)
					IsContSection := line ~= "i)^\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$"
			; skip if within block comment/continuation section or if it's a solitary line comment
			if (IsBlockComment || IsContSection || (InStr(line, ";") == 1)) {
				if (IsBlockComment && (InStr(line, "*/") == 1))
					IsBlockComment := false
				if (IsContSection && (InStr(line, ")") == 1))
					IsContSection := false
				continue
			}

			if RegExMatch(line, "Oi)^#Include(Again)?(?:\s*,\s*|\s+)(?:(\*i)\s+)?(\S.*?)(?:\s*|\s+;.*)$", match) {
				IsIncludeAgain := (match[1] = "Again")
				IgnoreFailure := (match[2] = "*i")
				this_include := match[3]
				
				if (this_include ~= "^<.+?>$") {
					lib := Trim(SubStr(this_include, 2, -1), " `t")
					if (lib_pfx := InStr(lib, "_",, 2))
						lib_pfx := SubStr(lib, 1, lib_pfx-1)

					libs := [AhkScriptDir . "\Lib", A_MyDocuments . "\AutoHotkey\Lib", AhkExe . "\..\Lib"]
					for i, lib_dir in libs {
						if FileExist(this_include := Format("{1}\{2}.ahk", lib_dir, lib))
						|| (lib_pfx && FileExist(this_include := Format("{1}\{2}.ahk", lib_dir, lib_pfx)))
							break
						this_include := ""
					}

				} else {
					this_include := StrReplace(this_include, "`%A_ScriptDir`%", AhkScriptDir)
					this_include := StrReplace(this_include, "`%A_AppData`%", A_AppData)
					this_include := StrReplace(this_include, "`%A_AppDataCommon`%", A_AppDataCommon)
					this_include := StrReplace(this_include, "`%A_LineFile`%", args[1])

					if InStr(FileExist(this_include), "D") {
						SetWorkingDir, %this_include%
						continue
					}
				}

				if ((this_include != "") && DllCall("GetFullPathName", "Str", this_include, "UInt", 260, "Str", FullPath, "Ptr", 0, "UInt"))
					this_include := FullPath

				if (IsIncludeAgain || !includes[this_include]) {
					if !includes[this_include]
						includes[this_include] := ++count ; value doesn't really matter as long as it's 'truthy'
					else if IgnoreInclAgain ; satisfies (IsIncludeAgain && includes[this_include] && IgnoreInclAgain)
						continue

					if (FileExist(this_include) || IgnoreFailure) {
						e := !callback.Call(this_include)
						if FileExist(this_include)
							queue.Push([this_include, this_include])
					} else
						e := Exception("Required #Include file does not exist", -1, this_include)

					if e {
						f.Close(), f := ""
						break 2
					}
				}
			} ; if RegExMatch( ... )
		} ; while f[AtEOF]

		f.Close(), f := "" ; close file/stream

		if (!queue.Length() && !WshExec) {
			cmd := Format("{1}{2}{1} /iLib * /ErrorStdOut {1}{3}{1}", Chr(34), A_AhkPath, AhkScript)
			WshExec := ComObjCreate("WScript.Shell").Exec(cmd)
			
			if (err := WshExec.StdErr.ReadAll()) {
				e := Exception("Failed to retrieve auto-included script files. Script contains syntax error(s).", -1, cmd)
				; idea taken from Lexikos' LoadFile
				if RegExMatch(err, "Os)(.*?) \((\d+)\) : ==> (.*?)(?:\s*Specifically: (.*?))?\R?$", m)
					e.Message .= "`n`nReason:`t" . m[3] . "`nLine text:`t" . m[4] . "`nFile:`t" . m[1] . "`nLine:`t" . m[2]
				break
			}
			
			queue.Push([WshExec.StdOut, "*"])
		}
	
	} ; while queue.Length()
 	
	SetWorkingDir, %cwd% ; restore original working dir

	if IsObject(e) ; there was an error
		throw e

	return count ; NumGet(&includes + 4*A_PtrSize)
}