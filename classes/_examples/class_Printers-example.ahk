;Retrieves the default printer for the current user on the local computer
MsgBox % Printers.GetDefault()

;Sets the default printer for the current user on the local computer
MsgBox % Printers.SetDefault("\\192.0.0.1\PRINTER_A")

;Adds a connection to the specified printer for the current user
MsgBox % Printers.AddConnection("\\192.0.0.1\PRINTER_A")

;Deletes a connection to a printer that was established by a call to AddPrinterConnection or ConnectToPrinterDlg
MsgBox % Printers.DeleteConnection("\\192.0.0.1\PRINTER_A")

;Enumerates available printers, print servers, domains, or print providers
PrintArr(Printers.Enum(0x2|0x4))

PrintArr(Arr, Option := "w1200 h800", GuiNum := 90){
	for index, obj in Arr {
		if (A_Index = 1) {
			for k, v in obj {
				Columns .= k "|"
				cnt++
			}
			Gui, %GuiNum%: Margin, 5, 5
			Gui, %GuiNum%: Add, ListView, %Option%, % Columns
		}
		RowNum := A_Index
		Gui, %GuiNum%: default
		LV_Add("")
		for k, v in obj {
			LV_GetText(Header, 0, A_Index)
			if (k <> Header) {
				FoundHeader := False
				loop % LV_GetCount("Column") {
					LV_GetText(Header, 0, A_Index)
					if (k <> Header)
						continue
					else {
						FoundHeader := A_Index
						break
					}
				}
				if !(FoundHeader) {
					LV_InsertCol(cnt + 1, "", k)
					cnt++
					ColNum := "Col" cnt
				} else
					ColNum := "Col" FoundHeader
			} else
				ColNum := "Col" A_Index
			LV_Modify(RowNum, ColNum, (IsObject(v) ? "Object()" : v))
		}
	}
	loop % LV_GetCount("Column")
		LV_ModifyCol(A_Index, "AutoHdr")
	Gui, %GuiNum%: Show,, Array
}

#include %A_ScriptDir%\..\class_Printers.ahk