/*!
	Library: cTable library, version 0.2.0
		Simplified handling of tables
		
		Based on work by Learning one (see: http://www.autohotkey.com/forum/viewtopic.php?t=65995= 
        
	Author: Hoppfrosch
	License: WTFPL
*/

; ToDo: Automatische Update
; ToDo: Versionsüberprüfung (Numify der eigenen Version)

/*!
   Class: cTable
      Simplified handling of tables
   Inherits: cTableBase
*/
class cTable {
   static ColumnNames := Object()
   static FilePath := ""
   _columnsDelimiter := "`t"
   _rowsDelimiter := "`n"
   _debug := 0
   _version := "0.2.0"

   ; ##################### Properties (AHK >1.1.16.x) #################################################################
   columnsDelimiter[] {
	/* ------------------------------------------------------------------------------- 
	Property: columnsDelimiter [get/set]
	Column delimiter for the table file

	Value:
	value - column delimiter, default <`t>
	*/
		get {
			return this._columnsDelimiter
		}
		set {
			this._columnsDelimiter := value
			return this._columnsDelimiter
		}
	}
	debug[] {
	/* ------------------------------------------------------------------------------- 
	Property: debug [get/set]
	Debug flag for debugging the object

	Value:
	flag - *true* or *false*
	*/
		get {
			return this._debug
		}
		set {
			mode := value<1?0:1
			this._debug := mode
			return this._debug
		}
	}
    rowsDelimiter[] {
	/* ------------------------------------------------------------------------------- 
	Property: rowsDelimiter [get/set]
	Row delimiter for the table file

	Value:
	value - row delimiter, default <`n>
	*/
		get {
			return this._rowsDelimiter
		}
		set {
			this._rowsDelimiter := value
			return this._rowsDelimiter
		}
	}
    version[] {
	/* ------------------------------------------------------------------------------- 
	Property: version [get]
	Get the version of the class implementation
	*/
		get {
			return this._version
		}
	}
    
   
   ; ##################### public methods ##############################################################################
   __New(InputVariableOrFile, ColumnsDelimiter := "`t", RowsDelimiter :=  "`n", _debug := 0) {
      this.debug := _debug
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(InputVariableOrFile=(" InputVariableOrFile "), ColumnsDelimiter=("  ColumnsDelimiter "), RowsDelimiter=("  RowsDelimiter "))]"        ; _DBG_
      
      this.columnsDelimiter := ColumnsDelimiter
      this.rowsDelimiter := RowsDelimiter
      
      if % (A_AhkVersion < "1.1.23.00" && A_AhkVersion >= "2.0") {
         MsgBox % "This class is only tested with AHK later than 1.1.23.00 (and before 2.0)`nAborting..."
         OutputDebug % "<[" A_ThisFunc "(...) -> ()]"   ; _DBG_
         return 
      }
         
      IfExist, %InputVariableOrFile%   ; construct table from file
      {
         oFile := FileOpen(InputVariableOrFile, "r `n", "UTF-8")   ; hard coded or option...?
         InputVariable := oFile.Read()
         oFile.Close()
         this.FilePath := InputVariableOrFile   ; store constructor file's FilePath
      }
      else   ; construct table from variable
         InputVariable := InputVariableOrFile

      oColumnNames := Object()

