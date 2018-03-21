;Scriptfile to combine several usefull printerfunction
;version 1.0.1
;
;GetInstalledPrinters returns a list of all installed printers followed by the delimiter.
;The delimiter can be changed by setting the delimiter parameter.
;The Default parameter is to get the default selected printer with a double delimiter behind it.
;
;GetDefaultPrinter is just to get the currently selected default printer
;
;SetDefaultPrinter is to change the default printer. The parameter must be the COMPLETE name of the printer.

GetInstalledPrinters(Delimiter="|",Default=True)
{
	if (Default = True)
	{
		regread,defaultPrinter,HKCU,Software\Microsoft\Windows NT\CurrentVersion\Windows,device
		stringsplit,defaultName,defaultPrinter,`,
		defaultName := defaultName1
		printerlist =
		loop,HKCU,Software\Microsoft\Windows NT\CurrentVersion\devices
		{
			if (A_LoopRegName = defaultname)
			printerlist = %printerlist%%A_loopRegName%%Delimiter%%Delimiter%
			else printerlist = %printerlist%%A_loopRegName%%Delimiter%
		}
	}
	else
	{
		printerlist =
		loop,HKCU,Software\Microsoft\Windows NT\CurrentVersion\devices
		{
			printerlist = %printerlist%%A_loopRegName%%Delimiter%
		}
	}
	StringTrimRight, printerlist, printerlist, StrLen(Delimiter)
	return %printerlist%
}
return

GetDefaultPrinter()
   {
         nSize := VarSetCapacity(gPrinter, 256)
         DllCall(A_WinDir . "\system\winspool.drv\GetDefaultPrinterA", "str", gPrinter, "UintP", nSize)
         Return gprinter
   }
Return

SetDefaultPrinter(sPrinter)
   {
      DllCall(A_WinDir . "\system\winspool.drv\SetDefaultPrinterA", "str", sPrinter)
   }
Return
