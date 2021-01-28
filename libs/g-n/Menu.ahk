; ======================================================================================================================
; Namespace:      Menu
; Function:       Some functions related to AHK menus.
; Tested with:    AHK 1.1.14.03
; Tested on:      Win 8.1 Pro (x64)
; Changelog:
;     1.0.00.00/2014-03-26/just me - initial release
; General function parameters (not mentioned in the parameter description of functions):
;     HMENU       -  Handle to a menu or a menu bar.
;     ItemPos     -  1-based position of the menu item in the menu.
;     ItemName    -  Name (text string) of the menu item.
;     HWND        -  Handle to the window the menu is / will be assigned to.
; Credits:
;     Lexikos for MI.ahk (www.autohotkey.com/board/topic/20253-menu-icons-v2/) adopted in Menu_GetMenuByName().
; ======================================================================================================================
; BarHiliteItem   Adds or removes highlighting from an item in a menu bar.
; Parameters:     Hilite   -  Highlight the menu item (True / False).
;                             Default: True.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_BarHiliteItem(HWND, ItemPos, Hilite := True) {
   ; http://msdn.microsoft.com/en-us/library/ms647986(v=vs.85).aspx
   If (HMENU := Menu_GetMenu(HWND)) {
      Flags := 0x0400 | (Hilite ? 0x80 : 0x00)
      Return DllCall("User32.dll\HiliteMenuItem", "Ptr", HWND, "Ptr", HMENU, "UInt", ItemPos - 1, "UInt", Flags, "UInt")
   }
   Return False
}
; ======================================================================================================================
; BarRightJustify Right-justifies the menu item and any subsequent items in a menu bar.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_BarRightJustify(HWND, ItemPos) {
   ; http://msdn.microsoft.com/en-us/library/ms648001(v=vs.85).aspx
   Static MIIsize := (4 * 6) + (A_PtrSize * 6) + ((A_PtrSize - 4) * 2)
   If (HMENU := Menu_GetMenu(HWND)) {
      VarSetCapacity(MII, MIIsize, 0)              ; MENUITEMINFO structure
      NumPut(MIIsize, MII, 0, "UInt")              ; cbSize
      NumPut(0x0100, MII, 4, "UInt")               ; fMask: MIIM_FTYPE = 0x0100
      If DllCall("User32.dll\GetMenuItemInfo", "Ptr", HMENU, "UInt", ItemPos - 1, "UInt", 1, "Ptr", &MII, "UInt") {
         NumPut(NumGet(MII, 8, "UInt") | 0x4000, MII, 8, "UInt") ; fType: MFT_RIGHTJUSTIFY = 0x4000
         RC := DllCall("User32.dll\SetMenuItemInfo", "Ptr", HMENU, "UInt", ItemPos - 1, "UInt", 1, "Ptr", &MII, "UInt")
         DllCall("User32.dll\DrawMenuBar", "Ptr", HWND, "UInt")
         Return RC
      }
   }
   Return False
}
; ======================================================================================================================
; CheckRadioItem  Checks a specified menu item and makes it a radio item. At the same time, the function clears
;                 all other menu items in the associated group and clears the radio-item type flag for those items.
; Parameters:     First -  The 1-based position of the first menu item in the group.
;                          Default: 1 = first menu item.
;                 Last  -  The 1-based position of the last menu item in the group.
;                          Default: 0 = last menu item.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_CheckRadioItem(HMENU, ItemPos, First := 1, Last := 0) {
   ; http://msdn.microsoft.com/en-us/library/ms647621(v=vs.85).aspx
   If (Last < 1)
      Last := Menu_GetItemCount(HMENU)
   Return DllCall("User32.dll\CheckMenuRadioItem", "Ptr", HMENU, "UInt", First - 1, "UInt", Last - 1
                                                 , "UInt", ItemPos - 1, "UInt", 0x0400, "UInt")
}
; ======================================================================================================================
; GetItemCount    Determines the number of items in the specified menu.
; Return values:  If the function succeeds, the return value specifies the number of items in the menu.
;                 If the function fails, the return value is -1
; ======================================================================================================================
Menu_GetItemCount(HMENU) {
   ; http://msdn.microsoft.com/en-us/library/ms647978(v=vs.85).aspx
   Return DllCall("User32.dll\GetMenuItemCount", "Ptr", HMENU, "Int")
}
; ======================================================================================================================
; GetItemInfo     Retrieves information about a menu item.
; Return values:  If the function succeeds, the return value is an object containing the following keys:
;                       Type     -  The menu item type flags.
;                       State    -  The menu item state flags.
;                       ID       -  The application-defined value that identifies the menu item.
;                       HMENU    -  The handle to the submenu associated with the menu item, if exist.
;                       Name     -  The menu item text string , if any.
;                       HBITMAP  -  The handle to the bitmap to be displayed, if any.
;                 If the function fails, the return value is zero (False).
; ======================================================================================================================
Menu_GetItemInfo(HMENU, ItemPos) {
   ; http://msdn.microsoft.com/en-us/library/ms647980(v=vs.85).aspx
   Static MIIsize := (4 * 6) + (A_PtrSize * 6) + ((A_PtrSize - 4) * 2)
   Static MIIoffs := (A_PtrSize = 8) ? {Type: 8, State: 12, ID: 16, HMENU: 24, String: 56, cch: 64, HBITMAP: 72}
                                     : {Type: 8, State: 12, ID: 16, HMENU: 20, String: 36, cch: 40, HBITMAP: 44}
   VarSetCapacity(MII, MIIsize, 0)              ; MENUITEMINFO structure
   NumPut(MIIsize, MII, 0, "UInt")              ; cbSize
   NumPut(0x1EF, MII, 4, "UInt")                ; fMask
   VarSetCapacity(String, 1024, 0)
   NumPut(&String, MII, MIIoffs.String, "UPtr") ; dwTypeData
   NumPut(512, MII, MIIoffs.cch, "UInt")        ; cch
   If DllCall("User32.dll\GetMenuItemInfo", "Ptr", HMENU, "UInt", ItemPos - 1, "UInt", 1, "Ptr", &MII, "UInt")
      Return {Type: NumGet(MII, MIIoffs.Type, "UInt")
            , State: NumGet(MII, MIIoffs.State, "UInt")
            , ID: NumGet(MII, MIIoffs.ID, "UInt")
            , HMENU: NumGet(MII, MIIoffs.HMENU, "UPtr")
            , Name: StrGet(&String, NumGet(MII, MIIoffs.cch, "UInt"))
            , HBITMAP: NumGet(MII, MIIoffs.HBITMAP, "UPtr")}
   Return False
}
; ======================================================================================================================
; GetItemPos      Retrieves the position of the menu item specified by its name in the menu.
; Return values:  If the function succeeds, the return value is the 1-based position of the menu item.
;                 If the function fails, the return value is zero (False).
; ======================================================================================================================
Menu_GetItemPos(HMENU, ItemName) {
   Loop, % Menu_GetItemCount(HMENU)
      If (ItemName = Menu_GetItemName(HMENU, A_Index))
         Return A_Index
   Return False
}
; ======================================================================================================================
; GetItemState    Retrieves the state flags associated with the specified menu item.
; Return values:  If the specified item does not exist, the return value is -1.
;                 If the menu item opens a submenu, the low-order byte of the return value contains the menu flags,
;                 and the high-order byte contains the number of items in the submenu.
;                 Otherwise, the return value is a mask (Bitwise OR) of the menu flags.
; ======================================================================================================================
Menu_GetItemState(HMENU, ItemPos) {
   ; http://msdn.microsoft.com/en-us/library/ms647982(v=vs.85).aspx
   Return DllCall("User32.dll\GetMenuState", "Ptr", HMENU, "UInt", ItemPos - 1, "UInt", 0x0400, "UInt")
}
; ======================================================================================================================
; GetItemName     Retrieves the name (text string) of the specified menu item.
; Return values:  If the function succeeds, the return value is the text string of the specified menu item.
;                 Otherwise, the return value is an empty string.
; ======================================================================================================================
Menu_GetItemName(HMENU, ItemPos) {
   ; http://msdn.microsoft.com/en-us/library/ms647983(v=vs.85).aspx
   VarSetCapacity(Str, 1024, 0) ; should be sufficient
   If DllCall("User32.dll\GetMenuString", "Ptr", HMENU, "UInt", ItemPos - 1, "Str", Str, "Int", 512
                                        , "UInt", 0x0400, "Int")
      Return Str
   Return ""
}
; ======================================================================================================================
; GetMenu         Retrieves a handle to the menu assigned to the specified window.
; Return values:  The return value is a handle to the menu.
;                 If the specified window has no menu, the return value is NULL.
;                 If the window is a child window, the return value is undefined.
; ======================================================================================================================
Menu_GetMenu(HWND) {
   ; http://msdn.microsoft.com/en-us/library/ms647640(v=vs.85).aspx
   Return DllCall("User32.dll\GetMenu", "Ptr", HWND, "Ptr")
}
; ======================================================================================================================
; GetMenuByName   Retrieves a handle to the menu specified by its name.
; Return values:  If the function succeeds, the return value is a handle to the menu.
;                 Otherwise, the return value is zero (False).
; Remarks:        Based on MI.ahk by Lexikos -> http://www.autohotkey.com/board/topic/20253-menu-icons-v2/
; ======================================================================================================================
Menu_GetMenuByName(MenuName) {
   Static HMENU := 0
   If !(HMENU) {
      Menu, %A_ThisFunc%Menu, Add
      Menu, %A_ThisFunc%Menu, DeleteAll
      Gui, %A_ThisFunc%GUI:+HwndHGUI
      Gui, %A_ThisFunc%GUI:Menu, %A_ThisFunc%Menu
      HMENU := Menu_GetMenu(HGUI)
      Gui, %A_ThisFunc%GUI:Menu
      Gui, %A_ThisFunc%GUI:Destroy
   }
   If !(HMENU)
      Return 0
   Menu, %A_ThisFunc%Menu, Add, :%MenuName%
   HSUBM := Menu_GetSubMenu(HMENU, 1)
   Menu, %A_ThisFunc%Menu, Delete, :%MenuName%
   Return HSUBM
}
; ======================================================================================================================
; GetSubMenu      Retrieves a handle to the submenu activated by the specified menu item.
; Return values:  If the function succeeds, the return value is a handle to the submenu activated by the menu item.
;                 If the menu item does not activate a submenu, the return value is zero (False).
; ======================================================================================================================
Menu_GetSubMenu(HMENU, ItemPos) {
   ; http://msdn.microsoft.com/en-us/library/ms647984(v=vs.85).aspx
   Return DllCall("User32.dll\GetSubMenu", "Ptr", HMENU, "Int", ItemPos - 1, "Ptr")
}
; ======================================================================================================================
; IsItemChecked   Determines whether the specified menu item is checked.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_IsItemChecked(HMENU, ItemPos) {
   Return (Menu_GetItemState(HMENU, ItemPos) & 0x08) ; MF_CHECKED = 0x00000008
}
; ======================================================================================================================
; IsSeparator     Determines whether the specified menu item  is a separator.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_IsSeparator(HMENU, ItemPos) {
   Return (Menu_GetItemInfo(HMENU, ItemPos).Type & 0x0800) ; MFT_SEPARATOR = 0x00000800
}
; ======================================================================================================================
; IsSubmenu       Determines whether the specified menu item opens a submenu.
; Return values:  If the function succeeds, the return value is a handle to the submenu; otherwise, it is zero (False).
; ======================================================================================================================
Menu_IsSubmenu(HMENU, ItemPos) {
   Return Menu_GetItemInfo(HMENU, ItemPos).HMENU
}
; ======================================================================================================================
; RemoveCheckMarks Removes the space reserved for check marks from the specified menu.
; Parameters:     ApplyToSubMenus   -  Settings apply to the menu and all of its submenus (True / False).
;                                      Default: True.
; Return value:   Always True.
; ======================================================================================================================
Menu_RemoveCheckMarks(HMENU, ApplyToSubMenus := True) {
   ; http://msdn.microsoft.com/en-us/library/ff468864(v=vs.85).aspx
   Static MIsize := (4 * 4) + (A_PtrSize * 3)
   VarSetCapacity(MI, MIsize, 0)
   NumPut(MIsize, MI, 0, "UInt")
   NumPut(0x00000010, MI, 4, "UInt") ; MIM_STYLE = 0x00000010
   DllCall("User32.dll\GetMenuInfo", "Ptr", HMENU, "Ptr", &MI, "UInt")
   If (ApplyToSubMenus)
      NumPut(0x80000010, MI, 4, "UInt") ; MIM_APPLYTOSUBMENUS = 0x80000000 | MIM_STYLE = 0x00000010
   NumPut(NumGet(MI, 8, "UINT") | 0x80000000, MI, 8, "UInt") ; MNS_NOCHECK = 0x80000000
   DllCall("User32.dll\SetMenuInfo", "Ptr", HMENU, "Ptr", &MI, "UInt")
   Return True
}
; ======================================================================================================================
; ShowAligned     Displays a shortcut menu at the specified location using the specified alignment.
; Parameters:     X     -  The horizontal location of the shortcut menu, in screen coordinates.
;                 Y     -  The vertical location of the shortcut menu, in screen coordinates.
;                 Align -  Array containing one or a more of the keys defined in 'Alignment'.
; Return values:  If the function succeeds, the return value is nonzero; otherwise, it is zero (False).
; ======================================================================================================================
Menu_ShowAligned(HMENU, HWND, X, Y, XAlign, YAlign) {
   ; http://msdn.microsoft.com/en-us/library/ms648002(v=vs.85).aspx
   Static XA := {0: 0, 4: 4, 8: 8, LEFT: 0x00, CENTER: 0x04, RIGHT: 0x08}
   Static YA := {0: 0, 16: 16, 32: 32, TOP: 0x00, VCENTER: 0x10, BOTTOM: 0x20}
   If !XA.HasKey(XAlign) || !YA.HasKey(YAlign)
      Return False
   Flags := XA[XAlign] | YA[YAlign]
   Return DllCall("User32.dll\TrackPopupMenu", "Ptr", HMENU, "UInt", Flags, "Int", X, "Int", Y, "Int", 0, "Ptr", HWND
                                             , "Ptr", 0, "UInt")
}
; ======================================================================================================================