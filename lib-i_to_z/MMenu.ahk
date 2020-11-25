/* =========================================================================
	developed here by majkinetor:
    http://www.autohotkey.com/board/topic/16248-module-mmenu-10-b1/#entry

	The original file was modified as follows for this toolbar:
	Line 700 (now commented out) was replaced by line 701 (to remove the space for the checkmark) according to Lexikos' instructions in post 120.

	MMenu													by Miodrag Milic
													 miodrag.milic@gmail.com
	Interface
	---------

	MMenu_Create	( [options] )
	MMenu_Destroy	( menu )

	MMenu_Add		( menu [,title, icon, position, options ])
	MMenu_Set		( menu, item, title [,icon, options] )
	MMenu_Remove	( menu, item )

	MMenu_Show		( menu, X, Y, OnClick [,OnSelect, OnInit, OnUninit ])
	MMenu_Hide		()
	MMenu_About		()

	MMenu_Count		 ( menu )
	MMenu_GetPosition(pMenu, ByRef X, ByRef Y) {


	See documentation, in MMenu.htm for more details

============================================================================
*/

MMenu_Create( pOptions="" ) {
	local menu, hMenu

	;Menu info is kept in the MMenu_aMenu array
	;MMenu_aMenu[0] keeps the number of menus

	MMenu_aMenu[0]++
	menu := MMenu_aMenu[0]

	;Create the menu and associate its handle.
	hMenu := API_CreatePopUpMenu()
	if hMenu < 0		;convert to unsigned integer
		hMenu += 4294967296
	MMenu_aMenu[%menu%] := hMenu
	MMenu_aHandles[%hMenu%] := menu

	MMenu_parseMenuOptions( menu, pOptions )


	MMenu_setMaxHeight(menu)
	MMenu_setBackground(menu)

	return menu
}

MMenu_Count( pMenu ) {
	return API_GetMenuItemCount( MMenu_aMenu[%pMenu%] )
}

;------------------------------------------------------------------------

MMenu_Destroy( pMenu ) {
	local hMenu := MMenu_aMenu[%pMenu%]
	API_DestroyMenu( hMenu )

	MMenu_freeMenu( pMenu)
}

MMenu_GetPosition(pMenu, ByRef X, ByRef Y, pSelection=false) {
	local hMenu := MMenu_aMenu[%pMenu%]
	local res := 1
	local item

	item = 0
	if (pSelection)
		loop, % API_GetMenuItemCount(hMenu)
			if API_GetMenuState( hMenu, A_Index-1, 0x400) & 0x80     ;MF_HILITE= 0x80
			{
				item := A_Index-1
				break
			}

	RECT_Set("MMenu_rect")
	res := DllCall("GetMenuItemRect", "uint", 0, "uint", hMenu, "uint", item, "uint", &MMenu_rect_c)
	RECT_Get("MMenu_rect")

	X := MMenu_rect_left
	Y := MMenu_rect_top

	return %res%
}

;-----------------------------------------------------------------------------
; Add new menu item with specified attributes above pItem
; If pItem doesn't exist, or if it equals to 0, the new item will be appended
;
; Returns false if pMenu is invalid or true if item is added.
MMenu_Add( pMenu, pTitle="", pIcon="", pItem=0, pOptions="" ) {
	local hMenu := MMenu_aMenu[%pMenu%]
	local idx, res
	static sID

	if (hMenu = "")
		return 0				;ERR_MENU

	sID++

	if (pIcon . pTitle . pOptions . pItem = 0)	;check for separator
		pOptions := "s"

	;set the item data
	MMenu_aItem[%sID%]_parent := pMenu
	MMenu_aItem[%sID%]_title  := pTitle

	;get item
	idx := MMenu_getItemIdx( pMenu, pItem )
	res := API_InsertMenu(hMenu, idx, 0x0, sID, &pTitle)  ;MF_BYCOMMAND = 0x0

	;set icon
	MMenu_setItemIcon(pMenu, sID, pIcon)

	;set item options
	MMenu_setItemOptions( pMenu, sID, pOptions )

	MMenu_aItem[0] := sID
	return res
}

;------------------------------------------------------------------------

