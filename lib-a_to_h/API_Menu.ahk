/*
	-- FUN --
	CreatePopupMenu			()
	DeleteMenu				( hMenu, uPos, uFlags )
	DestroyMenu				( hMenu )
	GetMenuCheckMarkDimensions()
	GetMenuItemCount		( hMenu )
	GetMenuItemID			( hMenu, nPos )
	GetMenuItemInfo			( hMenu, uItem, fByPosition, lpmii )
	GetMenuState			( hMenu, uId, uFlags )
	GetMenuString			( hMenu, uIDItem, lpString, nMaxCount, uFlag )
	GetSubmenu				( hMenu, nPos)
	SetMenuItemInfo			( hMenu, uItem, fByPosition, lpmii )
	SetMenuInfo				( hMenu, sMENUINFO )
	TrackPopupMenu			( hMenu, uFlags, X, Y, hWnd )
	InsertMenu				( hMenu, uPos, uFlags, uID, pData)
	IsMenu					( hMenu )
	RemoveMenu				( hMenu, uPosition, uFlags )


	-- STRUCTS --
	MENUINFO
	MENUITEMINFO
	SIZE
*/

API_GetMenuCheckMarkDimensions() {
	return DllCall("GetMenuCheckMarkDimensions")
}

API_GetMenuState( hMenu, uId, uFlags ) {
	return DllCall("GetMenuState", "uint", hMenu, "uint", uID, "uint", uFlags)
}

API_GetMenuString( hMenu, uIDItem, lpString, nMaxCount, uFlag ){
	return DllCall("GetMenuString", "uint", hMenu, "uint", uIDItem, "str", lpString, "uint", nMaxCount, "uint", uFlag)
}

API_IsMenu( hMenu ) {
	return DllCall("IsMenu", "uint", hMenu)
}

API_GetSubmenu(hMenu, nPos) {
	return DllCall("GetSubMenu", "uint", hMenu, "int", nPos)
}

API_RemoveMenu( hMenu, uPosition, uFlags ) {
	return DllCall("RemoveMenu", "uint", hMenu, "uint", uPosition, "uint", uFlags)
}

API_GetMenuItemID( hMenu, nPos ) {
	return DllCall("GetMenuItemID", "uint", hMenu, "int", nPos)
}

