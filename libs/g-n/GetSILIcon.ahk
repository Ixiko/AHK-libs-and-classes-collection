; v1.1 © Drugwash
;================================================================
GetSILIcon(File="", h="0")
;================================================================
{
Global
Static init, SHFILEINFOsz, SHFILEINFO
if !init	; one-time switch to initialize COM and locally-defined types for AHK Basic
	{
	init := !DllCall("ole32\CoInitialize", "UInt", 0)	; SHGetFileInfo() requires COM init in AHK Basic
;	SHGFI_SYSICONINDEX := 0x4000	SHGFI_USEFILEATTRIBUTES := 0x10
;	SHGFI_ICON := 0x100	SHGFI_SMALLICON := 0x1	SHGFI_LARGEICON := 0x0
;	SHGFI_SHELLICONSIZE := 0x4
	SHFILEINFOsz := VarSetCapacity(SHFILEINFO, PtrSz+8+340*A_CharSize, 0)
	}
else if (!File && init)
	return DllCall("ole32\CoUninitialize")
if InStr(h, "h")
	{
	StringRight, h, h, 1
	return DllCall("shell32\SHGetFileInfo" AW
			 , "Str"	, File
			 , "UInt"	, 0x80
			 , Ptr	, &SHFILEINFO
			 , "UInt"	, SHFILEINFOsz
			 , "UInt"	, 0x4010+(h&0x5)
			, Ptr)
	}
DllCall("shell32\SHGetFileInfo" AW
		 , "Str"	, File
		 , "UInt"	, 0x80
		 , Ptr	, &SHFILEINFO
		 , "UInt"	, SHFILEINFOsz
		 , "UInt"	, (h>"1" ? 0x100+(h&5) : 0x4000+h))
; h=0 large icon, h=1 small icon, h=2=large handle, h=3 small handle, h=4 large shell icon h=5 small shell icon
return h > 1
	? NumGet(SHFILEINFO, 0, Ptr)			; return handle to icon (may have overlay)
	: 1+NumGet(SHFILEINFO, PtrSz, "UInt")	; ImageList index is zero-based so bump it up one notch
}
