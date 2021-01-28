Gui Add, Edit, x56 y64 w120 h21 +Number +Password +HwndHED
SubclassControl( HED, "EditSubclass" ) ; placed here to catch preemptive balloontips
Gui, Show, w244 h155, Window
Return

GuiClose:
ExitApp

; ======================================================================================================================
; Add these functions to your script TLM ;)
EditSubclass( HWND, Msg, wParam, lParam, SubclassID, RefData )
{
   ttl := ( Msg = 0x1503 ? StrGet(NumGet(lParam + A_PtrSize, "UPtr"), "UTF-16") : "" )
   if ( ttl = "Caps Lock is On" )
   {
   		EM_HideBalloonTip( HWND )
		Return 0
   }

   Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", HWND, "UInt", Msg, "Ptr", wParam, "Ptr", lParam)
}

EM_HideBalloonTip( HWND )
{
   ; EM_HIDEBALLOONTIP = 0x1504 -> msdn.microsoft.com/en-us/library/bb761604(v=vs.85).aspx
   Return DllCall("User32.dll\SendMessage", "Ptr", HWND, "UInt", 0x1504, "Ptr", 0, "Ptr", 0, "Ptr")
}

; ======================================================================================================================
; SubclassControl Author:            just me -> https://www.autohotkey.com/boards/viewtopic.php?p=18416
SubclassControl( HCTRL, FuncName, RefData := 0 )
{
   Static ControlCB := []

   If ControlCB.HasKey(HCTRL) {
      DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", HCTRL, "Ptr", ControlCB[HCTRL], "Ptr", HCTRL)
      DllCall("Kernel32.dll\GlobalFree", "Ptr", ControlCB[HCTRL], "Ptr")
      ControlCB.Remove(HCTRL, "")
      If (FuncName = "")
         Return True
   }
   If !DllCall("User32.dll\IsWindow", "Ptr", HCTRL, "UInt")
   Or !IsFunc(FuncName) || (Func(FuncName).MaxParams <> 6)
   Or !(CB := RegisterCallback(FuncName, , 6))
      Return False

   If !DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", HCTRL, "Ptr", CB, "Ptr", HCTRL, "Ptr", RefData)
      Return (DllCall("Kernel32.dll\GlobalFree", "Ptr", CB, "Ptr") & 0)

   Return (ControlCB[HCTRL] := CB)
}