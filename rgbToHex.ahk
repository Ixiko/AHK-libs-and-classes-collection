; MsgBox, % "Example:`n`n" . rgbToHex("255,255,255") . "`n" . HexToRgb("#FFFFFF") . "`n" . CheckHexC("000000")

rgbToHex(s, d = "") {
   StringSplit, s, s, % d = "" ? "," : d
   SetFormat, Integer, % (f := A_FormatInteger) = "D" ? "H" : f
   h := s1 + 0 . s2 + 0 . s3 + 0
   SetFormat, Integer, %f%
   Return, "#" . RegExReplace(RegExReplace(h, "0x(.)(?=$|0x)", "0$1"), "0x")
}

hexToRgb(s, d = "") {
   SetFormat, Integer, % (f := A_FormatInteger) = "H" ? "D" : f
   Loop, % StrLen(s := RegExReplace(s, "^(?:0x|#)")) // 2
      c%A_Index% := 0 + (h := "0x" . SubStr(s, A_Index * 2 - 1, 2))
   SetFormat, Integer, %f%
   Return, c1 . (d := d = "" ? "," : d) . c2 . d . c3
}

CheckHexC(s, d = "") {
   If InStr(s, (d := d = "" ? "," : d))
      e := hexToRgb(rgbToHex(s, d), d) = s
   Else e := rgbToHex(hexToRgb(s)) = (InStr(s, "#") ? "" : "#"
      . RegExReplace(s, "^0x"))
   Return, e
}