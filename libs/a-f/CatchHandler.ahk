; CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
CatchHandler(fnCallingFunctionName, fnMessage, fnWhat, fnExtra, fnFile, fnLine, fnShowInfoTip := 0, fnPromptToOpenFile := 0, fnRethrowError := 0)
{
	Global CatchHandlerLogFile
	
	CatchHandlerLogFile := CatchHandlerLogFile ? CatchHandlerLogFile : A_ScriptDir "\" SubStr(A_ScriptName,1,-4) "_CatchHandlerLog.csv" ;set default if necessary
	
	If !(fnExtra = "AlwaysSilent")
	{
		; construct an error message
		If fnMessage is Integer
			fnMessage := GetSystemErrorText(fnMessage)
		RethrowMessage := fnCallingFunctionName ": Error at line " fnLine " of " fnWhat (fnMessage ? ": `n`n" fnMessage : "") (fnExtra ? "`n`n" fnExtra : "")  "`n`n" ApplicationName (fnFile ? "`n`n" fnFile  : "")
		RethrowMessageLog := A_YYYY "-" A_MM "-" A_DD " " A_Hour ":" A_Min ":" A_Sec "," StrReplace(RethrowMessage,"`n`n",",") "`r`n"
		FileAppend, %RethrowMessageLog%, %CatchHandlerLogFile%
		

		; display a warning message
		If fnShowInfoTip
			InfoTip(RethrowMessage,,,3,A_ThisFunc,1,10000)
		
		
		; open the file with the error
		If fnPromptToOpenFile
		{
			MsgBox, 8500, %ApplicationName%, %RethrowMessage%`n`nOpen containing file?`n`n%fnFile%
			IfMsgBox, Yes
				Run, Edit %fnFile%
		}
		
		
		; rethrow error
		If fnRethrowError
			Throw, RethrowMessage
	}
}

/* ; testing
CatchHandler("TestMessage","Test What","Test Extra","Test File","Test Line",1,0,1)
*/