GetClipboardData(_format, ByRef @data)
{
	local cfFormat, hData, pData, dataLen

	If _format is integer
	{
		cfFormat := _format
	}
	Else
	{
		cfFormat := DllCall("RegisterClipboardFormat", "Str", _format, "UInt")
		If (cfFormat = 0)
		{
			Return "BAD_FORMAT"
		}
	}
	If (DllCall("IsClipboardFormatAvailable", "UInt", cfFormat) = 0)
	{
		return "NO_DATA"
	}
	If (DllCall("OpenClipboard", "UInt", 0) != 0)
	{
		hData := DllCall("GetClipboardData", "UInt", cfFormat, "UInt")
		If (hData != 0)
		{
			dataLen := DllCall("GlobalSize", "UInt", hData)
			pData := DllCall("GlobalLock", "UInt", hData, "UInt")
			VarSetCapacity(@data, dataLen, 0)
			; Might do a lstrcpyW (and lstrlenW) for Unicode format...
;~ 			r := DllCall("lstrcpy", "Str", @data, "UInt", pData, "UInt")
			DllCall("RtlMoveMemory"
					, "UInt", &@data	; Destination
					, "UInt", pData	; Source
					, "UInt", dataLen)	; Length
			DllCall("GlobalUnlock", "UInt", hData)
		}
		DllCall("CloseClipboard")
	}
	Return dataLen
}

GetClipboardData(CF_TEXT, str)
MsgBox %str%
GetClipboardData(CF_RTF, str)
MsgBox %str%