MMenu_Set( pMenu, pItem, pTitle="", pIcon="", pOptions="" ){
	local hMenu := MMenu_aMenu[%pMenu%]
	local idx := MMenu_getItemIdx( pMenu, pItem )
	local r	:= 1


	if !idx				;if invalid item
		return 0

	if (hMenu = "")
		return 0

	if (pTitle != "")
	{
		if (pTitle = " ")
			pTitle =

		r := MMenu_setItemTitle(pMenu, idx, pTitle)
	}

	if (pIcon != "") {
		if (pIcon = " ")
			pIcon =
		r := MMenu_setItemIcon(pMenu, idx, pIcon) AND r

	}

	if (pOptions != "")
		r := MMenu_setItemOptions( pMenu, idx, pOptions ) AND r

	return r ? 1 : 0
}

;- - - - - - - - - - - - - - - -

MMenu_setItemTitle(pMenu, pIdx, pTitle) {
	local hMenu := MMenu_aMenu[%pMenu%]

	MMenu_aItem[%pIdx%]_title := pTitle

	MMenu_mii_fMask := 0x40				;MIIM_STRING
	MMenu_mii_dwTypeData := &pTitle
	MMenu_mii_cch := StrLen(pTitle)

	MENUITEMINFO_Set("MMenu_mii")
 	return, API_SetMenuItemInfo(hMenu, pIdx, false, &MMenu_mii )
}

;- - - - - - - - - - - - - - - -
; Should set for picon="" too
;
MMenu_setItemIcon(pMenu, pIdx, pIcon) {
	local hMenu		:= MMenu_aMenu[%pMenu%]
	local iconSize	:= MMenu_aMenu[%pMenu%]_iconSize
	local sub		:= MMenu_aItem[%pIdx%]_submenu
	local hSub		:= MMenu_aMenu[%sub%]
	local res := 1

	;remove old icon
	;if (MMenu_aItem[%pIdx%]_separator)

	if (MMenu_aItem[%pIdx%]_hIcon != "")
		MMenu_destroyIcon( MMenu_aItem[%pIdx%]_hIcon )

	MMenu_aItem[%pIdx%]_icon := pIcon
	if pIcon is number
		 MMenu_aItem[%pIdx%]_hIcon := MMenu_mii_dwItemData := pIcon
	else MMenu_aItem[%pIdx%]_hIcon := MMenu_mii_dwItemData := MMenu_loadIcon(pIcon, iconSize)



	if (MMenu_mii_dwItemData != 0)
		 MMenu_aMenu[%pMenu%]_hasIcons := true
	else res := 0


	MMenu_mii_fMask		:= 0x80 | 0x20	;MIIM_BITMAP | MIIM_DATA
	MMenu_mii_hbmpItem	:= -1
	MENUITEMINFO_Set("MMenu_mii")
	res := API_SetMenuItemInfo(hMenu, pIdx, false, &MMenu_mii) & res

	return res
}

;- - - - - - - - - - - - - - - -

