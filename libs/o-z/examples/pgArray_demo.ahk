; #Include pgArray.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Note that there are some more examples at the bottom of the code above
#SingleInstance, Force
GoSub SetVars

;inserting to a specific index:
   pgArray_Insert("Array", 3, "Inserted starting @ 3", "another string"), Display("Inserting:")

;removing an element:
   pgArray_Shift("Array", 3), Display("Removing #3:")

;shifting 5 to 2
   pgArray_Rotate( "Array", 5, 2), Display("Rotated 5 to 2:")

;popping the last element:
   pgArray_Shift( "Array", -1 ), Display("popped the last element:")

;inserting several elements at the end:
   pgArray_Insert("Array", 0, "Added to end", "added more"), Display("added to end")
return

SetVars:
   Array0=7
   Array1=one
   Array2=two
   Array3=three
   Array4=four
   Array5=five
   Array6=six
   Array7=seven
Return

Display(x)
{ ;demonstration script specific - Infogulch
   local Info
   Info := x "`n"
   Loop % Array0
      Info .= A_Index ":`t" Array%A_Index% "`n"
   MsgBox % Info
   GoSub SetVars ;reset the vars for the next function
}