HideInfotipOnMouseOver(fnInfotipText,ByRef fnInfotipID)
{
	; hides a given infotip when the mouse moves over it
	; MsgBox fnInfotipText: %fnInfotipText%`nfnInfotipID: %fnInfotipID%


	; declare local, global, static variables
	Global itXdefault, itYdefault, TicketInfotipX, TicketInfotipY, TicketInfotipW, TicketInfotipH, TicketInfotipID


	Try
	{
		; set default return value
		ReturnValue := 0 ; success


		; validate parameters


		; initialise variables
		CoordMode, Mouse, Screen ; relative to screen
		MouseGetPos, mX, mY ; get mouse position


		; hide or reveal the infotip
		If (mX >= TicketInfotipX && mX <= TicketInfotipX+TicketInfotipW && mY >= TicketInfotipY && mY <= TicketInfotipY+TicketInfotipH) ; if mouse is in infotip area
		{
			IfWinExist, ahk_id %fnInfotipID% ; and it is showing
				Infotip("",,,"TicketInfo") ; close it
		}
		Else ; if mouse is not in infotip area
		{
			IfWinNotExist, ahk_id %fnInfotipID% ; and its not showing
				Infotip(fnInfotipText,itXdefault,itYdefault,"TicketInfo",,TicketInfotipX,TicketInfotipY,TicketInfotipW,TicketInfotipH,TicketInfotipID) ; show it
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
SomeInfotipText := 'Here is some text"
SomeInfotipID := "0x"
ReturnValue := HideInfotipOnMouseOver(SomeInfotipText,SomeInfotipID)
MsgBox, HideInfotipOnMouseOver`n`nReturnValue: %ReturnValue%
*/