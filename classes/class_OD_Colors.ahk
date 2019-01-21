; ======================================================================================================================
; AHK 1.1.13+
; ======================================================================================================================
; Namespace:   OD_Colors
; Function:    Helper class for colored items in ListBox and DropDownList controls.
; AHK version: 1.1.13.00 (U64)
; Tested on:   Win 7 Pro x64
; Language:    English
; Version:     1.0.01.00/2013-10-24/just me
; MSDN:        Owner-Drawn ListBox -> http://msdn.microsoft.com/en-us/library/hh298352(v=vs.85).aspx
; Credits:     THX, Holle. You never gave up trying to manage it. So I remembered your problem from time to time
;              and finally found this solution.
; https://www.autohotkey.com/boards/viewtopic.php?t=338
; ======================================================================================================================
; How to use:  To register a control call OD_Colors.Attach() passing two parameters:
;                 Hwnd   - HWND of the control
;                 Colors - Object which may contain the following keys:
;                          T - default text color.
;                          B - default background color.
;                          The one-based index of items with special text and/or background colors.
;                          Each of this keys contains an object with up to two key/value pairs:
;                             T - text colour.
;                             B - background colour.
;                          Color values have to be passed as RGB integer values (0xRRGGBB).
;                          If either T or B is not specified, the control's default colour will be used.
;              To update a control after content or colour changes call OD_Colors.Update() passing two parameters:
;                 Hwnd   - HWND of the control.
;                 Colors - see above.
;              To unregister a control call OD_Colors.Detach() passing one parameter:
;                 Hwnd  - see above.
; Note:        ListBoxes must have the styles LBS_OWNERDRAWFIXED (0x0010) and LBS_HASSTRINGS (0x0040),
;              DropDownLists CBS_OWNERDRAWFIXED (0x0010) and  CBS_HASSTRINGS (0x0200) set at creation time.
;              Before adding the control, you have to set OD_Colors.ItemHeight (see OD_Colors.MeasureItem).
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================

