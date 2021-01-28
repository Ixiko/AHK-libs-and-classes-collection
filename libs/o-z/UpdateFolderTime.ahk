#SingleInstance, Force
SetBatchLines, -1  ; Make the operation run at maximum speed.
lastFileModified := GetLastModified(A_MyDocuments,"")
FormatTime, OutputVar, %lastFileModified%
msgbox %outputVar%



GetLastModified(file, ByRef _lastModified) {
	;msgbox Looping %file%
	Loop, Files, %file%*.*, DF
	{
		if (InStr(FileExist(A_LoopFileFullPath), "D")) {	
			;msgbox %A_LoopFileName% is a Directory! Should now recurse into %A_LoopFileFullPath%
			new_LastModified := GetLastModified(A_LoopFileFullPath "\",_lastModified) 
			if (new_LastModified > _LastModified){
				;msgbox _LastModified changed by recursion
				_LastModified := new_LastModified	
			}
		}
		Else If (A_LoopFileTimeModified  > _LastModified && A_LoopFileTimeModified < A_Now) {
			;Msgbox _LastModified changed by file: %A_LoopFileName%
			_LastModified := A_LoopFileTimeModified
		}
	}
	Return _LastModified
}