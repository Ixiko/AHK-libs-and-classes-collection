CompileList(Find, Criteria, Col, LV, ColumnList) {
  /*
  Find: What do you want to be in "Criteria" Column? (All means ALL)
  Criteria: What Column do you want to find "Find"?
  Col: What Column will do you want to build list of if "Find" is found?
  LV: Which ListView? (Name)
  ColumnList: ALWAYS ColumnList
  */
  ;~ Gui, 1: Default
  Gui, ListView, %LV%
  loop, parse, ColumnList, `|
  {
    if (A_Loopfield = Col)
    ;~ {
      A := A_Index
      ;~ break
    ;~ }
  ;~ }
  ;~ loop, parse, ColumnList, `|
  ;~ {
    if (A_Loopfield = Criteria)
    ;~ {
      B := A_Index
      ;~ break
    ;~ }
  }
  ;~ MsgBox, % Find . " / " . Criteria . " " . B . " / " . Col . " " . A . " / " . LV . " / " . ColumnList
  NList=
  RowNumber = 0
  Gui, ListView, %LV%
  Ttl := LV_GetCount()
  Loop %Ttl%
  {
    LV_GetText(Text, A_Index, B)
    ;~ MsgBox, %Text%
    if (Find = "NonBlank" and Text <> "")
      Text := "NonBlank"

    if (Text <> Find and Find <> "All" and Find <> "NONE")
      Continue
    if (Text = "" and Find = "NONE")
    {
      LV_GetText(Found, A_Index, A)
      if (NList = "")
        NList .= Found
      else
        NList .= "|" . Found
      Continue
    }
    LV_GetText(Found, A_Index, A)
    if (NList = "")
      NList .= Found
    else
      NList .= "|" . Found
  }
  Sort, NList, D| U
  ;~ MsgBox, %NList%
  Return NList
}

Search(ByRef SRow,SearchFor,Col,LV) {
  ;~ Returns Row Number according to parameters
  ;~ SRow: Starting row (if set to same variable as returned, can be made into a search loop)
  ;~ SearchFor: Criteria to be searched for (PCRE options and Wild cards supported, see https://autohotkey.com/docs/misc/RegEx-QuickRef.htm
    ;~ SearchFor syntax for finding label names is "A)[LabelName]-+")
  ;~ Col: Column NUMBER to be searched (Can be ALL)
  ;~ LV: Grid to be searched
  StringReplace, SearchFor, SearchFor, `*, `., All
  Gui, Listview, %LV%
  Ttl := LV_GetCount()
  TtlC := LV_GetCount("Column")
  SearchLoop:
  Loop
  {
    SRow +=1
    if (SRow > Ttl)
      Break, SearchLoop
    if(Col = "All")
    {
      Loop, %TtlC%
      {
        LV_GetText(SText, SRow, A_Index)
        ;~ OLD WAY (no wildcard support)
        ;~ if (SText = SearchFor)
          ;~ Break, SearchLoop
        FoundPos := RegExMatch(SText, SearchFor)
          if FoundPos
            Break, SearchLoop
      }
    }
    else
    {
      LV_GetText(SText, SRow, Col)
      ;~ MsgBox, %SText% %SearchFor%
      Clipboard := SearchFor
      FoundPos := RegExMatch(SText, SearchFor)
      if FoundPos
        Break, SearchLoop
      ;~ OLD WAY (no wildcard support)
      ;~ if (SText = SearchFor)
          ;~ Break, SearchLoop
    }
   }
  ;~ if (SText <> SearchFor)
  if not FoundPos
    SRow := 0
Return SRow
}

