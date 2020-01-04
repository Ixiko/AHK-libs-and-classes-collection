#include %A_ScriptDir%\..\Class_ZeeGrid.ahk
main := GuiCreate()

main.OnEvent("close", () => ExitApp())

grid := new ZeeGrid(main, "w600 h400", "", A_PtrSize = 8 ? "ZeeGridx64.dll" : "ZeeGrid.dll")
grid.OnEvent(grid.ZGN_RIGHTCLICK, Func("onRightClick"))

grid.DimGrid(10)
grid.AllocateRows(100)
grid.ShowRowNumbers(true)
grid.EnableRowSizing(true)
grid.SetColumnHeaderHeight(25)

for i, headerText in {1: "Editable", 2: "Checkbox", 4: "Dates", 6: "Numbers (%)", 8: "Buttons"} {
    grid.SetCellText(i, headerText, 1)
}

cols := grid.GetCols()
Loop(rows := 20) {
    grid.AppendRow()
    cell := cols * A_Index + A_Index
    col := grid.GetColOfIndex(cell)

    if (col = 2) {
        grid.SetCellType(cell, Mod(A_Index, 2) ? grid.BOOL_TRUE : grid.BOOL_FALSE)
    }
    else if (col = 4) {
        grid.SetCellType(cell, 4)
        grid.SetCellEdit(cell, 4)
        grid.SetCellCDate(cell, "04/01/2019", 1)
    }
    else if (col = 6) {
        grid.SetCellType(cell, grid.NUMERIC)
        grid.SetCellFormat(cell, 1)
        grid.SetCellText(cell, String(A_Index / 50), 1)
    }
    else if (col = 8) {
        grid.SetCellText(cell, "Button #" A_Index, 1)
        grid.SetCellType(cell, grid.BUTTON)
    }
    else {
        grid.SetCellText(cell, "Test #" A_Index, 1)
    }
}

grid.AutoSize_All_Columns()

grid.AlternateRowColors(1, 8)
grid.SetColBColor(2, 12)

grid.SetColEdit(1, 1)

grid.SetColEdit(2, 3)

main.show()
return

onRightClick(grid) {
    col := grid.GetMouseCol()
    row := grid.GetMouseRow()
    cell := grid.GetCellIndex(row, col)

    ToolTip(row "x" col "`nCell Index " cell)
}