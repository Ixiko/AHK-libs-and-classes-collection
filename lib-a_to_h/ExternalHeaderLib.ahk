/*
Title: ExternalHeaderLib (v0.1 February 5, 2014)

Introduction
------------

	'ExternalHeaderLib' enables to read the texts of the column headers from an external
	ListView control or from an external Tab control.
	It also enables to search for the presence of such control types in any external Window.
	
Compatibility
-------------

   This lib was designed to run on AutoHotkey v1.0.48.04+ (32 and 64-bit)), on Windows 2000+.

Links
-----

	Shell Functions
	http://msdn.microsoft.com/en-us/library/windows/desktop/bb776426%28v=vs.85%29.aspx

	Process and Thread Functions
	http://msdn.microsoft.com/en-us/library/windows/desktop/ms684847%28v=vs.85%29.aspx

	Memory Management Functions
	http://msdn.microsoft.com/en-us/library/windows/desktop/ms684847%28v=vs.85%29.aspx

	Debugging Functions
	http://msdn.microsoft.com/en-us/library/windows/desktop/ms679303%28v=vs.85%29.aspx

	About Messages and Message Queues
	http://msdn.microsoft.com/en-us/library/windows/desktop/ms644927%28v=vs.85%29.aspx

	Handle and Object Functions
	http://msdn.microsoft.com/en-us/library/windows/desktop/ms724461%28v=vs.85%29.aspx

Credit
------

	unknown russian	(xx-xx-xxxx) http://forum.script-coding.info/viewtopic.php?pid=26126#p26126
	YMP (russian)		(23-07-2009) http://forum.script-coding.com/viewtopic.php?id=3440
											 SysTabControl32x Ansi platform
	entropic/leef_me	(14-11-2009) SysTabControl32x Ansi platform
	Lucid_Method 		(02-08-2011) SysHeader32x Ansi platform
	Oldman       		(03-02-2014) SysTabControl32x and SysHeader32x
											 Ansi and Unicode (32 & 64-bits) platforms

How to used it
--------------

	If you don't know the ClassNN of the control, call the GetExternalHeaderClassNN() function :
	
		GetExternalClassNN(WinTitle),
		the function returns an array with all the SysTabControl32x and all the SysHeader32x
		classNN.
		or
		GetExternalClassNN(WinTitle, "SysTabControl32"),
		the function returns an array with all the SysTabControl32x ClassNN.
		or
		GetExternalClassNN(WinTitle, "SysHeader32"),
		the function returns an array with all the the SysHeader32x ClassNN.
	
	if you konw the ClassNN of the control, call the GetExternalHeaderText() function :
	
		GetExternalHeaderText(WinTitle),
		the function returns an array with the text header of the default classNN (SysHeader321).
		or
		GetExternalHeaderText(WinTitle, "SysHeader322"),
		the function returns an array with the text header of the "SysHeader322" ClassNN.
		or
		GetExternalHeaderText(WinTitle, "SysTabControl321"),
		the function returns an array with the text header of the "SysTabControl321" ClassNN.
		or ...

Changes
-------

	0.1 11/02/2014 minor change
		 bugfix on the comparison of the Dll version, the 2nd majorVersion >= 5 -->
		 majorVersion >= 6.
		 change in the allocation of the virtual memory (4096 bytes instead of itemLen+MaxLen)

Author
------

	JPV alias Oldman
*/