MMenu_setItemOptions(pMenu, pIdx, pOptions) {
	local hMenu := MMenu_aMenu[%pMenu%], sub

	;parse options
	MMenu_parseItemOptions(pIdx, pOptions, pMenu)

	;get previous item state
	MMenu_mii_fMask := 0x1	;MMenu_miiM_STATE
	MENUITEMINFO_Set("MMenu_mii")
	API_GetMenuItemInfo(hMenu, pIdx, false, &MMenu_mii )
	MENUITEMINFO_Get("MMenu_mii")


;TYPE OPTIONS, only one at the time can be set
	if (MMenu_aItem[%pIdx%]_separator)
		 MMenu_mii_fType :=  0x800				;MFT_SEPARATOR

	else if (MMenu_aItem[%pIdx%]_break)
			MMenu_mii_fType := 	MMenu_aItem[%pIdx%]_break = 2 ? 0x20 : 0x40		;MFT_MENUBARBREAK :	MFT_MENUBREAK

		 else MMenu_mii_fType := 0


;STATE OPTIONS, more can be set
	if (MMenu_aItem[%pIdx%]_grayed)
		 MMenu_mii_fState |= 0x3		;MFS_GRAYED
	else MMenu_mii_fState &= ~0x3

	if (MMenu_aItem[%pIdx%]_check)
		 MMenu_mii_fState |= 0x8		;MFS_CHECKED
	else MMenu_mii_fState &= ~0x8

	if (MMenu_aItem[%pIdx%]_default)
		 MMenu_mii_fState |= 0x1000	    ;MFS_DEFAULT
	else MMenu_mii_fState &= ~0x1000


;SUBMENU OPTION
	sub  := MMenu_aItem[%pIdx%]_submenu
	if (sub != "") {
		 MMenu_mii_hSubmenu := MMenu_aMenu[%sub%]
		 MMenu_aMenu[%sub%]_parent := pMenu			;!!! if the user adds the same submenu into menu multiple times... who cares
	}
 	else MMenu_mii_hSubmenu := 0


	;set type options
	MMenu_mii_fMask := 0x100			;MIIM_FTYPE
	MENUITEMINFO_Set("MMenu_mii")
	API_SetMenuItemInfo(hMenu, pIdx, false, &MMenu_mii )

	;set state options
	MMenu_mii_fMask := 0x1	;MIIM_STATE
	MENUITEMINFO_Set("MMenu_mii")
 	API_SetMenuItemInfo(hMenu, pIdx, false, &MMenu_mii )

	;set submenu options
	MMenu_mii_fMask := 0x4				;MIIM_SUBMENU = 0x4
	MENUITEMINFO_Set("MMenu_mii")
 	API_SetMenuItemInfo(hMenu, pIdx, false, &MMenu_mii )

	return 1
}


;------------------------------------------------------------------------
; return false on failure, true on succes
MMenu_Remove( pMenu, pItem=0 ) {
	local hMenu := MMenu_aMenu[%pMenu%]
	local idx := MMenu_getItemIdx( pMenu, pItem )
	local res

 	res := API_RemoveMenu(hMenu, idx, 0x0)		;MF_BYCOMMAND=0x0
	MMenu_freeItem( idx )

	return res
}

;------------------------------------------------------------------------
; returns items internal id, or 0 on failure
;
MMenu_getItemIdx( pMenu, pItem ) {


	if InStr(pItem, A_Space, false, 0)	{
		StringTrimRight, pItem, pItem, 1
		return MMenu_findItemByTitle( pMenu, pItem)
	}

	if pItem is integer
		 return MMenu_findItemByPos( pMenu, pItem )
    else return MMenu_findItemByID( pMenu, pItem )
}

;------------------------------------------------------------------------
; return 0 on failure
MMenu_findItemByID( pMenu, pID ) {
	local res

	res := MMenu_aID[%pID%]
	if res =
		return 0

	return res
}

;- - - - - - - - - - - - - - - -
; return 0 on failure
MMenu_findItemByTitle( pMenu, pTitle ) {
	local hMenu := MMenu_aMenu[%pMenu%]
	local cnt := API_GetMenuItemCount(hMenu)
	local buf

	if pTitle =
		return 0

	VarSetCapacity(buf, 512)
	loop, %cnt%
	{
	  	 DllCall("GetMenuString", "uint", hMenu, "uint", A_Index-1, "str", buf, "uint", 512, "uint", 0x400) ;MF_BYPOSITION = 0x400
		 if (buf = pTitle)
			return MMenu_GetMenuItemID(hMenu, A_Index-1)
	}

	return 0
}

;- - - - - - - - - - - - - - - -
; return 0 on failure
MMenu_findItemByPos( pMenu, pPos ) {
	local hMenu := MMenu_aMenu[%pMenu%]
	local cnt := API_GetMenuItemCount(hMenu)
	local res

	if pPos <= 0
		return 0

	if pPos > cnt
		return 0

	res := MMenu_GetMenuItemID(hMenu, --pPos)
	if res = -1
		return 0

	return res

}

;this works for submenus too. Original OS function returns -1 for submenus.
MMenu_getMenuItemID(hMenu, pos){
	global

	MMenu_mii_fMask := 0x2				;MIIM_ID
	MMenu_mii_wID := 0
	MENUITEMINFO_Set("MMenu_mii")
	API_GetMenuItemInfo(hMenu, pos, true, &MMenu_mii )
	MENUITEMINFO_Get("MMenu_mii")

	return MMenu_mii_wID
}

