;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 脚本启动后默认进程名为AutoHotkey.exe，改变之
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SMExe(file)
{
	Loop, %file%
		Filename := RegExReplace(A_LoopFileName, "\.[^\.]*$")

	OrigAhk := A_AhkPath
	SplitPath, OrigAhk, , DumpAhk
	DumpAhk .= "\"
	DumpAhk .= "AutoHotkeyDump.exe"

	if (!FileExist(DumpAhk))
		FileCopy, %OrigAhk%, %DumpAhk%

	Loop, %DumpAhk%
		path := A_LoopFileDir

	FileMove, %DumpAhk%, %path%\%FileName%.exe
	If ErrorLevel
		Return ErrorLevel

	Loop
		Loop, %path%\%FileName%.exe
		{
			Run, %A_LoopFileFullPath% "%file%", % RegExReplace(file, "\\[^\\]*$"), , PID
			Process, Wait, %PID%, 10
			FileMove, %A_LoopFileFullPath%, %DumpAhk%
			Process, Wait, %PID%, 0.1
			Return ErrorLevel
		}
}
