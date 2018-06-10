blnIsErrorChecking := False
blnNextLineState := False

FileDelete, ws4ahk--err.ahk

Loop, Read, ws4ahk.ahk, ws4ahk--err.ahk
{
	blnIsErrorChecking := blnNextLineState
	
	If (LineBeginsErrorChecking(A_LoopReadLine))
	{
		If !blnIsErrorChecking
		{
			blnIsErrorChecking := True
			blnNextLineState := True
		}
		Else
		{
			Msgbox % "Error at line " A_Index "`nAlready error checking."
			Return
		}
	}
	If (LineEndsErrorChecking(A_LoopReadLine))
	{
		If blnIsErrorChecking 
			blnNextLineState := False
		Else
		{
			Msgbox % "Error at line " A_Index "`nAlready not error checking."
			Return
		}
	}

	If (A_Index = 1)
		FileAppend, `;`; Error checking removed %A_MM%\%A_MDAY%\%A_YEAR%`n
		
	If (!blnIsErrorChecking)
		FileAppend, %A_LoopReadLine%`n
}

If blnIsErrorChecking
	Msgbox % "Error checked the rest of the file to oblivion."

Return


LineBeginsErrorChecking(sLine)
{
	If (InStr(sLine, "#BeginErrorChecking"))
		Return True
	Else
		Return False
}


LineEndsErrorChecking(sLine)
{
	If (InStr(sLine, "#EndErrorChecking"))
		Return True
	Else
		Return False
}
