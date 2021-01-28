; ======================================================================================================================
; Demo of MySQLAPI class
;
; You must have access to a running MySQL server. This demo app will create a database and a table and present
; a simple GUI to add, edit, or remove records.
;
; Programmer:     panofish (www.autohotkey.com)
; Modified by:    just me  (www.autohotkey.com)
; AutoHotkey:     v1.1.10.+
; ======================================================================================================================
#NoEnv
#SingleInstance Force
SetBatchLines, -1
ListLines, Off
#Include Class_MySQLAPI.ahk ; pull from local directory
OnExit, AppExit
Global MySQL_SUCCESS := 0
; ======================================================================================================================
; Settings
; ======================================================================================================================
UserID := "root"           ; User name - must have privileges to create databases
UserPW := "toor"           ; User''s password
Server := "localhost"      ; Server''s host name or IP address
Database := "Test"         ; Name of the database to work with
DropDatabase := False      ; DROP DATABASE
DropTable := False         ; DROP TABLE Address
; ======================================================================================================================
; Connect to MySQL
; ======================================================================================================================
; Instantiate a MYSQL object
If !(My_DB := New MySQLAPI)
   ExitApp
; Get the version of libmysql.dll
ClientVersion := My_DB.Get_Client_Info()
; Connect to the server, Host can be a hostname or IP address
If !My_DB.Connect(Server, UserID, UserPW) {  ; Host, User, Password
   MsgBox, 16, MySQL Error!, % "Connection failed!`r`n" . My_DB.ErrNo() . " - " . My_DB.Error()
   ExitApp
}
; ======================================================================================================================
; CREATE DADABASE Test
; ======================================================================================================================
If (DropDatabase)
   My_DB.Query("DROP DATABASE IF EXISTS " . DataBase)
SQL := "CREATE DATABASE IF NOT EXISTS " . Database . " DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_bin"
My_DB.Query(SQL)
; ======================================================================================================================
; Select the database as default
; ======================================================================================================================
My_DB.Select_DB(Database)
; ======================================================================================================================
; CREATE TABLE Address
; ======================================================================================================================
If (DropTable)
   My_DB.Query("DROP TABLE IF EXISTS Address")
SQL := "CREATE TABLE IF NOT EXISTS Address ( "
     . "Name VARCHAR(50) NULL, "
     . "Address VARCHAR(50) NULL, "
     . "City VARCHAR(50) NULL, "
     . "State VARCHAR(2) NULL, "
     . "Zip INT(5) ZEROFILL NULL, "
     . "PRIMARY KEY (Name) )"
My_DB.Query(SQL)
; ======================================================================================================================
; Build GUI
; ======================================================================================================================
Fields := ["Name", "Address", "City", "State", "Zip"]
Gui, 1:Default
Gui, Margin, 10, 10
Gui, +OwnDialogs
Gui, Add, Text, Section Right w70, Name
Gui, Add, Edit, x+10 w250 vName
GuiControlGet, C, Pos, Name
Gui, Add, Text, xs Right w70, Address
Gui, Add, Edit, x+10 w250 vAddress
Gui, Add, Text, xs Right w70, City
Gui, Add, Edit, x+10 w150 vCity
Gui, Add, Text, xs Right w70, State
Gui, Add, Edit, x+10 w30 Uppercase Limit2 vState
Gui, Add, Text, xs Right w70, Zip
Gui, Add, Edit, x+10 w60  Number Limit5 vZip
Gui, Add, Button, ys x410 w100 h%CH% vBtnAddUpd gSubBtnAction Default, Add
Gui, Add, Button, wp hp gSubBtnClear, Clear
Gui, Add, Button, wp hp vBtnDelete gSubBtnAction, Delete
Gui, Add, Button, wp hp gUpdateListView, Reload
; To increase performance use Count option if you know the max number of lines
; LV0x00010000 = LV_EX_DOUBLEBUFFER
Gui, Add, ListView, xs r10 w500 AltSubmit vList1 Grid -Multi +LV0x00010000 gSubListView
Gui, Add, StatusBar
Gui, Show, , MySQLAPI Demo - Client version: %ClientVersion%
Gosub, UpdateListView
; ======================================================================================================================
; Make a first query and get the result "manually"
; ======================================================================================================================
SQL := "SELECT COUNT(*) FROM Address"
If (My_DB.Query(SQL) = MySQL_SUCCESS) {
   My_Result := My_DB.Store_Result()
   My_Field := My_DB.Fetch_Field(My_Result)
   FieldName := StrGet(NumGet(My_Field + 0, 0, "UPtr"), "UTF-8")
   My_Row := My_DB.Fetch_Row(My_Result)
   FieldValue := StrGet(NumGet(My_Row + 0, 0, "UPtr"), "UTF-8")
   My_DB.Free_Result(My_Result)
}
MsgBox, 0,  MySQLAPI Demo, Query:`r`n%SQL%`r`n`r`nResult:`r`nName = %FieldName%`r`nValue = %FieldValue%
Return
; ======================================================================================================================
; ListView event handler
; DoubleClick a row to delete / edit the entry
; ======================================================================================================================
SubListView:
   If (A_GuiEvent = "DoubleClick") {
      CurrentRow := A_EventInfo
      Loop, % LV_GetCount("Column") {
         LV_GetText(Value, CurrentRow, A_Index)
         If (Fields[A_Index] = "Zip")
            Value := SubStr("0000" . Value, -4)
         GuiControl, , % Fields[A_Index], %Value%
      }
      GuiControl, +ReadOnly, Name
      GuiControl, , BtnAddUpd, Update
      GuiControl, Focus, Address
   }
