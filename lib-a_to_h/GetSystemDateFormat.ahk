; https://autohotkey.com/board/topic/66811-way-to-get-short-date-format-used-by-local-machine/
GetSystemDateFormat()
{
	; return the system short date format e.g. dd-MMM-yyyy
	; MsgBox params: %params%


	; declare local, global, static variables


	Try
	{
		; set default return value
		; ReturnValue := 0
		DateFormat := ""


		; validate parameters
		; If !Condition
			; Throw, Exception("xErrorMessagex")


		; initialise variables


		; get system date format
		LOCALE_SYSTEM_DEFAULT := 0x0800
		LOCALE_USER_DEFAULT := 0x0400
		LOCALE_SSHORTDATE := 0x1F
		VarSetCapacity(DateFormat,80)
		DllCall("GetLocaleInfo","uint",LOCALE_USER_DEFAULT,"uint",LOCALE_SSHORTDATE,"str",DateFormat,"uint",80)

	}
	Catch, ThrownValue
	{
		; ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,0)
	}
	Finally
	{
	}

	; return
	; Return ReturnValue
	Return DateFormat
}


/* ; testing
ReturnValue := GetSystemDateFormat()
MsgBox, GetSystemDateFormat`n`nReturnValue: %ReturnValue%
*/