      Loop, parse, InputVariable, %RowsDelimiter%
      {
         CurRow := A_LoopField
         if A_index = 1   ; column names are specified as first row
         {
            Loop, parse, CurRow, %ColumnsDelimiter%
            {
               oColumnNames.Insert(A_LoopField)
               ColumnsCount++
            }
            this.ColumnNames := oColumnNames
            continue
         }
         RowNum := A_index-1
         %RowNum% :=  new cTableRow(CurRow, ColumnsCount, this.columnsDelimiter, this.debug)
      
         this.Insert(%RowNum%)
      }
      
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...) -> (" _cTable_ToString(this) ")]"   ; _DBG_
      return this
   }
   
   AddRow(Fields*) {   ; adds new row to table (to the bottom)
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(Fields=(" Fields "))]"           ; _DBG_
      
      NewRowNum := this.MaxIndex() + 1
      TotalColumns := this.ColumnNames.MaxIndex()
      %NewRowNum% := new cTableRow("",0,this.columnsDelimiter)
      For k,v in Fields
      {
         if (A_index > TotalColumns)
            break
         %NewRowNum%.Insert(v)
      }
      this.Insert(%NewRowNum%)
      
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...) -> (" NewRowNum ")]"           ; _DBG_
      
      return NewRowNum
   }
   
   Col2Num(ColumnsToSearch) {      ; converts column name(s) to column number(s)
      
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(ColumnsToSearch=(" ColumnsToSearch "))]"           ; _DBG_
      
      StringReplace, ColumnsToSearch, ColumnsToSearch, `,, `,`,, all
      StringReplace, ColumnsToSearch, ColumnsToSearch, |, `,, all
      For k,v in this.ColumnNames
      {
         if v in %ColumnsToSearch%
            Found .= k "|"
      }
      RetVal := RTrim(Found, "|")
      
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...) -> (" RetVal ")]"           ; _DBG_
      
      return RetVal
   }
   
   DeleteRow(RowToDeleteNumber := "") {   ; deletes row(s)
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(RowToDeleteNumber=(" RowToDeleteNumber "))]"           ; _DBG_
      
      if (RowToDeleteNumber = 0)   ; delete all existing rows
      {
         this.Remove(1, this.MaxIndex())
         if (this.debug)           ; _DBG_
            OutputDebug % "<[" A_ThisFunc "(...) -> ()]"           ; _DBG_
         return
      }
      Else if (RowToDeleteNumber = "")   ; delete last row
      {
         oDeletedRow := Object()
         LastRN := this.MaxIndex()
         oDeletedRow := this[LastRN]
         this.Remove(LastRN)
         if (this.debug)           ; _DBG_
            OutputDebug % "<[" A_ThisFunc "(...) -> (" _cTable_ToString(oDeletedRow) ")]"           ; _DBG_
         return oDeletedRow
      }
      else   ; delete specified row
      {
         oDeletedRow := Object()
         oDeletedRow := this[RowToDeleteNumber]
         this.Remove(RowToDeleteNumber)
         if (this.debug)           ; _DBG_
            OutputDebug % "<[" A_ThisFunc "(...) -> (" _cTable_ToString(oDeletedRow) ")]"           ; _DBG_
         return oDeletedRow
      }
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...) -> ()]"           ; _DBG_
   }
   
   HeaderToString(ColumnsDelimiter := "") {   ; converts table's header (first row) to string
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(ColumnsDelimiter=("  ColumnsDelimiter "))]"           ; _DBG_
      if ColumnsDelimiter =
         ColumnsDelimiter := this.columnsDelimiter
      For k,v in this.ColumnNames
         Header .= v ColumnsDelimiter
      RetVal := RTrim(Header, ColumnsDelimiter)
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...) -> (" RetVal ")]"            ; _DBG_
      return RetVal
   }
   
   InsertRow(NewRowNum ,Fields*) {   ; inserts new row in table
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(NewRowNum=(" NewRowNum "), Fields=(" Fields "))]"           ; _DBG_
      if NewRowNum = 0   ; not allowed
         return
   
      if (NewRowNum > this.MaxIndex())
         NewRowNum := this.MaxIndex() + 1   ; add as last row
   
      %NewRowNum% := new cTableRow("",0,this.columnsDelimiter)
      TotalColumns := this.ColumnNames.MaxIndex()
      For k,v in Fields
      {
         if (A_index > TotalColumns)
            break
         %NewRowNum%.Insert(v)
      }
      this.Insert(NewRowNum, %NewRowNum%)
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...)]"           ; _DBG_
   }
   
   LVAdd(Fields*) {   ; adds new row to oTable and ListView
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(Fields=(" _cTable_ToString(Fields) "))]"           ; _DBG_
      ; add to oTable
      this.AddRow(Fields*)   
   
      ; add to ListView
      TotalColumns := this.ColumnNames.MaxIndex()
      data := Object()
      For k,v in Fields
      {
         if (A_index > TotalColumns)
         break
         data.insert(v)
      }

      LV_Add("", data*)
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...)]"           ; _DBG_
   }
   
   LVDelete(RowNumToSearch := "") {   ; deletes selected row from oTable and ListView. Deletes just 1. selected row for now.
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(RowNumToSearch=(" RowNumToSearch "))]"           ; _DBG_
      oSelected := this.LVSelInfo(RowNumToSearch)
      For k,v in oSelected   ; oSelected structure: o1SelRow, o2SelRow, o3SelRow, etc.
      {
         ; structure: [1] oTableRowNum     [2] LVRowNum      [3,4,5 etc.] FieldsText
         for k2,v2 in oSelected[k]
         {
            if A_index = 1      ; [1] oTableRowNum
               this.DeleteRow(v2)
            else if A_index = 2   ; [2] LVRowNum
               LV_Delete(v2)
            else
               break   ; [3,4,5 etc.] FieldsText - not relevant
         }
         if (this.debug)           ; _DBG_
            OutputDebug % "<[" A_ThisFunc "(...) -> (" _cTable_ToString(oSelected.1) ")]"           ; _DBG_
         return  oSelected.1      ; allow deleting just 1. selected row for now. Ignore other. Return info about deleted row.
      }
   }
   
   LVModify1(RowNumToSearch := "") {   ; Returns row's to modify fields. Must be called prior to oTable.LVModify2()
      ; Relevant for machine: stores oTableRowNum and LVRowNum in oTable.LVModifyRowNums
      ; for faster performance when displaying search results in LV, specify oFound.LastFound as RowNumToSearch
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(RowNumToSearch=(" RowNumToSearch "))]"           ; _DBG_
      oSelected := this.LVSelInfo(RowNumToSearch)
      oFields := Object()
      oRowNums := Object()

      For k,v in oSelected.1   ; first selected row info
      {
         if A_index = 1      ; [1] oTableRowNum
            oRowNums.Insert(v)
         else if A_index = 2   ; [2] LVRowNum
            oRowNums.Insert(v)
         else   ; [3,4,5 etc.] FieldsText
            oFields.Insert(v)   
      }
      this.LVModifyRowNums := oRowNums   ; info used by oTable.LVModify2
      if (this.debug)           ; _DBG_
            OutputDebug % "<[" A_ThisFunc "(...) -> (" _cTable_ToString(oFields) ")]"           ; _DBG_
      return oFields   ; return row's to modify fields
   } 
   
   LVModify2(oNewFields) {   ; modifies row in ListView and oTable
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(oNewFields=(" _cTable_ToString(oNewFields) "))]"           ; _DBG_
    
      TableRowNum := this.LVModifyRowNums.1   ; [1] oTableRowNum
      LVRowNum := this.LVModifyRowNums.2   ; [2] LVRowNum

      this.ModifyRow(TableRowNum, oNewFields*)
      data := Object()
      For k,v in oNewFields
         data.insert(v)
      LV_Modify(LVRowNum,"",data*)
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...)]"           ; _DBG_
   }

   LVSelInfo(RowNumToSearch := "") {   ; gets info about selected rows in ListView
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(RowNumToSearch=(" RowNumToSearch "))]"           ; _DBG_
      Loop, %   LV_GetCount("Column") ; total number of columns in LV
         FromColumns .= A_Index "|"   
      FromColumns := RTrim(FromColumns,"|")
   
      ; oSelected structure: o1SelRow, o2SelRow, o3SelRow, etc.
      ; oSelRow structure: [1] oTableRowNum     [2] LVRowNum      [3,4,5 etc.] FieldsText
      oSelected := Object()
      Loop
      {
         RowNumber := LV_GetNext(RowNumber)
         if !RowNumber
            break
      
         oSelRow := A_Index
         %oSelRow% := Object()   ; oSelRow
         %oSelRow%.Insert("")   ; [1] oTable RowNum - dummy
         %oSelRow%.Insert(RowNumber)   ; [2] LV owNum
      
         oFields := Object()
         Loop, parse, FromColumns, |
         {
            LV_GetText(FieldText, RowNumber, A_LoopField)
            oFields.Insert(FieldText)
            %oSelRow%.Insert(FieldText)
         }
         %oSelRow%[1] := this.Row2NumL(RowNumToSearch, oFields*)    ; [1] oTable RowNum - real
         oSelected.Insert(%oSelRow%), oFields := ""
      }
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...) -> (" _cTable_ToString(oSelected) ")]"           ; _DBG_
      return oSelected
   }

   ModifyRow(RowToModifyNumber, Fields*) {   ; modifies row(s)
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(RowToModifyNumber=(" RowToModifyNumber "), Fields=(" Fields "))]"           ; _DBG_
   
      oModifyedRow := new cTableRow("",0,this.columnsDelimiter)
      TotalColumns := this.ColumnNames.MaxIndex()
      For k,v in Fields
      {
         if (A_index > TotalColumns)
            break
         oModifyedRow.Insert(v)
      }
      if RowToModifyNumber = 0   ; modify all existing rows
      {
         Loop, % this.MaxIndex()
            this[A_Index] := oModifyedRow
      }
      else   ; modify specified row
         this[RowToModifyNumber] := oModifyedRow
      if (this.debug)           ; _DBG_
      OutputDebug % "<[" A_ThisFunc "(...)]"           ; _DBG_
   }
 
   NewFromScheme() {   ; creates new empty table from table object template
      if (this.debug)                                                           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "()]"                                    ; _DBG_
      oNewTable := new cTable("", this.ColumnsDelimiter, this.rowsDelimiter)
      oNewTable.ColumnNames := this.ColumnNames
      if (this.debug)                                                           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "() -> (" _cTable_ToString(oTable)")]"           ; _DBG_
      return oNewTable
   }
   
   Open() {   ; opens table's constructor file in Notepad if it exists
      if (this.debug)                                                           ; _DBG_
         OutputDebug % "|[" A_ThisFunc "()]"                                    ; _DBG_
      FilePath := this.FilePath
      IfExist, %FilePath%
         Run, notepad "%FilePath%"
   }
   
   Reload() {   ; reads table's constructor file again and reconstructs table object if constructor file exists   
      FilePath := this.FilePath
      IfNotExist, %FilePath%   ; if constructor file doesn't exist
         return   ; return and leave old table object as is
   
      this := new cTable(FilePath, this.columnsDelimiter,this.rowsDelimiter) 
   
      return this   ; not necessary as first param is ByRef, but keep it
   }
   
   Row2Num(Fields*) {   ; converts row identified by its fields to number. First matching.
      if (this.debug)                                                           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(Fields=(" Fields "))]"                 ; _DBG_
      TotalColumns := this.ColumnNames.MaxIndex()
      For k,v in Fields
      {
         if (A_index > TotalColumns)
            break
         RowStringToSearch .= v
      }
      For k,v in this
      {
         if k is not integer   ;Rows are integers.
            continue
         For k2,v2 in this[k]
            RowString .= v2
      
         if (RowString = RowStringToSearch) {
            if (this.debug)                                                 ; _DBG_
               OutputDebug % "<[" A_ThisFunc "(...) -> (" k ")]"            ; _DBG_
            return k
         }
      
         RowString =
      }
      if (this.debug)                                                       ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...) -> ()]"                       ; _DBG_
   }
   
   Row2NumL(RowNumToSearch, Fields*) {   ; converts row identified by its fields to number but searches only through specified row numbers (limit). First matching. RowNumToSearch should be oFound.LastFound's value.
      TotalColumns := this.ColumnNames.MaxIndex()
      For k,v in Fields
      {
         if (A_index > TotalColumns)
            break
         RowStringToSearch .= v
      }
   
      if (RowNumToSearch = "")   ; search through all rows
         return this.Row2Num(Fields*)
   
      Loop, parse, RowNumToSearch, |   ; search through specified rows
      {
         For k2,v2 in this[A_LoopField]
            RowString .= v2
      
         if (RowString = RowStringToSearch)
            return A_LoopField
      
         RowString =
      }
   }
   
   Save() {   ; converts table object to string and saves it to its constructor file. Use only if oTable is created from file.
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "()]"           ; _DBG_
      if (this.FilePath = "")
         return
      this.SaveAs(this.FilePath)
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(1)]"if (this.debug)           ; _DBG_
      return 1
   }

   SaveAs(FilePath, ColumnsDelimiter := "`t", RowsDelimiter := "`n") {   ; converts table object to string and saves it to specified file
      if (this.debug)                                                                                                                                       ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(FilePath=(" FilePath "), ColumnsDelimiter=("  ColumnsDelimiter "), RowsDelimiter=("  RowsDelimiter "))]"           ; _DBG_
      if ColumnsDelimiter =
         ColumnsDelimiter := this.columnsDelimiter
      if RowsDelimiter =
         RowsDelimiter := this.rowsDelimiter
      this.FilePath := FilePath
   
      FileContents := this.HeaderToString(ColumnsDelimiter) RowsDelimiter this.ToString(ColumnsDelimiter, RowsDelimiter)
   
      oFile := FileOpen(FilePath, "w `n", "UTF-8")   ; creates a new file, overwriting any existing file.
      oFile.Write(FileContents)
      oFile.Close()
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...)]"           ; _DBG_
   }
   
   Search(ColumnsToSearch, StringsToSearch, MatchType := "containing") {   ; performs search through columns or whole table
      /* Parameters:
      ColumnsToSearch      "|" delimited list of columns to search. If empty (""), search through whole table (all columns.)
      StringsToSearch      "|" delimited list of strings to search except in RegEx MatchType.
      MatchType            Containing, Exactly, StartingWith, EndingWith, RegEx,  Containing+, Exactly+, StartingWith+, EndingWith+
                           "+" suffix means more permissive match type where spaces, tabs, newlines and carriage returns are not relevant for match.
      */
      
      if (this.debug)                                                                                                                                           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(ColumnsToSearch=(" ColumnsToSearch "), StringsToSearch=("  StringsToSearch "), MatchType=("  MatchType "))]"           ; _DBG_
      oFound := this.NewFromScheme()   ; create empty table from this template

      If (ColumnsToSearch = "")      ; search through all columns - whole table.
      {
         For k,v in this.ColumnNames
            ColumnsToSearch .= A_Index "|"
         ColumnsToSearch := RTrim(ColumnsToSearch,"|")
      }
      else   ; search through specified columns
         ColumnsToSearch := this.Col2Num(ColumnsToSearch)
      
      If (SubStr(MatchType,0) = "+")   ; more permissive match type where spaces, tabs, newlines and carriage returns are not relevant for match.
         _cTable_StringReplace(StringsToSearch, A_Space, "", A_Tab, "", "`n", "", "`r", "")   ; like RegExReplace(StringsToSearch, "\s")

      
      if MatchType in Containing,Exactly,Containing+,Exactly+   ; prepare matchlist
      {
         StringReplace, StringsToSearch, StringsToSearch, `,, `,`,, all
         StringReplace, StringsToSearch, StringsToSearch, |, `,, all
      }
      
      ; About coding style below: longer way, but better performance due to less "if evaluations" in loop for MatchTypes not containing "+".
      if MatchType = Containing
      {
         For k in this
         {
            if k is not integer   ;Rows are integers.
               continue
            Loop, parse, ColumnsToSearch, |
            {
               CurField := this[k][A_LoopField]
               if CurField contains %StringsToSearch%
               {
                  oFound.Insert(this[k])
                  oFound.LastFound := oFound.LastFound "," k
               }
            }
         }
      }
      else if MatchType = Exactly
      {
         For k in this
         {
            if k is not integer   ;Rows are integers.
               continue
            Loop, parse, ColumnsToSearch, |
            {
               CurField := this[k][A_LoopField]
               if CurField in %StringsToSearch%
               {
                  oFound.Insert(this[k])
                  oFound.LastFound := oFound.LastFound "," k
               }
            }
         }
      }
      else if MatchType = StartingWith
      {
         For k in this
         {
            if k is not integer   ;Rows are integers.
               continue
            Loop, parse, ColumnsToSearch, |
            {
               CurField := this[k][A_LoopField]
               Loop, parse, StringsToSearch, "|"
               {
                  if (SubStr(CurField,1,StrLen(A_LoopField)) = A_LoopField)
                  {
                     oFound.Insert(this[k])
                     oFound.LastFound := oFound.LastFound "," k
                  }
               }
            }
         }
      }
      else if MatchType = EndingWith
      {
         For k in this
         {
            if k is not integer   ;Rows are integers.
               continue
            Loop, parse, ColumnsToSearch, |
            {
               CurField := this[k][A_LoopField]
               Loop, parse, StringsToSearch, "|"
               {
                  if (SubStr(CurField, - (StrLen(A_LoopField) - 1)) = A_LoopField)
                  {
                     oFound.Insert(this[k])
                     oFound.LastFound := oFound.LastFound "," k
                  }
               }
            }
         }
      }
      else if MatchType = Containing+
      {
         For k in this
         {
            if k is not integer   ;Rows are integers.
               continue
            Loop, parse, ColumnsToSearch, |
            {
               CurField := this[k][A_LoopField]
               _cTable_StringReplace(CurField, A_Space, "", A_Tab, "", "`n", "", "`r", "")
               if CurField contains %StringsToSearch%
               {
                  oFound.Insert(this[k])
                  oFound.LastFound := oFound.LastFound "," k
               }
            }
         }
      }
      else if MatchType = Exactly+
      {
         For k in this
         {
            if k is not integer   ;Rows are integers.
               continue
            Loop, parse, ColumnsToSearch, |
            {
               CurField := this[k][A_LoopField]
               _cTable_StringReplace(CurField, A_Space, "", A_Tab, "", "`n", "", "`r", "")
               if CurField in %StringsToSearch%
               {
                  oFound.Insert(this[k])
                  oFound.LastFound := oFound.LastFound "," k
               }
            }
         }
      }
      else if MatchType = StartingWith+
      {
         For k in this
         {
            if k is not integer   ;Rows are integers.
               continue
            Loop, parse, ColumnsToSearch, |
            {
               CurField := this[k][A_LoopField]
               _cTable_StringReplace(CurField, A_Space, "", A_Tab, "", "`n", "", "`r", "")
               Loop, parse, StringsToSearch, "|"
               {
                  if (SubStr(CurField,1,StrLen(A_LoopField)) = A_LoopField)
                  {
                     oFound.Insert(this[k])
                     oFound.LastFound := oFound.LastFound "," k
                  }
               }
            }
         }
      }
      else if MatchType = EndingWith+
      {
         For k in this
         {
            if k is not integer   ;Rows are integers.
               continue
            Loop, parse, ColumnsToSearch, |
            {
               CurField := this[k][A_LoopField]
               _cTable_StringReplace(CurField, A_Space, "", A_Tab, "", "`n", "", "`r", "")
               Loop, parse, StringsToSearch, "|"
               {
                  if (SubStr(CurField, - (StrLen(A_LoopField) - 1)) = A_LoopField)
                  {
                     oFound.Insert(this[k])
                     oFound.LastFound := oFound.LastFound "," k
                  }
               }
            }
         }
      }
      else if MatchType = RegEx
      {
         For k in this
         {
            if k is not integer   ;Rows are integers.
               continue
            Loop, parse, ColumnsToSearch, |
            {
               CurField := this[k][A_LoopField]
               if RegExMatch(CurField, StringsToSearch)   ; StringsToSearch = NeedleRegEx
               {
                  oFound.Insert(this[k])
                  oFound.LastFound := oFound.LastFound "," k
               }
            }
         }
      }
      
      oFound.LastFound := LTrim(oFound.LastFound, ",")   ; stores row numbers of found rows in latest search
      if (this.debug)                                                           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "() -> (" _cTable_ToString(oFound)")]"           ; _DBG_
      return oFound
   }

   StringReplace(params*) { ; replaces "param1" with "param2", "param3" with "param4" (etc.) in all fields in table object
      if (this.debug)                                               ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(params=(" params "))]"     ; _DBG_
      For k,v in this
      {
         if k is not integer   ;Rows are integers.
            continue
         this[k] =  this[k].StringReplace(params) 
      }
      if (this.debug)                                               ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...) -> ()]"               ; _DBG_
   }

   ToString(ColumnsDelimiter := "", RowsDelimiter := "") {      ; converts table object to string
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(ColumnsDelimiter=("  ColumnsDelimiter "), RowsDelimiter=("  RowsDelimiter "))]"           ; _DBG_
      if ColumnsDelimiter =
         ColumnsDelimiter := this.ColumnsDelimiter
      if RowsDelimiter =
         RowsDelimiter := this.rowsDelimiter

      MyCount := this.MaxIndex()
      Loop, %MyCount%
      {
         Row := this[A_Index]
         RowString .= Row.ToString()
         if (A_Index < this.MaxIndex() )
            RowString .= RowsDelimiter
      }
      RetVal := RowString
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...) -> (" RetVal ")]"           ; _DBG_
      return RetVal
   }
   
   ToListView() {   ; puts table object to ListView
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "()]"           ; _DBG_
      For k,v in this
      {
         if k is not integer   ;Rows are integers.
            continue
         data := object()
         For k2,v2 in this[k]
         {
            data.insert(v2)
         }
         LV_Add("",data*)
         data :=
      }
      if (this.debug)           ; _DBG_
         OutputDebug % "<[" A_ThisFunc "() -> ()]"           ; _DBG_
   }
   
}

