; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62955&sid=946210846b62fc770d1a8241764148d4


Class Printers
{
	; ===========================================================================================================================
	; https://docs.microsoft.com/en-us/windows/desktop/printdocs/addprinterconnection
	; ===========================================================================================================================
	AddConnection(printer)
	{
		if !(DllCall("winspool.drv\AddPrinterConnection", "str", printer))
			return false
		return true
	}

	; ===========================================================================================================================
	; https://docs.microsoft.com/en-us/windows/desktop/printdocs/closeprinter
	; ===========================================================================================================================
	CloseHandle(handle)
	{
		if !(DllCall("winspool.drv\ClosePrinter", "str", handle))
			return false
		return true
	}

	; ===========================================================================================================================
	; https://docs.microsoft.com/en-us/windows/desktop/printdocs/deleteprinterconnection
	; ===========================================================================================================================
	DeleteConnection(printer)
	{
		if !(DllCall("winspool.drv\DeletePrinterConnection", "str", printer))
			return false
		return true
	}

	; ===========================================================================================================================
	; https://docs.microsoft.com/en-us/windows/desktop/printdocs/enumprinters
	; ===========================================================================================================================
	Enum(flags)
	{
		if !(DllCall("winspool.drv\EnumPrinters", "uint", flags, "ptr", 0, "uint", 2, "ptr", 0, "uint", 0, "uint*", size, "uint*", 0))
		{
			size := VarSetCapacity(buf, size << 1, 0)
			if (DllCall("winspool.drv\EnumPrinters", "uint", flags, "ptr", 0, "uint", 2, "ptr", &buf, "uint", size, "uint*", 0, "uint*", count))
			{
				addr := &buf, PRINTER_INFO_2 := []
				loop % count
				{
					PRINTER_INFO_2[A_Index, "ServerName"]      := StrGet(NumGet(addr + 0,                   "ptr"))
					PRINTER_INFO_2[A_Index, "PrinterName"]     := StrGet(NumGet(addr + A_PtrSize,           "ptr"))
					PRINTER_INFO_2[A_Index, "ShareName"]       := StrGet(NumGet(addr + A_PtrSize *  2,      "ptr"))
					PRINTER_INFO_2[A_Index, "PortName"]        := StrGet(NumGet(addr + A_PtrSize *  3,      "ptr"))
					PRINTER_INFO_2[A_Index, "DriverName"]      := StrGet(NumGet(addr + A_PtrSize *  4,      "ptr"))
					PRINTER_INFO_2[A_Index, "Comment"]         := StrGet(NumGet(addr + A_PtrSize *  5,      "ptr"))
					PRINTER_INFO_2[A_Index, "Location"]        := StrGet(NumGet(addr + A_PtrSize *  6,      "ptr"))
					;DevMode                                   :=        NumGet(addr + A_PtrSize *  7,      "ptr")
					; https://docs.microsoft.com/en-us/windows/desktop/api/Wingdi/ns-wingdi-_devicemodea
					PRINTER_INFO_2[A_Index, "SepFile"]         := StrGet(NumGet(addr + A_PtrSize *  8,      "ptr"))
					PRINTER_INFO_2[A_Index, "PrintProcessor"]  := StrGet(NumGet(addr + A_PtrSize *  9,      "ptr"))
					PRINTER_INFO_2[A_Index, "Datatpye"]        := StrGet(NumGet(addr + A_PtrSize * 10,      "ptr"))
					PRINTER_INFO_2[A_Index, "Parameters"]      := StrGet(NumGet(addr + A_PtrSize * 11,      "ptr"))
					;SecurityDescriptor                        :=        NumGet(addr + A_PtrSize * 12,      "ptr")
					; https://docs.microsoft.com/de-de/windows/desktop/api/winnt/ns-winnt-_security_descriptor
					PRINTER_INFO_2[A_Index, "Attributes"]      :=        NumGet(addr + A_PtrSize * 13,      "uint")
					PRINTER_INFO_2[A_Index, "Priority"]        :=        NumGet(addr + A_PtrSize * 13 +  4, "uint")
					PRINTER_INFO_2[A_Index, "DefaultPriority"] :=        NumGet(addr + A_PtrSize * 13 +  8, "uint")
					PRINTER_INFO_2[A_Index, "StartTime"]       :=        NumGet(addr + A_PtrSize * 13 + 12, "uint")
					PRINTER_INFO_2[A_Index, "UntilTime"]       :=        NumGet(addr + A_PtrSize * 13 + 16, "uint")
					PRINTER_INFO_2[A_Index, "Status"]          :=        NumGet(addr + A_PtrSize * 13 + 20, "uint")
					PRINTER_INFO_2[A_Index, "Jobs"]            :=        NumGet(addr + A_PtrSize * 13 + 24, "uint")
					PRINTER_INFO_2[A_Index, "AveragePPM"]      :=        NumGet(addr + A_PtrSize * 13 + 28, "uint")
					addr += A_PtrSize * 13 + 32
				}
				return PRINTER_INFO_2
			}
		}
		return false
	}


	; ===========================================================================================================================
	; https://docs.microsoft.com/en-us/windows/desktop/printdocs/getdefaultprinter
	; ===========================================================================================================================
	GetDefault()
	{
		if !(DllCall("winspool.drv\GetDefaultPrinter", "ptr", 0, "uint*", size))
		{
			size := VarSetCapacity(buf, size << 1, 0)
			if !(DllCall("winspool.drv\GetDefaultPrinter", "str", buf, "uint*", size))
				return false
		}
		return buf
	}

	; ===========================================================================================================================
	; https://docs.microsoft.com/en-us/windows/desktop/printdocs/getprinter
	; ===========================================================================================================================
	GetInfo(printer)
	{
		if (handle := this.OpenHandle(printer))
		{
			if !(DllCall("winspool.drv\GetPrinter", "ptr", handle, "uint", 1, "ptr", 0, "uint", 0, "uint*", size))
			{
				size := VarSetCapacity(buf, size << 1, 0)
				if (DllCall("winspool.drv\GetPrinter", "ptr", handle, "uint", 1, "ptr", &buf, "uint", size, "uint*", 0))
				{
					PRINTER_INFO_1             := {}
					PRINTER_INFO_1.Flags       := NumGet(&buf + 0, "uint")
					PRINTER_INFO_1.Description := StrGet(NumGet(&buf + (A_PtrSize * 1), "uptr"), "utf-16")
					PRINTER_INFO_1.Name        := StrGet(NumGet(&buf + (A_PtrSize * 2), "uptr"), "utf-16")
					PRINTER_INFO_1.Comment     := StrGet(NumGet(&buf + (A_PtrSize * 3), "uptr"), "utf-16")
					this.CloseHandle(handle)
					return PRINTER_INFO_1
				}
			}
			this.CloseHandle(handle)
		}
		return false
	}

	; ===========================================================================================================================
	; https://docs.microsoft.com/en-us/windows/desktop/printdocs/openprinter
	; ===========================================================================================================================
	OpenHandle(printer)
	{
		if !(DllCall("winspool.drv\OpenPrinter", "ptr", &printer, "ptr*", handle, "ptr", 0))
			return false
		return handle
	}

	; ===========================================================================================================================
	; https://docs.microsoft.com/en-us/windows/desktop/printdocs/setdefaultprinter
	; ===========================================================================================================================
	SetDefault(printer)
	{
		if !(DllCall("winspool.drv\SetDefaultPrinter", "str", printer))
			return false
		return true
	}
}