Return
; ======================================================================================================================
; Perform the requested action
; ======================================================================================================================
SubBtnAction:
   Gui, +OwnDialogs
   Gui, Submit, NoHide
   GuiControlGet, Name
   If !Trim(Name, " `t`r`n")
      Return
   ; Escape mysql special characters in case user entered them
   V1 := My_DB.Real_Escape_String(Name)
   V2 := My_DB.Real_Escape_String(Address)
   V3 := My_DB.Real_Escape_String(City)
   V4 := My_DB.Real_Escape_String(State)
   V5 := My_DB.Real_Escape_String(Zip)
   ; Get the action
   GuiControlGet, Action, , %A_GuiControl%
   SQL := ""
   If (Action = "Add") {
      ;-----------------------------------------------------------------------------------------------------------------
      ; Insert new record
      ;-----------------------------------------------------------------------------------------------------------------
      SB_SetText("Inserting new record!")
      SQL := "INSERT INTO Address ( Name, Address, City, State, Zip) "
           . "VALUES ( '" . V1 . "', '" . V2 . "', '" . V3 . "', '" . V4 . "', '" . V5 . "')"
      Done := "inserted!"
   }
   Else If (Action = "Delete") {
      ;-----------------------------------------------------------------------------------------------------------------
      ; Delete record
      ;-----------------------------------------------------------------------------------------------------------------
      MsgBox, 36, Delete, Do you really want to delete '%Name%'?
      IfMsgBox, Yes
      {
         SB_SetText("Deleting record!")
         SQL := "DELETE FROM Address WHERE Name = '" . Name . "'"
         Done := "deleted!"
      }
   }
   Else If (Action = "Update") {
      ;-----------------------------------------------------------------------------------------------------------------
      ; Update record
      ;-----------------------------------------------------------------------------------------------------------------
      SB_SetText("Updating record!")
      SQL := "UPDATE Address SET Address = '" . V2 . "', City = '" . V3 . "', State='" . V4 . "', Zip='" . V5 . "' "
           . "WHERE Name = '" . V1 . "'"
      Done := "updated!"
   }
   If (SQL) {
      If (My_DB.Query(SQL) = MySQL_SUCCESS) {
         Rows := My_DB.Affected_Rows()
         Gosub, UpdateListView
         GoSub, SubBtnClear
         SB_SetText(Rows . " row(s) " . Done)
      } Else {
         MsgBox, 16, MySQL Error!, % My_DB.ErrNo() . ": " . My_DB.Error()
      }
   }
Return
; ======================================================================================================================
; Clear Edits
; ======================================================================================================================
SubBtnClear:
   For Each, Ctrl In Fields
      GuiControl, , % Fields[A_Index]
   GuiControl, -Readonly, Name
   GuiControl, , BtnAddUpd, Add
   GuiControl, Focus, Name
   SB_SetText("")
Return
; ======================================================================================================================
; Fill ListView with existing addresses from database
; ======================================================================================================================
UpdateListView:
   SQL := "SELECT Name, Address, City, State, Zip FROM Address ORDER BY Name"
   If (My_DB.Query(SQL) = MySQL_SUCCESS) {
      Result := My_DB.GetResult()
      LV_Fill(Result, "List1")
      SB_SetText("ListView has been updated: " . Result.Columns . " columns - " . Result.Rows . " rows.")
   }
Return
; ======================================================================================================================
; GUI was closed
; ======================================================================================================================
GuiClose:
ExitApp
AppExit:
   My_DB := ""
ExitApp
; ======================================================================================================================
; Fill ListView with the result of a query.
; Note: The current data in the ListView are replaced with the new data.
; Parameters:
;    Result       -  Result object returned from MySQLDAPI.Query()
;    ListViewName -  Name of the ListView''s asociated variable
; ======================================================================================================================
LV_Fill(Result, ListViewName) {
   ;--------------------------------------------------------------------------------------------------------------------
   ; Delete all rows and columns of the ListView
   ;--------------------------------------------------------------------------------------------------------------------
   GuiControl, -Redraw, %ListViewName%             ; to improve performance, turn off redraw then turn back on at end
   Gui, ListView, %ListViewName%                   ; specify which listview will be updated with LV commands
   LV_Delete()                                     ; delete all rows in the listview
   Loop, % LV_GetCount("Column")                   ; delete all columns of the listview
      LV_DeleteCol(1)
   ;--------------------------------------------------------------------------------------------------------------------
   ; Parse field names
   ;--------------------------------------------------------------------------------------------------------------------
   Loop, % Result.Fields.MaxIndex() {
      LV_InsertCol(A_Index, "", Result.Fields[A_Index].Name)
   }
   ;--------------------------------------------------------------------------------------------------------------------
   ; Parse rows
   ;--------------------------------------------------------------------------------------------------------------------
   Count := 0
   Loop, % Result.MaxIndex() {
      RowNum := LV_Add("")                         ; add a blank row to the listview
      Row := Result[A_Index]                                ; extract the row from the result
      Loop, % Row.MaxIndex() {                              ; populate the columns of the current row
         Value := Row[A_Index]
         If (A_Index = 5)
            Value := SubStr("0000" . Value, -4)
         LV_Modify(RowNum, "Col" . A_Index, Value) ; update current column of current row
      }
   }
   ;--------------------------------------------------------------------------------------------------------------------
   ; Autosize columns: should be done outside the row loop to improve performance
   ;--------------------------------------------------------------------------------------------------------------------
   Loop, % LV_GetCount("Column")
      LV_ModifyCol(A_Index, "AutoHdr") ; Autosize header.
   LV_ModifyCol(1, "Sort Logical")
   GuiControl, +Redraw, %ListViewName% ; to improve performance, turn off redraw at beginning then turn back on at end
   Return
}