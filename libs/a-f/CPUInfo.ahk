; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

msgbox % CPUInfo()

CPUInfo() {
  MCode(CPUID,"538b4424080fa2508b44241489188b44241889088b44241c89105b8b44240c89185bc3")
  VarSetCapacity(a,4,0), VarSetCapacity(b,4,0), VarSetCapacity(c,4,0), VarSetCapacity(d,4,0)
  dllcall(&CPUID,"UInt",0, "Str",a, "Str",b, "Str",c, "Str",d, "CDECL")
  s := StrGet(&b, 4, "utf-8") . StrGet(&d, 4, "utf-8") . StrGet(&c, 4, "utf-8") . " "
  format = %A_FormatInteger%       ; save original integer format
 
  SetFormat Integer, hex   ; lowercase 'h'ex for lowercase hex letters in AHK_L
  VarSetCapacity(a,4,0), VarSetCapacity(b,4,0), VarSetCapacity(c,4,0), VarSetCapacity(d,4,0)
  dllcall(&CPUID,"UInt",1, "Uint*",a, "UInt*",b, "UInt*",c, "UInt*",d, "CDECL")
  s .= a . " " . c . " " . d . " "
 
  VarSetCapacity(a,4,0), VarSetCapacity(b,4,0), VarSetCapacity(c,4,0), VarSetCapacity(d,4,0)
  dllcall(&CPUID,"UInt",2, "Uint*",a, "UInt*",b, "UInt*",c, "UInt*",d, "CDECL")
  s .= a . " " . b . " " . c . " " . d
 
  SetFormat Integer, %format%      ; restore original format
  return s
}

MCode(ByRef code, hex) { ; allocate memory and write Machine Code there
   VarSetCapacity(code,StrLen(hex)//2)
   Loop % StrLen(hex)//2
      NumPut("0x" . SubStr(hex,2*A_Index-1,2), code, A_Index-1, "Char")
}
