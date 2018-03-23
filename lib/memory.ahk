Memory(Type=3,Param1=0,Param2=0,Param3=0)
{
   Static ProcessHandle
   If Type = 1 ; Open a new handle.     Syntax: Memory(1, PID)
      ProcessHandle := DllCall("OpenProcess","Int",2035711,"Int", 0,"UInt",Param1)
   Else If Type = 2 ; Close the handle. Syntax: Memory(2)
      DllCall("CloseHandle","UInt",ProcessHandle)
   Else If Type = 3 ; Reading a value.  Syntax: Memory(3, Address [, Length])
   {
      Param2 := ((!Param2) ? 4 : Param2) ; If length is left out it defaults to 4
      VarSetCapacity(MVALUE,Param2,0)
      If (ProcessHandle) && DllCall("ReadProcessMemory","UInt"
      ,ProcessHandle,"UInt",Param1,"Str",MVALUE,"UInt",Param2,"UInt",0)
      {
         Loop %Param2%
            Result += *(&MVALUE + A_Index-1) << 8*(A_Index-1)
         Return Result
      }
      Return !ProcessHandle ? "Handle Closed: " Closed : "Fail"
   }
   Else If Type = 4 ; Writing a Value.  Syntax: Memory(4, Address, Value [, Length])
   {
      Param3 := ((!Param3) ? 4 : Param3) ; If length is left out it defaults to 4
      If (ProcessHandle) && DllCall("WriteProcessMemory","UInt"
      ,ProcessHandle,"UInt",Param1,"Uint*",Param2,"Uint",Param3,"Uint",0)
         Return "Success"
      Return !ProcessHandle ? "Handle Closed: " closed : "Fail"
   }
   Else If Type = 5 ; Pointing.         Syntax: Memory(5, Pointer, Offset)
   {
      Param1 := Memory(3, Param1)
      If Param1 is not xdigit
         Return Param1
      Return Param1 + Param2
   }
}

;#############################################################################
; Code from this thread: http://www.autohotkey.com/forum/viewtopic.php?t=18327
;#############################################################################

HexToFloat(x) {
   Return (1-2*(x>>31)) * (2**((x>>23 & 255)-150)) * (0x800000 | x & 0x7FFFFF)
}

HexToDouble(x) { ; may be wrong at extreme values
   Return (2*(x>0)-1) * (2**((x>>52 & 0x7FF)-1075)) * (0x10000000000000 | x & 0xFFFFFFFFFFFFF)
}

FloatToHex(f) {
   form := A_FormatInteger
   SetFormat Integer, HEX
   v := DllCall("MulDiv", Float,f, Int,1, Int,1, UInt)
   SetFormat Integer, %form%
   Return v
}

DoubleToHex(d) {
   form := A_FormatInteger
   SetFormat Integer, HEX
   v := DllCall("ntdll.dll\RtlLargeIntegerShiftLeft",Double,d, UChar,0, Int64)
   SetFormat Integer, %form%
   Return v
}