;------------------------------------------------------------------------

MMenu_freeMenu( pMenu ){
	local hMenu := abs(MMenu_aMenu[%pMenu%])
	local sub

	loop,%MMenu_aItem[0]%
		if (MMenu_aItem[%A_Index%]_parent = pMenu)
		{
			sub := MMenu_aItem[%A_Index%]_submenu
			if ( sub != "")
				MMenu_freeMenu( sub )

			MMenu_freeItem( A_Index )
		}

	MMenu_aMenu[%pMenu%]			=
	MMenu_aMenu[%pMenu%]_iconSize	=
	MMenu_aMenu[%pMenu%]_textOffset =
	MMenu_aMenu[%pMenu%]_maxHeight	=
	MMenu_aMenu[%pMenu%]_hasIcons	=
	MMenu_aMenu[%pMenu%]_color		=
	MMenu_aMenu[%pMenu%]_text		=
	MMenu_aMenu[%pMenu%]_parent		=
	MMenu_aHandles[%hMenu%]			=
}

;- - - - - - - - - - - - - - - -

MMenu_freeItem(pIdx){
	local id :=	MMenu_aItem[%pIdx%]_ID

	if (MMenu_aItem[%pIdx%]_hIcon != "")
		MMenu_destroyIcon( MMenu_aItem[%pIdx%]_hIcon )


	MMenu_aItem[%pIdx%]_hIcon	 =
	MMenu_aItem[%pIdx%]_title	 =
	MMenu_aItem[%pIdx%]_icon	 =
 	MMenu_aItem[%pIdx%]_ID		 =
	MMenu_aItem[%pIdx%]_iconSize =
	MMenu_aItem[%pIdx%]_parent	 =
	MMenu_aItem[%pIdx%]_submenu	 =
	MMenu_aItem[%pIdx%]_break	 =

	MMenu_aID[%id%]	=
}

;------------------------------------------------------------------------
MMenu_Hide(){
	DllCall("EndMenu", "uint", MMenu_hParent)
}


MMenu_parseHandlers( pOptions  ){
	local c, token

	MMenu_userInit	:= 	MMenu_userUninit := MMenu_userSelect := ""
	MMenu_userMiddle := MMenu_userRight := MMenu_userMenuChar := ""

	Loop, Parse, pOptions, %A_Space%
	{
		StringLeft c, A_LoopField, 1
		StringTrimLeft token, A_LoopField, 1

		if (c="S") {
			MMenu_userSelect := token
			continue
		}

		if (c="I") {
			MMenu_userInit	:= token
			continue
		}
		if (c="U") {
			MMenu_userUninit	:= token
			continue
		}
		if (c="M") {
			MMenu_userMiddle := token
			continue
		}
		if (c="R") {
			MMenu_userRight	:= token
		}

		if (c="C") {
			MMenu_userMenuChar := token
		}
	}

}


MMenu_Show( pMenu, pX, pY, pOnClick, pHandlers="") {
	local hMenu := MMenu_aMenu[%pMenu%], itemID

	MMenu_parseHandlers(pHandlers)

	if MMenu_hParent =
	{
		Gui 77:+LastFound +ToolWindow
		MMenu_hParent := WinExist()
	}
	Gui 77:Show, ;x0 y0 w100 h100 noactivate

	MMenu_MsgMonitor(true)
	itemID := API_TrackPopupMenu( hMenu, 0x100, pX, pY, MMenu_hParent) ;TPM_RETURNCMD = 0x100
	MMenu_MsgMonitor(false)
	Gui 77:Hide

;	A_LastError=1401 -invalid menu handle

	;if menu is canceled, return
	if itemID = 0
		return


	M_Title		:= MMenu_aItem[%itemID%]_title
	M_ID		:= MMenu_aItem[%itemID%]_ID
	M_Menu		:= MMenu_aItem[%itemID%]_parent

	GoSub %pOnClick%
}

;------------------------------------------------------------------------

