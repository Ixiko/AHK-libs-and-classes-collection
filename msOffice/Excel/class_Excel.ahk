; Link:   	https://gist.github.com/tmplinshi/ea8060941584feec6f550d0b9f9ebee2
; Author:	tmplinshi
; Date:
; for:


/*
	Functions:
		CreateByArray(outputFile, arr)
		CreateByHLV(outputFile, HLV, Obj_LV_Colors := "", IncludeLvHeader := false)
			HLV           - Listview hwnd
			Obj_LV_Colors - Created by using 'New LV_Colors(HLV)'
	ChangeLog:
		v1.05 (2017-8-17) - Added "Column AutoFit"; Added .xls file support
		v1.04 (2016-12-9) - 'IncludeLvHeader' option now doesn't need to change default listview
		v1.03 (2016-12-9) - Added support for LV_Colors's AlternateRows/AlternateCols
		                  - Added 'IncludeLvHeader' option
		v1.02 (2016-12-8) - Fixed some color bugs
		v1.01 (2016-12-8) - Added support for saving listview cell colors

*/

Class Excel {

	static ForceCellFormatToText := true

	CreateByArray(outputFile, arr, colCount="") {
		this.Array_To_SafeArray(arr, SafeArray, colCount)
		this.SafeArray_To_Excel(SafeArray, outputFile)
	}

	CreateByHLV(outputFile, HLV, Obj_LV_Colors := "", IncludeLvHeader := false) {
		ControlGet, lvData, List,,, ahk_id %HLV%
		ControlGet, rowCount, List, Count,, ahk_id %HLV%
		ControlGet, colCount, List, Count Col,, ahk_id %HLV%

		SafeArray := ComObjArray(VT_VARIANT:=12, rowCount, colCount)
		Loop, Parse, lvData, `n, `r
		{
			row := A_Index - 1
			Loop, Parse, A_LoopField, %A_Tab%
				SafeArray[row, A_Index-1] := A_LoopField
		}
		this.HLV := HLV
		this.SafeArray_To_Excel(SafeArray, outputFile, Obj_LV_Colors, IncludeLvHeader)
	}

	Class ApplyColors
	{
		DoIt(SafeArray, oExcel, Obj_LV_Colors) {
			if !IsObject(Obj_LV_Colors)
				return

			sheet := oExcel.ActiveSheet
			this.rowCount := SafeArray.MaxIndex(1) + 1
			this.colCount := SafeArray.MaxIndex(2) + 1

			this.Handle_AlternateRows(Obj_LV_Colors, sheet)
			this.Handle_Rows(Obj_LV_Colors, sheet)
			this.Handle_AlternateCols(Obj_LV_Colors, sheet)
			this.Handle_Cells(Obj_LV_Colors, sheet)
		}

		Handle_AlternateRows(Obj_LV_Colors, sheet) {
			if !Obj_LV_Colors.AltRows || (this.rowCount < 2)
				return

			Loop, % this.rowCount {
				if !Mod(A_Index, 2) && !Obj_LV_Colors.Rows.HasKey(A_Index) {
					cell1 := sheet.Cells(A_Index, 1)
					cell2 := sheet.Cells(A_Index, this.colCount)
					if Obj_LV_Colors.HasKey("ARB")
						try sheet.Range(cell1, cell2).Interior.Color := Obj_LV_Colors.ARB
					if Obj_LV_Colors.HasKey("ART")
						try sheet.Range(cell1, cell2).Font.Color := Obj_LV_Colors.ART
				}
			}
		}

		Handle_AlternateCols(Obj_LV_Colors, sheet) {
			if !Obj_LV_Colors.AltCols || (this.colCount < 2)
				return

			Loop, % this.colCount {
				if !Mod(A_Index, 2) {
					cell1 := sheet.Cells(1, A_Index)
					cell2 := sheet.Cells(this.rowCount, A_Index)
					if Obj_LV_Colors.HasKey("ACB")
						try sheet.Range(cell1, cell2).Interior.Color := Obj_LV_Colors.ACB
					if Obj_LV_Colors.HasKey("ACT")
						try sheet.Range(cell1, cell2).Font.Color := Obj_LV_Colors.ACT
				}
			}
		}

		Handle_Rows(Obj_LV_Colors, sheet) {
			For nRow, oColor in Obj_LV_Colors.Rows {
				if Obj_LV_Colors.IsStatic {
					nRow := this.MapIDToIndex(nRow, Obj_LV_Colors.HWND)
				}

				cell1 := sheet.Cells(nRow, 1)
				cell2 := sheet.Cells(nRow, this.colCount)
				if oColor.HasKey("B")
					try sheet.Range(cell1, cell2).Interior.Color := oColor.B
				if oColor.HasKey("T")
					try sheet.Range(cell1, cell2).Font.Color := oColor.T
			}
		}

		Handle_Cells(Obj_LV_Colors, sheet) {
			For nRow, oCols in Obj_LV_Colors.Cells {
				if Obj_LV_Colors.IsStatic {
					nRow := this.MapIDToIndex(nRow, Obj_LV_Colors.HWND)
				}

				For nCol, oColor in oCols {
					if oColor.HasKey("B")
						try sheet.Cells(nRow, nCol).Interior.Color := oColor.B
					if oColor.HasKey("T")
						try sheet.Cells(nRow, nCol).Font.Color := oColor.T
				}
			}
		}

		MapIDToIndex(ID, HWND) {
			SendMessage, 0x10B5, % ID, 0, , % "ahk_id " . HWND ; LVM_MAPIDTOINDEX
			Return ErrorLevel + 1
		}
	}

	Array_To_SafeArray(arr, ByRef SafeArray, colCount="") {
		rowCount := arr.MaxIndex()
		If !colCount
			colCount := IsObject(arr.1) ? arr.1.MaxIndex() : 1
		SafeArray := ComObjArray(VT_VARIANT:=12, rowCount, colCount)

		Loop, % arr.MaxIndex()
		{
			row := A_Index - 1
			If IsObject( subArr := arr[A_Index] )
				Loop, % subArr.MaxIndex()
					SafeArray[row, A_Index-1] := subArr[A_Index]
			Else
				SafeArray[row, 0] := arr[A_Index]
		}
	}

	SafeArray_To_Excel(SafeArray, ExcelFile, Obj_LV_Colors="", IncludeLvHeader=false) {
		If !InStr(ExcelFile, ":") ; Ensure is fullpath
			ExcelFile := A_ScriptDir "\" ExcelFile

		xl := ComObjCreate("Excel.Application")
		xl.DisplayAlerts := False
		xl.Workbooks.Add

		rowCount := SafeArray.MaxIndex(1) + 1
		colCount := SafeArray.MaxIndex(2) + 1

		sheet := xl.activeSheet

		cell1 := sheet.cells(1, 1)
		cell2 := sheet.cells(rowCount, colCount)
		if this.ForceCellFormatToText
			sheet.Range(cell1, cell2).NumberFormatLocal := "@" ; Set format to Text
		sheet.Range(cell1, cell2).value := SafeArray

		col_start := sheet.Columns(1)
		col_end := sheet.Columns(colCount)
		sheet.Range(col_start, col_end).EntireColumn.AutoFit

		if Obj_LV_Colors {
			this.ApplyColors.DoIt(SafeArray, xl, Obj_LV_Colors)
		}
		if IncludeLvHeader {
			sheet.Rows("1:1").Insert(xlDown:=-4121)
			cell1 := sheet.cells(1, 1)
			cell2 := sheet.cells(1, colCount)
			sheet.Range(cell1, cell2).value := this.Build_LvHdr_SafeArr(colCount)
			sheet.Range(cell1, cell2).Font.Bold := true
		}

		if (ExcelFile ~= "i)\.xls$")
			XlFileFormat := 56 ; xlExcel8
		else
			XlFileFormat := 51 ; xlWorkbookDefault
		sheet.SaveAs(ExcelFile, XlFileFormat)
		xl.Quit
	}

	Build_LvHdr_SafeArr(colCount) {
		SafeArray_Hdr := ComObjArray(VT_VARIANT:=12, 1, colCount)
		Loop %colCount% {
			SafeArray_Hdr[0, A_Index-1] := this.LV_GetHeaderText(this.HLV, A_Index)
		}
		return SafeArray_Hdr
	}

	LV_GetHeaderText(hwndLV, ColumnNumber) {
		static LVM_GETHEADER := 0x101F
		     , HDM_GETITEM := A_IsUnicode ? 0x120B : 0x1203 ; HDM_GETITEMW : HDM_GETITEMA
		     , HDI_TEXT := 0x0002

		SendMessage, LVM_GETHEADER, 0, 0,, ahk_id %hwndLV%
		if !(hWndHeader := ErrorLevel)
			return

		VarSetCapacity(hdi, 48, 0)
		VarSetCapacity(HDITEMTEXT, 1024 * (A_IsUnicode ? 2 : 1), 0)
		NumPut(HDI_TEXT, hdi, 0, "UInt")
		NumPut(&HDITEMTEXT, hdi, 8, "Ptr")
		NumPut(1024, hdi, 8 + (A_PtrSize * 2), "Int")

		SendMessage, HDM_GETITEM, ColumnNumber-1, &hdi,, ahk_id %hWndHeader%
		return StrGet( NumGet(hdi, 8) )
	}
}