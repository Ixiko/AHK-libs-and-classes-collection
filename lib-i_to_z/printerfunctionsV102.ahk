;Scriptfile to combine several usefull printerfunction
;version 1.0.2 from 18.02.2019
;changed by Ixiko for compatibility with AHK V1.3*

;GetInstalledPrinters returns a list of all installed printers followed by the delimiter.
;The delimiter can be changed by setting the delimiter parameter.
;The Default parameter is to get the default selected printer with a double delimiter behind it.

;GetDefaultPrinter is just to get the currently selected default printer

;SetDefaultPrinter is to change the default printer. The parameter must be the COMPLETE name of the printer.

GetInstalledPrinters(Delimiter="|",Default=True) {
	
	if (Default = True)
	{
			RegRead, defaultPrinter, HKCU, Software\Microsoft\Windows NT\CurrentVersion\Windows, Device
			defaultName:= Strsplit(defaultPrinter, ",")
			defaultName := defaultName[1]
			printerlist := ""
			
			Loop, HKCU, Software\Microsoft\Windows NT\CurrentVersion\devices
			{
					if (A_LoopRegName = defaultname)
						printerlist .= A_LoopRegName . Delimiter . Delimiter				;orig: printerlist = %printerlist%%A_loopRegName%%Delimiter%%Delimiter%
					else 
						printerlist .= A_loopRegName . Delimiter
			}
	}
	else
	{
			printerlist := ""
			Loop, HKCU, Software\Microsoft\Windows NT\CurrentVersion\devices
					printerlist .= A_loopRegName . Delimiter
	}
	
	return RTrim(printerlist, Delimiter)
	
}

GetDefaultPrinter()  {
         nSize := VarSetCapacity(gPrinter, 256)
         DllCall(A_WinDir . "\system\winspool.drv\GetDefaultPrinterA", "str", gPrinter, "UintP", nSize)
         Return gprinter
}

SetDefaultPrinter(sPrinter) {
      DllCall(A_WinDir . "\system\winspool.drv\SetDefaultPrinterA", "str", sPrinter)
}

