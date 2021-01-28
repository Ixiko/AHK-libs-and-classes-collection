; v1.0.0
; http://www.autohotkey.com/board/topic/105112-enum-explorer-receive-all-explorer-in-z-order/
Enum_Explorer(hWnd=0, lParam=0) {
	If hWnd
	{
		WinGetClass, class, ahk_id %hwnd%
		If (class = "CabinetWClass")
		{
			array := object(lParam)
			If IsObject(array[hwnd])
			{
				array.ZOrder.insert(array[hwnd])
			}
		}
	return 1
	}

	Array        := {}
	array.ZOrder := {}
	for Item in ComObjCreate("Shell.Application").Windows
		If (Path := PathCreateFromURL(Item.LocationURL)) ; URL = NULL while explorer is Library...
		{
			Array[Item.HWND, "path"]        := path
			Array[Item.HWND, "URL"]         := Item.LocationURL
			Array[Item.HWND, "Prog"]        := Item.Name
			Array[Item.HWND, "processpath"] := Item.FullName
			Array[Item.HWND, "hwnd"]        := Item.HWND
		}
	Static callback := RegisterCallBack("Enum_Explorer", "", 2) ; EnumWindowsProc
	DllCall("EnumWindows", "Ptr", callback, "uint", Object(Array))
return Array
}

PathCreateFromURL( URL )
{
 VarSetCapacity( fPath, Sz := 2084, 0 )
 DllCall( "shlwapi\PathCreateFromUrl" ( A_IsUnicode ? "W" : "A" )
         , "Str",URL, "Str",fPath, "UIntP",Sz, "UInt",0 )
 return fPath
}

; Example:
; Array := Enum_Explorer()
; If array.ZOrder.maxindex()
; {
	; For i, o in Array.ZOrder
	; {
		; tt .= "path: " o.path "`n"
		; tt .= "URL: " o.URL "`n"
		; tt .= "Prog: " o.Prog "`n"
		; tt .= "processpath: " o.processpath "`n"
		; tt .= "hwnd: " o.hwnd "`n-------------------------`n"
	; }
; }
; msgbox,% tt