#NoEnv
; #Warn
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
ListLines, Off
; ==================

#Include <AHKEZ>
;#Include <Class_StringList>
#Include %A_ScriptDir%\..\src\Class_StringList.ahk

#Include <AHKEZ_Debug>

Example_String:

  SL := ""
  SL := New StringList
  SL.LoadFromFile(A_ScriptFullPath)
  IndexBeforeSort := SL.IndexOf("#Include <AHKEZ>")
  ListArray(1,"Example_StringList.ahk Before Sort", SL)
  SL.Sort(True)
  ListArray(1,"Example_StringList.ahk After Sort", SL)
  IndexAfterSort := SL.IndexOf("#Include <AHKEZ>")
  ListVars(1,"Indexes", IndexBeforeSort, IndexAfterSort)

Example_NameValue:

  Array1 := {"Three": "Apple", "One": "Banana", "Two": "Cherry"}

  SL := ""
  SL := New StringList
  SL.Append("_Note 1: Name keys are in ascending order")
  SL.Append(Array1)
  ListArray(1,"NameValue, Count: " SL.Count, SL)

  Array2 := Object("Four", "Fig", "Six", "Strawberry", "Five", "Finger Lime", "One", "Grape")

  SL.Append(Array2)
  SL.Append("_Note 2: Dup Key overwrites previous")
  ListArray(1,"NameValue, Count: " SL.Count, SL)

Example_AddCSV:

  ArrayCSV      := "Six, One, Two, Three, Nine"
  ArrayCSVPair  := "Sixty: Six, Seventy: Seven, Eighty: Eight"

  SL := ""
  SL := New StringList
  index := SL.Add(ArrayCSV)
  ListArray(1,"Add Array CSV, Index: " index, SL)
  SL.Sort(True)
  ListArray(1," Add Array CSV After Sort, Count: " SL.Count, SL)
  
  SL := ""
  SL := New StringList
  index := SL.Add(ArrayCSVPair)
  ListArray(1,"Add Array CSV, Index: " index, SL)
  
Gosub FreeMemory

Escape::
FreeMemory:
SL := ""
ExitApp
