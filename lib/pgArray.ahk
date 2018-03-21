/*
;–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
;                             pgArray v2.1 ~ by Infogulch
;                  http://www.autohotkey.com/forum/viewtopic.php?t=36072
;                        Lib for manipulating ahk's psuedo-arrays
;–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
; Note:
;   these functions are lib compatible
;   these functions only work on global arrays
;   the number of elements of the given array MUST be contained in the
;      0 element index of the array (e.g. "MyArray0")
;   you can't use the p character as the name of an array, as that is the name of the
;      array of internal params of the _Insert function. (will change to more obscure)
;   see link above for docs. there are several examples at the bottom of this script
;–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
*/

pgArray_Insert( ArrayName, Idx, p1, p2="", p3="", p4="", p5="" ) 
{ ;By Infogulch - insert a values into an array starting at idx
;you can add more params as needed. (p6="", p7=""..) put the last n of pN in the loop just below
   Local p0=0, MoveToNum, MoveFmNum, pc
   Loop 5
      If (p%A_Index% != "")
         p0 := A_Index
   pc := p0
   If Idx < 1
      Idx += %ArrayName%0 + 1
   Loop % (%ArrayName%0+=p0)
      If ((MoveToNum:=%ArrayName%0-(A_Index-1)) < Idx) ;zero-based reverse index
         Break
      Else If (MoveToNum<=Idx+p0-1 && MoveToNum>=Idx)
         %ArrayName%%MoveToNum% := p%pc%, pc--
      Else
         MoveFmNum := MoveToNum - p0, %ArrayName%%MoveToNum% := %ArrayName%%MoveFmNum%
   return "" %ArrayName%0
}

pgArray_Shift( ArrayName, Idx=1, HowFar=1 )
{ ;By Infogulch - delete element @ Idx and shift left all the elements to its right
   Local Num, RetVal
   If Idx < 1
      Idx += %ArrayName%0 + 1
   RetVal := %ArrayName%%Idx%
   LC:=%ArrayName%0
   %ArrayName%0-=HowFar
   Loop % LC
   {
      If (A_Index < Idx )
         Continue
      NxtIdx:=A_Index+HowFar
      %ArrayName%%A_Index% := ( A_Index <= %ArrayName%0 ? %ArrayName%%NxtIdx% : "" )
   }
   ErrorLevel := 0
   return RetVal
}

pgArray_Rotate( ArrayName, FromIdx, ToIdx )
{
;By Infogulch - pulls out an element in an array and inserts it to the new location,
;   rotating all elements between FromIdx and ToIdx
   Local Save
   If FromIdx < 1
      FromIdx += %ArrayName%0 + 1
   If ToIdx < 1
      ToIdx += %ArrayName%0 + 1
   Save := %ArrayName%%FromIdx%
   pgArray_Shift(ArrayName, FromIdx)
   pgArray_Insert(ArrayName, ToIdx, Save)
   return Abs(FromIdx-ToIdx)
}

pgArray_Swap( ByRef Var1, ByRef Var2 )
{ ;almost striaght from the manual
   Var1_ := Var1
   Var1  := Var2
   Var2  := Var1_
}

/* Some More Examples:

Shift:
   Remove the last element: (pop)
      pgArray_Shift("MyArray", -1)
   Remove the last two elements:
      pgArray_Shift("MyArray", -2, 2)
   Remove the first element: (shift)
      pgArray_Shift("MyArray")
*/