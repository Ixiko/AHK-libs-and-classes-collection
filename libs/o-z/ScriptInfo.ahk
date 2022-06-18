ScriptInfo(Command) {

   static hEdit := 0, pfn, bkp, cmds := {ListLines:65406, ListVars:65407, ListHotkeys:65408, KeyHistory:65409}
   if !hEdit {
      hEdit := DllCall("GetWindow", "ptr", A_ScriptHwnd, "uint", 5, "ptr")
      user32 := DllCall("GetModuleHandle", "str", "user32.dll", "ptr")
      pfn := [], bkp := []
      for i, fn in ["SetForegroundWindow", "ShowWindow"] {
         pfn[i] := DllCall("GetProcAddress", "ptr", user32, "astr", fn, "ptr")
         DllCall("VirtualProtect", "ptr", pfn[i], "ptr", 8, "uint", 0x40, "uint*", 0)
         bkp[i] := NumGet(pfn[i], 0, "int64")
      }
   }

   if (A_PtrSize=8) {  ; Disable SetForegroundWindow and ShowWindow.
      NumPut(0x0000C300000001B8, pfn[1], "int64")  ; return TRUE
      NumPut(0x0000C300000001B8, pfn[2], "int64")  ; return TRUE
   } else {
      NumPut(0x0004C200000001B8, pfn[1], "int64")  ; return TRUE
      NumPut(0x0008C200000001B8, pfn[2], "int64")  ; return TRUE
   }

   ( cmds[Command] && DllCall("SendMessage", "ptr", A_ScriptHwnd, "uint", 0x111, "ptr", cmds[Command], "ptr", 0) )

   NumPut(bkp[1], pfn[1], "int64")  ; Enable SetForegroundWindow.
   NumPut(bkp[2], pfn[2], "int64")  ; Enable ShowWindow.

   ControlGetText, text,, ahk_id %hEdit%
   return text
}

CleanGlobalVars() {
   varsInfo := ScriptInfo("ListVars")
   RegExMatch(varsInfo, "s)Global Variables \(alphabetical\)\R-+\R\K.*", vars)
   Loop, parse, % vars, `n, `r
      if RegExMatch(A_LoopField, "^.+?(?=\[|:)", var)
         %var% := ""
}