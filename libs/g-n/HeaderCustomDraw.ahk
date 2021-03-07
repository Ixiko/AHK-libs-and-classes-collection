; Title:   	colored listview headers
; Link:   	autohotkey.com/boards/viewtopic.php?f=76&t=87318
; Author:	just me & Bugz000
; Date:		07.03.2021
; for:     	AHK_L
; rem:     	in progress?

/*

   #NoEnv
   SetBatchLines, -1
   ; MsgBox, % Format("{:06X}", DllCall("GetSysColor", "Int", 15, "UInt"))
   ; Create a GUI with a ListView
   Gui, +hwndHGUI
   Gui, Margin, 20, 20
   Gui, Font, s12 Italic
   Gui, Add, ListView, w600 r20 hwndHLV Grid NoSort gSubLV AltSubmit Background808080
      , Message|State|Item|HickCount ; C0000FF
   ; Get the HWND of the ListView's Header control
   HHDR := DllCall("SendMessage", "Ptr", HLV, "UInt", 0x101F, "Ptr", 0, "Ptr", 0, "UPtr") ; LVM_GETHEADER
   ; Create an object containing the color for each Header control
   HeaderColors := {}
   HeaderColors[HHDR] := {Txt: 0xFFFFFF, Bkg: 0xFE9050, Grid: 1} ; Note: It's BGR instead of RGB!
   SubClassControl(HLV, "LV_HeaderCustomDraw")
   LV_Add("", "Message", "State", "Item", "HickCount")
   ; LV_ModifyCol(0, "AutoHdr")
   LV_ModifyCol(1, "Left 150")
   LV_ModifyCol(2, "Center 150")
   LV_ModifyCol(3, "Right 150")
   LV_ModifyCol(4, "100")
   ; ----------------------------------------------------------------------------------------------------------------------
   ; DllCall("UxTheme.dll\SetWindowTheme", "Ptr", HHEADER, "Ptr", 0, "Str", "")     ; Win XP
   ; Control, Style, +0x0200, , ahk_id %HHEADER%                                    ; Win XP (HDS_FLAT = 0x0200)
   ; ----------------------------------------------------------------------------------------------------------------------
   Gui, Show, , Colored LV Header
   ; Redraw the Header to get the notfications for all Header items
   WinSet, Redraw, , ahk_id %HHEADER%
   Return

   GuiClose:
   GuiEscape:
   ExitApp

   SubLV:
   ; ToolTip, %A_GuiEvent% - %ErrorLevel%
   Return

*/