Class OD_Colors {
   ; ===================================================================================================================
   ; Class variables ===================================================================================================
   ; ===================================================================================================================
   ; WM_MEASUREITEM := 0x002C
   Static OnMessageInit := OnMessage(0x002C, "OD_Colors.MeasureItem")
   Static ItemHeight := 0
   Static Controls := {}
   ; ===================================================================================================================
   ; You must not instantiate this class! ==============================================================================
   ; ===================================================================================================================
   __New(P*) {
      Return False
   }
   ; ===================================================================================================================
   ; Public methods ====================================================================================================
   ; ===================================================================================================================
   Attach(HWND, Colors) {
      Static WM_DRAWITEM := 0x002B
      If !IsObject(Colors)
         Return False
      This.Controls[HWND] := {}
      ControlGet, Content, List, , , ahk_id %HWND%
      This.Controls[HWND].Items := StrSplit(Content, "`n")
      This.Controls[HWND].Colors := {}
      For Key, Value In Colors {
         If (Key = "T") {
            This.Controls[HWND].Colors.T := ((Value & 0xFF) << 16) | (Value & 0x00FF00) | ((Value >> 16) & 0xFF)
            Continue
         }
         If (Key = "B") {
            This.Controls[HWND].Colors.B := ((Value & 0xFF) << 16) | (Value & 0x00FF00) | ((Value >> 16) & 0xFF)
            Continue
         }
         If ((Item := Round(Key)) = Key) {
            If ((C := Value.T) <> "")
               This.Controls[HWND].Colors[Item, "T"] := ((C & 0xFF) << 16) | (C & 0x00FF00) | ((C >> 16) & 0xFF)
            If ((C := Value.B) <> "")
               This.Controls[HWND].Colors[Item, "B"] := ((C & 0xFF) << 16) | (C & 0x00FF00) | ((C >> 16) & 0xFF)
         }
      }
      If !OnMessage(WM_DRAWITEM)
         OnMessage(WM_DRAWITEM, "OD_Colors.DrawItem")
      WinSet, Redraw, , ahk_id %HWND%
      Return True
   }
   ; ===================================================================================================================
   Detach(HWND) {
      This.Controls.Remove(HWND, "")
      If (This.Controls.MaxIndex = "")
         OnMessage(WM_DRAWITEM, "")
      WinSet, Redraw, , ahk_id %HWND%
      Return True
   }
   ; ===================================================================================================================
   Update(HWND, Colors := "") {
      If This.Controls.HasKey(HWND)
         This.Detach(HWND)
      Return This.Attach(HWND)
   }
   ; ===================================================================================================================
   SetItemHeight(FontOptions, FontName) {
      Gui, OD_Colors_SetItemHeight:Font, %FontOptions%, %FontName%
      Gui, OD_Colors_SetItemHeight:Add, Text, 0x200 hwndHTX, Dummy
      VarSetCapacity(RECT, 16, 0)
      DllCall("User32.dll\GetClientRect", "Ptr", HTX, "Ptr", &RECT)
      Gui, OD_Colors_SetItemHeight:Destroy
      Return (OD_Colors.ItemHeight := NumGet(RECT, 12, "Int"))
   }
   ; ===================================================================================================================
   ; Called by system ==================================================================================================
   ; ===================================================================================================================
   MeasureItem(lParam, Msg, Hwnd) { ; first param 'wParam' is passed as 'This'.
      ; ----------------------------------------------------------------------------------------------------------------
      ; Sent once to the parent window of an OWNERDRAWFIXED ListBox or ComboBox when an the control is being created.
      ; When the owner receives this message, the system has not yet determined the height and width of the font used
      ; in the control. That is why OD_Colors.ItemHeight must be set to an appropriate value before the control will be
      ; created by Gui, Add, ... You either might call 'OD_Colors.SetItemHeight' passing the current font options and
      ; name to calculate the value or set it manually.
      ; WM_MEASUREITEM      -> http://msdn.microsoft.com/en-us/library/bb775925(v=vs.85).aspx
      ; MEASUREITEMSTRUCT   -> http://msdn.microsoft.com/en-us/library/bb775804(v=vs.85).aspx
      ; ----------------------------------------------------------------------------------------------------------------
      ; lParam -> MEASUREITEMSTRUCT offsets
      Static offHeight := 16
      NumPut(OD_Colors.ItemHeight, lParam + 0, offHeight, "Int")
      Return True
   }
   ; ===================================================================================================================
   DrawItem(lParam, Msg, Hwnd) { ; first param 'wParam' is passed as 'This'.
      ; ----------------------------------------------------------------------------------------------------------------
      ; Sent to the parent window of an owner-drawn ListBox or ComboBox when a visual aspect of the control has changed.
      ; WM_DRAWITEM         -> http://msdn.microsoft.com/en-us/library/bb775923(v=vs.85).aspx
      ; DRAWITEMSTRUCT      -> http://msdn.microsoft.com/en-us/library/bb775802(v=vs.85).aspx
      ; ----------------------------------------------------------------------------------------------------------------
      ; lParam / DRAWITEMSTRUCT offsets
      Static offItem := 8, offAction := offItem + 4, offState := offAction + 4, offHWND := offState + A_PtrSize
           , offDC := offHWND + A_PtrSize, offRECT := offDC + A_PtrSize, offData := offRECT + 16
      ; Owner Draw Type
      Static ODT := {2: "LISTBOX", 3: "COMBOBOX"}
      ; Owner Draw Action
      Static ODA_DRAWENTIRE := 0x0001, ODA_SELECT := 0x0002, ODA_FOCUS := 0x0004
      ; Owner Draw State
      Static ODS_SELECTED := 0x0001, ODS_FOCUS := 0x0010
      ; Draw text format flags
      Static DT_Flags := 0x24 ; DT_SINGLELINE = 0x20, DT_VCENTER = 0x04
      ; ----------------------------------------------------------------------------------------------------------------
      Critical ; may help in case of drawing issues
      HWND := NumGet(lParam + offHWND, 0, "UPtr")
      If OD_Colors.Controls.HasKey(HWND) && ODT.HasKey(NumGet(lParam + 0, 0, "UInt")) {
         ODCtrl := OD_Colors.Controls[HWND]
         Item := NumGet(lParam + offItem, 0, "Int") + 1
         Action := NumGet(lParam + offAction, 0, "UInt")
         State := NumGet(lParam + offState, 0, "UInt")
         HDC := NumGet(lParam + offDC, 0, "UPtr")
         RECT := lParam + offRECT
         If (Action = ODA_FOCUS)
            Return True
         If ODCtrl.Colors.HasKey("B")
            CtrlBgC := ODCtrl.Colors.B
         Else
            CtrlBgC := DllCall("Gdi32.dll\GetBkColor", "Ptr", HDC, "UInt")
         If ODCtrl.Colors.HasKey("T")
            CtrlTxC := ODCtrl.Colors.T
         Else
            CtrlTxC := DllCall("Gdi32.dll\GetTextColor", "Ptr", HDC, "UInt")
         BgC := ODCtrl.Colors[Item].HasKey("B") ? ODCtrl.Colors[Item].B : CtrlBgC
         Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BgC, "UPtr")
         DllCall("User32.dll\FillRect", "Ptr", HDC, "Ptr", RECT, "Ptr", Brush)
         DllCall("Gdi32.dll\DeleteObject", "Ptr", Brush)
         Txt := ODCtrl.Items[Item], Len := StrLen(Txt)
         TxC := ODCtrl.Colors[Item].HasKey("T") ? ODCtrl.Colors[Item].T : CtrlTxC
         NumPut(NumGet(RECT + 0, 0, "Int") + 2, RECT + 0, 0, "Int")
         DllCall("Gdi32.dll\SetBkMode", "Ptr", HDC, "Int", 1) ; TRANSPARENT
         DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", TxC)
         DllCall("User32.dll\DrawText", "Ptr", HDC, "Ptr", &Txt, "Int", Len, "Ptr", RECT, "UInt", DT_Flags)
         NumPut(NumGet(RECT + 0, 0, "Int") - 2, RECT + 0, 0, "Int")
         If (State & ODS_SELECTED)
            DllCall("User32.dll\DrawFocusRect", "Ptr", HDC, "Ptr", RECT)
         DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", CtrlTxC)
         Return True
      }
   }
}