GetDefaultPrinter() {
         nSize := VarSetCapacity(gPrinter, 256)
         DllCall(A_WinDir . "\system\winspool.drv\GetDefaultPrinterA", "str", gPrinter, "UintP", nSize)
         Return gprinter
   }

SetDefaultPrinter(sPrinter) {
      DllCall(A_WinDir . "\system\winspool.drv\SetDefaultPrinterA", "str", sPrinter)
   }

GetInstalledPrinters() {
	regread,defaultPrinter,HKCU,Software\Microsoft\Windows NT\CurrentVersion\Windows,device
	stringsplit,defaultName,defaultPrinter,`,
	defaultName := defaultName1
	SplitPath, defaultName , DefaultPrinterName
	printerlist =
	loop,HKCU,Software\Microsoft\Windows NT\CurrentVersion\devices
	{
		SplitPath, A_LoopRegName , PrinterName
		if (PrinterName = DefaultPrinterName)
		printerlist = %printerlist%%PrinterName%||
		else printerlist = %printerlist%%PrinterName%|
	}
	return %printerlist%
}