; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?t=12735
; Author:	Flipeador
; Date:
; for:     	AHK_L

/*

	;EnumPrinters = tested on 32&64-bit system; AHK UNICODE ONLY!
	for k, v in EnumPrinters()
		MsgBox % "#" k "`nFlags: " v.Flags "`nDescription: " v.Description
			. "`nName: " v.Name "`nComment: " v.Comment
	ExitApp

*/


SetDefaultPrinter(Printer := 0) {
	return DllCall("Winspool.drv\SetDefaultPrinterW", "Ptr", &Printer, "Int")
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/dd162971(v=vs.85).aspx

GetDefaultPrinter() {
	DllCall("Winspool.drv\GetDefaultPrinterW", "Ptr", 0, "UIntP", Size)
	, VarSetCapacity(OutputVar, Size * 2, 0)
	, Ok := DllCall("Winspool.drv\GetDefaultPrinterW", "Str", OutputVar, "UIntP", Size, "Int")
	return OutputVar, ErrorLevel := !Ok
} ;https://msdn.microsoft.com/en-us/library/windows/desktop/dd144876(v=vs.85).aspx

EnumPrinters() {

	LocalPrinters   := 0x00000002   ; https://msdn.microsoft.com/en-us/library/cc244669.aspx
	NetworkPrinters := 0x00000004   ; https://msdn.microsoft.com/en-us/library/cc244669.aspx

	DllCall("Winspool.drv\EnumPrinters", "UInt", Flags, "Ptr", 0, "UInt", 1, "Ptr", 0, "UInt", 0, "UIntP", Size, "UIntP", 0)
	, VarSetCapacity(PRINTER_INFO_1, Size * 2, 0)
	, DllCall("Winspool.drv\EnumPrinters", "UInt", Flags, "Ptr", 0, "UInt", 1, "Ptr", &PRINTER_INFO_1, "UInt", Size, "UIntP", 0, "UIntP", Count)
	Offset := A_PtrSize=4?-16:-32, List := []
	Loop, % Count {
		Info := {}, Offset += A_PtrSize=4?16:32
		, Info.Flags := NumGet(PRINTER_INFO_1, Offset, "UInt")
		, Info.Description := StrGet(NumGet(PRINTER_INFO_1, Offset+A_PtrSize))
		, Info.Name := StrGet(NumGet(PRINTER_INFO_1, Offset+(A_PtrSize*2)))
		, Info.Comment := StrGet(NumGet(PRINTER_INFO_1, Offset+(A_PtrSize*3)))
		, List.Push(Info)
	}
	return List
}



