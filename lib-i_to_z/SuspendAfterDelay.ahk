SuspendAfterDelay(fnSuspendType,fnDelayInSeconds := 0)
{
	; suspend the computer after the specified delay
	; MsgBox fnSuspendType: %fnSuspendType%`nfnDelayInSeconds: %fnDelayInSeconds%


	; declare local, global, static variables
	Global SessionWasSuspended, SuspendMode


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters
		If fnSuspendType not in Hibernate,H,Sleep,S,Shutdown,X
			Throw, Exception("fnSuspendType parameter not recognized")
			
		If fnDelayInSeconds is not Integer
			Throw, Exception("fnDelayInSeconds parameter must be an integer")


		; initialise variables
		If fnDelayInSeconds < 0
			fnDelayInSeconds := 0


		; show what's happening
		IconTip := A_IconTip ; store current IconTip
		StringLower, TrayTipText, SuspendMode
		TrayTipText := "Getting ready to " TrayTipText "..."
		TrayTip,, %TrayTipText%
		SuspendText := SuspendMode = "Sleep"     ? "Sleeping" 
					:  SuspendMode = "Hibernate" ? "Hibernating" 
					:  SuspendMode = "Shutdown"  ? "Shutting down" 
		While fnDelayInSeconds > 0
		{
			Menu, Tray, Tip, %SuspendText% in %fnDelayInSeconds% seconds
			fnDelayInSeconds--
			Sleep, 1000
		}
		Menu, Tray, Tip, %IconTip%
		
		
		; suspend
		; https://msdn.microsoft.com/en-us/library/windows/desktop/aa373201(v=vs.85).aspx
		SessionWasSuspended := 1
		Hibernate := 0
		ForceCritical := 0
		DisableWakeEvent := 0
		If fnSuspendType in Hibernate,H
			Hibernate := 1
		
		If fnSuspendType in Shutdown,X
		{
			Shutdown, 1+8 ; Shutdown+Power down
		}
		Else
		{
			DllCall("PowrProf\SetSuspendState","int",Hibernate,"int",ForceCritical,"int",DisableWakeEvent)
			If ErrorLevel
				Throw, Exception("SuspendAfterDelay error: ErrorLevel: " ErrorLevel)
		}

	}
	Catch, ThrownValue
	{
		ReturnValue := !ReturnValue
		CatchHandler(A_ThisFunc,ThrownValue.Message,ThrownValue.What,ThrownValue.Extra,ThrownValue.File,ThrownValue.Line,0,0,1)
	}
	Finally
	{
	}

	; return
	Return ReturnValue
}


/* ; testing
params := xxx
ReturnValue := SuspendAfterDelay(params)
MsgBox, SuspendAfterDelay`n`nReturnValue: %ReturnValue%
*/