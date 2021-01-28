;------------------------------------------------------------------------------
; Atl.ahk Standard Library
; by Sean
;
; REQUIREMENT: 32/64-bit UNICODE AutoHotkey_L
;------------------------------------------------------------------------------

Atl_Init()
{
	Static	h
	If Not	h
		h:=DllCall("LoadLibrary","Str","atl","Ptr"), DllCall("atl\AtlAxWinInit")
}

Atl_AxGetHost(hWnd)
{
	Atl_Init()
	If	DllCall("atl\AtlAxGetHost", "Ptr", hWnd, "Ptr*", punk)=0
	Return	ComObjEnwrap(punk)
}

Atl_AxGetControl(hWnd)
{
	Atl_Init()
	If	DllCall("atl\AtlAxGetControl", "Ptr", hWnd, "Ptr*", punk)=0
	Return	ComObjEnwrap(punk)
}

Atl_AxAttachControl(punk, hWnd)
{
	Atl_Init()
	If	DllCall("atl\AtlAxAttachControl", "Ptr", IsObject(punk)?ComObjUnwrap(punk):punk, "Ptr", hWnd, "Ptr", 0)=0
	Return	IsObject(punk)?punk:ComObjEnwrap(punk)
}

Atl_AxCreateControl(hWnd, Name)
{
	Atl_Init()
	If	DllCall("atl\AtlAxCreateControlEx", "WStr", Name, "Ptr", hWnd, "Ptr", 0, "Ptr", 0, "Ptr*", punk, "Ptr", VarSetCapacity(GUID,16,0)*0+&GUID, "Ptr", 0)=0
	Return	ComObjEnwrap(punk)
}

Atl_AxCreateContainer(hWnd, l, t, w, h, Name = "", ExStyle = 0, Style = 0x54000000)
{
	Atl_Init()
	Return	DllCall("CreateWindowEx", "UInt", ExStyle, "Str", "AtlAxWin", "Str", Name, "UInt", Style, "Int", l, "Int", t, "Int", w, "Int", h, "Ptr", hWnd, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")
}
