GetMonitorId(hwnd)
{
	local wp, mon, winCenterX, winCenterY
	
	GetWindowPlacement(hwnd, wp) ; GetWindowPlacement returns restored position of window (need this in case hwnd is minimized)
	
	SysGet, monitorCount, MonitorCount
	
	Loop, % monitorCount
	{
		mon := new SnapMonitor(A_Index)
		
		winCenterX := (wp.rcNormalPosition.left + mon.workarea.xo + wp.rcNormalPosition.right + mon.workarea.xo) / 2 ; wp coordinates are in workspace coordinates
		winCenterY := (wp.rcNormalPosition.top + mon.workarea.yo + wp.rcNormalPosition.bottom + mon.workarea.yo) / 2 ; wp coordinates are in workspace coordinates
		if (winCenterX >= mon.area.x && winCenterX <= mon.area.r && winCenterY >= mon.area.y && winCenterY <= mon.area.b)
		{
			return % A_Index
		}
	}
	
	return 1
}

NumGetInc(ByRef VarOrAddress, ByRef Offset, Type)
{
	value := NumGet(VarOrAddress, Offset, Type)
	Offset := Offset + SizeOf[Type]
	return value
}

NumPutInc(Number, ByRef VarOrAddress, ByRef Offset, Type)
{
	NumPut(Number, VarOrAddress, Offset, Type)
	Offset := Offset + SizeOf[Type]
}

GetWindowPlacement(hwnd, ByRef lpwndpl)
{
	VarSetCapacity(_lpwndpl, 44)
	NumPut(44, _lpwndpl)
	result := DllCall("GetWindowPlacement", Ptr, hwnd, Ptr, &_lpwndpl)
	runningOffset := 0
	lpwndpl := new WINDOWPLACEMENT(NumGetInc(_lpwndpl, runningOffset, "UInt")
											, NumGetInc(_lpwndpl, runningOffset, "UInt")
											, NumGetInc(_lpwndpl, runningOffset, "UInt")
											, new tagPOINT(NumGetInc(_lpwndpl, runningOffset, "Int")
															, NumGetInc(_lpwndpl, runningOffset, "Int"))
											, new tagPOINT(NumGetInc(_lpwndpl, runningOffset, "Int")
															, NumGetInc(_lpwndpl, runningOffset, "Int"))
											, new _RECT(NumGetInc(_lpwndpl, runningOffset, "Int")
															, NumGetInc(_lpwndpl, runningOffset, "Int")
															, NumGetInc(_lpwndpl, runningOffset, "Int")
															, NumGetInc(_lpwndpl, runningOffset, "Int")))
	return result
}

SetWindowPlacement(hwnd, ByRef lpwndpl)
{
	VarSetCapacity(_lpwndpl, 44)
	runningOffset := 0
	NumPutInc(lpwndpl.length , _lpwndpl, runningOffset, "UInt")
	NumPutInc(lpwndpl.flags  , _lpwndpl, runningOffset, "UInt")
	NumPutInc(lpwndpl.showCmd, _lpwndpl, runningOffset, "UInt")
	NumPutInc(lpwndpl.ptMinPosition.x, _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.ptMinPosition.y, _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.ptMaxPosition.x, _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.ptMaxPosition.y, _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.rcNormalPosition.left  , _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.rcNormalPosition.top   , _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.rcNormalPosition.right , _lpwndpl, runningOffset, "Int")
	NumPutInc(lpwndpl.rcNormalPosition.bottom, _lpwndpl, runningOffset, "Int")
	result := DllCall("SetWindowPlacement", Ptr, hwnd, Ptr, &_lpwndpl)
	return result
}

GetClientRect(hwnd, ByRef lpRect)
{
	VarSetCapacity(_lpRect, SizeOf.Long * 4)
	NumPut(SizeOf.Long * 4, _lpRect)
	result := DllCall("GetClientRect", Ptr, hwnd, Ptr, &_lpRect)
	runningOffset := 0
	lpRect := new _RECT(NumGetInc(_lpRect, runningOffset, "Int")
							, NumGetInc(_lpRect, runningOffset, "Int")
							, NumGetInc(_lpRect, runningOffset, "Int")
							, NumGetInc(_lpRect, runningOffset, "Int"))
	return result
}

SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwflags)
{
	return DllCall("SetWinEventHook", UInt, eventMin, UInt, eventMax, UInt, hmodWinEventProc, UInt, lpfnWinEventProc, UInt, idProcess, UInt, idThread, UInt, dwflags)
}

ThisCallbackTracker := []

RegisterCallbackToThis(FunctionName, ParamCount, your_this)
{
	global ThisCallbackTracker
	index := ThisCallbackTracker.Push({ your_this: &your_this, FunctionName: FunctionName })
	return RegisterCallback("ThisCallback", "", ParamCount, index)
}

ThisCallback( param01 = "", param02 = "", param03 = "", param04 = "", param05 = "", param06 = "", param07 = "", param08 = ""
				, param09 = "", param10 = "", param11 = "", param12 = "", param13 = "", param14 = "", param15 = "", param16 = ""
				, param17 = "", param18 = "", param19 = "", param20 = "", param21 = "", param22 = "", param23 = "", param24 = ""
				, param25 = "", param26 = "", param27 = "", param28 = "", param29 = "", param30 = "", param31 = "")
{
	global ThisCallbackTracker
	this_info := ThisCallbackTracker[A_EventInfo]
;debug.write("ThisCallback: " A_EventInfo " " this_info.your_this " " this_info.FunctionName)
;debug.write("      params: " param01 " " param02 " " param03 " " param04 " " param05 " " param06 " " param07 " " param08 " "param09 " " param10 " " param11 " " param12 " " param13 " " param14 " " param15 " " param16 " " param17 " " param18 " " param19 " " param20 " " param21 " " param22 " " param23 " " param24 " " param25 " " param26 " " param27 " " param28 " " param29 " " param30 " " param31)
	Object(this_info.your_this)[this_info.FunctionName]( param01, param02, param03, param04, param05, param06, param07, param08
																		, param09, param10, param11, param12, param13, param14, param15, param16
																		, param17, param18, param19, param20, param21, param22, param23, param24
																		, param25, param26, param27, param28, param29, param30, param31)
}

IndexOf(array, value, itemProperty = "")
{
	local i, item
	for i, item in array
	{
		if ((itemProperty <> "" && item[itemProperty] = value) || item = value)
		{
			return i
		}
	}
	return 0
}

Max(a, b)
{
	return a > b ? a : b
}

Join(separator, items*)
{
	local i, item, joined
	joined := ""
	for i, item in items
	{
		joined := joined item separator
	}
	return SubStr(joined, 1, -1 * StrLen(separator))
}