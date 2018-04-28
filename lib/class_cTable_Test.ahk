#include cTable.ahk

;===oTable testing area=================================================================
Variable =      ; column names are specified as first row
(
First name%A_Tab%Last name%A_Tab%Occupation%A_Tab%Notes
Jack%A_Tab%Gates%A_Tab%Driver%A_Tab%
Mark%A_Tab%Weber%A_Tab%Student%A_Tab%His father is a driver.
Jim%A_Tab%Tucker%A_Tab%Driver%A_Tab%
Jill%A_Tab%Lochte%A_Tab%Artist%A_Tab%Jack's sister.
Jessica%A_Tab%Hickman%A_Tab%Student%A_Tab%
Mary%A_Tab%Jones%A_Tab%Teacher%A_Tab%Her favorite song is "D r i v e r".
Lenny%A_Tab%Stark%A_Tab%Driver%A_Tab%
Jack%A_Tab%Black%A_Tab%Actor%A_Tab%His wife is artist.
Tony%A_Tab%Jackman%A_Tab%Surfer%A_Tab%
Jonny%A_Tab%Poor%A_Tab%Beggar%A_Tab%
Scott%A_Tab%Jenstan%A_Tab%Teacher%A_Tab%Lives in New York.
)


oTable := new cTable(Variable)   ; creates table object from variable
Variable =    ; not longer needed



; create simple gui for testing
Gui 1: Add, ListView, x5 y5 w500 h300 grid, % oTable.HeaderToString("|")   ; converts table's header (first row) to string.
Gui 1: Show, w510 h310 hide


;=== Field management ===
;MsgBox % oTable.3.2   ; get value from [3. row, 2. column]
;oTable.1.1 := "Bobby"   ; set [1. row, 1. column] to "Bobby"


;=== Converting to numbers ===
;MsgBox % oTable.Row2Num("Jonny", "Poor", "Beggar")   ; get number of row whose fields are: Jonny, Poor, Beggar. (Identification by fields)
;MsgBox % oTable.Col2Num("Occupation")   ; get number of "Occupation" column
;MsgBox % oTable.Col2Num("First name|Notes")   ; get numbers of "First name" and "Notes" columns


;=== ToString method ===
;MsgBox % oTable.ToString()   ; convert whole table object to string
;MsgBox % oTable.3.ToString()   ; convert 3. row object to string
;MsgBox % oTable.11.ToString("#")   ; convert 11. row object to string but use custom delimiter
;MsgBox % oTable.HeaderToString()   ; converts table's header (first row) to string


;=== MaxIndex (Count) ===
;MsgBox % oTable.MaxIndex()   ; get total number of rows (in future maybe: oTable.Count)
;MsgBox % oTable.ColumnNames.MaxIndex()   ; get total number of columns


;=== Row management ===
;oTable.AddRow("Joe", "Newman", "Kiteboarder", "Freestyle & Wave")   ; add row (to the bottom)
;oTable.InsertRow(2 ,"Mike", "Insertovich", "Actor")   ; inserts new row number 2.
;oTable.ModifyRow(3 ,"Sergey", "Modifysky", "Actor")   ; modify row number 3.
;oTable.ModifyRow(0 ,"Chris", "Allman", "Actor")   ; modify all existing rows
;oTable.DeleteRow(2)   ; delete 2. row
;oTable.DeleteRow()      ; delete last row
;oTable.DeleteRow(0)   ; delete all rows


;=== Searching ===
;MsgBox % oTable.Search("Occupation", "Driver").ToString()    ; search Occupation column for containing string "driver"
;MsgBox % oTable.Search("Occupation|Notes", "Driver").ToString()    ; search Occupation and Notes columns for containing string "driver"
;MsgBox % oTable.Search("", "Driver", "containing+").ToString()    ; search whole table (all columns) for containing string "driver" but ignore withespaces
;MsgBox % oTable.Search("Last name", "^J.*an$", "RegEx").ToString() ; Search for all last names starting with "J" and ending with "an".
;MsgBox % oTable.Search("First name", "ny", "EndingWith").ToString()    ;  search first names ending with "ny"
;MsgBox % oTable.Search("Last name", "ja|bla", "StartingWith").ToString()    ;  search last names starting with "ja" or "bla"
;MsgBox % oTable.Search("", "Jack", "exactly").ToString()    ; search whole table (all columns) for string "Jack" (not containing, but exactly)


