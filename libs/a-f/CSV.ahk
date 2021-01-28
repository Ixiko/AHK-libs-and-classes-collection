; AutoHotkey Version: 1.0.48 
; Author: Kdoske, trueski  
; http://www.autohotkey.com/forum/viewtopic.php?p=329126#329126
; http://www.autohotkey.com/community/viewtopic.php?p=340948#p340948 good link
;##################################################    CSV    FUNCTIONS     ############################################### 
;if A Functions Field requires commas do not use spaces after each comma exp: 'text1,text2,text3,text,4'
;Encapsulation must be quotations, example: 'text1, "text, 2", text3, text4'
;When you CSV_Load a blank file you must specify the column count before adding new rows or columns with a command similar to: %CSV_Identifier%CSV_TotalCols := 'column count'.
;CSV_Load(FileName, CSV_Identifier, Delimiter)                                      ;Load CSV file into memory, must complete first.
;CSV_TotalRows(CSV_Identifier)                                                      ;Return total number of rows 
;CSV_TotalCols(CSV_Identifier)                                                      ;Return total number of columns 
;CSV_Delimiter(CSV_Identifier)                                                      ;Return the delimiter used 
;CSV_FileName(CSV_Identifier)                                                       ;Return the filename 
;CSV_Path(CSV_Identifier)                                                           ;Return the path 
;CSV_FileNamePath(CSV_Identifier)                                                   ;Return the filename with the full path 
;CSV_Save(FileName, CSV_Identifier, OverWrite?)                                     ;Save CSV file 
;CSV_DeleteRow(CSV_Identifier, RowNumber)                                           ;Delete a row 
;CSV_AddRow(CSV_Identifier, "Cell1,Cell2...")                                       ;Add a row 
;CSV_DeleteColumn(CSV_Identifier, ColNumber)                                        ;Delete a column 
;CSV_AddColumn(CSV_Identifier, "Cell1,Cell2...")                                    ;Add a column 
;CSV_ModifyCell(CSV_Identifier, NewValue,Row, Col)                                  ;Modify an existing cell 
;CSV_ModifyRow(CSV_Identifier, "NewValue1,NewValue2...", RowNumber)                 ;Modify an existing row 
;CSV_ModifyColumn(CSV_Identifier, "NewValue1,NewValue2...", ColNumber))              ;Modify an existing column 
;CSV_Search(CSV_Identifier, SearchText, Instance)                                   ;Search for text within 
;CSV_SearchRow(CSV_Identifier, SearchText, RowNumber, Instance)                     ;Search for text within a cell within a specific row 
;CSV_SearchColumn(CSV_Identifier, SearchText, ColNumber, Instance)                  ;Search for text within a cell within a specific column 
;CSV_MatchCell(CSV_Identifier, SearchText, Instance)                                ;Search for a cell containing exactly the data specified
;CSV_MatchCellColumn(CSV_Identifier, SearchText, ColNumber, Instance=1)            ;Search for a cell containing exactly the data specified in a specific column
;CSV_MatchCellRow(CSV_Identifier, SearchText, RowNumber, Instance=1)            ;Search for a cell containing exactly the data specified in a specific row
;CSV_MatchRow(CSV_Identifier, "SearchText1,SearchText2", Instance)                  ;Search for a row containing exactly the data specified 
;CSV_MatchCol(CSV_Identifier, "SearchText1, SearchText2", Instance)                 ;Search for a column containing exactly the data specified 
;CSV_ReadCell(CSV_Identifier, Row, Column)                                          ;Read data from the specified cell
;CSV_ReadRow(CSV_Identifier, RowNumber)                                             ;Read data from the specified row 
;CSV_ReadCol(CSV_Identifier, ColNumber)                                             ;Read data from the specified column 
;CSV_LVLoad(CSV_Identifier, Gui, x, y, w, h, header, Sort?, RowIdentification?, AutoAdjustCol?)         ;Load data into a listview in the specified gui window, listviewname variable  will equal "CSV_Identifier" 
;CSV_LVSave(FileName, CSV_Identifier, Delimiter, OverWrite?, Gui)                                       ;Save the specified listview as a CSV file, CSV_Identifier is the ListView's associated variable name. 
;#################################################################################################################### 
;CSV Functions
;#################################################################################################################### 
CSV_Load(FileName, CSV_Identifier="", Delimiter="`,") 
{ 
  Local Row 
  Local Col 
  temp :=  %CSV_Identifier%CSVFile
  FileRead, temp, %FileName%
  StringReplace, temp, temp, `r`n`r`n, `r`n, all   ;Remove all blank lines from the CSV file
  Loop, Parse, temp, `n, `r 
  { 
    Col := ReturnDSVArray(A_LoopField, CSV_Identifier . "CSV_Row" . A_Index . "_Col", Delimiter) 
    Row := A_Index 
    Loop, Parse, A_LoopReadLine, %Delimiter% 
    { 
      Col := A_Index
      %CSV_Identifier%CSV_Row%Row%_Col%Col% := A_LoopField 
    } 
  } 
  %CSV_Identifier%CSV_TotalRows := Row 
  %CSV_Identifier%CSV_TotalCols := Col 
  %CSV_Identifier%CSV_Delimiter := Delimiter
  SplitPath, FileName, %CSV_Identifier%CSV_FileName, %CSV_Identifier%CSV_Path 
  IfNotInString, FileName, `\ 
  { 
    %CSV_Identifier%CSV_FileName := FileName 
    %CSV_Identifier%CSV_Path := A_ScriptDir 
  } 
  %CSV_Identifier%CSV_FileNamePath := %CSV_Identifier%CSV_Path . "\" . %CSV_Identifier%CSV_FileName
} 
;#################################################################################################################### 
CSV_Save(FileName, CSV_Identifier, OverWrite="1") 
{ 
Local Row 
Local Col 

If OverWrite = 0 
 IfExist, %FileName% 
   Return 
  
FileDelete, %FileName% 

EntireFile = 
CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows 
CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols
Loop, %currentcsv_totalrows% 
{ 
    Row := A_Index 
   Loop, %currentCSV_TotalCols% 
   { 
      Col := A_Index 
      EntireFile .= Format4CSV(%CSV_Identifier%CSV_Row%Row%_Col%Col%)
      If (Col <> %CSV_Identifier%CSV_TotalCols) 
         EntireFile .= %CSV_Identifier%CSV_Delimiter 
   } 
   If (Row < %CSV_Identifier%CSV_TotalRows) 
      EntireFile .= "`n" 
}  
   StringReplace, temp, temp, `r`n`r`n, `r`n, all   ;Remove all blank lines from the CSV file
   loop,
   {
      stringright, test, EntireFile, EntireFile, 1
      if (test = "`n") or (test = "`r")
         stringtrimright, EntireFile, EntireFile, 1
      Else
         break
   }
    FileAppend, %EntireFile%, %FileName% 
}
;#################################################################################################################### 
CSV_TotalRows(CSV_Identifier) 
{ 
  global    
  CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows
  Return %CurrentCSV_TotalRows% 
} 
;#################################################################################################################### 
CSV_TotalCols(CSV_Identifier) 
{ 
  global   
  CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols
  Return %CurrentCSV_TotalCols% 
} 
;#################################################################################################################### 
CSV_Delimiter(CSV_Identifier) 
{ 
  global 
  CurrentCSV_Delimiter := %CSV_Identifier%CSV_Delimiter
  Return %CurrentCSV_Delimiter% 
} 
;#################################################################################################################### 
CSV_FileName(CSV_Identifier) 
{ 
  global    
  CurrentCSV_FileName := %CSV_Identifier%CSV_FileName
  Return %CurrentCSV_FileName% 
} 
;#################################################################################################################### 
CSV_Path(CSV_Identifier) 
{ 
  global 
  CurrentCSV_Path := %CSV_Identifier%CSV_Path
  Return %CurrentCSV_Path% 
} 
;#################################################################################################################### 
CSV_FileNamePath(CSV_Identifier) 
{ 
  global
  CurrentCSV_FileNamePath := %CSV_Identifier%CSV_FileNamePath
  Return %CurrentCSV_FileNamePath% 
} 
;#################################################################################################################### 
CSV_DeleteRow(CSV_Identifier, RowNumber) 
{ 
  Local Row 
  Local Col 
  Local NewRow 
  CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows 
  CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols   
  Loop, %CurrentCSV_TotalRows% 
  { 
    Row := A_Index 
    NewRow := Row + 1 
    If Row < %RowNumber% 
      Continue 
    Else 
      Loop, %CurrentCSV_TotalCols% 
      { 
        Col := A_Index 
        %CSV_Identifier%CSV_Row%Row%_Col%Col% := %CSV_Identifier%CSV_Row%NewRow%_Col%Col% 
      } 
  } 
  %CSV_Identifier%CSV_TotalRows -- 
} 
;#################################################################################################################### 
CSV_AddRow(CSV_Identifier, RowData) 
{ 
  global 
  %CSV_Identifier%CSV_TotalRows ++
  CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows
  CurrentCSV_Delimiter := %CSV_Identifier%CSV_Delimiter
  ReturnDSVArray(RowData, CSV_Identifier . "CSV_Row" . CurrentCSV_TotalRows . "_Col", CurrentCSV_Delimiter)
} 
;#################################################################################################################### 
CSV_DeleteColumn(CSV_Identifier, ColNumber) 
{ 
  Local Row 
  Local Col 
  Local NewCol 
  CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows 
  CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols
  Loop, %currentCSV_TotalRows% 
  { 
    Row := A_Index 
    Loop, %currentCSV_TotalCols% 
    { 
      Col := A_Index 
      NewCol := Col + 1 
      If Col < %ColNumber% 
        Continue 
      Else 
        %CSV_Identifier%CSV_Row%Row%_Col%Col% := %CSV_Identifier%CSV_Row%Row%_Col%NewCol% 
    } 
  } 
    %CSV_Identifier%CSV_TotalCols --   
} 
;#################################################################################################################### 
CSV_AddColumn(CSV_Identifier, ColData)
{
  global
  %CSV_Identifier%CSV_TotalCols ++
  CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols
  CurrentCSV_Delimiter := %CSV_Identifier%CSV_Delimiter
  _tmpColItems:=ReturnDSVArray(Coldata, "_tmpCOL", CurrentCSV_Delimiter)
  Loop, %_tmpColItems%
   {
    %CSV_Identifier%CSV_Row%A_Index%_Col%CurrentCSV_TotalCols% := _tmpCOL%A_Index%
   _tmpCOL%A_Index%:= ; clear mem
   }
   _tmpColItems= ; clear mem
 }