DblSearch(Criteria, Column, Criteria2, Column2, LV) {
  ;~ Returns RowNumber that meets both Criteria explicitly, does not have support for wildcards yet.
  ;~ Criteria: Literal, complete phrase you want to find in %Column%
  ;~ Column: Literal, complete, NAME of column you want to search for %Criteria%
  ;~ Criteria2: Same as %Criteria% but in relation to %Column2%
  ;~ Column2: Same as %Column% but in relation to %Criteria2%
  ;~ LV: Which grid (ListView) you want to find results in
  ;~ ColumnList: Complete "|" Separated list of Column Names in %LV%
  TtlC := LV_GetCount("Column")
  Loop, %TtlC%
  {
    LV_GetText(Name, 0, A_Index)
    If (Name = Column)
      A := A_Index
    else if (Name = Column2)
      B := A_Index
    if (A <> "" and B <> "")
      Break
  }
  If (A = "" or B = "" or A = 0 or B = 0)
    ;~ Give better MsgBox when MsgBox app working
    MsgBox, Column(s) not Found in %LV%!`n Parameters Given:`n`tColumn:`t%Column%`n`tColumn2:`t%Column2%
;~ OLD WAY OF ASSOCIATING COLUMN NAME WITH COLUMN NUMBER, Uses 6th Parameter (ColumnList)
;~ {
  ;~ loop, parse, ColumnList, `|
  ;~ {
    ;~ if (A_Loopfield = Column)
    ;~ {
      ;~ A := A_Index
      ;~ break
    ;~ }
  ;~ }
  ;~ loop, parse, ColumnList, `|
  ;~ {
    ;~ if (A_Loopfield = Column2)
    ;~ {
      ;~ B := A_Index
      ;~ break
    ;~ }
  ;~ }
;~ }

  RowNumber = 0
  Gui, ListView, %LV%
  Ttl := LV_GetCount()
  Loop %Ttl%
  {
    LV_GetText(Text, A_Index, A)
    LV_GetText(Text2, A_Index, B)
    if (Text = Criteria and Text2 = Criteria2)
      Found := A_Index
  }
  ;~ if (Found = "")
    ;~ Found := 0
  Return Found
}

TripSearch(Criteria, Column, Criteria2, Column2, Criteria3, Column3, LV) {
  ;~ Returns RowNumber that meets both Criteria explicitly, does not have support for wildcards yet.
  ;~ Criteria: Literal, complete phrase you want to find in %Column%
  ;~ Column: Literal, complete, NAME of column you want to search for %Criteria%
  ;~ Criteria2: Same as %Criteria% but in relation to %Column2%
  ;~ Column2: Same as %Column% but in relation to %Criteria2%
  ;~ LV: Which grid (ListView) you want to find results in
  ;~ ColumnList: Complete "|" Separated list of Column Names in %LV%
  TtlC := LV_GetCount("Column")
  Loop, %TtlC%
  {
    LV_GetText(Name, 0, A_Index)
    If (Name = Column)
      A := A_Index
    else if (Name = Column2)
      B := A_Index
    else if (Name = Column3)
      C := A_Index
    if (A <> "" and B <> "" and C <> "")
      Break
  }
  If (A = "" or B = "" or A = 0 or B = 0 or C = "" or C = 0)
    ;~ Give better MsgBox when MsgBox app working
    MsgBox, Column(s) not Found in %LV%!`n Parameters Given:`n`tColumn:`t%Column%`n`tColumn2:`t%Column2%n`tColumn3:`t%Column3%
;~ OLD WAY OF ASSOCIATING COLUMN NAME WITH COLUMN NUMBER, Uses 6th Parameter (ColumnList)
;~ {
  ;~ loop, parse, ColumnList, `|
  ;~ {
    ;~ if (A_Loopfield = Column)
    ;~ {
      ;~ A := A_Index
      ;~ break
    ;~ }
  ;~ }
  ;~ loop, parse, ColumnList, `|
  ;~ {
    ;~ if (A_Loopfield = Column2)
    ;~ {
      ;~ B := A_Index
      ;~ break
    ;~ }
  ;~ }
;~ }

  RowNumber = 0
  Gui, ListView, %LV%
  Ttl := LV_GetCount()
  Loop %Ttl%
  {
    LV_GetText(Text, A_Index, A)
    LV_GetText(Text2, A_Index, B)
    LV_GetText(Text3, A_Index, C)
    if (Text = Criteria and Text2 = Criteria2 and Text3 = Criteria3)
      Found := A_Index
  }
  ;~ if (Found = "")
    ;~ Found := 0
  Return Found
}

