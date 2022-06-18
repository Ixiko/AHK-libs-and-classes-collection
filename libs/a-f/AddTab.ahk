AddTab(IconNumber, TabName) {
; Relies on caller having set the last found window for us.
; https://autohotkey.com/board/topic/5692-icons-in-tabs/#entry34938
	VarSetCapacity(TCITEM, 100, 0)
	InsertInteger(3, TCITEM, 0)  ; Mask (3) comes from TCIF_TEXT(1) + TCIF_IMAGE(2).
	InsertInteger(&TabName, TCITEM, 12)  ; pszText
	InsertInteger(IconNumber - 1, TCITEM, 20)  ; iImage: -1 to convert to zero-based.
	SendMessage, 0x1307, 999, &TCITEM, SysTabControl321  ; 0x1307 is TCM_INSERTITEM
}