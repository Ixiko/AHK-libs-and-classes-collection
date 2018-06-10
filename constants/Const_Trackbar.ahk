; ======================================================================================================================
; Function:         Constants for Trackbar controls (Slider)
; AHK version:      1.1.05 +
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; CCM_FIRST  = 0x2000
; TRBN_FIRST = -1501    ; trackbar (>= Vista)
; WM_USER    = 0x0400
; Class ================================================================================================================
Global WC_TRACKBAR             := "msctls_trackbar32"
; Messages =============================================================================================================
Global TBM_CLEARSEL            := 0x0413   ; (WM_USER + 19)
Global TBM_CLEARTICS           := 0x0409   ; (WM_USER + 9)
Global TBM_GETBUDDY            := 0x0421   ; (WM_USER + 33)    ; wparam = BOOL fLeft (or right)
Global TBM_GETCHANNELRECT      := 0x041A   ; (WM_USER + 26)
Global TBM_GETLINESIZE         := 0x0418   ; (WM_USER + 24)
Global TBM_GETNUMTICS          := 0x0410   ; (WM_USER + 16)
Global TBM_GETPAGESIZE         := 0x0416   ; (WM_USER + 22)
Global TBM_GETPOS              := 0x0400   ; (WM_USER)
Global TBM_GETPTICS            := 0x040E   ; (WM_USER + 14)
Global TBM_GETRANGEMAX         := 0x0402   ; (WM_USER + 2)
Global TBM_GETRANGEMIN         := 0x0401   ; (WM_USER + 1)
Global TBM_GETSELEND           := 0x0412   ; (WM_USER + 18)
Global TBM_GETSELSTART         := 0x0411   ; (WM_USER + 17)
Global TBM_GETTHUMBLENGTH      := 0x041C   ; (WM_USER + 28)
Global TBM_GETTHUMBRECT        := 0x0419   ; (WM_USER + 25)
Global TBM_GETTIC              := 0x0403   ; (WM_USER + 3)
Global TBM_GETTICPOS           := 0x040F   ; (WM_USER + 15)
Global TBM_GETTOOLTIPS         := 0x041E   ; (WM_USER + 30)
Global TBM_GETUNICODEFORMAT    := 0x2006   ; (CCM_FIRST + 6)   ; CCM_GETUNICODEFORMAT
Global TBM_SETBUDDY            := 0x0420   ; (WM_USER + 32)    ; wparam = BOOL fLeft (or right)
Global TBM_SETLINESIZE         := 0x0417   ; (WM_USER + 23)
Global TBM_SETPAGESIZE         := 0x0415   ; (WM_USER + 21)
Global TBM_SETPOS              := 0x0405   ; (WM_USER + 5)
Global TBM_SETPOSNOTIFY        := 0x0422   ; (WM_USER + 34)
Global TBM_SETRANGE            := 0x0406   ; (WM_USER + 6)
Global TBM_SETRANGEMAX         := 0x0408   ; (WM_USER + 8)
Global TBM_SETRANGEMIN         := 0x0407   ; (WM_USER + 7)
Global TBM_SETSEL              := 0x040A   ; (WM_USER + 10)
Global TBM_SETSELEND           := 0x040C   ; (WM_USER + 12)
Global TBM_SETSELSTART         := 0x040B   ; (WM_USER + 11)
Global TBM_SETTHUMBLENGTH      := 0x041B   ; (WM_USER + 27)
Global TBM_SETTIC              := 0x0404   ; (WM_USER + 4)
Global TBM_SETTICFREQ          := 0x0414   ; (WM_USER + 20)
Global TBM_SETTIPSIDE          := 0x041F   ; (WM_USER + 31)
Global TBM_SETTOOLTIPS         := 0x041D   ; (WM_USER + 29)
Global TBM_SETUNICODEFORMAT    := 0x2005   ; (CCM_FIRST + 5)   ; CCM_SETUNICODEFORMAT
; Notifications ========================================================================================================
Global TRBN_THUMBPOSCHANGING   := -1502    ; (TRBN_FIRST-1)    ; >= Vista
; Styles ===============================================================================================================
Global TBS_AUTOTICKS           := 0x0001
Global TBS_BOTH                := 0x0008
Global TBS_BOTTOM              := 0x0000
Global TBS_DOWNISLEFT          := 0x0400  ; Down=Left and Up=Right (default is Down=Right and Up=Left)
Global TBS_ENABLESELRANGE      := 0x0020
Global TBS_FIXEDLENGTH         := 0x0040
Global TBS_HORZ                := 0x0000
Global TBS_LEFT                := 0x0004
Global TBS_NOTHUMB             := 0x0080
Global TBS_NOTICKS             := 0x0010
Global TBS_NOTIFYBEFOREMOVE    := 0x0800  ; >= Vista : Trackbar should notify parent before repositioning the slider
;                                           due touser action (enables snapping)
Global TBS_REVERSED            := 0x0200  ; Accessibility hint: the smaller number (usually the min value) means "high"
;                                           andthe larger number (usually the max value) means "low"
Global TBS_RIGHT               := 0x0000
Global TBS_TOOLTIPS            := 0x0100
Global TBS_TOP                 := 0x0004
Global TBS_TRANSPARENTBKGND    := 0x1000  ; >= Vista : Background is painted by the parent via WM_PRINTCLIENT
Global TBS_VERT                := 0x0002
; Others ===============================================================================================================
; Custom draw item specs
Global TBCD_CHANNEL            := 0x0003
Global TBCD_THUMB              := 0x0002
Global TBCD_TICS               := 0x0001
; Interaction notification codes
Global TB_BOTTOM               := 7
Global TB_ENDTRACK             := 8
Global TB_LINEDOWN             := 1
Global TB_LINEUP               := 0
Global TB_PAGEDOWN             := 3
Global TB_PAGEUP               := 2
Global TB_THUMBPOSITION        := 4
Global TB_THUMBTRACK           := 5
Global TB_TOP                  := 6
; ======================================================================================================================