MMenu_parseMenuOptions( pMenu, pOptions ){
	local c, token

	;defaults
	MMenu_aMenu[%pMenu%]_iconSize := 32
	MMenu_aMenu[%pMenu%]_textOffset := 5
	MMenu_aMenu[%pMenu%]_color := 0xFFFFFF
	MMenu_aMenu[%pMenu%]_text  := 0

	Loop, Parse, pOptions, %A_Space%
	{
		StringLeft c, A_LoopField, 1
		StringTrimLeft token, A_LoopField, 1

		;icon size
		if (c="S")	{
			MMenu_aMenu[%pMenu%]_iconSize := token
			continue
		}

		if (c="O")	{
			MMenu_aMenu[%pMenu%]_textOffset := token
			continue
		}

		if (c="H")	{
			if token < 100
				token := 100

			MMenu_aMenu[%pMenu%]_maxHeight := token
			continue
		}

		if (c="C")	{
			MMenu_aMenu[%pMenu%]_color := "0x" token
			continue
		}

		if (c="T")	{
			MMenu_aMenu[%pMenu%]_text := "0x" token
			continue
		}
	}
}

;------------------------------------------------------------------------

MMenu_setMaxHeight( pMenu ) {
	local  hMenu := MMenu_aMenu[%pMenu%]

	MMenu_mi_fMask	:= 0x1		;MIM_MAXHEIGHT
	MMenu_mi_cyMax	:= MMenu_aMenu[%pMenu%]_maxHeight

	MENUINFO_Set("MMenu_mi")
	API_SetMenuInfo( hMenu, &MMenu_mi )
}

;- - - - - - - - - - - - - - - -

MMenu_parseItemOptions( idx, pOptions, pMenu  )
{
	local c, token, bRemove

	;default values
	MMenu_aItem[%idx%]_color := MMenu_aMenu[%pMenu%]_text

    Loop, Parse, pOptions, %A_Space%, +
	{
		StringLeft c, A_LoopField, 1
		StringTrimLeft token, A_LoopField, 1

		if (c="-") {
			bRemove := true
			c := chr(*&token)
		}

		if (c="I")	{
			MMenu_aItem[%idx%]_id := token
			MMenu_aID[%token%] := idx
			continue
		}

		if (c="S")	{
			MMenu_aItem[%idx%]_separator:= bRemove ?  "" : true
			continue
		}

		if (c="D")	{
			MMenu_aItem[%idx%]_default	:= bRemove ?  "" : true
			continue
		}

		if (c="B")	{
			MMenu_aItem[%idx%]_break	:= bRemove ?  "" : (token = "" ? 1 : 2)
			continue
		}

		if (c="G")	{
			MMenu_aItem[%idx%]_grayed	:= bRemove ?  false : true
			continue
		}

		if (c="M")	{
			MMenu_aItem[%idx%]_submenu	:= bRemove ?  "" : token
			continue
		}

		if (c="C")	{
			MMenu_aItem[%idx%]_check	:= bRemove ?  "" : true
			continue
		}

		if (c="T")	{
			MMenu_aItem[%idx%]_color	:= bRemove ?  MMenu_aMenu[%pMenu%]_text  : "0x" token
			continue
		}
	}
}

