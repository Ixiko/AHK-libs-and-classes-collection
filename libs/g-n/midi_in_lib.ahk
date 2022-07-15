midi_in_Open(defaultDevID = -1)
{
	global
	if ((midi_in_hModule := DllCall("LoadLibrary", Str,A_ScriptDir . "\midi_in.dll")) == 0)
	{ 
		MsgBox "Cannot load library midi_in.dll"
		return 1
	}
	if (defaultDevID >= DllCall("midi_in.dll\getNumDevs"))
		defaultDevID := -1
	
	midi_in_MakeTrayMenu(defaultDevID)
	if (defaultDevID >= 0)
		midi_in_OpenDevice(defaultDevID)
	return 0
}

midi_in_MakeTrayMenu(defaultDevID)
{
	numDevs := DllCall("midi_in.dll\getNumDevs")
	global midi_in_lastSelectedMenuItem
	
	Menu devNameMenu, Add, No input, sub_menu_openinput
	Menu devNameMenu, Add ; separator 
	if (defaultDevID < 0)
		midi_in_lastSelectedMenuItem := "No Input"

	loop %numDevs%
	{
		devID := A_Index-1
		if ((devName := DllCall("midi_in.dll\getDevName", Int,devID, Str)) == 0)
		{
			MsgBox, Error in creating midi input device list
			return 1
		}
		Menu devNameMenu, Add, %devName%, sub_menu_openinput
		if (devID == defaultDevID)
		{
			Menu devNameMenu, Check, %devName%
			midi_in_lastSelectedMenuItem := devName
		}
	}
	Menu TRAY, Add, MIDI-in device, :devNameMenu
}

sub_menu_openinput:
	midi_in_OpenDevice(A_ThisMenuItemPos-3)
	; Move the check mark to new position
	Menu %A_ThisMenu%, Check, %A_ThisMenuItem%
	Menu %A_ThisMenu%, Uncheck, %midi_in_lastSelectedMenuItem%
	midi_in_lastSelectedMenuItem := A_ThisMenuItem
return

midi_in_OpenDevice(deviceID) ;deviceID < 0 means no input
{
	Critical
	midi_in_Stop()
	
	Gui +LastFound
	hWnd := WinExist()

	curDevID := DllCall("midi_in.dll\getCurDevID", Int)
	if (deviceID == curDevID)
		return 0
	if (curDevID >= 0)
		result := DllCall("midi_in.dll\close")
	if (result)
	{
		MsgBox Error closing midi device`nmidi_in.dll\close returned %result%
		return 1
	}
	if (deviceID < 0)
		return 0

		result := DllCall("midi_in.dll\open", UInt,hWnd, Int,deviceID, Int)
	if (result)
	{
		MsgBox Error opening midi device`nmidi_in.dll\open(%hWnd%, %deviceID%) returned %result%
		return 1
	}
;	MsgBox Press OK to start midi input
	midi_in_Start()
	return 0
}
	
midi_in_Close()
{
	global
	if (midi_in_hModule)
	DllCall("FreeLibrary", UInt,midi_in_hModule), midi_in_hModule := "" 
}

midi_in_Start()
{
	DllCall("midi_in.dll\start")
}

midi_in_Stop()
{
	DllCall("midi_in.dll\stop")
}

listenNote(noteNumber, funcName, channel=0)
{
	global msgNum
	GoSub, sub_increase_msgnum
	DllCall("midi_in.dll\listenNote", Int,noteNumber, Int,channel, Int,msgNum)
	OnMessage(msgNum, funcName)
}

listenNoteRange(rangeStart, rangeEnd, funcName, flags=0, channel=0)
{
	global msgNum
	GoSub, sub_increase_msgnum
	msgCount := DllCall("midi_in.dll\listenNoteRange", int,rangeStart, int,rangeEnd, int,(flags & 0x07), int,channel, int,msgNum)

	
	if (msgCount <= 0)
		return
	if (flags & 0x01)
		loop %msgCount%
		{
			OnMessage(msgNum, funcName . A_Index)
			GoSub, sub_increase_msgnum
		}
	else
		OnMessage(msgNum, funcName)
}

listenCC(ccNumber, funcName, channel=0)
{
	global msgNum
	GoSub, sub_increase_msgnum
	DllCall("midi_in.dll\listenCC", Int,ccNumber, Int,channel, Int,msgNum)
	OnMessage(msgNum, funcName)
}

listenWheel(funcName, channel=0)
{
	global msgNum
	GoSub, sub_increase_msgnum
	DllCall("midi_in.dll\listenWheel", Int,channel, Int,msgNum)
	OnMessage(msgNum, funcName)
}

listenChanAT(funcName, channel=0)
{
	global msgNum
	GoSub, sub_increase_msgnum
	DllCall("midi_in.dll\listenChanAT", Int,channel, Int,msgNum)
	OnMessage(msgNum, funcName)
}


getNoteOn(noteNumber, channel)
{
	return DllCall("midi_in.dll\getNoteOn", Int,noteNumber, Int,channel)
}

getCC(ccNumber, channel)
{
	return DllCall("midi_in.dll\getCC", Int,ccNumber, Int,channel)
}

getWheel(channel)
{
	return DllCall("midi_in.dll\getWheel", Int,channel)
}

getChanAT(channel)
{
	return DllCall("midi_in.dll\getChanAT", Int,channel)
}

sub_increase_msgnum:
	if msgNum
		msgNum++
	else
		msgNum := 0x2000
return