INIT_Menu(){
;	global
;	;messages
;	WM_MENUSELECT	= 0x11F
;	WM_MEASUREITEM	= 0x2C
;	WM_DRAWITEM		= 0x2B
;	WM_ENTERMENULOOP= 0x211
;
;	MNS_DRAGDROP	= 0x20000000
;	MNS_MODELESS	= 0x40000000
;	MNS_NOTIFYBYPOS	= 0x80000000
;
;
;	;InsertMenu flags
;	MF_STRING		= 0
;	MF_BYCOMMAND	= 0
;	MF_BYPOSITION	= 0x400
;	MF_CHECKED		= 0x8
;	MF_DISABLED		= 0x2
;	MF_ENABLED		= 0x0
;	MF_MENUBREAK	= 0x40
;	MF_POPUP		= 0x10
;	MF_SEPARATOR	= 0x800
;	MF_UNCHECKED	= 0x0
;	MF_OWNERDRAW	= 0x100
;	MF_DEFAULT		= 0x1000
;	MF_HILITE		= 0x80
;
;	;types
;	MFT_MENUBREAK	:= MF_MENUBREAK
;	MFT_SEPARATOR	:= MF_SEPARATOR
;	MFT_STRING		:= MF_STRING
;	MFT_RADIOCHECK	:= 0x200
;
;	;TrackPopupMenu flags
;	TPM_CENTERALIGN		 = 0x4
;	TPM_BOTTOMALIGN		 = 0x20
;	TPM_HORIZONTAL		 = 0x0
;	TPM_HORNEGANIMATION	 = 0x800
;	TPM_HORPOSANIMATION	 = 0x400
;	TPM_LEFTALIGN		 = 0x0
;	TPM_LEFTBUTTON		 = 0x0
;	TPM_NOANIMATION		 = 0x4000
;	TPM_NONOTIFY		 = 0x80
;	TPM_RECURSE			 = 0x1
;	TPM_RETURNCMD		 = 0x100
;	TPM_RIGHTALIGN		 = 0x8
;	TPM_RIGHTBUTTON		 = 0x2
;	TPM_TOPALIGN		 = 0x0
;	TPM_VCENTERALIGN	 = 0x10
;	TPM_VERNEGANIMATION	 = 0x2000
;	TPM_VERPOSANIMATION	 = 0x1000
;	TPM_VERTICAL		 = 0x40
;
;	;MENUINFO mask
;	MIM_APPLYTOSUBMENUS	 = 0x80000000
;	MIM_BACKGROUND		 = 0x2
;	MIM_MENUDATA		 = 0x8
;	MIM_MAXHEIGHT		 = 0x1
;	MIM_STYLE			 = 0x10
;
;
;	;MENUINFO styles
;	MNS_AUTODISMISS		 = 0x10000000
;	MNS_NOTIFYBYPOS		 = 0x8000000
;	MNS_NOCHECK			 = 0x80000000
;	MNS_MODELESS		 = 0x40000000
;	MNS_DRAGDROP		 = 0x20000000
;	MNS_CHECKORBMP		 = 0x4000000
;
;	;MENUITEMINFO constants
;	MIIM_STRING = 0x40
;	MIIM_FTYPE	= 0x100
;	MIIM_TYPE   = 0x10
;	MIIM_ID		= 0x2
;	MIIM_DATA	= 0x20
;	MIIM_BITMAP = 0x80
;	MIIM_STATE	= 0x1
;
;
;
;
;	;states
;	ODS_CHECKED			= 0x08
;	ODS_DEFAULT			= 0x020
;	ODS_DISABLED		= 0x04
;	ODS_FOCUS			= 0x010
;	ODS_GRAYED			= 0x02
;	ODS_HOTLIGHT		= 0x040
;	ODS_INACTIVE		= 0x080
;	ODS_NOACCEL			= 0x0100
;	ODS_NOFOCUSRECT		= 0x0200
;	ODS_SELECTED		= 0x01
;
;	;actions
;	ODA_DRAWENTIRE	 = 0x1
;	ODA_FOCUS		 = 0x4
;	ODA_SELECT		 = 0x2
;
;
;	;masks
;	DI_COMPAT	= 4
;	DI_IMAGE	= 2
;	DI_MASK		= 1
;	DI_DEFAULTSIZE	= 8
;	DI_NORMAL	:= DI_MASK | DI_IMAGE
;
;	;STYLES
;	MFS_GRAYED	  := 0x3
;	MFS_ENABLED	  := MF_ENABLED
;	MFS_CHECKED	  := MF_CHECKED
;	MFS_UNCHECKED := MF_UNCHECKED
;	MFS_DEFAULT	  := MF_DEFAULT
}
;----------------------------------------------------------
API_InsertMenu( hMenu, uPos, uFlags, uID, pData){
   return DllCall("InsertMenu"
					,"uint", hMenu
					,"uint", uPos
				    ,"uint", uFlags
			        ,"uint", uID
		            ,"uint", pData)
}
;----------------------------------------------------------
API_GetMenuItemCount( hMenu ) {
	return DllCall("GetMenuItemCount", "uint", hMenu)
}
;----------------------------------------------------------
API_CreatePopupMenu() {
	return DllCall("CreatePopupMenu")
}
;----------------------------------------------------------
API_DestroyMenu( hMenu ) {
	return  DllCall("DestroyMenu", "uint", hMenu)
}
;----------------------------------------------------------
API_TrackPopupMenu( hMenu, uFlags, X, Y, hWnd ) {
   global

	return DllCall("TrackPopupMenu"
               , "uint", hMenu
               , "uint", uFlags
               , "int", X
               , "int", Y
               , "uint", 0
               , "uint", hWnd
               , "uint", 0)
}
;----------------------------------------------------------
API_SetMenuInfo(hMenu, sMENUINFO){
	return DllCall("SetMenuInfo", "uint", hMenu, "uint", sMENUINFO)
}
;----------------------------------------------------------
API_DeleteMenu( hMenu, uPos, uFlags) {
   DllCall("DeleteMenu"
         ,"uint", hMenu
         ,"uint", uPos
         ,"uint", uFlags)
}
;-------------------------------------------------------------------------------------------------
API_SetMenuItemInfo( hMenu, uItem, fByPosition, lpmii){
	return, DllCall("SetMenuItemInfo", "uint", hMenu, "uint", uItem, "uint", fByPosition, "uint", lpmii)
}
;-------------------------------------------------------------------------------------------------
API_GetMenuItemInfo( hMenu, uItem, fByPosition, lpmii){
	return, DllCall("GetMenuItemInfo", "uint", hMenu, "uint", uItem, "uint", fByPosition, "uint", lpmii)
}