;---------------------------
; Get external header texts
;---------------------------
GetExternalHeaderText(_winTitle, _classNN="SysHeader321", MaxName=100) {
	static XXX_GETITEMCOUNT
	static XXX_GETITEM
	
	static HDI_TEXT             	:= 0x2
	static HDM_GETITEMCOUNT     	:= 0x1200
	static HDM_GETITEMA         	:= 0x1203
	static HDM_GETITEMW         	:= 0x120B
	
	static TCIF_TEXT            	:= 0x1
	static TCM_GETITEMCOUNT     	:= 0x1304
	static TCM_GETITEMA         	:= 0x1305
	static TCM_GETITEMW         	:= 0x133C
	
	static MEM_COMMIT           	:= 0x1000
	static MEM_RESERVE          	:= 0x2000
	static MEM_DECOMMIT         	:= 0x4000
	static MEM_RELEASE          	:= 0x8000
	
	static PAGE_READWRITE       	:= 0x4
	
	static PROCESS_VM_OPERATION 	:= 0x8
	static PROCESS_VM_READ      	:= 0x10
	static PROCESS_VM_WRITE     	:= 0x20
	
	enum := []
	
	if (A_OSType = WIN32_WINDOWS)
	{
		MsgBox, % A_ThisFunc " does not support OS " A_OSVersion ".`nMinimum supported Windows 2000."
		return false
	}
	
	if ((classNN := SubStr(_classNN, 1, 11)) <> "SysHeader32")
	{
		if ((classNN := SubStr(_classNN, 1, 15)) <> "SysTabControl32")
		{
			MsgBox, % A_ThisFunc " does not support ClassNN " _classNN
			return false
		}
	}
	
	ControlGet, hHeader, Hwnd,, %_classNN%, %_winTitle%
	
	if !hHeader
	{
		MsgBox, % A_ThisFunc " ControlGet Hwnd failed for " _classNN "`n" _winTitle
		return false
	}
	
	;---------------------------------
	; Get comctl32.dll version number
	;---------------------------------
	Ptr := A_IsUnicode ? "Ptr" : "UInt"
	
	VarSetCapacity(dvi2, 32, 0)
	NumPut(32, dvi2, 0, "UInt")
	
	if DllCall("comctl32.dll\DllGetVersion", Ptr, &dvi2, "UInt")
	{
		MsgBox, % A_ThisFunc " DllGetVersion() failed " ErrorLevel
		return false
	}
	
	majorVersion := NumGet(dvi2, 4, "UInt")
	
	;-----------------
	; Get process pid
	;-----------------
	WinGet, pid, PID, %_winTitle%
	
	if !pid
	{
		MsgBox, % A_ThisFunc " WinGet PID failed for " _winTitle
		return false
	}
	
	;--------------
	; Open Process
	;--------------
	options := PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE
	
	if !hProcess := DllCall("OpenProcess", "UInt", options, "Int", false, "UInt", pid)
	{
		MsgBox, % A_ThisFunc " OpenProcess() failed for " pid "`n" _winTitle " - " A_LastError
		return
	}
	
	;----------------------------
	; Calculate structure length
	;----------------------------
	if (classNN = "SysHeader32")
	{
		; UInt + Int + 2Ptr + 2Int + Ptr
		itemLen := 16 + 3 * A_PtrSize
		
		; + 2Int
		if (majorVersion >= 3)
			itemLen += 8
		
		; + UInt + Ptr
		if (majorVersion >= 5)
			itemLen += 4 + A_PtrSize
		
		; + UInt
		if (majorVersion >= 6)
			itemLen += 4
	}
	else if (classNN = "SysTabControl32")
	{
		; 3UInt + Ptr + 2Int + Ptr
		itemLen := 12 + A_PtrSize + 8 + A_PtrSize
	}
	
	;-------------------------
	; Allocate virtual memory
	;-------------------------
	if !pMem := DllCall("VirtualAllocEx",  Ptr  , hProcess
													,  Ptr  , 0
													, "UInt", 4096
													, "UInt", MEM_COMMIT
													, "UInt", PAGE_READWRITE)
	{
		MsgBox, % A_ThisFunc " VirtualAllocEx() failed for " _winTitle " - " A_LastError
		gosub, CloseHandle
		return false
	}
	
	;----------------------
	; Write virtual memory
	;----------------------
	MaxLen := MaxName * (A_IsUnicode ? 2 : 1)
	
	VarSetCapacity(buf, MaxLen, 0)
	VarSetCapacity(item, itemLen, 0)
	
	if (classNN = "SysHeader32")
	{
		NumPut(HDI_TEXT, item, 0, "UInt")						; mask
		NumPut(pMem+itemLen, item, 8, Ptr)						; pszText
		NumPut(MaxName, item, 8+2*A_PtrSize, "Int")			; cchTextMax
	}
	else if (classNN = "SysTabControl32")
	{
		NumPut(TCIF_TEXT, item, 0, "UInt")						; mask
		NumPut(pMem+itemLen, item, 12, Ptr)						; pszText
		NumPut(MaxName, item, 12+A_PtrSize, "Int")			; cchTextMax
	}
	
	if !DllCall("WriteProcessMemory",  Ptr  , hProcess
											  ,  Ptr  , pMem
											  ,  Ptr  , &item
											  , "UInt", itemLen
											  , "UInt", 0)
	{
		MsgBox, % A_ThisFunc " WriteProcessMemory() failed for " _winTitle " - " A_LastError
		gosub, FreeMemory
		gosub, CloseHandle
		return false
	}
	
	;-----------------------
	; Get number of columns
	;-----------------------
	if (classNN = "SysHeader32")
	{
		XXX_GETITEMCOUNT := HDM_GETITEMCOUNT
		XXX_GETITEM      := A_IsUnicode ? HDM_GETITEMW : HDM_GETITEMA
	}
	else if (classNN = "SysTabControl32")
	{
		XXX_GETITEMCOUNT := TCM_GETITEMCOUNT
		XXX_GETITEM      := A_IsUnicode ? TCM_GETITEMW : TCM_GETITEMA
	}
	
	SendMessage, XXX_GETITEMCOUNT, 0, 0,, ahk_id %hHeader%
	
	if (ErrorLevel < 0 or ErrorLevel = "FAIL")
	{
		MsgBox, % A_ThisFunc " SendMessage GETITEMCOUNT(" XXX_GETITEMCOUNT ") failed for " _classNN
		gosub, FreeMemory
		gosub, CloseHandle
		return false
	}
	
	nbItem := ErrorLevel
	
	;-------------------------
	; Get header column texts
	;-------------------------
	Loop, % nbItem
	{
		SendMessage, XXX_GETITEM, A_Index-1, pMem,, ahk_id %hHeader%
		
		if !ErrorLevel
		{
			MsgBox, % A_ThisFunc " SendMessage GETITEM(" XXX_GETITEM ") failed for " _classNN
			gosub, FreeMemory
			gosub, CloseHandle
			return false
		}
		
		if !DllCall("ReadProcessMemory",  Ptr  , hProcess
												 ,  Ptr  , pMem+itemLen
												 ,  Ptr  , &buf
												 , "UInt", MaxLen
												 , "UInt", 0)
		{
			MsgBox, % A_ThisFunc " ReadProcessMemory() failed for " _winTitle " - " A_LastError
			gosub, FreeMemory
			gosub, CloseHandle
			return false
		}
		
		VarSetCapacity(buf, -1)
		enum[A_Index] := buf
	}
	
	gosub, FreeMemory
	gosub, CloseHandle
	return enum

FreeMemory:
	DllCall("VirtualFreeEx", Ptr, hProcess, Ptr, pMem, "UInt", 0, "UInt", MEM_DECOMMIT)
	return
	
CloseHandle:
	DllCall("CloseHandle", Ptr, hProcess)
	return
}

;----------------------
; Get external ClassNN
;----------------------
GetExternalHeaderClassNN(_winTitle, _sysHeader="")
{
	WinGet, ctrlList, ControlList, %_winTitle%
	
	enum := []
	i    := 0
	
	if _sysHeader
	{
		Loop, Parse, ctrlList, `n
			if InStr(A_LoopField, _sysHeader)
				enum[++i] := A_LoopField
	}
	else
	{
		Loop, Parse, ctrlList, `n
			if InStr(A_LoopField, "SysHeader32")
			or InStr(A_LoopField, "SysTabControl32")
				enum[++i] := A_LoopField
	}
	
	return enum
}
