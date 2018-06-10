; ======================================================================================================================
; Function:          Constants for StatusBar controls
; AHK version:       1.1.05+
; Language:          English
; Version:           1.0.00.00/2012-04-01/just me
;                    1.1.00.00/2012-12-29/just me   - added SB_SIMPLEID
; ======================================================================================================================
; CCM_FIRST = 0x2000
; SBN_FIRST = -880  ; status bar
; WM_USER   = 0x0400
; ======================================================================================================================
; Class ================================================================================================================
Global WC_STATUSBAR        := "msctls_statusbar32"
; Messages =============================================================================================================
Global SB_GETBORDERS        := 0x0407 ; (WM_USER + 7)
Global SB_GETICON           := 0x0414 ; (WM_USER + 20)
Global SB_GETPARTS          := 0x0406 ; (WM_USER + 6)
Global SB_GETRECT           := 0x040A ; (WM_USER + 10)
Global SB_GETTEXTA          := 0x0402 ; (WM_USER + 2)
Global SB_GETTEXTLENGTHA    := 0x0403 ; (WM_USER + 3)
Global SB_GETTEXTLENGTHW    := 0x040C ; (WM_USER + 12)
Global SB_GETTEXTW          := 0x040D ; (WM_USER + 13)
Global SB_GETTIPTEXTA       := 0x0412 ; (WM_USER + 18)
Global SB_GETTIPTEXTW       := 0x0413 ; (WM_USER + 19)
Global SB_GETUNICODEFORMAT  := 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
Global SB_ISSIMPLE          := 0x040E ; (WM_USER + 14)
Global SB_SETBKCOLOR        := 0x2001 ; (CCM_FIRST + 1) CCM_SETBKCOLOR lParam = bkColor
Global SB_SETICON           := 0x040F ; (WM_USER + 15)
Global SB_SETMINHEIGHT      := 0x0408 ; (WM_USER + 8)
Global SB_SETPARTS          := 0x0404 ; (WM_USER + 4)
Global SB_SETTEXTA          := 0x0401 ; (WM_USER + 1)
Global SB_SETTEXTW          := 0x040B ; (WM_USER + 11)
Global SB_SETTIPTEXTA       := 0x0410 ; (WM_USER + 16)
Global SB_SETTIPTEXTW       := 0x0411 ; (WM_USER + 17)
Global SB_SETUNICODEFORMAT  := 0x2005 ; (CCM_FIRST + 5) CCM_SETUNICODEFORMAT
Global SB_SIMPLE            := 0x0409 ; (WM_USER + 9)
; Notifications ========================================================================================================
Global SBN_SIMPLEMODECHANGE := -880   ; (SBN_FIRST - 0)
; Styles ===============================================================================================================
Global SBARS_SIZEGRIP       := 0x0100
Global SBARS_TOOLTIPS       := 0x0800
Global SBT_TOOLTIPS         := 0x0800 ; this is a status bar flag, preference to SBARS_TOOLTIPS
; Others ===============================================================================================================
; SB_GET/SETTEXT return codes
Global SBT_NOBORDERS        := 0x0100
Global SBT_NOTABPARSING     := 0x0800
Global SBT_OWNERDRAW        := 0x1000
Global SBT_POPOUT           := 0x0200
Global SBT_RTLREADING       := 0x0400
; SB_SETTEXT wParam
Global SB_SIMPLEID          := 0x00FF
; ======================================================================================================================