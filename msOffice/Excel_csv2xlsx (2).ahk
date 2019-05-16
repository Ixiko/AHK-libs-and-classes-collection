Excel := ComObjCreate("Excel.Application")
Excel.Workbooks.Add

QueryTable := Excel.ActiveSheet.QueryTables.Add("TEXT;" "C:\Temp\mycsv.csv", Excel.Range("$A$1"))
QueryTable.Name                         := mycsv
QueryTable.FieldNames                   := True
QueryTable.RowNumbers                   := False
QueryTable.FillAdjacentFormulas         := False
QueryTable.PreserveFormatting           := True
QueryTable.RefreshOnFileOpen            := False
QueryTable.RefreshStyle                 := xlInsertDeleteCells := 1
QueryTable.SavePassword                 := False
QueryTable.SaveData                     := True
QueryTable.AdjustColumnWidth            := True
QueryTable.RefreshPeriod                := 0
QueryTable.TextFilePromptOnRefresh      := False
QueryTable.TextFilePlatform             := 65001 ;1252
QueryTable.TextFileStartRow             := 1
QueryTable.TextFileParseType            := xlDelimited := 1
QueryTable.TextFileTextQualifier        := xlTextQualifierDoubleQuote := 1
QueryTable.TextFileConsecutiveDelimiter := False
QueryTable.TextFileTabDelimiter         := False
QueryTable.TextFileSemicolonDelimiter   := True
QueryTable.TextFileCommaDelimiter       := False
QueryTable.TextFileSpaceDelimiter       := False
SafeArray := ComObjArray(0x3, 6)
loop 6
    SafeArray[A_Index - 1] := 2
QueryTable.TextFileColumnDataTypes      := SafeArray
QueryTable.TextFileTrailingMinusNumbers := True
QueryTable.Refresh(False)

WorkBook := Excel.ActiveWorkbook.SaveAs("C:\Temp\myexcel.xlsx", 51)
WorkBook.Close()
Excel.Quit()