; ######################################################################################################################
/*!
   Class: cTableRow
      Base class for handling table rows
*/
class cTableRow {
   _version := "0.1.2"
   _columnsDelimiter := "`t"
   _debug := 0

   ; ##################### Properties (AHK >1.1.16.x) #################################################################
	columnsDelimiter[] {
	/* ------------------------------------------------------------------------------- 
	Property: columnsDelimiter [get/set]
	colums Delimiter for given Row

	Value:
	flag - *true* or *false*
	*/
		get {
			return this._columnsDelimiter
		}
		set {
			this._columnsDelimiter := value
			return this._columnsDelimiter
		}
	}
	debug[] {
	/* ------------------------------------------------------------------------------- 
	Property: debug [get/set]
	Debug flag for debugging the object

	Value:
	flag - *true* or *false*
	*/
		get {
			return this._debug
		}
		set {
			mode := value<1?0:1
			this._debug := mode
			return this._debug
		}
	}
    version[] {
	/* ------------------------------------------------------------------------------- 
	Property: version [get]
	Get the version of the class implementation
	*/
		get {
			return this._version
		}
	}
    
   ; ##################### public methods ##############################################################################
   __New(CurRow := "", ColumnsCount := 0, ColumnsDelimiter := "`t", _debug := 0) {
      this.__debug(_debug)
      if (this.debug)           ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(CurRow=(" CurRow "), ColumnsCount=(" ColumnsCount "), ColumnsDelimiter=("  ColumnsDelimiter "))]"           ; _DBG_
      