;------------------------------------------------------------------------
MMenu_msgMonitor( on ){
	local WM_MENUSELECT		= 0x11F
	local WM_MEASUREITEM	= 0x2C
	local WM_DRAWITEM		= 0x2B
	local WM_ENTERMENULOOP	= 0x211
	local WM_INITMENUPOPUP	= 0x117
	local WM_UNINITMENUPOPUP= 0x125
	local WM_MENUSELECT		= 0x11F
	local WM_EXITMENULOOP	= 0x212
	local WM_MENUCOMMAND	= 0x126
	local WM_CONTEXTMENU	= 0x7b
	local WM_MBUTTONDOWN	= 0x207
	local WM_MENUCHAR		= 0x120



	static oldMeasure, oldDraw, oldrbutton, oldMButton, oldMenuChar

	if (on)	{
						OnMessage(WM_ENTERMENULOOP, "MMenu_OnEnterLoop")
		oldMeasure	:=  OnMessage(WM_MEASUREITEM,	"MMenu_OnMeasure")
		oldDraw		:=  OnMessage(WM_DRAWITEM,		"MMenu_OnDraw")

						OnMessage(WM_MENUSELECT,    "MMenu_OnSelect")
						OnMessage(WM_INITMENUPOPUP, "MMenu_OnInit")
						OnMessage(WM_UNINITMENUPOPUP,"MMenu_OnUninit")
		oldrbutton	:=	OnMessage(WM_CONTEXTMENU,	"MMenu_OnRButtonDown")
		oldMbutton	:=	OnMessage(WM_MBUTTONDOWN,	"MMenu_OnMButtonDown")
		oldMenuChar :=	OnMessage(WM_MENUCHAR,	"MMenu_OnMenuChar")
	}
	else {
		OnMessage(WM_ENTERMENULOOP)
		OnMessage(WM_MEASUREITEM,	oldMeasure)
		OnMessage(WM_DRAWITEM,		oldDraw)
		OnMessage(WM_INITMENUPOPUP)
		OnMessage(WM_MENUSELECT)
		OnMessage(WM_EXITMENULOOP)
		OnMessage(WM_UNINITMENUPOPUP)
		OnMessage(WM_CONTEXTMENU, oldrbutton)
		OnMessage(WM_MBUTTONDOWN, oldMbutton)
		OnMessage(WM_MENUCHAR,	oldMenuChar)
	}
}

;--------------------------------------------------------------------------------

MMenu_onEnterLoop(){
	return 1
}

;- - - - - - - - - - - - - - - -
;MIM_BACKGROUND = 2
MMenu_setBackground(pmenu){
	local  hMenu := MMenu_aMenu[%pMenu%]

	MMenu_mi_fMask	 := 0x2		;MIM_MAXHEIGHT
	MMenu_mi_hbrBack := API_CreateSolidBrush( MMenu_aMenu[%pMenu%]_color )

	MENUINFO_Set("MMenu_mi")
	API_SetMenuInfo( hMenu, &MMenu_mi )

}

MMenu_onDraw(wparam, lparam){
	local clr, mnu, obj

	DRAWITEM_GetA("MMenu_di", lparam)
	if !MMenu_aItem[%MMenu_di_itemID%]_grayed
	{
		obj := API_SelectObject( MMenu_di_hDC, API_CreateSolidBrush( MMenu_aItem[%MMenu_di_itemID%]_color ) )
		API_DeleteObject(obj)
		API_SetTextColor(MMenu_di_hDC, MMenu_aItem[%MMenu_di_itemID%]_color)
	}

	;API_DrawIconEx(MMenu_di_hDC, (API_GetMenuCheckMarkDimensions() & 0xFFFF) + 4, MMenu_di_rcItem_Top, MMenu_di_itemData, 0, 0, 0, 0, 3) ;MMenu_di_NORMAL=3	  = MMenu_di_MASK | MMenu_di_IMAGE (1 | 2)
	API_DrawIconEx(MMenu_di_hDC,  4, MMenu_di_rcItem_Top, MMenu_di_itemData, 0, 0, 0, 0, 3) ;MMenu_di_NORMAL=3	  = MMenu_di_MASK | MMenu_di_IMAGE (1 | 2)
	return 1
}




MMenu_setMenuStyle( pMenu, dwStyle ) {
	local  hMenu := MMenu_aMenu[%pMenu%]

	MMenu_mi_fMask		:= 0x10		;MIM_STYLE
	MMenu_mi_dwStyle	:= dwStyle

	MENUINFO_Set("MMenu_mi")
	API_SetMenuInfo( hMenu, &MMenu_mi )
}



;- - - - - - - - - - - - - - - -

