; #Include a.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

Loop, 5 ; Add 5 elements to Array
{
   VarSetCapacity(t,5,asc("0")+A_Index)
   A_Put(MyArray,t)
}
Data := "1234567890abcdefghijklmnopqrstuvwxyz"
A_Put(MyArray, Data, 5) ; Change fifth entry in variable.
MsgBox, , Array Dump, % A_Dump(MyArray)
Loop, 5 ; Retrieve all elements via loop
{
   ArrayElements .= "ArrayElement #" A_Index ": " . A_Get(MyArray,A_Index) "`n"
}
MsgBox, , Via Loop retrieved, %ArrayElements%