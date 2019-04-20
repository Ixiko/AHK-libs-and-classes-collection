debugger(message) 
{
	;~ ToolTip, % message
	;~ sleep 100
	return
}

turnCapslockOff()
{
	;if the capslock key is down then set the capslock state to on so that
	;when the user lets go it will change the state to off
	if(GetKeyState("Capslock", "P"))
	{
		SetCapsLockState, On
	} else
	{
		SetCapsLockState , Off
	}
	return
}

/*
 * If we send the keystrokes too quickly you sometimes get a flickering of the screen
 */
send(toSend)
{
	oldDelay := A_KeyDelay
	SetKeyDelay, 30
	
	send, % toSend
	
	SetKeyDelay, % oldDelay
	return 
}

closeMultitaskingViewFrame()
{
	if(isMultiTaskingViewActive())
	{
		send("#{tab}")
	}
	return 
}

	
openMultitaskingViewFrame()
{
	if(! isMultiTaskingViewActive())
	{
		send("#{tab}")
		WinWaitActive, ahk_class MultitaskingViewFrame
	}
	return
}

isMultiTaskingViewActive() 
{
	return WinActive("ahk_class MultitaskingViewFrame")
}

callFunction(possibleFunction)
{
	if(IsFunc(possibleFunction)) 
	{
		%possibleFunction%()
	} else if(IsObject(possibleFunction))
	{
		possibleFunction.Call()
	} else if(IsLabel(possibleFunction))
	{
		gosub, % possibleFunction
	}
	return
}

getDesktopNumberFromHotkey(keyCombo)
{
	number := RegExReplace(keyCombo, "[^\d]", "")
	return number == 0 ? 10 : number
}

getIndexFromArray(searchFor, array) 
{
	loop, % array.MaxIndex()
	{
		if(array[A_index] == searchFor) 
		{
			return A_index
		}
	}
	return -1
}