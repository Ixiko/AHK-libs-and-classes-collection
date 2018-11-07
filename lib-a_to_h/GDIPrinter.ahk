#Include, gdip.ahk

EnumPrinters()
{
	PRINTER_ENUM_NAME := 0x8
	Level := 4
	DllCall("Winspool.drv\EnumPrinters", "UInt", PRINTER_ENUM_NAME, "Str", "", "UInt", Level, "Ptr", 0, "UInt", 0, "UIntP", pcbNeeded, "UIntP", pcReturned)
	cbBuf := VarSetCapacity(pPrinterEnum, pcbNeeded)
	DllCall("Winspool.drv\EnumPrinters", "UInt", PRINTER_ENUM_NAME, "Str", NULL, "UInt", Level, "Ptr", &pPrinterEnum, "UInt", cbBuf, "UIntP", pcbNeeded, "UIntP", pcReturned)
	
	Loop, % pcReturned
		Name := Name "|" StrGet(NumGet(pPrinterEnum, (A_Index - 1)*(A_PtrSize*2+4)))
	return, Trim(Name, "|")
}

GetPrinterDC(PrinterName)
{
	out := DllCall("Gdi32.dll\CreateDC", "Str", "", "Ptr", &PrinterName, "Str", "", "Ptr", "")
	return, out
}

BeginPrintDocument(hDC, Document_Name)
{
   VarSetCapacity(DOCUMENTINFO_STRUCT,(A_PtrSize * 4) + 4,0),
   NumPut((A_PtrSize * 4) + 4, DOCUMENTINFO_STRUCT)
   NumPut(&Document_Name,DOCUMENTINFO_STRUCT,A_PtrSize)
   if DllCall("Gdi32.dll\StartDoc","Ptr",hDC,"Ptr",&DOCUMENTINFO_STRUCT,"int") > 0
    out := DllCall("Gdi32.dll\StartPage","Ptr",hDC,"int")
 return %out%
}

EndPrintDocument(hDC)
{
   DllCall("Gdi32.dll\EndPage","Ptr",hDC,"int")
   DllCall("Gdi32.dll\EndDoc","Ptr",hDC)
   DeleteDC(hDC)
   return
}
