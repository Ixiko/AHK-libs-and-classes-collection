CompareFileNameArray()
{
	; compares each file to the array and determines if a newer version exists
	; MsgBox params: %params%


	; declare local, global, static variables
	Global


	Try
	{
		; set default return value
		NewerVersionExists := 0


		; validate parameters


		; initialise variables


		; campare the array
		Loop, %FileNameArray0%
		{
			IfNotExist, % FileNameArray%A_Index% ; if the filename stored in the array doesn't exist
				Continue

			FileGetTime, FileModifyStampCheck, % FileNameArray%A_Index%, M ; get 'Date Modified' of the file

			If (FileNameArrayModTime%A_Index%  < FileModifyStampCheck) ; if stored mod time is earlier than actual mod time
			{
				NewerVersionExists := 1
				Break
			}
		}


	}
	Catch, ThrownValue
	{
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	Return NewerVersionExists
}


/* ; testing
params := xxx
ReturnValue := CompareFileNameArray(params)
MsgBox, CompareFileNameArray`n`nReturnValue: %ReturnValue%
*/