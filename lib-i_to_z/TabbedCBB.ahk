; ======================================================================================================================
; TabbedCBB       	Draws tabbed text in ComboBoxes and DropDownLists.
; Author:         		just me -> http://ahkscript.org/boards/viewtopic.php?f=5&t=4263&p=24051#p24051
; Link: 					https://autohotkey.com/boards/viewtopic.php?t=4344
; Tested on:      		WIn 8.1 Pro x64
; Tested with:    	AHK 1.1.15.04 (A32/U32/U64)
; ======================================================================================================================
; Register ComboBox/DDL controls for tabbed text drawing.
; Parameters:
;     HWND     -  the HWND of the control.
;     Tabs*    -  zero or more integer values specifying ascending tab positions in dialog units.
;                 If omitted, tabs are expanded to eight times the average character width (32 dialog units).
;                 If only one parameter is passed, the tabs are separated by the distance specified by the this value.
;                 Otherwise, a tab stop is set for each value.
;                 (see also: http://ahkscript.org/docs/commands/GuiControls.htm#ListBox_Options -> Tn)
; Return values:  True on success, otherwise False.
; ======================================================================================================================
TabbedCBB_Controls(HWND, Tabs*) {
   Static Controls := {}
   If (HWND = "Get")
      Return Controls[Tabs.1]
   If DllCall("User32.dll\IsWindow", "Ptr", HWND, "UInt") {
      Obj := {}
      HDC := DllCall("User32.dll\GetDC", "Ptr", HWND, "UPtr")
      Obj.BC := DllCall("Gdi32.dll\GetBkColor", "Ptr", HDC, "UInt")
      Obj.TC := DllCall("Gdi32.dll\GetTextColor", "Ptr", HDC, "UInt")
      DllCall("User32.dll\ReleaseDC", "Ptr", HWND, "Ptr", HDC)
      If ((TabsCount := Tabs.MaxIndex()) = "") {
         Obj.TabsCount := 0
         Obj.TabsAddr := 0
      }
      Else {
         Obj.TabsCount := TabsCount
         Obj.SetCapacity("TabsArray", TabsCount * 4)
         Addr := Obj.GetAddress("TabsArray")
         Obj.TabsAddr := Addr
         PrevTab := 0
         For Each, Tab In Tabs
            Addr := NumPut(Tab, Addr + 0, "UInt")
      }
      Controls[HWND] := Obj
      Return True
   }
   Return False
}
; ======================================================================================================================
TabbedCBB_DrawItem(wParam, lParam) {
   ; ----------------------------------------------------------------------------------------------------------------
   ; Sent to the parent window of an owner-drawn ListBox or ComboBox when a visual aspect of the control has changed.
   ; WM_DRAWITEM         -> http://msdn.microsoft.com/en-us/library/bb775923(v=vs.85).aspx
   ; DRAWITEMSTRUCT      -> http://msdn.microsoft.com/en-us/library/bb775802(v=vs.85).aspx
   ; ----------------------------------------------------------------------------------------------------------------
   ; lParam / DRAWITEMSTRUCT offsets
   Static offItem := 8, offAction := offItem + 4, offState := offAction + 4, offHWND := offState + A_PtrSize
        , offDC := offHWND + A_PtrSize, offRECT := offDC + A_PtrSize, offData := offRECT + 16
   ; Owner Draw Type
   Static ODT_COMBOBOX := 3
   ; Owner Draw Action
   Static ODA_DRAWENTIRE := 0x0001, ODA_SELECT := 0x0002, ODA_FOCUS := 0x0004
   ; Owner Draw State
   Static ODS_SELECTED := 0x0001, ODS_FOCUS := 0x0010 , ODS_COMBOBOXEDIT := 0x1000
   ; Selection colors
   Static SBC := DllCall("User32.dll\GetSysColor", "Int", 13, "UInt")
   Static STC := DllCall("User32.dll\GetSysColor", "Int", 14, "UInt")
   ; Call OnMessage() automatically
   Static Init := OnMessage(0x2B, "TabbedCBB_DrawItem") ; WM_DRAWITEM
   ; ----------------------------------------------------------------------------------------------------------------
   Critical ; may help in case of drawing issues
   If (NumGet(lParam + 0, 0, "UInt") = ODT_COMBOBOX)
   && (HWND := NumGet(lParam + offHWND, 0, "UPtr"))
   && IsObject(ODDL := TabbedCBB_Controls("Get", HWND))
   && (Action := NumGet(lParam + offAction, 0, "UInt") <> ODA_FOCUS) {
      ; Get the DRAWITEMSTRUCT fields
      Item := NumGet(lParam + offItem, 0, "Int")
      State := NumGet(lParam + offState, 0, "UInt")
      HDC := NumGet(lParam + offDC, 0, "UPtr")
      RECT := lParam + offRECT
      ; Background & text colors
      If (State & ODS_SELECTED) ; } || (State & ODA_FOCUS)
         BC := SBC, TC := STC
      Else
         BC := ODDL.BC, TC := ODDL.TC
      ; Fill the item's background
      Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BC, "UPtr")
      DllCall("User32.dll\FillRect", "Ptr", HDC, "Ptr", RECT, "Ptr", Brush)
      DllCall("Gdi32.dll\DeleteObject", "Ptr", Brush)
      ; Set the text colors
      PBC := DllCall("Gdi32.dll\SetBkColor", "Ptr", HDC, "UInt", BC)
      PTC := DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", TC)
      ; Get the item text
      SendMessage, 0x0149, % Item, 0, , % "ahk_id " . HWND ; CB_GETLBTEXTLEN
      Len := ErrorLevel
      VarSetCapacity(Txt, Len << !!A_IsUnicode, 0)
      SendMessage, 0x0148, % Item, &Txt, , % "ahk_id " . HWND ; CB_GETLBTEXT
      VarSetCapacity(Txt, -1)
      ; Adjust the text position, if necessary
      If !(State & ODS_COMBOBOXEDIT)
         NumPut(NumGet(RECT + 0, 0, "Int") + 2, RECT + 0, 0, "Int")
      X := NumGet(RECT + 0, "Int"), Y := NumGet(RECT + 4, "Int")
      ; Draw the tabbed text
      DllCall("User32.dll\TabbedTextOut", "Ptr", HDC, "Int", X, "Int", Y, "Str", Txt, "Int", Len
                                        , "Int", ODDL.TabsCount, "Ptr", ODDL.TabsAddr, "Int", X)
      ; Restore the text colors, if necessary
      If (State & ODS_SELECTED) {
         DllCall("Gdi32.dll\SetBkColor", "Ptr", HDC, "UInt", PBC)
         DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", PTC)
      }
      Return True
   }
}
; ======================================================================================================================
TabbedCBB_MeasureItem(wParam, lParam := "", Msg := "", Hwnd := 0) {
   ; -------------------------------------------------------------------------------------------------------------------
   ; Sent once to the parent window of an OWNERDRAWFIXED ListBox or ComboBox when an the control is being created.
   ; When the owner receives this message, the system has not yet determined the height and width of the font used
   ; in the control. That is why ItemHeight must be set to an appropriate value before the control will be created
   ; created by 'Gui, Add, ...'. To do that, call TabbedCBB_MeasureItem passing the following parameters:
   ;     wParam   -  "SetItemHeight",
   ;     lParam   -  the font options used in 'Gui, Font, ...' as string, otherwise "",
   ;     Msg      -  the font name used in 'Gui, Font, ...' as string, otherwise "".
   ; WM_MEASUREITEM      -> http://msdn.microsoft.com/en-us/library/bb775925(v=vs.85).aspx
   ; MEASUREITEMSTRUCT   -> http://msdn.microsoft.com/en-us/library/bb775804(v=vs.85).aspx
   ; -------------------------------------------------------------------------------------------------------------------
   ; lParam -> MEASUREITEMSTRUCT offsets
   Static offHeight := 16
   ; Owner Draw Type
   Static ODT_COMBOBOX := 3
   ; Others
   Static ItemHeight := 0
   ; Call OnMessage() automatically
   Static Init := OnMessage(0x2C, "TabbedCBB_MeasureItem") ; WM_MEASUREITEM
   ; -------------------------------------------------------------------------------------------------------------------
   If (wParam = "SetItemHeight") {
      Gui, TabbedCBB_MeasureItemGUI:Font, %lParam%, %Msg%
      Gui, TabbedCBB_MeasureItemGUI:Add, Text, 0x200 hwndHTX, Dummy
      VarSetCapacity(RECT, 16, 0)
      DllCall("User32.dll\GetClientRect", "Ptr", HTX, "Ptr", &RECT)
      Gui, TabbedCBB_MeasureItemGUI:Destroy
      Return (ItemHeight := NumGet(RECT, 12, "Int"))
   }
   If (NumGet(lParam + 0, 0, "UInt") = ODT_COMBOBOX) && (ItemHeight) {
      NumPut(ItemHeight, lParam + 0, offHeight, "Int")
      Return True
   }
   Return False
}