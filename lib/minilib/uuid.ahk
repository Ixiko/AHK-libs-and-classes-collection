; Universally Unique Identifier (UUID/GUID) Generator by Titan
; http://www.autohotkey.com/forum/viewtopic.php?t=14917
uuid(c = false) { ; v1.1 - by Titan
   static n = 0, l, i
   f := A_FormatInteger, t := A_Now, s := "-"
   SetFormat, Integer, H
   t -= 1970, s
   t := (t . A_MSec) * 10000 + 122192928000000000
   If !i and c {
      Loop, HKLM, System\MountedDevices
      If i := A_LoopRegName
         Break
      StringGetPos, c, i, %s%, R2
      StringMid, i, i, c + 2, 17
   } Else {
      Random, x, 0x100, 0xfff
      Random, y, 0x10000, 0xfffff
      Random, z, 0x100000, 0xffffff
      x := 9 . SubStr(x, 3) . s . 1 . SubStr(y, 3). SubStr(z, 3)
   } t += n += l = A_Now, l := A_Now
   SetFormat, Integer, %f%
   Return, SubStr(t, 10) . s . SubStr(t, 6, 4) . s . 1 . SubStr(t, 3, 3). s . (c ? i : x)
}
