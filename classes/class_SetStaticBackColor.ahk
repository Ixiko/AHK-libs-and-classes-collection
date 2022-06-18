/*
Gui, Font, s24
Gui, Add, Text, hwndhText, % "  Hello, World!  "
Inst := new SetStaticBackColor(hText, 0xFFAA55)
Gui, Show
Return

GuiClose:
   ExitApp
*/

class SetStaticBackColor{

   __New(hStatic, color) {
      static SetWindowLong := A_PtrSize=8 ? "SetWindowLongPtr" : "SetWindowLong"
      this.hStatic := hStatic
      this.TextBackgroundColor := color
      this.TextBackgroundBrush := DllCall("CreateSolidBrush", "UInt", color)
      this.clbk := new BoundFuncCallback( ObjBindMethod(this, "WindowProc"), 4 )
      WindowProcNew := this.clbk.addr
      hGui := DllCall("GetAncestor", "Ptr", hStatic, "UInt", GA_ROOT := 2, "Ptr")
      this.WindowProcOld := DllCall(SetWindowLong, "Ptr", hGui, "Int", GWL_WNDPROC := -4, "Ptr", WindowProcNew, "Ptr")
   }

   WindowProc(hwnd, uMsg, wParam, lParam)   {
       Critical
       if (uMsg = 0x0138 && lParam = this.hStatic) { ; 0x0138 is WM_CTLCOLORSTATIC.
           DllCall("SetBkColor", "Ptr", wParam, "UInt", this.TextBackgroundColor)
           return this.TextBackgroundBrush
       }
       return DllCall("CallWindowProc", "Ptr", this.WindowProcOld, "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
   }
}

class BoundFuncCallback{

   __New(BoundFuncObj, paramCount, options := "") {
      this.pInfo := Object( {BoundObj: BoundFuncObj, paramCount: paramCount} )
      this.addr := RegisterCallback(this.__Class . "._Callback", options, paramCount, this.pInfo)
   }
   __Delete() {
      ObjRelease(this.pInfo)
      DllCall("GlobalFree", "Ptr", this.addr, "Ptr")
   }
   _Callback(Params*) {
      Info := Object(A_EventInfo), Args := []
      Loop % Info.paramCount
         Args.Push( NumGet(Params + A_PtrSize*(A_Index - 2)) )
      Return Info.BoundObj.Call(Args*)
   }
}