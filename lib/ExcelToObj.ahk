; Function:  ExcelToObj
; Author:    tmplinshi
; Tested On: AHK: 1.1.14.03 U32 | OS: WinXP_SP3 | Microsoft Excel: 2010
; =================================================================
; Parameters:
; 	ExcelFile - Path to xls/xlsx file
; 	ResultObj - Structure is [ [], [], ... ]
; 	Format    - Can be "csv" (default) or "html"
ExcelToObj(ExcelFile, ByRef ResultObj, Format = "csv") {
	static xlCSV := 6, xlHTML := 44

	; Make sure ExcelFile is fullpath
	Loop, % ExcelFile
		ExcelFile := A_LoopFileLongPath

	; Temp files
	If (Format = "html") {
		TempDir  := A_Temp "\.ExcelToObj." A_Now
		TempFile := TempDir "\1.html"
		FileRemoveDir, % TempDir, 1
		FileCreateDir, % TempDir
	}
	Else
		TempFile := A_Temp "\.ExcelToObj." A_Now ".csv"

	; Convert excel file to csv or html
	oExcel := ComObjCreate("Excel.Application")
	oExcel.Workbooks.Open(ExcelFile)
	oExcel.Visible := False
	oExcel.DisplayAlerts := False
	oExcel.ActiveWorkbook.SaveAs( TempFile, (Format = "html") ? xlHTML : xlCSV )
	oExcel.Quit()

	; Extract data
	If (Format = "html") {
		;
		; Read stylesheet.css
		;
		FileRead, content, % TempDir "\1.files\stylesheet.css"
		content := RegExReplace(content, "m`a)^\.")
		content := RegExReplace(content, "\bfont-family:.*?;")
		content := RegExReplace(content, "\s")

		Pos := 1, style := []
		While ( Pos := RegExMatch(content, "([^{]+){(.*?)}", Match, Pos + StrLen(Match)) )
			style[Match1] := Match2

		;
		; Read sheet001.html
		;
		FileRead, html, % TempDir "\1.files\sheet001.html"

		; Replace class="..." to style="..."
		For ClassName, style_value in style
			StringReplace, html, html, % "class=""" ClassName """", % "style=""" style_value """", All

		; Save html data to object
		ResultObj := [], Pos := 1
		While ( Pos := RegExMatch(html, "si)<tr.*?</tr>", tr_data, Pos + StrLen(tr_data)) ) {
			tr_data := RegExReplace(tr_data, "(<\w+[^\r\n>]+)[\r\n]+\s*", "$1 ")

			obj_td := [], Pos2 := 1, td_list := ""
			While ( Pos2 := RegExMatch(tr_data, "si)<td.*?>(.*?)</td>", td_data, Pos2 + StrLen(td_data)) )
				td_list .= td_data1, obj_td.Insert(td_data1)

			If ( Trim(td_list, " `t`r`n") != "" ) ; Exclude empty rows
				ResultObj.Insert( obj_td )
		}

		FileRemoveDir, % TempDir, 1
	}
	Else ; If (Format = "csv")
	{
		FileRead, content, % TempFile
		content := RegExReplace(content, "m`a)^[, \t]+$")
		content := Trim(content, "`r`n")
		content := RegExReplace(content, "[\r\n]+([\s\x22]+)", "$1")

		ResultObj := []
		Loop, Parse, content, `n, `r
		{
			ResultObj.Insert( [] ), RowNum := A_Index
			Loop, parse, A_LoopField, CSV
				ResultObj[RowNum].Insert(A_LoopField)
		}

		FileDelete, % TempFile
	}
}