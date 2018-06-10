; ======================================================================================================================
; Function:         Constants for UpDown controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; WM_USER   = 0x400
; CCM_FIRST = 0x2000
; UDN_FIRST = -721
; ======================================================================================================================
; Class ================================================================================================================
Global WC_UPDOWN            := "msctls_updown32"
; Messages =============================================================================================================
Global UDM_GETACCEL         := 0x046C ; (WM_USER + 108)
Global UDM_GETBASE          := 0x046E ; (WM_USER + 110)
Global UDM_GETBUDDY         := 0x046A ; (WM_USER + 106)
Global UDM_GETPOS           := 0x0468 ; (WM_USER + 104)
Global UDM_GETPOS32         := 0x0472 ; (WM_USER + 114)
Global UDM_GETRANGE         := 0x0466 ; (WM_USER + 102)
Global UDM_GETRANGE32       := 0x0470 ; (WM_USER + 112) wParam & lParam are LPINT
Global UDM_GETUNICODEFORMAT := 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
Global UDM_SETACCEL         := 0x046B ; (WM_USER + 107)
Global UDM_SETBASE          := 0x046D ; (WM_USER + 109)
Global UDM_SETBUDDY         := 0x0469 ; (WM_USER + 105)
Global UDM_SETPOS           := 0x0467 ; (WM_USER + 103)
Global UDM_SETPOS32         := 0x0471 ; (WM_USER + 113)
Global UDM_SETRANGE         := 0x0465 ; (WM_USER + 101)
Global UDM_SETRANGE32       := 0x046F ; (WM_USER + 111)
Global UDM_SETUNICODEFORMAT := 0x2005 ; (CCM_FIRST + 5) CCM_SETUNICODEFORMAT
; Notifications ========================================================================================================
Global UDN_DELTAPOS         := -722   ; (UDN_FIRST - 1)
; Styles ===============================================================================================================
Global UDS_ALIGNLEFT        := 0x0008
Global UDS_ALIGNRIGHT       := 0x0004
Global UDS_ARROWKEYS        := 0x0020
Global UDS_AUTOBUDDY        := 0x0010
Global UDS_HORZ             := 0x0040
Global UDS_HOTTRACK         := 0x0100
Global UDS_NOTHOUSANDS      := 0x0080
Global UDS_SETBUDDYINT      := 0x0002
Global UDS_WRAP             := 0x0001
; ======================================================================================================================