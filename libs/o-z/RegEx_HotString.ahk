; Title:   	https://www.autohotkey.com/boards/viewtopic.php?p=321060
; Link:
; Author:
; Date:
; for:     	AHK_L

/*

   text =
   (
   ===============================================================================
      Find these AHK commands:

   ::xcx::  ; HotString
   :*:yyz::  ; HotStringNoSpace
   >^F7::  ; Right <Ctrl>+<F7>  HotKey
   >!F6::  ; Right <Alt>+<F6>  HotKey
   #Z::  ; <Windows><Z>  HotKey
   <!^+Home::  ; Left <Ctrl><Alt><Shift><Home>  HotKey
   <!^+End::  ; Left <Ctrl><Alt><Shift><End>  HotKey
   ^!d::  ; <Ctrl><Alt><D>   HotKey
   ~^!d::  ; <Ctrl><Alt><D> and OS sees d  HotKey
   =================================================================================

   )

   hotstrings := RegExFindHotstrings(text)

*/
RegExFindHotstrings(text) {

      hotstrings := Array()

      Loop, parse, text, `n, `r
      {
         i := A_Index
         if RegExMatch(A_LoopField, "O)^\h*((?<HotString>::\S+)|(?<HotStringNoSpace>:\*:\S+)|(?<HotKey>\S+))::", m) {
            for k, v in ["HotString", "HotStringNoSpace", "HotKey"]
               if (m[v] != "")
                  break
            hotstrings.Push := {"name":v, "value":m[v], "line":i}
         }
      }

return hotstrings
}