; Link:   	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

Menu_SetBitmapItem(HMENU, ItemPos, HBITMAP) { ; ItemPos is 1-based
   ID := DllCall("GetMenuItemID", "Ptr", HMENU, "Int", ItemPos - 1, "Int")
   If (ID = -1)
      ID := DllCall("GetSubMenu", "Ptr", HMENU, "Int", ItemPos - 1, "UPtr")
   If (ID)
      Return DllCall("ModifyMenu", "Ptr", HMENU, "UInt", ItemPos - 1, "UInt", 0x0404, "Ptr", ID, "Ptr", HBITMAP, "UInt")
   Return False
}
