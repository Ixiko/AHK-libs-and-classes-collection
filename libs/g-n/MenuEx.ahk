MENU(hWnd) {

	;Link: https://autohotkey.com/board/topic/52343-make-this-control-transparent/

	  hMenu :=DllCall("GetMenu","UInt",hWnd)
	  If hMenu=0
	  {
			hMenu :=DllCall("CreateMenu")
			DllCall("SetMenu","UInt",hWnd,"UInt",hMenu)
			uFlags	:=0x1 | 0x4000 ;MF_BITMAP:=0x0004 MF_MENUBREAK:=0x40 MF_GRAYED:=0x1 MF_RIGHTJUSTIFY:=0x4000 MF_OWNERDRAW:=0x0100
			new		:=1
	  }
	  Else
	  {
			uFlags	:=0x40 | 0x1 | 0x4000 ;MF_BITMAP:=0x0004 MF_MENUBREAK:=0x40 MF_GRAYED:=0x1 MF_RIGHTJUSTIFY:=0x4000 MF_OWNERDRAW:=0x0100
			new		:=0
	  }
	  lpNewItem:=applicationname
	  VarSetCapacity(uIDNewItem,4,1)
	  DllCall("AppendMenu", UInt, hMenu, UInt, uFlags, UInt, &uIDNewItem, STR, lpNewItem)
	  DllCall("DrawMenuBar",UInt,hWnd)

Return,%new%
}

GetMenuBarInfo(hwnd, idObject, xx, yy) {

	;Link: https://autohotkey.com/board/topic/52343-make-this-control-transparent/
	;dependencies: ExtractInteger

	DllCall("GetMenuBarInfo", Int,hWnd, Int,0xFFFFFFFD, Int, 0, Int,&pbmi)    ;idObject=OBJID_MENU  ;idItem

	rcBar_left  		:=ExtractInteger(pbmi,4,False)
	rcBar_top   		:=ExtractInteger(pbmi,8,False)
	rcBar_right 		:=ExtractInteger(pbmi,12,False)
	rcBar_bottom	:=ExtractInteger(pbmi,16,False)

}

TrackPopupMenu(Menu, hCtl, hWnd, Flags := 0x8) {
    ; 0x8 = TPM_TOPALIGN | TPM_RIGHTALIGN
    WingetPos wx, wy, ww, wh, ahk_id %hWnd%
    ControlGetPos cx, cy, cw, ch,, ahk_id %hCtl%
    x := wx + cx + cw
    y := wy + cy + ch
    hMenu := MenuGetHandle(Menu)
    DllCall("TrackPopupMenu", "Ptr", hMenu, "UInt", Flags, "Int", x, "Int", y, "Int", 0, "Ptr", hWnd, "Ptr", 0)
}