      this.columnsDelimiter := ColumnsDelimiter
      StringSplit, field, CurRow, %ColumnsDelimiter%
      Loop, %ColumnsCount%
         this.Insert(field%A_Index%)
      Loop, %ColumnsCount%
         field%A_Index% =
      
      if (this.debug)                                                   ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(" _cTable_ToString(this) ")]"          ; _DBG_
      
      return this
   }
   
   ToString(ColumnsDelimiter := "") {   ; converts row object to string
      if (this.debug)                                                   ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(ColumnsDelimiter=("  ColumnsDelimiter "))]"            ; _DBG_
      
      if ColumnsDelimiter = 
         ColumnsDelimiter := this.columnsDelimiter
      Cols := this.MaxIndex()
      Loop, %Cols%
      {
         RowString .= this[A_Index]
         if (A_Index < this.MaxIndex() )
            RowString .= ColumnsDelimiter
      }
      RetVal:= RowString
      if (this.debug)                                                  ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(ColumnsDelimiter=("  ColumnsDelimiter ")) -> (" RetVal ")]"           ; _DBG_
      return RetVal
   }
   
   ToListView() {   ; puts row object to ListView
      if (this.debug)                                   ; _DBG_
         OutputDebug % ">[" A_ThisFunc "()]"            ; _DBG_
         data := object()
      For k,v in this
      {
         if k is not integer   ; field keys are integers.
            continue
         data.insert(v)
      }
      LV_Add("",data*)
      if (this.debug)                                   ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...) -> ()]"   ; _DBG_
   }
      
   StringReplace(params*) { ; replaces "param1" with "param2", "param3" with "param4" (etc.) in all fields in table object
      if (this.debug)                                                     ; _DBG_
         OutputDebug % ">[" A_ThisFunc "(params=(" params "))]"           ; _DBG_
      For k,v in this   ; v = field
      {
         c := 0
         For k2,v2 in params[1]
         {
            c++
            if c = 1
            {
               st := v2
               continue
            }
            rt := v2, c := 0
            StringReplace, v, v, %st%, %rt%, all
         }
         this[k] := v
      }
      if (this.debug)                                                     ; _DBG_
         OutputDebug % "<[" A_ThisFunc "(...) -> (" _cTable_ToString(this) ")]"   ; _DBG_
      return this 
   }
}


