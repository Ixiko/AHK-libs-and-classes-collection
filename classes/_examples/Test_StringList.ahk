#NoEnv
; #Warn
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
ListLines, Off
; ==================

#Include <AHKEZ>
#Include <AHKEZ_Debug>
#Include <AHKEZ_UnitTest>
;#Include <Class_StringList>
#Include %A_ScriptDir%\..\src\Class_StringList.ahk

T := New UnitTest

;comment out the following SetOption if used with Run_Tests.ahk
T.SetOption("Debug")

StringCaseSense("Off") ; default is Off, manually change to test

Test_Init:

  if (CRLF = "")
    CRLF := "`r`n"

  String        := "Stallion"
  StringPair    := "Pony: Horse"

  Array         := ["one", "two", "three"]
  ArrayPair     := ["one:Dell", "two:IBM", "three:HPE"]

  ArrayCSV      := "Six, One, Two, Three, Nine"
  ArrayCSVPair  := "Sixty: Six, Seventy: Seven, Eighty: Eight"

  ArrayObj1     := {"Three": "Apple", "One": "Banana", "Two": "Cherry"}
  ArrayObj2     := Object("Six", "Apple", "Four", "Banana", "Five", "Cherry")

  ArrayText     := "Ten" . CRLF . "Eleven" . CRLF . "Twelve" . CRLF
  ArrayTextPair := "Not supported because text may contain colons" . CRLF

