Color2Hex(C) { ; v2
   If (Type(C) = "Integer") {
      VarSetCapacity(Hex, 7 << !!A_IsUnicode, 0)
      If (DllCall("Shlwapi.dll\wnsprintf", "Str", Hex, "Int", 7, "Str", "`%06I32X", "UInt", C & 0xFFFFFF, "Int") = 6)
         Return Hex
   }
   Return ""
}