;#################################################################################################################### 
CSV_ModifyCell(CSV_Identifier, Value, Row, Col) 
  { 
   global 
    %CSV_Identifier%CSV_Row%Row%_Col%Col% := Value 
  } 
;#################################################################################################################### 
CSV_ModifyRow(CSV_Identifier, Value, RowNumber) 
{
  CurrentCSV_Delimiter := %CSV_Identifier%CSV_Delimiter
  ReturnDSVArray(Value, CSV_Identifier . "CSV_Row" . RowNumber . "_Col", CurrentCSV_Delimiter)
}
;####################################################################################################################    
CSV_ModifyColumn(CSV_Identifier, Coldata, ColNumber)
{
  global
  CurrentCSV_Delimiter := %CSV_Identifier%CSV_Delimiter
  _tmpColItems:=ReturnDSVArray(Coldata, "_tmpCOL", CurrentCSV_Delimiter)
  Loop, %_tmpColItems%
   {
  %CSV_Identifier%CSV_Row%A_Index%_Col%ColNumber% := _tmpCOL%A_Index%
    _tmpCOL%A_Index%:= ; clear mem
  }
 _tmpColItems= ; clear mem
}
;#################################################################################################################### 
CSV_Search(CSV_Identifier, SearchText, Instance=1) 
{ 
  Local Row 
  Local Col 
  Local FoundInstance 
  CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows 
  CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols    
  
  Loop, %CurrentCSV_TotalRows% 
  { 
    Row := A_Index 
    Loop, %CurrentCSV_TotalCols% 
    { 
      Col := A_Index 
      CurrentString := %CSV_Identifier%CSV_Row%Row%_Col%Col%
      IfInString, CurrentString, %SearchText% 
      { 
        FoundInstance ++ 
        CurrentCell = %Row%`,%Col%  
        If FoundInstance = %Instance% 
          Return %CurrentCell% 
      } 
    } 
  } 
  Return 0 
} 
;#################################################################################################################### 
CSV_SearchRow(CSV_Identifier, SearchText, RowNumber, Instance=1) 
{ 
  Local Col 
  Local FoundInstance 
  CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols
  
  Loop, %CurrentCSV_TotalCols% 
  { 
    Col := A_Index 
    CurrentString := %CSV_Identifier%CSV_Row%RowNumber%_Col%Col% 
    IfInString, CurrentString, %SearchText% 
    { 
     FoundInstance ++ 
     If FoundInstance = %Instance% 
       Return %Col% 
    } 
  } 
  Return 0 
} 
;#################################################################################################################### 
CSV_SearchColumn(CSV_Identifier, SearchText, ColNumber, Instance=1) 
{ 
  Local Row 
  Local FoundInstance 
  CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows

  Loop, %CurrentCSV_TotalRows% 
  { 
    Row := A_Index 
    CurrentString := %CSV_Identifier%CSV_Row%Row%_Col%ColNumber% 
    IfInString, CurrentString, %SearchText% 
    { 
      FoundInstance ++ 
      If FoundInstance = %Instance% 
        Return %Row% 
    } 
  } 
  Return 0 
} 
;#################################################################################################################### 
CSV_MatchCell(CSV_Identifier,SearchText, Instance=1) 
{ 
Local Row 
Local Col 
Local FoundInstance 
CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows 
CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols

Loop, %CurrentCSV_TotalRows% 
  { 
    Row := A_Index 
    Loop, %CurrentCSV_TotalCols% 
    { 
      Col := A_Index 
      CurrentString := %CSV_Identifier%CSV_Row%Row%_Col%Col% 
      IfEqual, CurrentString, %SearchText% 
      { 
        FoundInstance ++ 
        CurrentCell = %Row%`,%Col% 
        If FoundInstance = %Instance% 
          Return %CurrentCell% 
      } 
    } 
  } 
  Return 0 
}
;#################################################################################################################### 
CSV_MatchCellColumn(CSV_Identifier, SearchText, ColNumber, Instance=1) 
{ 
  Local Row 
  Local FoundInstance 
  CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows

  Loop, %CurrentCSV_TotalRows% 
  { 
    Row := A_Index 
    CurrentString := %CSV_Identifier%CSV_Row%Row%_Col%ColNumber% 
   IfEqual, CurrentString, %SearchText%
    { 
      FoundInstance ++ 
      If FoundInstance = %Instance% 
        Return %Row% 
    } 
  } 
  Return 0 
}
;#################################################################################################################### 
CSV_MatchCellRow(CSV_Identifier, SearchText, RowNumber, Instance=1) 
{ 
  Local Col 
  Local FoundInstance 
  CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols
  
  Loop, %CurrentCSV_TotalCols% 
  { 
    Col := A_Index 
    CurrentString := %CSV_Identifier%CSV_Row%RowNumber%_Col%Col% 
   IfEqual, CurrentRow, %SearchText% 
    { 
     FoundInstance ++ 
     If FoundInstance = %Instance% 
       Return %Col% 
    } 
  } 
  Return 0 
} 
;#################################################################################################################### 
CSV_MatchRow(CSV_Identifier, SearchText, Instance=1) 
{ 
  Local Col 
  Local Row 
  Local CurrentRow 
  Local FoundInstance 
  CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows 
  CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols 
  Loop, %CurrentCSV_TotalRows% 
  { 
    Row := A_Index 
    CurrentRow = 
    Loop, %CurrentCSV_TotalCols% 
    { 
      Col := A_Index 
      CurrentRow .= %CSV_Identifier%CSV_Row%Row%_Col%Col% 
      If Col <> %CurrentCSV_TotalCols% 
        CurrentRow .= "`," 
      IfEqual, CurrentRow, %SearchText% 
      { 
        FoundInstance ++        
        If FoundInstance = %Instance% 
          Return %Row% 
      } 
    } 
  } 
  Return 0 
} 
;#################################################################################################################### 
CSV_MatchCol(CSV_Identifier, SearchText, Instance=1) 
{ 
Local Col 
Local Row 
Local CurrentCol 
Local FoundInstance 
CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows 
CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols    
Loop, %CurrentCSV_TotalCols% 
  {    
    Col := A_Index 
    CurrentCol = 
    Loop, %CurrentCSV_TotalRows% 
    { 
      Row := A_Index 
      CurrentCol .= %CSV_Identifier%CSV_Row%Row%_Col%Col% 
      If Row <> %CurrentCSV_TotalRows% 
        CurrentCol .= "`," 
      IfEqual, CurrentCol, %SearchText% 
      { 
        FoundInstance ++ 
        If FoundInstance = %Instance% 
          Return %Col% 
      } 
    } 
  } 
Return 0 
} 
;#################################################################################################################### 
CSV_ReadCell(CSV_Identifier, Row, Col) 
{ 
  Local CellData 
  CellData := %CSV_Identifier%CSV_Row%Row%_Col%Col% 
  Return %CellData% 
} 
;#################################################################################################################### 
CSV_ReadRow(CSV_Identifier, RowNumber) 
{ 
  Local CellData 
  CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols  
  
  Loop, %CurrentCSV_TotalCols% 
  { 
    RowData .= %CSV_Identifier%CSV_Row%RowNumber%_Col%A_Index% 
    If A_Index <> %CurrentCSV_TotalCols% 
      RowData .= "`," 
  } 
  Return %RowData% 
} 
;#################################################################################################################### 
CSV_ReadCol(CSV_Identifier, ColNumber) 
{ 
  Local CellData 
  CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows    
  
  Loop, %CurrentCSV_TotalRows% 
  { 
    ColData .= %CSV_Identifier%CSV_Row%A_Index%_Col%ColNumber% 
    If A_Index <> %CurrentCSV_TotalRows% 
      ColData .= "`," 
  } 
  Return %ColData% 
} 
;#################################################################################################################### 
CSV_LVLoad(CSV_Identifier, Gui=1, x=10, y=10, w="", h="", header="", Sort=0, AutoAdjustCol=1) 
{ 
  Local Row
  CurrentCSV_TotalRows := %CSV_Identifier%CSV_TotalRows 
  CurrentCSV_TotalCols := %CSV_Identifier%CSV_TotalCols
  
  If %CSV_Identifier%CSV_LVAlreadyCreated = 
  { 
    Gui, %Gui%:Add, ListView, v%CSV_Identifier% x%x% y%y% w%w% h%h%, %header% 
    %CSV_Identifier%CSV_LVAlreadyCreated = 
  } 
  ;Set GUI window, clear any existing data 
  Gui, %Gui%:Default 
  GuiControl, -Redraw, %CSV_Identifier% 
  Sleep, 200 
  LV_Delete() 

  ;Add Data 
  Loop, %currentcsv_totalrows% 
    LV_Add("", "") 
  Loop, %currentcsv_totalrows% 
  { 
    Row := A_Index 
    Loop, %currentCSV_TotalCols% 
    LV_Modify(Row, "Col" . A_Index, %CSV_Identifier%CSV_Row%Row%_Col%A_Index%) 
  } 
  ;Display Data 
  If Sort <> 0 
    LV_ModifyCol(Sort, "Sort") 

  If AutoAdjustCol = 1 
    LV_ModifyCol() 
  GuiControl, +Redraw, %CSV_Identifier% 
} 
;#################################################################################################################### 
CSV_LVSave(FileName, CSV_Identifier, Delimiter=",",OverWrite=1, Gui=1) 
{ 
  Gui, %Gui%:Default 
  Gui, ListView, %CSV_Identifier%
  Rows := LV_GetCount() 
  Cols := LV_GetCount("Col") 

  IfExist,2 %FileName% 
    If OverWrite = 0 
      Return 0 
  FileDelete, %FileName% 

  Loop, %Rows% 
  { 
    FullRow = 
    Row := A_Index 
    Loop, %Cols% 
    { 
      LV_GetText(CellData, Row, A_Index) 
      FullRow .= CellData
      If A_Index <> %Cols% 
        FullRow .= Delimiter 
    } 
    If Row <> %Rows% 
      FullRow .= "`n" 
    EntireFile .= FullRow 
  } 
  FileAppend, %EntireFile%, %FileName% 
} 
;#################################################################################################################### 
; Format4CSV by Rhys 
; http://www.autohotkey.com/forum/topic27233.html 
Format4CSV(F4C_String) 
{ 
   Reformat:=False ;Assume String is OK 
   IfInString, F4C_String,`n ;Check for linefeeds 
      Reformat:=True ;String must be bracketed by double quotes 
   IfInString, F4C_String,`r ;Check for linefeeds 
      Reformat:=True 
   IfInString, F4C_String,`, ;Check for commas 
      Reformat:=True 
   IfInString, F4C_String, `" ;Check for double quotes 
   {   Reformat:=True 
      StringReplace, F4C_String, F4C_String, `",`"`", All ;The original double quotes need to be double double quotes 
   } 
   If (Reformat) 
      F4C_String=`"%F4C_String%`" ;If needed, bracket the string in double quotes 
   Return, F4C_String 
} 
;#################################################################################################################### 
; Delimiter Seperated Values by DerRaphael 
; http://www.autohotkey.com/forum/post-203280.html#203280 
; 
; Proof of Concept to extract DSV (Delimiter Seperator Values) 
;      - adapted for AHK by derRaphael / 21st July 2008 - 
;                           derRaphael@oleco.net 
; Following rules apply: 
;   You have to set a delimiter char and an encapsulation char. 
;   1) If you're using the delimeter char within your value, the value has 
;      to be surrounded by your encapsulation char. One at beginning and one 
;      at its end. 
;   2) If you're using your encapsulation char within your value you have to 
;      double it each time it occurs and surround your value as in rule 1. 
; Remarks: 
;   The whole concept will break, when using same EOL (End Of Line) as LineBreaks 
;   in a value as in the entire file. Either you will have to escape these chars 
;   somehow or use a single linefeed (`n) in values and carriage return linefeed 
;   (`r`n) as EOL in your DSV file. 
;   Encapsulation and delimiter chars have to be single Chars. Strings containing 
;   more than one char are not supported by concept. 
;CurrentDSVLine=a,b,c,"d,e","f"","",g",,i 
; 
;Loop, % ReturnDSVArray(CurrentDSVLine) 
;   MsgBox % A_Index ": " DSVfield%A_Index% 

ReturnDSVArray(CurrentDSVLine, ReturnArray="DSVfield", Delimiter=",", Encapsulator="""") 
{ 
   global 
   if ((StrLen(Delimiter)!=1)||(StrLen(Encapsulator)!=1)) 
   { 
      return -1                            ; return -1 indicating an error ... 
   } 
   SetFormat,integer,H                      ; needed for escaping the RegExNeedle properly 
   local d := SubStr(ASC(delimiter)+0,2)    ; used as hex notation in the RegExNeedle 
   local e := SubStr(ASC(encapsulator)+0,2) ; used as hex notation in the RegExNeedle 
   SetFormat,integer,D                      ; no need for Hex values anymore 

   local p0 := 1                            ; Start of search at char p0 in DSV Line 
   local fieldCount := 0                    ; start off with empty fields. 
   CurrentDSVLine .= delimiter              ; Add delimiter, otherwise last field 
   ;                                          won't get recognized 
   Loop 
   { 
      Local RegExNeedle := "\" d "(?=(?:[^\" e "]*\" e "[^\" e "]*\" e ")*(?![^\" e "]*\" e "))" 
      Local p1 := RegExMatch(CurrentDSVLine,RegExNeedle,tmp,p0) 
      ; p1 contains now the position of our current delimitor in a 1-based index 
      fieldCount++                         ; add count 
      local field := SubStr(CurrentDSVLine,p0,p1-p0) 
      ; This is the Line you'll have to change if you want different treatment 
      ; otherwise your resulting fields from the DSV data Line will be stored in AHK array 
      if (SubStr(field,1,1)=encapsulator) 
      { 
       ; This is the exception handling for removing any doubled encapsulators and 
       ; leading/trailing encapsulator chars 
       field := RegExReplace(field,"^\" e "|\" e "$") 
       StringReplace,field,field,% encapsulator encapsulator,%encapsulator%, All 
      } 
      Local _field := ReturnArray A_Index  ; construct a reference for our ReturnArray name 
      %_field% := field                    ; dereference _field and assign our value to it 
      if (p1=0) 
      {                          ; p1 is 0 when no more delimitor chars have been found 
         fieldCount--                     ; so correct fieldCount due to last appended delimitor 
         Break                            ; and exit loop 
      } Else 
         p0 := p1 + 1                     ; set the start of our RegEx Search to last result 
   }                                        ; added by one 
   return fieldCount 
}
;#################################################################################################################### 