LV_HeaderCustomDraw(H, M, W, L, IdSubclass, RefData) {
   Static DC_Brush      := DllCall("GetStockObject", "UInt", 18, "UPtr") ; DC_BRUSH = 18
   Static DC_Pen        := DllCall("GetStockObject", "UInt", 19, "UPtr") ; DC_PEN = 19
   Static DefGridClr    := DllCall("GetSysColor", "Int", 15, "UInt") ; COLOR_3DFACE
   Static HDM_GETITEM   := (A_IsUnicode ? 0x120B : 0x1203) ; ? HDM_GETITEMW : HDM_GETITEMA
   Static OHWND         := 0
   Static OCode         := (2 * A_PtrSize)
   Static ODrawStage    := OCode + A_PtrSize
   Static OHDC          := ODrawStage + A_PtrSize
   static ORect         := OHDC + A_PtrSize
   Static OItemSpec     := ORect + 16
   Static OItemState    := OItemSpec + A_PtrSize
   Static LM := 4       ; left margin of the first column (determined experimentally)
   Static TM := 6       ; left and right text margins (determined experimentally)
   Global HeaderColors
   ;
   Critical 1000 ; ?
   ;
   If (M = 0x004E) && (NumGet(L + OCode, "Int") = -12) { ; WM_NOTIFY -> NM_CUSTOMDRAW
      ; Get sending control's HWND
      HHD := NumGet(L + OHWND, "UPtr")
      ; If HeaderColors contains an appropriate key ...
      If HeaderColors.HasKey(HHD) {
         HC := HeaderColors[HHD]
         DrawStage := NumGet(L + ODrawStage, "UInt")
         ; -------------------------------------------------------------------------------------------------------------
         If (DrawStage = 0x00010001) { ; CDDS_ITEMPREPAINT
            ; Get the item's text, format and column order
            Item := NumGet(L + OItemSpec, "Ptr")
            , VarSetCapacity(HDITEM, 24 + (6 * A_PtrSize), 0)
            , VarSetCapacity(ItemTxt, 520, 0)
            , NumPut(0x86, HDITEM, "UInt") ; HDI_TEXT (0x02) | HDI_FORMAT (0x04) | HDI_ORDER (0x80)
            , NumPut(&ItemTxt, HDITEM, 8, "Ptr")
            , NumPut(260, HDITEM, 8 + (2 * A_PtrSize), "Int")
            , DllCall("SendMessage", "Ptr", HHD, "UInt", HDM_GETITEM, "Ptr", Item, "Ptr", &HDITEM)
            , VarSetCapacity(ItemTxt, -1)
            , Fmt := NumGet(HDITEM, 12 + (2 * A_PtrSize), "UInt") & 3
            , Order := NumGet(HDITEM, 20 + (3 * A_PtrSize), "Int")
            ; Get the device context
            , HDC := NumGet(L + OHDC, "Ptr")
            ; Draw a solid rectangle for the background
            , VarSetCapacity(RC, 16, 0)
            , DllCall("CopyRect", "Ptr", &RC, "Ptr", L + ORect)
            , NumPut(NumGet(RC, "Int") + (!(Item | Order) ? LM : 0), RC, "Int")
            , NumPut(NumGet(RC, 8, "Int") + 1, RC, 8, "Int")
            , DllCall("SetDCBrushColor", "Ptr", HDC, "UInt", HC.Bkg)
            , DllCall("FillRect", "Ptr", HDC, "Ptr", &RC, "Ptr", DC_Brush)
            ; Draw the text
            DllCall("SetBkMode", "Ptr", HDC, "UInt", 0)
            , DllCall("SetTextColor", "Ptr", HDC, "UInt", HC.Txt)
            , DllCall("InflateRect", "Ptr", L + ORect, "Int", -TM, "Int", 0)
            ; DT_EXTERNALLEADING (0x0200) | DT_SINGLELINE (0x20) | DT_VCENTER (0x04)
            ; HDF_LEFT (0) -> DT_LEFT (0), HDF_CENTER (2) -> DT_CENTER (1), HDF_RIGHT (1) -> DT_RIGHT (2)
            , DT_ALIGN := 0x0224 + ((Fmt & 1) ? 2 : (Fmt & 2) ? 1 : 0)
            , DllCall("DrawText", "Ptr", HDC, "Ptr", &ItemTxt, "Int", -1, "Ptr", L + ORect, "UInt", DT_ALIGN)
            ; Draw a 'grid' line at the left edge of the item if required
            If (HC.Grid) && (Order) {
               DllCall("SelectObject", "Ptr", HDC, "Ptr", DC_Pen, "UPtr")
               , DllCall("SetDCPenColor", "Ptr", HDC, "UInt", DefGridClr)
               , NumPut(NumGet(RC, 0, "Int"), RC, 8, "Int")
               , DllCall("Polyline", "Ptr", HDC, "Ptr", &RC, "Int", 2)
            }
            Return 4 ; CDRF_SKIPDEFAULT
         }
         ; -------------------------------------------------------------------------------------------------------------
         If (DrawStage = 1) { ; CDDS_PREPAINT
            Return 0x30 ; CDRF_NOTIFYITEMDRAW | CDRF_NOTIFYPOSTPAINT
         }
         ; -------------------------------------------------------------------------------------------------------------
         If (DrawStage = 2) { ; CDDS_POSTPAINT
            VarSetCapacity(RC, 16, 0)
            , DllCall("GetClientRect", "Ptr", HHD, "Ptr", &RC, "UInt")
            , Cnt := DllCall("SendMessage", "Ptr", HHD, "UInt", 0x1200, "Ptr", 0, "Ptr", 0, "Int") ; HDM_GETITEMCOUNT
            , VarSetCapacity(RCI, 16, 0)
            , DllCall("SendMessage", "Ptr", HHD, "UInt", 0x1207, "Ptr", Cnt - 1, "Ptr", &RCI) ; HDM_GETITEMRECT
            , R1 := NumGet(RC, 8, "Int")
            , R2 := NumGet(RCI, 8, "Int")
            If (R2 < R1) {
               HDC := NumGet(L + OHDC, "UPtr")
               , NumPut(R2, RC, 0, "Int")
               , DllCall("SetDCBrushColor", "Ptr", HDC, "UInt", HC.Bkg)
               , DllCall("FillRect", "Ptr", HDC, "Ptr", &RC, "Ptr", DC_Brush)
               If (HC.Grid) {
                  DllCall("SelectObject", "Ptr", HDC, "Ptr", DC_Pen, "UPtr")
                  , DllCall("SetDCPenColor", "Ptr", HDC, "UInt", DefGridClr)
                  , NumPut(NumGet(RC, 0, "Int"), RC, 8, "Int")
                  , DllCall("Polyline", "Ptr", HDC, "Ptr", &RC, "Int", 2)
               }
            }
            Return 4 ; CDRF_SKIPDEFAULT
         }
         ; All other drawing stages ------------------------------------------------------------------------------------
         Return 0 ; CDRF_DODEFAULT
      }
   }
   Else If (M = 0x0002) { ; WM_DESTROY
      SubclassControl(H, "") ; remove the subclass procedure
   }
   ; All messages not completely handled by the function must be passed to the DefSubclassProc:
   Return DllCall("DefSubclassProc", "Ptr", H, "UInt", M, "Ptr", W, "Ptr", L, "Ptr")
}
; ======================================================================================================================
; SubclassControl    Installs, updates, or removes the subclass callback for the specified control.
; Parameters:        HCTL     -  Handle to the control.
;                    FuncName -  Name of the callback function as string.
;                                If you pass an empty string, the subclass callback will be removed.
;                    Data     -  Optional integer value passed as dwRefData to the callback function.
; Return value:      Non-zero if the subclass callback was successfully installed, updated, or removed;
;                    otherwise, False.
; Remarks:           The callback function must have exactly six parameters, see
;                    SUBCLASSPROC -> msdn.microsoft.com/en-us/library/bb776774(v=vs.85).aspx
; MSDN:              Subclassing Controls -> msdn.microsoft.com/en-us/library/bb773183(v=vs.85).aspx
; ======================================================================================================================
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
; ======================================================================================================================
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