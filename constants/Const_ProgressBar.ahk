; ======================================================================================================================
; Function:          Constants for ProgressBar controls
; AHK version:       1.1.05+
; Language:          English
; Version:           1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; CCM_FIRST = 0x2000
; WM_USER   = 0x0400
; ======================================================================================================================
; Class ================================================================================================================
Global WC_PROGRESSBAR    := "msctls_progress32"
; Messages =============================================================================================================
Global PBM_DELTAPOS      := 0x0403 ; (WM_USER + 3)
Global PBM_GETBARCOLOR   := 0x040F ; (WM_USER + 15)  >= Vista
Global PBM_GETBKCOLOR    := 0x040E ; (WM_USER + 14)  >= Vista
Global PBM_GETPOS        := 0x0408 ; (WM_USER + 8)
Global PBM_GETRANGE      := 0x0407 ; (WM_USER + 7)   wParam = return:= (TRUE ? low : high). lParam = PPBRANGE or NULL
Global PBM_GETSTATE      := 0x0411 ; (WM_USER + 17)  >= Vista
Global PBM_GETSTEP       := 0x040D ; (WM_USER + 13)  >= Vista
Global PBM_SETBARCOLOR   := 0x0409 ; (WM_USER + 9)   lParam = bar color
Global PBM_SETBKCOLOR    := 0x2001 ; (CCM_FIRST + 1) CCM_SETBKCOLOR lParam = bkColor
Global PBM_SETMARQUEE    := 0x040A ; (WM_USER + 10)
Global PBM_SETPOS        := 0x0402 ; (WM_USER + 2)
Global PBM_SETRANGE      := 0x0401 ; (WM_USER + 1)
Global PBM_SETRANGE32    := 0x0406 ; (WM_USER + 6)   lParam = high, wParam = low
Global PBM_SETSTATE      := 0x0410 ; (WM_USER + 16)  >= Vista, wParam = PBST_[State]:= (NORMAL, ERROR, PAUSED)
Global PBM_SETSTEP       := 0x0404 ; (WM_USER + 4)
Global PBM_STEPIT        := 0x0405 ; (WM_USER + 5)
; Styles ===============================================================================================================
Global PBS_MARQUEE       := 0x08
Global PBS_SMOOTH        := 0x01
Global PBS_SMOOTHREVERSE := 0x10   ; >= Vista
Global PBS_VERTICAL      := 0x04
; Others ===============================================================================================================
; PBM_SETSTATE states >= Vista
Global PBST_NORMAL       := 1
Global PBST_ERROR        := 2
Global PBST_PAUSED       := 3
; ======================================================================================================================