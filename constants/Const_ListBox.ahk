; ======================================================================================================================
; Function:         Constants for ListBox controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
;                   1.0.01.00/2012-05-30/just me - Sorted
; ======================================================================================================================
; Class ================================================================================================================
Global WC_LISTBOX             := "ListBox"
; Messages =============================================================================================================
Global LB_ADDFILE             := 0x0196
Global LB_ADDSTRING           := 0x0180
Global LB_DELETESTRING        := 0x0182
Global LB_DIR                 := 0x018D
Global LB_FINDSTRING          := 0x018F
Global LB_FINDSTRINGEXACT     := 0x01A2
Global LB_GETANCHORINDEX      := 0x019D
Global LB_GETCARETINDEX       := 0x019F
Global LB_GETCOUNT            := 0x018B
Global LB_GETCURSEL           := 0x0188
Global LB_GETHORIZONTALEXTENT := 0x0193
Global LB_GETITEMDATA         := 0x0199
Global LB_GETITEMHEIGHT       := 0x01A1
Global LB_GETITEMRECT         := 0x0198
Global LB_GETLISTBOXINFO      := 0x01B2
Global LB_GETLOCALE           := 0x01A6
Global LB_GETSEL              := 0x0187
Global LB_GETSELCOUNT         := 0x0190
Global LB_GETSELITEMS         := 0x0191
Global LB_GETTEXT             := 0x0189
Global LB_GETTEXTLEN          := 0x018A
Global LB_GETTOPINDEX         := 0x018E
Global LB_INITSTORAGE         := 0x01A8
Global LB_INSERTSTRING        := 0x0181
Global LB_ITEMFROMPOINT       := 0x01A9
Global LB_MULTIPLEADDSTRING   := 0x01B1
Global LB_RESETCONTENT        := 0x0184
Global LB_SELECTSTRING        := 0x018C
Global LB_SELITEMRANGE        := 0x019B
Global LB_SELITEMRANGEEX      := 0x0183
Global LB_SETANCHORINDEX      := 0x019C
Global LB_SETCARETINDEX       := 0x019E
Global LB_SETCOLUMNWIDTH      := 0x0195
Global LB_SETCOUNT            := 0x01A7
Global LB_SETCURSEL           := 0x0186
Global LB_SETHORIZONTALEXTENT := 0x0194
Global LB_SETITEMDATA         := 0x019A
Global LB_SETITEMHEIGHT       := 0x01A0
Global LB_SETLOCALE           := 0x01A5
Global LB_SETSEL              := 0x0185
Global LB_SETTABSTOPS         := 0x0192
Global LB_SETTOPINDEX         := 0x0197
; Notifications ========================================================================================================
Global LBN_DBLCLK             := 2
Global LBN_ERRSPACE           := -2
Global LBN_KILLFOCUS          := 5
Global LBN_SELCANCEL          := 3
Global LBN_SELCHANGE          := 1
Global LBN_SETFOCUS           := 4
; Styles ===============================================================================================================
Global LBS_COMBOBOX           := 0x8000
Global LBS_DISABLENOSCROLL    := 0x1000
Global LBS_EXTENDEDSEL        := 0x0800
Global LBS_HASSTRINGS         := 0x0040
Global LBS_MULTICOLUMN        := 0x0200
Global LBS_MULTIPLESEL        := 0x0008
Global LBS_NODATA             := 0x2000
Global LBS_NOINTEGRALHEIGHT   := 0x0100
Global LBS_NOREDRAW           := 0x0004
Global LBS_NOSEL              := 0x4000
Global LBS_NOTIFY             := 0x0001
Global LBS_OWNERDRAWFIXED     := 0x0010
Global LBS_OWNERDRAWVARIABLE  := 0x0020
Global LBS_SORT               := 0x0002
Global LBS_STANDARD           := 0xA00003 ; (LBS_NOTIFY | LBS_SORT | WS_VSCROLL = 0x200000 | WS_BORDER = 0x800000)
Global LBS_USETABSTOPS        := 0x0080
Global LBS_WANTKEYBOARDINPUT  := 0x0400
; Errors ===============================================================================================================
Global LB_ERR                 := -1
Global LB_ERRSPACE            := -2
Global LB_OKAY                := 0
; ======================================================================================================================