MMenu_onMeasure(wparam, lparam) {
	local iconSize, textOffset, menu
	local idx := ExtractIntegerAtAddr(lparam, 8,  1)	;pointer to the MEASUREITEMSTRUCT is in lparam

	menu  := MMenu_aItem[%idx%]_parent
	iconSize := MMenu_aMenu[%menu%]_iconSize
	textOffset := MMenu_aMenu[%menu%]_textOffset


	if (MMenu_aItem[%idx%]_hIcon=0)
		if !MMenu_amenu[%menu%]_hasIcons         	;if item  has no icon at all menu has no icons at all, just return
				return 0
		else{
			InsertIntegerAtAddr(iconsize + textOffset, lParam, 12)		;else put the width and offset only (without this, windows displays non icon titles bugy)
			return 1
		}

	InsertIntegerAtAddr(iconSize + textOffset, lParam, 12)
	InsertIntegerAtAddr(iconSize, lParam, 16)

	return 1
}

;- - - - - - - - - - - - - - - -

MMenu_onMenuChar(wparam, lparam){
	global

	if MMenu_userMenuChar =
		return

	M_CMENU := MMenu_aHandles[%lparam%]
	M_CHAR  := wparam & 0xFFFF

	GoSub %MMenu_userMenuChar%
	return 3<<16
}

;- - - - - - - - - - - - - - - -

MMenu_onInit(wparam, lparam){
	global

	if MMenu_userInit =
		return

	if wparam < 0		;convert to unsigned integer
		wparam += 4294967296

	- try to fix the deactivation bug
	M_MENU := MMenu_aHandles[%wparam%]

	GoSub %MMenu_userInit%
}

;- - - - - - - - - - - - - - - -
;wParam
;
;The low-order word specifies the menu item or submenu index.
;If the selected item is a command item, this parameter contains the identifier of the menu item.
;If the selected item opens a drop-down menu or submenu, this parameter contains the index of the
;drop-down menu or submenu in the main menu, and the lParam parameter contains the handle to the
;main (clicked) menu; use the GetSubMenu function to get the menu handle to the drop-down menu or submenu.
;
MMenu_onSelect(wparam, lparam){
	local idx  := wparam & 0xFFFF
	local menuFlag := wparam >> 16
	local hSub, gg, menu, sub

	;lparam = 0 represents dummy message that is sent when user press ESC
	if (lparam = 0) or ( MMenu_userSelect = "")
		return

	if lparam < 0		;convert to unsigned integer
		hMenu += 4294967296

	if menuFlag in 32912,144			;MF_POPUP and some number for submenus
	{
		hSub := API_GetSubmenu( lparam, idx )
		if hSub < 0		;convert to unsigned integer
			hSub += 4294967296


		menu :=	MMenu_aHandles[%lparam%]
		sub :=	MMenu_aHandles[%hSub%]
		loop, %MMenu_aItem[0]%
		{
			if (MMenu_aItem[%A_Index%]_parent = menu)
				if (MMenu_aItem[%A_Index%]_submenu = sub)
				{
					idx := A_Index
					break
				}
		}
	}

	M_SMENU	:= MMenu_aHandles[%lparam%]
	M_SID	:= MMenu_aItem[%idx%]_id
	M_STITLE := MMenu_aItem[%idx%]_title

	GoSub %MMenu_userSelect%
}

;- - - - - - - - - - - - - - - -

MMenu_onUninit(wparam){
	global

	if MMenu_userUninit =
		return

	if wparam < 0		;convert to unsigned integer
		wparam += 4294967296

	M_MENU := MMenu_aHandles[%wparam%]
	GoSub %MMenu_userUninit%
}

;- - - - - - - - - - - - - - - -

MMenu_onRButtonDown(wparam, lparam){
	global

	if MMenu_userRight =
		return

	GoSub %MMenu_userRight%
}

;- - - - - - - - - - - - - - - -

MMenu_OnMButtonDown(wparam, lparam){
	global


	if MMenu_userMiddle =
		return

	GoSub %MMenu_userMiddle%
}

;--------------------------------------------------------------------------------

MMenu_About() {
	local msg
	local version := "1.0 b1"

	msg .= "MMenu" . "  " . version . "`n"
	msg .= "Open source menu extension for AutoHotKey`n`n`n"

	msg .= "Created by:`t`t    Miodrag Milic`n"
	msg .= "e-mail:`t`t miodrag.milic@gmail.com`n`n`n"



	msg .= "code.r-moth.com   |  www.r-moth.com `n             r-moth.deviantart.com`n"

	MsgBox, 64, About MMenu,  %msg%
}

