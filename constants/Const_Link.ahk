; ======================================================================================================================
; Function:         Constants for Link controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2014-09-13/just me
; MSDN:             http://msdn.microsoft.com/en-us/library/bb760704(v=vs.85).aspx
; ======================================================================================================================
; WM_USER   = 0x400
; ======================================================================================================================
; Class ================================================================================================================
Global WC_LINK            := "SysLink"
; Messages =============================================================================================================
Global LM_GETIDEALHEIGHT  := 0x0701 ; (WM_USER+0x301)  // wParam: cxMaxWidth, lparam: n/a, ret: cy
Global LM_GETIDEALSIZE    := 0x0701 ; (LM_GETIDEALHEIGHT)  // wParam: cxMaxWidth, lparam: SIZE*, ret: cy
Global LM_GETITEM         := 0x0703 ; (WM_USER+0x303)  // wParam: n/a, lparam: LITEM*, ret: BOOL
Global LM_HITTEST         := 0x0700 ; (WM_USER+0x300)  // wParam: n/a, lparam: PLHITTESTINFO, ret: BOOL
Global LM_SETITEM         := 0x0702 ; (WM_USER+0x302)  // wParam: n/a, lparam: LITEM*, ret: BOOL
; Styles ===============================================================================================================
Global LWS_IGNORERETURN   := 0x0002
Global LWS_NOPREFIX       := 0x0004 ; Vista+
Global LWS_RIGHT          := 0x0020 ; Vista+
Global LWS_TRANSPARENT    := 0x0001
Global LWS_USECUSTOMTEXT  := 0x0010 ; Vista+
Global LWS_USEVISUALSTYLE := 0x0008 ; Vista+
; LITEM mask ===========================================================================================================
Global LIF_ITEMINDEX      := 0x00000001
Global LIF_STATE          := 0x00000002
Global LIF_ITEMID         := 0x00000004
Global LIF_URL            := 0x00000008
; LITEM state ==========================================================================================================
Global LIS_FOCUSED        := 0x00000001
Global LIS_ENABLED        := 0x00000002
Global LIS_VISITED        := 0x00000004
Global LIS_HOTTRACK       := 0x00000008 ; Vista+
Global LIS_DEFAULTCOLORS  := 0x00000010 ; Vista+ // Don't use any custom text colors
; Others  ==============================================================================================================
Global INVALID_LINK_INDEX := -1
Global L_MAX_URL_LENGTH   := (2048 + 32 + 3) ; (+ sizeof("://"))
Global MAX_LINKID_TEXT    := 48