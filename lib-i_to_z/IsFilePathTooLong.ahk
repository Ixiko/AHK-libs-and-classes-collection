IsFilePathTooLong(fnFilePath,ByRef fnFilePathLength := 0)
{
	; returns boolean to indicate if fnFilePath is longer than Windows allowed maximum
	; https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx#maxpath
	; MsgBox fnFilePath %fnFilePath%
	
	
	; find out if long path names have been turned on
	; RegRead, RegistryKey, HKLM\SYSTEM\CurrentControlSet\Control\FileSystem LongPathsEnabled ;REG_DWORD
	; If !ErrorLevel
		; Return false
	
	
	; set max length
	MaxPathLength := 259
	
	
	; find string length
	StringLen, fnFilePathLength, fnFilePath
	
	
	; return
	Return fnFilePathLength > MaxPathLength ? true : false
	
}


/* ; testing
ThisPath := "xxx"
If IsFilePathTooLong(ThisPath,ThisLength)
	MsgBox, String length %ThisLength% is too long
Else
	MsgBox, String length %ThisLength% is ok
*/