MMenu_GetIcon( pPath, pNum=1 ) {
	return, DllCall("Shell32\ExtractIconA", "UInt", 0, "Str", pPath, "UInt", pNum)
}

;--------------------------------------------------------------------------------

#include API_Menu.ahk

;====================================================================================
; API_Draw.ahk
;=====================================================================================

MMenu_loadIcon(pPath, pSize=0)
{
	idx := InStr(pPath, ":", 0, 0)

	if idx >=4
	{
		resPath := SubStr( pPath, 1, idx-1)
		resIdx  := Substr( pPath, idx+1, 8)

		return MMenu_GetIcon( resPath, resIdx )
	}

;	h := DllCall("GetModuleHandle", "str", "c:\windows\system32\shell32.dll")
	return,  DllCall( "LoadImage"
                     , "uint", 0
                     , "str", pPath
                     , "uint", 2                ; IMAGE_ICON
                     , "int", pSize
                     , "int", pSize
                     , "uint", 0x10 | 0x20)     ; LR_LOADFROMFILE | LR_TRANSPARENT
}

;--------------------------------------------------------------------------------

MMenu_destroyIcon(hIcon) {
	return,	DllCall("DestroyIcon", "uint", hIcon)
}

;--------------------------------------------------------------------------------

API_DrawIconEx( hDC, xLeft, yTop, hIcon, cxWidth, cyWidth, istepIfAniCur, hbrFlickerFreeDraw, diFlags)
{
    return DllCall("DrawIconEx"
            ,"uint", hDC
            ,"uint", xLeft
            ,"uint", yTop
            ,"uint", hIcon
            ,"int",  cxWidth
            ,"int",  cyWidth
            ,"uint", istepIfAniCur
            ,"uint", hbrFlickerFreeDraw
            ,"uint", diFlags )
}

;--------------------------------------------------------------------------------

DRAWITEM_GetA(s, adr){
    global

    %s%_itemID      := ExtractIntegerAtAddr(adr,8,  0)
	%s%_itemAction  := ExtractIntegerAtAddr(adr,12, 0)
    %s%_itemState   := ExtractIntegerAtAddr(adr,16, 0)
    %s%_hwndItem    := ExtractIntegerAtAddr(adr,20, 0)
    %s%_hDC         := ExtractIntegerAtAddr(adr,24, 0)

    %s%_rcItem_Left   := ExtractIntegerAtAddr(adr,28, 0)
    %s%_rcItem_Top    := ExtractIntegerAtAddr(adr,32, 0)
    %s%_rcItem_Right  := ExtractIntegerAtAddr(adr,36, 0)
    %s%_rcItem_Bottom := ExtractIntegerAtAddr(adr,40, 0)
	%s%_itemData	  := ExtractIntegerAtAddr(adr,44, 0)
}


;-------------------------------------------------------------------------------------------------
API_SetTextColor(hDC, crColor){
	return, DllCall("SetTextColor", "uint", hDC, "uint", crColor)
}


API_CreateSolidBrush(crColor){
	return DllCall("CreateSolidBrush", "uint", crColor)
}

API_SelectObject( hDC, hgdiobj ){
    return DllCall("SelectObject", "uint", hDC, "uint", hgdiobj)
}

API_DeleteObject( hObj ){
   return DllCall("DeleteObject", "uint", hObj)
}


RECT_Set(var)
{
	global

	VarSetCapacity(%var%_c, 16 , 0)
	InsertInteger(%var%_left,   %var%_c, 0)
	InsertInteger(%var%_top,    %var%_c, 4)
	InsertInteger(%var%_right,  %var%_c, 8)
	InsertInteger(%var%_bottom, %var%_c, 12)
}

RECT_Get(var)
{
	global

	%var%_left   := ExtractInteger(%var%_c, 0)
	%var%_top	 := ExtractInteger(%var%_c, 4)
	%var%_right	 := ExtractInteger(%var%_c, 8)
	%var%_bottom := ExtractInteger(%var%_c, 12)
	%var%_width  := %var%_right - %var%_left
	%var%_height := %var%_bottom - %var%_top
}