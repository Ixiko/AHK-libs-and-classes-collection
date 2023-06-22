Menu, MyMenu, Add, Item 1, Label
Menu, MyMenu, Disable, Item 1
Menu, MyMenu, Add, Item 2, Label
DllCall("SetTimer", "Ptr", A_ScriptHwnd, "Ptr", id := 1, "UInt", 2000, "Ptr", RegisterCallback("MyTimer", "F"))
Menu, MyMenu, Show
Return

Label() {
   MsgBox, % A_ThisMenuItem
}

MyTimer() {
   DllCall("KillTimer", "Ptr", A_ScriptHwnd, "Ptr", id := 1)
   Menu, MyMenu, Enable , Item 1
   Menu, MyMenu, Disable, Item 2
}