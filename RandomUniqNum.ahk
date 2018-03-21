; Generating unique random integers by Laszlo
; http://www.autohotkey.com/forum/viewtopic.php?p=30664#30664
RandomUniqNum(Min,Max,N)
{
   If (Max - Min + 1 < N)
      MsgBox Cannot have %N% different numbers between %MIN% and %MAX%
   Else Loop %N%
     Loop
     {
       Random R, %MIN%, %MAX%     ; R = random number
       IfNotEqual i%R%,,Continue  ; repetition found, try again
       i%R% = 1                   ; note occurrence
       RNList = %RNList%,%R%
       break                      ; different number
     }
   StringTrimLeft RNList,RNList,1 ; remove leading ","
   Return RNList
}