;=== Multiple filters search ===
; step 1: search "Occupation" and "Notes" columns for containing "Driver" or "artist" strings. "|" is query delimiter.
; step 2: search that search result again: search "First name" column for containing "J" string
;oFound := oTable.Search("Occupation|Notes", "Driver|artist")      ; store search results as object
;oFound2 := oFound.Search("First name", "J")      ; search oFound (second search filter)

; or shorter:   oFound2 := oTable.Search("Occupation|Notes", "Driver|artist").Search("First name", "J")   ; etc. --> multiple filters

;MsgBox % oFound2.ToString()      ; convert search results to string
;MsgBox % oFound2.2.ToString()   ; convert 2. row from search results to string
;MsgBox % oFound2.1.3   ; get [1. row, 3. column] field from search results
;MsgBox % oFound2.MaxIndex()   ; get number of found rows - from oFound2 (in future maybe: oFound2.Count)


;=== RegEx search ===   and LastFound property
; Search for all last names starting with "J" and ending with "an"
;oFound3 := oTable.Search("Last name", "^J.*an$", "RegEx")   ; store search results as object
;MsgBox % oFound3.ToString()   ; convert search results to string
;MsgBox % oFound3.LastFound   ; each time after calling search method, row numbers of found rows are stored in LastFound key/property - read only.


;=== Massive StringReplace ===
;oTable.StringReplace("y", "X", ".", " :)")   ; replaces "param1" with "param2", "param3" with "param4" (etc.) in all fields in table object.


;=== Interacting with files ===
;oTable.SaveAs(A_ScriptDir "\Table file.txt","|","#")      ; converts table object to string and saves it to specified file but uses custom delimiters.
; When constructing table from such file, must specify custom delimiters -->  oTable := Table_ObjCreate(A_ScriptDir "\Table file.txt","|","#")

;oTable1 := new cTable(A_ScriptDir "\Table file.txt")   ; creates table object from constructor file
;oTable1.Save()   ; converts table object to string and saves it to its constructor file. Use only if oTable is created from file.
;oTable.SaveAs(A_ScriptDir "\Table file.txt")      ; converts table object to string and saves it to specified file.
;oTable.Open()   ; opens table's constructor file in Notepad if it exists
;oTable.Reload()   ; reads table's constructor file again and reconstructs table object if constructor file exists



;=== ToListView method ===
F1::   ; shows whole oTable in ListView
LV_Delete()   ; empty ListView
oTable.ToListView()
Gui 1: Show
Return


F2::   ; finds all drivers and shows search results in ListView
LV_Delete()   ; empty ListView
oTable.Search("Occupation", "driver").ToListView()
Gui 1: Show
Return


F3::   ; Do a RegEx search and show search results in ListView
LV_Delete()   ; empty ListView
oFound := oTable.Search("Last name", "^J.*an$", "RegEx") ; Search for all last names starting with "J" and ending with "an".
oFound.ToListView()
Gui 1: Show
;MsgBox, 64, Numbers of found rows in latest search, % oFound.LastFound   ; LastFound property
;MsgBox, 64, oFound to string, % oFound.ToString()
Return


F4::   ; search whole table (all columns) for containing string "new" and show search results in ListView
LV_Delete()   ; empty ListView
oTable.Search("","New").ToListView()   ; empty 1. parameter means: search through whole table (all columns)
;oTable.1.ToListView()   ; adds 1. row from oTable to ListView
Gui 1: Show
return



 
;=== oTable - ListView interaction ===
d::oTable.LVDelete()   ; delete selected row
a::oTable.LVAdd("Mia","Addstan","Driver")   ; add new row

e::      ; edit selected row
CurFields =
oCurFields := oTable.LVModify1()   ; returns row's to modify fields. Must be called prior to oTable.LVModify2()
for k,v in oCurFields
CurFields .= v "|"
CurFields := RTrim(CurFields,"|")

if (CurFields = "")   ; nothing selected
return

InputBox, NewRow,, Current Fields:  %CurFields%,,,,,,,,%CurFields%
if ErrorLevel
return

oNewFields := _cTable_SplitToObj(NewRow)
oTable.LVModify2(oNewFields)   ; modifies row in ListView and oTable
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ExitApp
Pause::
Suspend
Pause,,1
return

GuiClose:
Escape::
Suspend
ExitApp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
