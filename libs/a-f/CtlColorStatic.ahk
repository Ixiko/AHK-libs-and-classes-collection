; ======================================================================================================================
; Function:       CtlColorStatic
; Requires:       AHK 1.1
; Tested with:    AHK 1.1.15.02
; Tested on:      Win 8.1 (x64)
; Change history:
;     1.0.00.00/2014-07-19/just me     -  Initial release.
; https://www.autohotkey.com/boards/viewtopic.php?t=4026
; ======================================================================================================================
CtlColorStatic(W, L := "", M := "") { ; W : wParam, L : lParam, M : uMsg
   Static Controls := {}, Init := OnMessage(0x0138, "CtlColorStatic") ; WM_CTLCOLORSTATIC = 0x0138
   If DllCall("User32.dll\IsWindow", "Ptr", W, "UInt") { ; W is the HWND of an existing control, it is a setup call ----
      Controls.Remove(W, "")
      If (L <> "") && ((B := ((L & 0xFF0000) >> 16) | (L & 0x00FF00) | ((L & 0x0000FF) << 16)) <> "")
         Controls[W] := {B: B, T: M <> "" ? ((M & 0xFF0000) >> 16) | (M & 0x00FF00) | ((M & 0x0000FF) << 16) : ""}
      Return DllCall("User32.dll\RedrawWindow", "Ptr", W, "Ptr", 0, "Ptr", 0, "UInt", 0x0405, "UInt")
   }
   If Controls.HasKey(L) { ; Presumably called by message handler ------------------------------------------------------
      If (Controls[L].T <> "")
         DllCall("Gdi32.dll\SetTextColor", "Ptr", W, "UInt", Controls[L].T)
      DllCall("Gdi32.dll\SetBkColor", "Ptr", W, "UInt", Controls[L].B)
      DllCall("Gdi32.dll\SetDCBrushColor", "Ptr", W, "UInt", Controls[L].B)
      Return DllCall("Gdi32.dll\GetStockObject", "UInt", 18, "UPtr") ; DC_BRUSH = 18
   }
}