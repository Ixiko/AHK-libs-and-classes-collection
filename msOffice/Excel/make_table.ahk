; Link:   	https://raw.githubusercontent.com/rcalimlim/tlg/master/tlgmacro.ahk


;//////////////////////////////////////////////////////////////////////////////
; Name:         make_table
; Description:  Gets an excel workbook from passed file path and returns a safe
;               array object.
; Parameters:   sheet:     sheet name, defaults to 1
;               file_path: path to excel matrix
; Called by:    __all__maintable (global)
; Returns:      array object
make_table(file_path, sheet) {
    oWorkbook := comobjget(file_path)
    , lastrow := oWorkbook.Sheets(sheet).Range("A:A").SpecialCells(11).Row
    , lastcol := oWorkbook.Sheets(sheet).Range("1:1").SpecialCells(11).Column
    , rng := "A1:" . decode_col(lastcol) . lastrow
    return oWorkbook.Sheets(sheet).Range(rng).Value
}