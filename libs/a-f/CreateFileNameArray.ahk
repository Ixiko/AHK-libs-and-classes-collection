CreateFileNameArray(ByRef fnFileNameArrayMaxTime := "19000101000000")
{
	; creates a global array holding names of files in script directory
	; MsgBox fnFileNameArrayMaxTime: %fnFileNameArrayMaxTime%


	; declare local, global, static variables
	Global
	Local temp


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters


		; initialise variables
		FileNameArray0 := 0


		; create array
		Loop, Files, %A_ScriptDir%\*.*, F
		{
			If A_LoopFileExt not in ahk,ini
				Continue
			FileNameArray0++
			FileNameArray%FileNameArray0% := A_LoopFileFullPath
			FileGetTime, temp, %A_LoopFileFullPath%, M
			FileNameArrayModTime%FileNameArray0% := temp
			FileNameArrayExt%FileNameArray0% := A_LoopFileExt
			If A_LoopFileExt in ini,lnk
				Continue
			fnFileNameArrayMaxTime := FileNameArrayModTime%FileNameArray0% > fnFileNameArrayMaxTime ? FileNameArrayModTime%FileNameArray0% : fnFileNameArrayMaxTime
		}

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
params := xxx
ReturnValue := CreateFileNameArray(params)
MsgBox, CreateFileNameArray`n`nReturnValue: %ReturnValue%
*/