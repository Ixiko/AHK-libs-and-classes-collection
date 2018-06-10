; ======================================================================================================================
; Function:         Generic constants for common controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
;                   1.0.01.00/2012-05-26/just me - added custom draw constants
; ======================================================================================================================
; CCM_FIRST = 0x2000    Common control shared messages
; NM_FIRST  = 0         Generic to all controls
; ======================================================================================================================
; Common control shared messages =======================================================================================
Global CCM_DPISCALE            := 0x200C ; (CCM_FIRST + 0xC) wParam == Awareness
Global CCM_GETCOLORSCHEME      := 0x2003 ; (CCM_FIRST + 0x3) fills in COLORSCHEME pointed to by lParam
Global CCM_GETDROPTARGET       := 0x2004 ; (CCM_FIRST + 0x4)
Global CCM_GETUNICODEFORMAT    := 0x2006 ; (CCM_FIRST + 0x6)
Global CCM_GETVERSION          := 0x2008 ; (CCM_FIRST + 0x8)
Global CCM_SETBKCOLOR          := 0x2001 ; (CCM_FIRST + 0x1) lParam is bkColor
Global CCM_SETCOLORSCHEME      := 0x2002 ; (CCM_FIRST + 0x2) lParam is color scheme
Global CCM_SETNOTIFYWINDOW     := 0x2009 ; (CCM_FIRST + 0x9) wParam == hwndParent.
Global CCM_SETUNICODEFORMAT    := 0x2005 ; (CCM_FIRST + 0x5)
Global CCM_SETVERSION          := 0x2007 ; (CCM_FIRST + 0x7)
Global CCM_SETWINDOWTHEME      := 0x200B ; (CCM_FIRST + 0xB)
; Common control styles ================================================================================================
Global CCS_ADJUSTABLE          := 0x0020
Global CCS_BOTTOM              := 0x0003
Global CCS_LEFT                := 0x0081 ; (CCS_VERT | CCS_TOP)
Global CCS_NODIVIDER           := 0x0040
Global CCS_NOMOVEX             := 0x0082 ; (CCS_VERT | CCS_NOMOVEY)
Global CCS_NOMOVEY             := 0x0002
Global CCS_NOPARENTALIGN       := 0x0008
Global CCS_NORESIZE            := 0x0004
Global CCS_RIGHT               := 0x0083 ; (CCS_VERT | CCS_BOTTOM)
Global CCS_TOP                 := 0x0001
Global CCS_VERT                := 0x0080
; Generic WM_NOTIFY notification codes =================================================================================
Global NM_CHAR                 := -18 ; (NM_FIRST - 18) uses NMCHAR struct
Global NM_CLICK                := -2  ; (NM_FIRST - 2)  uses NMCLICK struct
Global NM_CUSTOMDRAW           := -12 ; (NM_FIRST - 12)
Global NM_CUSTOMTEXT           := -24 ; (NM_FIRST - 24) >= Vista uses NMCUSTOMTEXT struct
Global NM_DBLCLK               := -3  ; (NM_FIRST - 3)
Global NM_FONTCHANGED          := -23 ; (NM_FIRST - 23) >= Vista
Global NM_HOVER                := -13 ; (NM_FIRST - 13)
Global NM_KEYDOWN              := -15 ; (NM_FIRST - 15) uses NMKEY struct
Global NM_KILLFOCUS            := -8  ; (NM_FIRST - 8)
Global NM_LDOWN                := -20 ; (NM_FIRST - 20)
Global NM_NCHITTEST            := -14 ; (NM_FIRST - 14) uses NMMOUSE struct
Global NM_OUTOFMEMORY          := -1  ; (NM_FIRST - 1)
Global NM_RCLICK               := -5  ; (NM_FIRST - 5)  uses NMCLICK struct
Global NM_RDBLCLK              := -6  ; (NM_FIRST - 6)
Global NM_RDOWN                := -21 ; (NM_FIRST - 21)
Global NM_RELEASEDCAPTURE      := -16 ; (NM_FIRST - 16)
Global NM_RETURN               := -4  ; (NM_FIRST - 4)
Global NM_SETCURSOR            := -17 ; (NM_FIRST - 17) uses NMMOUSE struct
Global NM_SETFOCUS             := -7  ; (NM_FIRST - 7)
Global NM_THEMECHANGED         := -22 ; (NM_FIRST - 22)
Global NM_TOOLTIPSCREATED      := -19 ; (NM_FIRST - 19) notify of when the tooltips window is create
Global NM_TVSTATEIMAGECHANGING := -24 ; (NM_FIRST - 24) >= Vista, uses NMTVSTATEIMAGECHANGING struct
; NM_CUSTOMDRAW ========================================================================================================
; Values under 0x00010000 are reserved for global custom draw values, above that are for specific controls
; Drawstage flags.
Global CDDS_ITEM               := 0x010000
Global CDDS_ITEMPOSTERASE      := 0x010004 ; (CDDS_ITEM | CDDS_POSTERASE)
Global CDDS_ITEMPOSTPAINT      := 0x010002 ; (CDDS_ITEM | CDDS_POSTPAINT)
Global CDDS_ITEMPREERASE       := 0x010003 ; (CDDS_ITEM | CDDS_PREERASE)
Global CDDS_ITEMPREPAINT       := 0x010001 ; (CDDS_ITEM | CDDS_PREPAINT)
Global CDDS_POSTERASE          := 0x000004
Global CDDS_POSTPAINT          := 0x000002
Global CDDS_PREERASE           := 0x000003
Global CDDS_PREPAINT           := 0x000001
Global CDDS_SUBITEM            := 0x020000
; Itemstate flags
Global CDIS_CHECKED            := 0x0008
Global CDIS_DEFAULT            := 0x0020
Global CDIS_DISABLED           := 0x0004
Global CDIS_DROPHILITED        := 0x1000 ; >= Vista
Global CDIS_FOCUS              := 0x0010
Global CDIS_GRAYED             := 0x0002
Global CDIS_HOT                := 0x0040
Global CDIS_INDETERMINATE      := 0x0100
Global CDIS_MARKED             := 0x0080
Global CDIS_NEARHOT            := 0x0400 ; >= Vista
Global CDIS_OTHERSIDEHOT       := 0x0800 ; >= Vista
Global CDIS_SELECTED           := 0x0001
Global CDIS_SHOWKEYBOARDCUES   := 0x0200
; Return flags
Global CDRF_DODEFAULT          := 0x0000
Global CDRF_DOERASE            := 0x0008 ; draw the background
Global CDRF_NEWFONT            := 0x0002
Global CDRF_NOTIFYITEMDRAW     := 0x0020
Global CDRF_NOTIFYPOSTERASE    := 0x0040
Global CDRF_NOTIFYPOSTPAINT    := 0x0010
Global CDRF_NOTIFYSUBITEMDRAW  := 0x0020 ; flags are the same, we can distinguish by context
Global CDRF_SKIPDEFAULT        := 0x0004
Global CDRF_SKIPPOSTPAINT      := 0x0100 ; don't draw the focus rect
; ======================================================================================================================