Class MouseManager
{
	SetMouseSpeed(MouseSpeed)
	{
		SPI_SETMOUSESPEED = 0x0071
		DllCall("SystemParametersInfo", UInt, SPI_SETMOUSESPEED, UInt, 0, UInt, MouseSpeed, UInt, 0)
	}
	
	TurnOffPointerPrecision()
	{
		SPI_SETMOUSE = 0x0004
		VarSetCapacity(MySet, 12, 0)
		DllCall("SystemParametersInfo", UInt, SPI_SETMOUSE, UInt, 0, Str, MySet, UInt, 1)
	}
	
	TurnOnPointerPrecision()
	{
		SPI_SETMOUSE = 0x0004

		VarSetCapacity(MySet, 12, 0)

		MouseManager.InsertInteger(6, MySet, 0)		; MouseThreshold1
		MouseManager.InsertInteger(10, MySet, 4)	; MouseThreshold2
		MouseManager.InsertInteger(1, MySet, 8)		; MouseSpeed

		DllCall("SystemParametersInfo", UInt, SPI_SETMOUSE, UInt, 0, Str, MySet, UInt, 1)
	}
	
	InsertInteger(pInteger, ByRef pDest, pOffset = 0, pSize = 4)
	; The caller must ensure that pDest has sufficient capacity.  To preserve any existing contents in pDest,
	; only pSize number of bytes starting at pOffset are altered in it.
	{
		Loop %pSize%  ; Copy each byte in the integer into the structure as raw binary data.
			DllCall("RtlFillMemory", "UInt", &pDest + pOffset + A_Index-1, "UInt", 1, "UChar", pInteger >> 8*(A_Index-1) & 0xFF)
	}
}