CleanArchive(Directory,ArNum) {
  ;~ Keeps the number of archived inventories below the value defined in the ini (Default is 100)
  ;~ See "Archived File Name Explanation.txt" in the archive folder for more info and how to change that value if so desired.
  Files := ""
  Loop %Directory%\*.csv
    TtlA := A_Index
  if (TtlA > ArNum)
  {
    TtlA -= ArNum
    Loop %Directory%\*.csv
      Files .= A_LoopFileLongPath . "|"
    Sort, Files, D| \
    Loop, parse, files, |
    {
      if (A_Index <= TtlA)
        FileDelete, %A_Loopfield%
      else
        Break
    }
  }
  return
}

GrabView(SelCols,LV,Issue) {
  /*
  Returns "," separated list from current view based on criteria WITH HEADERS, commas are ~
  SelCols: Which Columns to grab, formatted 1|2|5|8
  LV: Which Listview, "ScanGuiAdd", "Inventory", "OHInventory" or "TIInventory"
  Issue: "YES" will only collect Checked Items, "NO" grabs all
  */

  Grid := ""
  Gui, 1: Default
  Gui, ListView, %LV%
  Ttl := LV_GetCount()
  Ttl += 1
  Loop, Parse, SelCols, |
    TtlC := A_Index
  RowNumber := 0
  Loop, %Ttl%
  {
    if (Issue = "YES" and A_Index <> 1)
    {
      RowNumber := LV_GetNext(RowNumber, "Checked")
      If Not RowNumber
        Break
    }
    Loop, Parse, SelCols, |         ;Parse through Selected Column Headers (SelCols)
    {
      LV_GetText(Text, RowNumber, A_Loopfield)
      StringReplace, Text, Text, `,, `~, ALL
      GridRow .= Text
      if (A_Index <> TtlC)
        GridRow .= "`,"
    }
    Grid .= GridRow
    GridRow=
    if (RowNumber <> Ttl)
      Grid .= "`n"
    if (Issue = "No")
      RowNumber += 1
  }
  Return Grid
}