Test_Add_Array:
  SL := ""
  SL := New StringList
  index := SL.Add(Array)
  ;ListArray(1,"Add Array", SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[2], "two")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

  SL := ""
  SL := New StringList
  index := SL.Add(ArrayPair)
  ;ListArray(1,"Add ArrayPair, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["three"], "hpe")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

Test_Add_CSV:
  SL := ""
  SL := New StringList
  index := SL.Add(ArrayCSV)
  ;ListArray(1,"Add Array CSV, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[5], "nine")
  T.Assert(A_ScriptName, A_LineNumber, index, 5)

  SL := ""
  SL := New StringList
  index := SL.Add(ArrayCSVPair)
  ;ListArray(1,"Add Array CSV, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["eighty"], "eight")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

Test_Add_Object:
  SL := ""
  SL := New StringList
  index := SL.Add(ArrayObj1)
  ;ListArray(1,"Add ArrayObj1, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["one"], "banana")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

  SL := ""
  SL := New StringList
  index := SL.AddObj(ArrayObj2)
  ;ListArray(1,"Add ArrayObj2, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["six"], "apple")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

Test_Add_String:
  SL := ""
  SL := New StringList
  index := SL.Add(String)
  ;ListArray(1,"Add String, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[1], "stallion")
  T.Assert(A_ScriptName, A_LineNumber, index, 1)

  SL := ""
  SL := New StringList
  index := SL.Add(StringPair)
  ;ListArray(1,"Add StringPair, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["pony"], "horse")
  T.Assert(A_ScriptName, A_LineNumber, index, 1)

Test_Add_Text:
  SL := ""
  SL := New StringList
  index := SL.Add(ArrayText)
  ;ListArray(1,"Add ArrayText", SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[2], "eleven")
  T.Assert(A_ScriptName, A_LineNumber, index, 3)

  SL := ""
  SL := New StringList
  index := SL.Add(ArrayTextPair)
  ;ListArray(1,"Add TextPair, Index: " index, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[1], RTrim(ArrayTextPair, " `r`n"))
  T.Assert(A_ScriptName, A_LineNumber, index, 1)

Test_Clear:
  ;ListArray(1,"Before Clear", SL)
  SL.Clear()
  ;ListArray(1,"After Clear, Count=" SL.Count(), SL)
  T.Assert(A_ScriptName, A_LineNumber, SL.Count(), 0)

Test_Delete:
  SL := ""
  SL := New StringList
  Loop, 5
  {
    SL.Add("Item " A_Index)
  }
  ;ListArray(1,"Before Delete Count=" SL.Count, SL)
  SL.Delete(3)
  ;ListArray(1,"After Delete Count=" SL.Count, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL.Count(), 4)

  SL := ""
  SL := New StringList
  SL.Add(ArrayObj1)
  ;ListArray(1,"Before Delete Count=" SL.Count, SL)
  SL.Delete("two")
  ;ListArray(1,"After Delete Count=" SL.Count, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL.Count(), 2)
  
Test_Get_Set_Text_Save_Load:
  SL := ""
  SL := New StringList
  SL.Add(String)
  SL.SaveToFile("temp.txt")
  text := FileRead("temp.txt")
  index := SL.SetText(text)
  ;ListArray(1,"SetText, Count=" SL.Count, SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[1], String)
  v := SL.GetText()
  ;ListVars(1,"GetText", SL.Count, v)
  T.Assert(A_ScriptName, A_LineNumber, v, String . CRLF)

Test_HasKey:
  SL := ""
  SL := New StringList
  index := SL.Add(String)
  v := SL.HasKey(1)
  ;ListVars(1,"HasKey", v)
  T.Assert(A_ScriptName, A_LineNumber, v, True)
  SL.Clear()
  index := SL.Add(StringPair)
  v := SL.HasKey("Pony")
  ;ListVars(1,"HasKey", v)
  T.Assert(A_ScriptName, A_LineNumber, v, True)

Test_IndexOf:
  SL := ""
  SL := New StringList

  ;IndexOf(String) is valid for String with Integer Index
  Loop, 5
  {
    SL.Append(String A_Index)
  }
  ;ListArray(1,"IndexOf String", SL)
  index := SL.IndexOf(String "4")
  ;ListVars(1,"IndexOf", index)
  T.Assert(A_ScriptName, A_LineNumber, index, 4)

  ;IndexOf(Value) is valid for Name:Value with String Index
  SL.Clear()
  SL.Append(ArrayObj1)
  ;ListArray(1,"IndexOf ArrayObj1", SL)
  index := SL.IndexOf("Cherry")
  ;ListVars(1,"IndexOf", index)
  T.Assert(A_ScriptName, A_LineNumber, index, "two")
  
Test_Push_Pop:
  SL := ""
  SL := New StringList
  item := "New Item"
  SL.Push(item "1")
  SL.Push(item "2")
  ;ListArray(1,"Push", SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[1], item "1")

  item := SL.Pop()
  ;ListArray(1,"Pop, Item=" item, SL)
  T.Assert(A_ScriptName, A_LineNumber, item, item)

Test_Sort:
  SL := ""
  SL := New StringList

  ;sort is valid for numeric keys
  Loop, 5
  {
    SL.Append(String . 5 - A_Index)
  }
  ;ListArray(1,"Before Sort", SL)
  SL.Sort(Ascending := True)
  ;ListArray(1,"After Sort", SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[1], String . 0)
  SL.Sort(Ascending := False)
  ;ListArray(1,"After Sort", SL)
  T.Assert(A_ScriptName, A_LineNumber, SL[1], String . 4)

  SL.Clear()
  ;ListArray(1,"Sort Clear, Count=" SL.Count, SL)

  ;sort is ignored for Name:Value String keys
  SL.Append(ArrayObj1)
  ;ListArray(1,"Before Sort", SL)
  SL.Sort(Ascending := True)
  ;ListArray(1,"After Sort", SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["One"], "Banana")
  SL.Sort(Ascending := False)
  ;ListArray(1,"After Sort", SL)
  T.Assert(A_ScriptName, A_LineNumber, SL["One"], "Banana")

Test_Value:
  SL := ""
  SL := New StringList

  ;Value(Key) is valid for Name:Value with String Index
  SL.Append(ArrayObj1)
  ;ListArray(1,"Value ArrayObj1", SL)
  value := SL.Value("Two")
  ;ListVars(1,"Value", value)
  T.Assert(A_ScriptName, A_LineNumber, value, "Cherry")

  ;Value(Key) returns "" if Key is integer
  value := SL.Value(1)
  T.Assert(A_ScriptName, A_LineNumber, value, "")

  SL.Clear()
  ;ListArray(1,"Value Clear, Count=" SL.Count, SL)

  ;Value(Index) is valid for String with Integer Index
  SL.Append(String)
  ;ListArray(1,"Value String", SL)
  value := SL.Value(1)
  ;ListVars(1,"Value", value)
  T.Assert(A_ScriptName, A_LineNumber, value, String)

  ;Value(Index) Index can be an integer string
  value := SL.Value("1")
  T.Assert(A_ScriptName, A_LineNumber, value, String)

  ;Value(Index) returns "" if Key is non-integer String
  value := SL.Value(String)
  T.Assert(A_ScriptName, A_LineNumber, value, "")
  
Test_Misc:
  text := "The rain in Spain" . CRLF
  T.Assert(A_ScriptName, A_LineNumber, StrContains(text, CRLF), True)
  T.Assert(A_ScriptName, A_LineNumber, StrEndsWith(text, CRLF), True)

Gosub FreeMemory
Return

Escape::
FreeMemory:
SL := ""
T := ""
ExitApp
