WriteToLogs(fnActionText,fnDetailsText := "",fnLogFile := 0,fnErrorLogFile := 0,fnDebugFile := 0,fnActionTextWidth := 35)
{
	; writes a text string to the provided log file objects
	; MsgBox fnActionText: %fnActionText%`nfnDetailsText: %fnDetailsText%`nfnActionTextWidth: %fnActionTextWidth%
	; MsgBox % "IsObject(fnLogFile): " IsObject(fnLogFile) "`nIsObject(fnErrorLogFile): " IsObject(fnErrorLogFile) "`nIsObject(fnDebugFile): " IsObject(fnDebugFile)
	; MsgBox % "fnLogFile.__Handle: " fnLogFile.__Handle "`nfnErrorLogFile.__Handle: " fnErrorLogFile.__Handle "`nfnDebugFile.__Handle: " fnDebugFile.__Handle
	; MsgBox % "fnLogFile address: " &fnLogFile "`nfnErrorLogFile address: " &fnErrorLogFile "`nfnDebugFile address: " &fnDebugFile


	; declare local, global, static variables


	Try
	{
		; set default return value
		BytesWritten := 0


		; validate parameters


		; initialise variables
		If !fnActionText
			fnActionText := "Unspecified action"


		; construct log text
		Action := SubStr(fnActionText StrReplicate(" ",fnActionTextWidth),1,fnActionTextWidth)
		LogText := TimeStampSQL(A_Now) "," Action "," fnDetailsText
		; MsgBox Action: %Action%`nLogText: %LogText%
		
		
		; write to logs
		BytesWritten := 0
		BytesWritten += fnLogFile.WriteLine(LogText)
		BytesWritten += fnErrorLogFile.WriteLine(LogText)
		BytesWritten += fnDebugFile.WriteLine(LogText)
		OutputDebug, %A_ScriptName%: %LogText%

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
	Return BytesWritten
}

/* ; testing
TestFileName = %A_Desktop%\testfile.txt
TestFile := FileOpen(TestFileName,"w `n")
MsgBox, % TestFileName "`nIsObject: " IsObject(TestFile) "`nFileHandle: " TestFile.__Handle
LogDetails := "some other details and more"
ReturnValue := WriteToLogs("Test action",LogDetails,0,TestFile)
MsgBox, ReturnValue: %ReturnValue%
; TestFile.Close()
MsgBox, % TestFile.Position
TestFile.Position := 0
MsgBox, % TestFile.Position
Line := TestFile.Read()
MsgBox, % TestFile.Position
MsgBox, FileLine: `n%Line%
; */