CompileItemLists(M,C,List) { ;(MasterIssueList,CompiledList,Desired Thing to be listed("SI"[Serialized Items] {or "ILM"[Issuable Location Models]} or "QI"[Quantified Items])

;~ C := "StartMe"
C := ""
Loop, parse, M, `n, `r
{
  Loop, parse, A_Loopfield, csv
  {
    if (A_Index = 1)
      I := A_Loopfield  ;Item
    if (A_Index = 4)
      M := A_Loopfield  ;Model
    if (A_Index = 7)
      S := A_Loopfield  ;Serial Number
  }
  If(List = "SI")
  {
    if (S <> "" and I <> "Issuable Location")
      C .= I . "`,"
      ;~ C .= "`n" . Item
  }
  /*
  If (List = "ILM")
  {
    if (I = "Issuable Location")
      C.Push(M)
      ;~ C .= "`n" . Item
  }
  */
  If (List = "QI")
  {
    if (S = "")
      C .= I . "`,"
      ;~ C .= "`n" . Item
  }
}
StringReplace, C, C, `n,,1
Sort, C, U D`,
Return C
}

CompileSerialLists(M,P,C,SLorQ) {       ;(MasterIssueList, ParseList(ItemList), CompiledList, Serialized, Labeled or Quantified)

  ;~ XMLAddSerials      DELETEME
Loop, Parse, P, csv
{
  DI := A_Loopfield                   ;Desired Item
  Loop, parse, M, `n, `r
  {
    If (A_Loopfield = "")
      Break
    Loop, parse, A_Loopfield, csv
    {
      if (A_Index = 1)
        I := A_Loopfield  ;Item
      if (A_Index = 3)
        L := A_Loopfield  ;Label
      if (A_Index = 4)
        Mo := A_Loopfield  ;Model
      if (A_Index = 6)
        Q := A_Loopfield  ;Qty
      if (A_Index = 7)
        S := A_Loopfield  ;Serial Number
    }

    If (I <> DI)
      Continue

    C .= "`n"

    if (SLorQ = "S")
      C .= I . "|" . L . "|" . S
    if (SLorQ = "L")
      C .= Mo . "|" . S
    if (SLorQ = "Q")
    {
      if (S = "")
        C .= I . "|" . Mo . "|" . Q
    }
  }
}
StringReplace, C, C, `n,
Sort, C
Return C
}

LV_SubitemHitTest(HLV) {
   ; https://autohotkey.com/board/topic/80265-solved-which-column-is-clicked-in-listview/
   ; To run this with AHK_Basic change all DllCall types "Ptr" to "UInt", please.
   ; HLV - ListView's HWND
  /*
typedef struct _LVHITTESTINFO {
  POINT pt;
  UINT  flags;
  int   iItem;
  int   iSubItem;
  int   iGroup;
} LVHITTESTINFO, *LPLVHITTESTINFO;
*/
   Static LVM_SUBITEMHITTEST := 0x1039
   VarSetCapacity(POINT, 8, 0)
   ; Get the current cursor position in screen coordinates
   DllCall("User32.dll\GetCursorPos", "Ptr", &POINT)
   ; Convert them to client coordinates related to the ListView
   DllCall("User32.dll\ScreenToClient", "Ptr", HLV, "Ptr", &POINT)
   ; Create a LVHITTESTINFO structure (see below)
   VarSetCapacity(LVHITTESTINFO, 24, 0)
   ; Store the relative mouse coordinates
   NumPut(NumGet(POINT, 0, "Int"), LVHITTESTINFO, 0, "Int")
   NumPut(NumGet(POINT, 4, "Int"), LVHITTESTINFO, 4, "Int")
   ; Send a LVM_SUBITEMHITTEST to the ListView
   SendMessage, LVM_SUBITEMHITTEST, 0, &LVHITTESTINFO, , ahk_id %HLV%
   ; If no item was found on this position, the return value is -1
   If (ErrorLevel = -1)
      Return 0
   ; Get the corresponding subitem (column)
   Subitem := NumGet(LVHITTESTINFO, 16, "Int") + 1
   Return Subitem
}

ActiveControlIsOfClass(Class) {
    ControlGetFocus, FocusedControl, A
    ControlGet, FocusedControlHwnd, Hwnd,, %FocusedControl%, A
    WinGetClass, FocusedControlClass, ahk_id %FocusedControlHwnd%
    return (FocusedControlClass=Class)
}

LetterArray(Begin,End) {
  ;~ Returns Array of letters at sequential index points, i.e. Columns[1] retrieves the first letter and so on
  ;~ Begin: First letter to Add to Array
  ;~ End: Last letter to add
  ;~ lowercase parameters ok
  ;~ reverse order letters ok (Means Array := LetterArray("c","a") returns, Array = [C,B,A])
  ;~ Only Handles A-Z right now will work later on AA and up
  Min := Asc(upper(Begin))
  Max := Asc(upper(End))
  Reverse := "NO"
  if (Min > Max)
  {
    Reverse := "Yes"
    tmp := Min
    Min := Max
    Max := tmp
  }
  if Max not between 65 and 90
    msgbox, Invalid parameters, Begin and End must only be single letters (in quotes if not using variables)
  Count := Max - Min + 1
    ;~ MsgBox, %Count%
  Letters := []
  loop %Count%
  {
    AsciiCode := A_Index + Min - 1 ;ASCII code for "A" is 65 for reference
    Letter := Chr(AsciiCode)
    Letters.Push(Letter)  ;adds letter to array with index = A_Index, so if Begin was "A" then Letters[1] = "A" and Letters[2] = "B"...
  }

  if (Reverse = "NO")
    Return Letters

  ReverseLetters := []
  Index := Count
  loop %Count%
  {
    Letter := Letters[Index]
    ReverseLetters.Push(Letter)
    Index -= 1
  }
  Return ReverseLetters


}

Upper(string) {
  StringUpper, STRING, String
  return STRING
}

hasValue(haystack, needle) {
    if(!isObject(haystack))
        return false
    if(haystack.Length()==0)
        return false
    for k,v in haystack
        if(v==needle)
            return true
    return false
}