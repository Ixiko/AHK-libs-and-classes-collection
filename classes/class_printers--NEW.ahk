; Title:   	
; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; ===============================================================================================================================
; AutoHotkey wrapper for Print Spooler API Functions
;
; Author ....: jNizM
; Released ..: 2020-07-19
; Modified ..: 2021-04-12
; ===============================================================================================================================


class Printers
{

	; ===== PUBLIC METHODS ======================================================================================================

	AddConnection(PrinterName)
	{
		if (DllCall("winspool.drv\AddConnection", "str", PrinterName))
			return true
		return false
	}


	Delete(PrinterName)
	{
		static PRINTER_ALL_ACCESS := 0x000F000C

		if (hPrinter := this.OpenHandle(PrinterName, PRINTER_ALL_ACCESS))
		{
			if (DllCall("winspool.drv\DeletePrinter", "ptr", hPrinter))
			{
				this.CloseHandle(hPrinter)
				return true
			}
			this.CloseHandle(hPrinter)
		}
		return false
	}


	DeleteConnection(PrinterName)
	{
		if (DllCall("winspool.drv\DeletePrinterConnection", "str", PrinterName))
			return true
		return false
	}


	Enum(flags := "")
	{
		flags := (flags) ? flags : 0x2|0x4
		if !(DllCall("winspool.drv\EnumPrinters", "uint", flags, "ptr", 0, "uint", 2, "ptr", 0, "uint", 0, "uint*", size, "uint*", 0))
		{
			size := VarSetCapacity(buf, size << 1, 0)
			if (DllCall("winspool.drv\EnumPrinters", "uint", flags, "ptr", 0, "uint", 2, "ptr", &buf, "uint", size, "uint*", 0, "uint*", enum))
			{
				addr := &buf, PRINTER_INFO := []
				loop % enum
				{
					PRINTER_INFO[A_Index, "ServerName"]  := StrGet(NumGet(addr + 0, "ptr"))
					PRINTER_INFO[A_Index, "PrinterName"] := StrGet(NumGet(addr + A_PtrSize, "ptr"))
					PRINTER_INFO[A_Index, "ShareName"]   := StrGet(NumGet(addr + A_PtrSize * 2, "ptr"))
					PRINTER_INFO[A_Index, "PortName"]    := StrGet(NumGet(addr + A_PtrSize * 3, "ptr"))
					PRINTER_INFO[A_Index, "DriverName"]  := StrGet(NumGet(addr + A_PtrSize * 4, "ptr"))
					PRINTER_INFO[A_Index, "Comment"]     := StrGet(NumGet(addr + A_PtrSize * 5, "ptr"))
					PRINTER_INFO[A_Index, "Location"]    := StrGet(NumGet(addr + A_PtrSize * 6, "ptr"))
					addr += A_PtrSize * 13 + 32
				}
				return PRINTER_INFO
			}
		}
		return false
	}


	GetDefault()
	{
		if !(DllCall("winspool.drv\GetDefaultPrinter", "ptr", 0, "uint*", size))
		{
			size := VarSetCapacity(buf, size << 1, 0)
			if (DllCall("winspool.drv\GetDefaultPrinter", "str", buf, "uint*", size))
				return buf
		}
		return false
	}


	GetInfo(PrinterName)
	{
		static PRINTER_ACCESS_USE := 0x00000008

		if (hPrinter := this.OpenHandle(PrinterName, PRINTER_ACCESS_USE))
		{
			if !(DllCall("winspool.drv\GetPrinter", "ptr", hPrinter, "uint", 2, "ptr", 0, "uint", 0, "uint*", size))
			{
				size := VarSetCapacity(buf, size << 1, 0)
				if (DllCall("winspool.drv\GetPrinter", "ptr", hPrinter, "uint", 2, "ptr", &buf, "uint", size, "uint*", 0))
				{
					addr := &buf, PRINTER_INFO := []
					PRINTER_INFO["ServerName"]  := StrGet(NumGet(addr + 0, "ptr"))
					PRINTER_INFO["PrinterName"] := StrGet(NumGet(addr + A_PtrSize, "ptr"))
					PRINTER_INFO["ShareName"]   := StrGet(NumGet(addr + A_PtrSize * 2, "ptr"))
					PRINTER_INFO["PortName"]    := StrGet(NumGet(addr + A_PtrSize * 3, "ptr"))
					PRINTER_INFO["DriverName"]  := StrGet(NumGet(addr + A_PtrSize * 4, "ptr"))
					PRINTER_INFO["Comment"]     := StrGet(NumGet(addr + A_PtrSize * 5, "ptr"))
					PRINTER_INFO["Location"]    := StrGet(NumGet(addr + A_PtrSize * 6, "ptr"))
					this.CloseHandle(hPrinter)
					return PRINTER_INFO
				}
			}
			this.CloseHandle(hPrinter)
		}
		return false
	}


	Properties(PrinterName, hWindow := 0)
	{
		static PRINTER_ACCESS_USE := 0x00000008

		if (hPrinter := this.OpenHandle(PrinterName, PRINTER_ACCESS_USE))
		{
			if (DllCall("winspool.drv\PrinterProperties", "ptr", hWindow, "ptr", hPrinter))
			{
				this.CloseHandle(hPrinter)
				return true
			}
			this.CloseHandle(hPrinter)
		}
		return false
	}


	SetDefault(Printer)
	{
		if (DllCall("winspool.drv\SetDefaultPrinter", "str", Printer))
			return true
		return false
	}


	; ===== PRIVATE METHODS =====================================================================================================

	CloseHandle(hPrinter)
	{
		if (DllCall("winspool.drv\ClosePrinter", "ptr", hPrinter))
			return true
		return false
	}


	OpenHandle(PrinterName, DesiredAccess)
	{
		VarSetCapacity(PRINTER_DEFAULTS, A_PtrSize * 3, 0)
		NumPut(DesiredAccess, PRINTER_DEFAULTS, A_PtrSize * 2, "ptr")
		if (DllCall("winspool.drv\OpenPrinter", "str", PrinterName, "ptr*", hPrinter, "ptr", &PRINTER_DEFAULTS))
			return hPrinter
		return false
	}

}

; ===============================================================================================================================