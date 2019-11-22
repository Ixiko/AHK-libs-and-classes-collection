; ===================================================================================
; 											ФУНКЦИЯ ОБРАБОТКИ ПЕРЕМЕННЫХ СРЕДЫ
; ===================================================================================
ExpandEnvironmentStrings(string){
   ; Find length of dest string:
   nSize := DllCall("ExpandEnvironmentStrings", "Str", string, "Str", NULL, "UInt", 0, "UInt")
  ,VarSetCapacity(Dest, size := (nSize * (1 << !!A_IsUnicode)) + !A_IsUnicode) ; allocate dest string
  ,DllCall("ExpandEnvironmentStrings", "Str", string, "Str", Dest, "UInt", size, "UInt") ; fill dest string
   return Dest
}
