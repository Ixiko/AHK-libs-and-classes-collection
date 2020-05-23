; This script does the following:
;   - Open the test workbook (located in the same directory as this script -
;     "..\Get sheet names and cells matching a color DATA.xlsx")
;   - Loop through each sheet in the workbook. Collect the name and tab-color of each sheet
;   - Prompt the user to select a column
;   - Loop through the cells in the chosen column. Display (MsgBox) the address and color of each cell. If the cell
;     color matches 0x00FFFF then collect the value.
;   - Display the results

Path := A_ScriptDir "\Get sheet names and cells matching a color DATA.xlsx"
xlApp := ComObjCreate("Excel.Application")
MyWorkbook := xlApp.Workbooks.Open(Path)  ; Open an existing file
xlApp.Visible := True
MyInfo := new WorkbookInfo  ; Create an object to store the results
for ThisSheet, in MyWorkbook.Sheets  ; Loop through each sheet in the sheets collection
{
    MyInfo.AddSheet(ThisSheet.Name, ThisSheet.Tab.Color)
}
MyColumn := ""
while MyColumn = ""  ; Prompt the user to enter a column
    MyColumn := GetColumn()

FirstCell :=  MyWorkbook.Sheets(1).Cells(1, MyColumn)
; Find the last cell which is not blank in the specified column.
; Start at the last cell in the Column, and look upwards for a non-blank cell
LastCell := xlApp.Sheets(1).Cells(xlApp.Rows.Count, MyColumn).End(-4162)  ; xlUp = -4162

; TODO prompt the user for a color here
MyColor := 0x00FFFF  ; Yellow (Temporary - for testing only)
for ThisCell, in xlApp.Sheets(1).Range(FirstCell, LastCell)
{
    MsgBox, % ThisCell.Address " = " Format("0x{:06X}", ThisCell.Interior.Color)
    if (ThisCell.Interior.Color = MyColor)  ; If the colors match
        MyValues .= ThisCell.Value ","
}

; Display the results
for i, ThisInfo in MyInfo.Sheets
{
    MsgBox, % "#: " i "`n"
            . "Name: " ThisInfo.Name "`n"
            . "Color: " ThisInfo.Color
}
MsgBox, % RTrim(MyValues, ",")  ; Show the yellow cells in the specified column. RTrim is to remove the rightmost comma
return

class WorkbookInfo
{
    __New()
    {
        this.Worksheets := this.Sheets := []
    }
    AddSheet(Nm, Clr)
    {
        this.Sheets.Push({Name: Nm, Color: Format("0x{:06X}", Clr)})
    }
}

GetColumn()
{
    ; The user should enter letters only, or digits only
    InputBox, Col, Enter a column, Enter a column. Column names and numbers both work.
    if RegExMatch(Col, "^\d+$")  ; The user entered digits only
        return ComObject(3, Col)  ; VT_I4 = 3 ; 32-bit signed int
    if RegExMatch(Col, "i)^[a-z]+$")  ; The user entered letters only
        return Col
}

; References:
;   - https://autohotkey.com/boards/viewtopic.php?f=5&t=28697