;====== Shared, other ======
_cTable_SplitToObj(String, Delimiter := "|") {
   obj := Object()
   Loop, parse, String, %Delimiter%
      obj.Insert(A_LoopField)
   return   obj
}

_cTable_StringReplace(ByRef String, params*) {   ; replaces "param1" with "param2", "param3" with "param4" (etc.) in string
   For k,v in params
   {
      c++
      if c = 1
      {
         st := v
         continue
      }
      rt := v, c := 0
      StringReplace, String, String, %st%, %rt%, all
   }
}

/*
Author: IsNull
http://www.autohotkey.com/forum/topic59244.html
license: not specified 
default license for forum where initially posted:GPL v2
*/
_cTable_ToString(this){
   if(!IsObject(this))
      return, this
   str := ""
   fields := this._NewEnum()
   while fields[k, v]
   {
      if(!IsObject(v)){
         str .= !IsFunc(v) ? "[" k "] := "  v "`n" : k "() calls "  v "`n"
      }else{
         subobje := _cTable_ToString(v)
         str .= "[" k "]<ob>`n" _cTable_multab(subobje)
      }
   }
   return, str
}

_cTable_multab(str){
   Loop, parse, str, `n, `r
      newstr .= A_Tab A_LoopField "`n"
   return, newstr
}