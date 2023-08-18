#NoEnv
SetBatchLines, -1
WM_NOTIFY := 0x004E
HDS_FLAT  := 0x0200
; Create a GUI with a ListView
Gui, Margin, 20, 20
Gui, Add, ListView, w600 r20 hwndHLV Grid C0000FF NoSort, Message         |State           |Item            |TickCount
LV_ModifyCol(0, "AutoHdr")
; Get the HWND of the ListView's Header control
SendMessage, LVM_GETHEADER := 0x101F, 0, 0, , ahk_id %HLV%
HHEADER := ErrorLevel + 0
; ----------------------------------------------------------------------------------------------------------------------
; DllCall("UxTheme.dll\SetWindowTheme", "Ptr", HHEADER, "Ptr", 0, "Str", "")     ; Win XP
; Control, Style, +0x0200, , ahk_id %HHEADER%                                    ; Win XP (HDS_FLAT = 0x0200)
; ----------------------------------------------------------------------------------------------------------------------
; Create an object containing the color for each Header control
HeaderColor := {}
HeaderColor[HHEADER] := {Color: 0xFF0000} ; Note: It's BGR instead of RGB!
SubClassControl(HLV, "HeaderCustomDraw")
Gui, Show, , Color LV Header
; Register message handler for WM_NOTIFY (-> NM_CUSTOMDRAW)
; OnMessage(WM_NOTIFY, "On_NM_CUSTOMDRAW")
; Redraw the Header to get the notfications for all Header items
WinSet, Redraw, , ahk_id %HHEADER%
Return
GuiClose:
GuiEscape:
ExitApp
; ======================================================================================================================
HeaderCustomDraw(H, M, W, L, IdSubclass, RefData) {
   Static NM_CUSTOMDRAW          := -12
   Static CDRF_DODEFAULT         := 0x00000000
   Static CDRF_NEWFONT           := 0x00000002
   Static CDRF_NOTIFYITEMDRAW    := 0x00000020
   Static CDRF_NOTIFYSUBITEMDRAW := 0x00000020
   Static CDDS_PREPAINT          := 0x00000001
   Static CDDS_ITEMPREPAINT      := 0x00010001
   Static CDDS_SUBITEM           := 0x00020000
   Static OHWND      := 0
   Static OMsg       := (2 * A_PtrSize)
   Static ODrawStage := OMsg + 4 + (A_PtrSize - 4)
   Static OHDC       := ODrawStage + 4 + (A_PtrSize - 4)
   Static OItemSpec  := OHDC + 16 + A_PtrSize
   Global HeaderColor
   Critical 1000
   Switch M {
      Case 0x004E:   ; WM_NOTIFY  --------------------------------------------------------------------------------------
         ; Get sending control's HWND
         HWND := NumGet(L + 0, OHWND, "UPtr")
         ; If HeaderColor contains appropriate key ...
         If (HeaderColor.HasKey(HWND)) {
            ; If the message is NM_CUSTOMDRAW ...
            If (NumGet(L + 0, OMsg, "Int") = NM_CUSTOMDRAW) {
               ; ... do the job!
               DrawStage := NumGet(L + 0, ODrawStage, "UInt")
               ; -------------------------------------------------------------------------------------------------------------
               Item := NumGet(L + 0, OItemSpec, "Ptr")                                       ; for testing
               LV_Modify(LV_Add("", NM_CUSTOMDRAW, DrawStage, Item, A_TickCount), "Vis")     ; for testing
               ; -------------------------------------------------------------------------------------------------------------
               If (DrawStage = CDDS_ITEMPREPAINT) {
                  HDC := NumGet(L + 0, OHDC, "Ptr")
                  DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", HeaderColor[HWND].Color)
                  Return CDRF_NEWFONT
               }
               If (DrawStage = CDDS_PREPAINT) {
                  Return CDRF_NOTIFYITEMDRAW
               }
               Return CDRF_DODEFAULT
            }
         }
      Case 0x0002:   ; WM_DESTROY --------------------------------------------------------------------------------------
         SubclassControl(H, "") ; remove the subclass procedure
   }

   ; All messages not completely handled by the function must be passed to the DefSubclassProc:
   Return DllCall("DefSubclassProc", "Ptr", H, "UInt", M, "Ptr", W, "Ptr", L, "Ptr")
}
; ==================================================================================================================================
; SubclassControl    Installs, updates, or removes the subclass callback for the specified control.
; Parameters:        HCTL     -  Handle to the control.
;                    FuncName -  Name of the callback function as string.
;                                If you pass an empty string, the subclass callback will be removed.
;                    Data     -  Optional integer value passed as dwRefData to the callback function.
; Return value:      Non-zero if the subclass callback was successfully installed, updated, or removed; otherwise, False.
; Remarks:           The callback function must have exactly six parameters, see
;                    SUBCLASSPROC -> msdn.microsoft.com/en-us/library/bb776774(v=vs.85).aspx
; MSDN:              Subclassing Controls -> msdn.microsoft.com/en-us/library/bb773183(v=vs.85).aspx
; ==================================================================================================================================
SubclassControl(HCTL, FuncName, Data := 0) {
   Static ControlCB := []
   If Controls.HasKey(HCTL) {
      DllCall("RemoveWindowSubclass", "Ptr", HCTL, "Ptr", ControlCB[HCTL], "Ptr", HCTL)
      DllCall("GlobalFree", "Ptr", Controls[HCTL], "Ptr")
      Controls.Delete(HCTL)
      If (FuncName = "")
         Return True
   }
   If !DllCall("IsWindow", "Ptr", HCTL, "UInt")
   || !IsFunc(FuncName) || (Func(FuncName).MaxParams <> 6)
   || !(CB := RegisterCallback(FuncName, , 6))
      Return False
   If !DllCall("SetWindowSubclass", "Ptr", HCTL, "Ptr", CB, "Ptr", HCTL, "Ptr", Data)
      Return (DllCall("GlobalFree", "Ptr", CB, "Ptr") & 0)
   Return (ControlCB[HCTL] := CB)
}
; ==================================================================================================================================
/*
SubclassProc(hWnd, uMsg, wParam, lParam, uIdSubclass, dwRefData) {
   ...
   ...
   ...
   ; All messages not completely handled by the function must be passed to the DefSubclassProc:
   Return DllCall("DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}
*/