/*
=================================================================================================

							STRUCTS

==================================================================================================
*/

;typedef struct tagSIZE {
;  LONG cx;
;  LONG cy;
;} SIZE, *PSIZE;
SIZE_Get(var){
	global
	%var%_cx := ExtractInteger(%var%_c,0)
	%var%_cy := ExtractInteger(%var%_c,4)
}

SIZE_Set(var){
	global

	VarSetCapacity(%var%_c, 4, 0)
	InsertInteger(%var%_cx, %var%_c, 0)
	InsertInteger(%var%_cy, %var%_c, 4)
}


;-------------------------------------------------------------------------------------------------
;typedef struct tagMENUITEMINFO {
;  UINT    cbSize;
;  UINT    fMask;
;  UINT    fType;
;  UINT    fState;
;  UINT    wID;
;  HMENU   hSubMenu;
;  HBITMAP hbmpChecked;
;  HBITMAP hbmpUnchecked;
;  ULONG_PTR dwItemData;
;  LPTSTR  dwTypeData;
;  UINT    cch;
;  HBITMAP hbmpItem;
;} MENUITEMINFO, *LPMENUITEMINFO;
MENUITEMINFO_Get(var){
	global
	%var%_fMask			:= ExtractInteger(%var%,4)
	%var%_fType			:= ExtractInteger(%var%,8)
	%var%_fState		:= ExtractInteger(%var%,12)
	%var%_wID			:= ExtractInteger(%var%,16)
	%var%_hSubMenu		:= ExtractInteger(%var%,20)
	%var%_dwItemData	:= ExtractInteger(%var%,32)
	%var%_dwTypeData	:= ExtractInteger(%var%,36)
	%var%_hbmpItem		:= ExtractInteger(%var%,44)
}

MENUITEMINFO_Set(var){
	global
	VarSetCapacity(%var%, 48, 0)
	InsertInteger(48,				%var%,0)
	InsertInteger(%var%_fMask,		%var%,4)
	InsertInteger(%var%_fType,		%var%,8)
	InsertInteger(%var%_fState,		%var%,12)
	InsertInteger(%var%_wID,		%var%,16)
	InsertInteger(%var%_hSubMenu,	%var%,20)
	InsertInteger(%var%_dwItemData,	%var%,32)
	InsertInteger(%var%_dwTypeData,	%var%,36)
	InsertInteger(%var%_cch,		%var%,40)
	InsertInteger(%var%_hbmpItem,	%var%,44)

}

;----------------------------------------------------------
;typedef struct MENUINFO {
;  DWORD   cbSize;				0
;  DWORD   fMask;				4
;  DWORD   dwStyle;				8
;  UINT    cyMax;				12
;  HBRUSH  hbrBack;				16
;  DWORD   dwContextHelpID;		20
;  ULONG_PTR  dwMenuData;		24
;
MENUINFO_Set(var){
	global

	VarSetCapacity(%var%, 28, 0)
	InsertInteger(28,				%var%, 0)
	InsertInteger(%var%_fMask,		%var%, 4)
	InsertInteger(%var%_dwStyle,	%var%, 8)
	InsertInteger(%var%_cyMax,		%var%, 12)
	InsertInteger(%var%_hbrBack,	%var%, 16)
	InsertInteger(%var%_dwMenuData,	%var%, 24)
}

MENUINFO_Get(var){
	global

	%var%_fMask		 := ExtractInteger(%var%, 4)
	%var%_dwStyle	 := ExtractInteger(%var%, 8)
	%var%_cyMax		 := ExtractInteger(%var%, 12)
	%var%_hbrBack	 := ExtractInteger(%var%, 16)
	%var%_dwMenuData := ExtractInteger(%var%, 24)
}