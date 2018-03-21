

handleClip(action)
{
   global static AddNextNum
   global static GetNextNum
   global static HighestNum
   global static ClipArray
   global static ClipArray1
   global static ClipArray2
   global static ClipArray3
   global static ClipArray4
   global static ClipArray5
   global static ClipArray6
   global static ClipArray7
   global static ClipArray8
   global static ClipArray9
   global static ClipArray10
   global static ClipArray11
   global static ClipArray12
   global static ClipArray13
   global static ClipArray14
   global static ClipArray15
   global static ClipArray16
   global static ClipArray17
   global static ClipArray18
   global static ClipArray19
   global static ClipArray20
   global static ClipArray21
   global static ClipArray22
   global static ClipArray23
   global static ClipArray24
   global static ClipArray25
   global static ClipArray26
   global static ClipArray27
   global static ClipArray28
   global static ClipArray29
   global static ClipArray30



   if (action = "save")
   {
      if (AddNextNum < 30)
      {
         AddNextNum += 1 ;
      }
      else
      {
         AddNextNum := 1 ;
      }


      if (HighestNum < 30)
      {
         HighestNum += 1 ;
      }


      GetNextNum := AddNextNum ;
      ClipArray%AddNextNum% := Clipboard
   }
   else if ((action = "get") OR (action = "roll"))
   {
      if (GetNextNum != 0)
      {
         if (action = "roll")
         {
            Send, ^z
         }
         Clipboard := ClipArray%GetNextNum%
         if (GetNextNum > 1)
         {
            GetNextNum -= 1 ;
         }
         else
         {
            GetNextNum := HighestNum
         }
         Send, ^v
      }
   }
   else if (action = "rollforward")
   {
      if (GetNextNum != 0)
      {
         Send, ^z
         if (GetNextNum < HighestNum)
         {
            GetNextNum += 1 ;
         }
         else
         {
            GetNextNum := 1
         }
         Clipboard := ClipArray%GetNextNum%
         Send, ^v
      }
   }
   else if (action = "clear")
   {

      GetNextNum := 0
      AddNextNum := 0
      HighestNum := 0
   }
}


#0::
   handleClip("clear")
return

#[::
   Send, ^c
   handleClip("save")

return


#]::
   handleClip("get")
return

#\::
   handleClip("roll")
return

#^\::
   handleClip("rollforward")
return

