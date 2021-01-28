WinVisible(hwnd)
{
	WinGet, Style, Style ,ahk_id %hwnd%
	Transform, Result, BitAnd, %Style%, 0x10000000 ; 0x10000000 is WS_VISIBLE. 
	if Result <> 0 ;Window is Visible
		Return 1
	Else  ;Window is Hidden
		Return 0
}

controlvisible(hwnd){
	controlget,v,visible,,,ahk_id %hwnd%
	return v
}

GetNextWindow(hwnd,next=1,visibleWin=1){
	result:=hwnd
	Loop {
		result:=DllCall("GetWindow", UInt, result, UINT, next?2:3, UINT)
		if(!result)
			return
		else if(visibleWin && !WinVisible(result))
			continue
		else
			return result
	}	
}

/*
return.array: full list
return.index: index of hwnd in list
*/
GetWindowOrder(hwnd="",visibleWin=1){
	if !hwnd
		hwnd:=winexist("ahk_pid " DllCall("GetCurrentProcessId"))
	
	arr1:=[]
	arr2:=[]
	
	hwndP:=hwnd
	loop {
		hwndP:=GetNextWindow(hwndP,1,visibleWin)
		if(hwndP=hwnd || !hwndP)
			break
		else
			arr1.insert(hwndP)
	}
	
	hwndN:=hwnd
	loop {
		hwndN:=GetNextWindow(hwndN,1,visibleWin)
		if(hwndN=hwnd || !hwndP)
			break
		else
			arr2.insert(hwndN)
	}
	
	arr:=[],max:=arr1.maxIndex()
	loop % max
		arr.insert(arr1[max+1-a_index])
	for k,v in arr2
		arr.insert(v)
	
	return {array: arr, index: max+1}
	
}

WinInsertAfter(hwnd, after){
	return DllCall("SetWindowPos", "UINT", hwnd, "UINT", after, "INT", 0, "INT", 0, "INT", 0, "INT", 0, "UINT", 0x0013)
}

;first=top
WinStack(ByRef arr){
	for k,v in arr {
		if(k=1)
			winactivate,% v
		else if (v)
			WinInsertAfter(v, last)
		last:=v?v:last
	
	}
}