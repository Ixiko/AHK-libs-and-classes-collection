#NoEnv
SetBatchLines, -1
; Create a GUI with a ListView
Gui, Margin, 20, 20
Gui, Font, s12 Italic
Gui, Add, ListView, w600 r20 hwndHLV Grid NoSort, Message|State|Item|HickCount ; C0000FF
LV_Add("", "Message", "State", "Item", "HickCount")
; LV_ModifyCol(0, "AutoHdr")
LV_ModifyCol(1, "Left 150")
LV_ModifyCol(2, "Center 150")
LV_ModifyCol(3, "Right 150")
; Get the HWND of the ListView's Header control
HHDR := DllCall("SendMessage", "Ptr", HLV, "UInt", 0x101F, "Ptr", 0, "Ptr", 0, "UPtr") ; LVM_GETHEADER
; ----------------------------------------------------------------------------------------------------------------------
; DllCall("UxTheme.dll\SetWindowTheme", "Ptr", HHEADER, "Ptr", 0, "Str", "")     ; Win XP
; Control, Style, +0x0200, , ahk_id %HHEADER%                                    ; Win XP (HDS_FLAT = 0x0200)
; ----------------------------------------------------------------------------------------------------------------------
; Create an object containing the color for each Header control
HeaderColors := {}
HeaderColors[HHDR] := {Txt: 0xFFFFFF, Bkg: 0x0000FF} ; Note: It's BGR instead of RGB!
SubClassControl(HLV, "HeaderCustomDraw")
Gui, Show, , Color LV Header
; Redraw the Header to get the notfications for all Header items
WinSet, Redraw, , ahk_id %HHEADER%
Return
GuiClose:
GuiEscape:
ExitApp

HeaderCustomDraw(H, M, W, L, IdSubclass, RefData) {
   Static HDM_GETITEM            := (A_IsUnicode ? 0x120B : 0x1203) ; ? HDM_GETITEMW : HDM_GETITEMA
   Static NM_CUSTOMDRAW          := -12
   Static CDRF_DODEFAULT         := 0x00000000
   Static CDRF_SKIPDEFAULT       := 0x00000004
   Static CDRF_NOTIFYITEMDRAW    := 0x00000020
   Static CDDS_PREPAINT          := 0x00000001
   Static CDDS_ITEMPREPAINT      := 0x00010001
   Static CDDS_SUBITEM           := 0x00020000
   Static DC_Brush   := DllCall("GetStockObject", "UInt", 18, "UPtr") ; DC_BRUSH = 18
   Static OHWND      := 0
   Static OMsg       := (2 * A_PtrSize)
   Static ODrawStage := OMsg + A_PtrSize
   Static OHDC       := ODrawStage + A_PtrSize
   static ORect      := OHDC + A_PtrSize
   Static OItemSpec  := OHDC + 16 + A_PtrSize
   Static LM := 4    ; left margin of the first column (determined experimentally)
   Static TM := 6    ; left and right text margins (determined experimentally)
   Global HeaderColors
   ;
   Critical ; 1000 ; ?
   ;
   If (M = 0x4E) { ; WM_NOTIFY
      ; Get sending control's HWND
      HWND := NumGet(L + OHWND, "UPtr")
      ; If HeaderColors contains an appropriate key ...
      If HeaderColors.HasKey(HWND) {
         HC := HeaderColors[HWND]
         Code := NumGet(L + OMsg, "Int")
         If (Code = NM_CUSTOMDRAW) {
            DrawStage := NumGet(L + ODrawStage, "UInt")
            ; -------------------------------------------------------------------------------------------------------------
            ; Item := NumGet(L + OItemSpec, "Ptr")                                          ; for testing
            ; LV_Modify(LV_Add("", NM_CUSTOMDRAW, DrawStage, Item, A_TickCount), "Vis")     ; for testing
            ; -------------------------------------------------------------------------------------------------------------
            If (DrawStage = CDDS_ITEMPREPAINT) {
               ; Get the item's text, format and column order
               Item := NumGet(L + OItemSpec, "Ptr")
               VarSetCapacity(HDITEM, 24 + (6 * A_PtrSize), 0)
               VarSetCapacity(ItemTxt, 520, 0)
               NumPut(0x86, HDITEM, "UInt") ; HDI_TEXT (0x02) | HDI_FORMAT (0x04) | HDI_ORDER (0x80)
               NumPut(&ItemTxt, HDITEM, 8, "Ptr")
               NumPut(260, HDITEM, 8 + (2 * A_PtrSize), "Int")
               DllCall("SendMessage", "Ptr", HWND, "UInt", HDM_GETITEM, "Ptr", Item, "Ptr", &HDITEM)
               VarSetCapacity(ItemTxt, -1)
               Fmt := NumGet(HDITEM, 12 + (2 * A_PtrSize), "UInt") & 3
               Order := NumGet(HDITEM, 20 + (3 * A_PtrSize), "Int")
               ; Get the device context
               HDC := NumGet(L + OHDC, "Ptr")
               ; Draw a solid rectangle for the background
               (Item = 0) && (Order = 0) ? NumPut(NumGet(L + ORect, "Int") + LM, L + ORect, "Int") : ""
               DllCall("SetDCBrushColor", "Ptr", HDC, "UInt", HC.Bkg)
               DllCall("FillRect", "Ptr", HDC, "Ptr", L + ORect, "Ptr", DC_Brush)
               (Item = 0) && (Order = 0) ? NumPut(NumGet(L + ORect, "Int") - LM, L + ORect, "Int") : ""
               ; Draw the text
               DllCall("SetBkMode", "Ptr", HDC, "UInt", 0)
               DllCall("SetTextColor", "Ptr", HDC, "UInt", HC.Txt)
               DllCall("InflateRect", "Ptr", L + ORect, "Int", -TM, "Int", 0)
               ; DT_EXTERNALLEADING (0x0200) | DT_SINGLELINE (0x20) | DT_VCENTER (0x04)
               ; HDF_LEFT (0x00)   -> DT_LEFT (0x00
               ; HDF_CENTER (0x02) -> DT_CENTER (0x01)
               ; HDF_RIGHT (0x01)  -> DT_RIGHT (0x02)
               DT_ALIGN := 0x0224 + ((Fmt & 1) ? 2 : (Fmt & 2) ? 1 : 0) ;
               DllCall("DrawText", "Ptr", HDC, "Ptr", &ItemTxt, "Int", -1, "Ptr", L + ORect, "UInt", DT_ALIGN)
               Return CDRF_SKIPDEFAULT
            }
            Return (DrawStage = CDDS_PREPAINT) ? CDRF_NOTIFYITEMDRAW : CDRF_DODEFAULT
         }
      }
   }
   Else If (M = 0x02) { ; WM_DESTROY
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
   If ControlCB.HasKey(HCTL) {
      DllCall("RemoveWindowSubclass", "Ptr", HCTL, "Ptr", ControlCB[HCTL], "Ptr", HCTL)
      DllCall("GlobalFree", "Ptr", ControlCB[HCTL], "Ptr")
      ControlCB.Delete(HCTL)
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



/*
typedef struct _HD_ITEMA {
  UINT    mask;
  int     cxy;
  LPSTR   pszText;
  HBITMAP hbm;
  int     cchTextMax;
  int     fmt;
  LPARAM  lParam;
  int     iImage;
  int     iOrder;
  UINT    type;
  void    *pvFilter;
  UINT    state;
} HDITEMA, *LPHDITEMA;

#define DT_LEFT                     0x00000000
#define DT_CENTER                   0x00000001
#define DT_RIGHT                    0x00000002
#define DT_VCENTER                  0x00000004
*/