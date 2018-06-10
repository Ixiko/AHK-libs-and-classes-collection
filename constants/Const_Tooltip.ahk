; ======================================================================================================================
; Function:         Constants for Tooltip controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; Remarks:          Although not a built-in AHK GUI control it might be useful to create Tooltips for the built-in.
; ======================================================================================================================
; CCM_FIRST = 0x2000
; TTN_FIRST = -520
; WM_USER   = 0x0400
; ======================================================================================================================
; Class ================================================================================================================
Global WC_TOOLTIP          := "tooltips_class32"
; Messages =============================================================================================================
Global TTM_ACTIVATE        := 0x0401 ; (WM_USER + 1)
Global TTM_ADDTOOLA        := 0x0404 ; (WM_USER + 4)
Global TTM_ADDTOOLW        := 0x0432 ; (WM_USER + 50)
Global TTM_ADJUSTRECT      := 0x041F ; (WM_USER + 31)
Global TTM_DELTOOLA        := 0x0405 ; (WM_USER + 5)
Global TTM_DELTOOLW        := 0x0433 ; (WM_USER + 51)
Global TTM_ENUMTOOLSA      := 0x040E ; (WM_USER + 14)
Global TTM_ENUMTOOLSW      := 0x043A ; (WM_USER + 58)
Global TTM_GETBUBBLESIZE   := 0x041E ; (WM_USER + 30)
Global TTM_GETCURRENTTOOLA := 0x040F ; (WM_USER + 15)
Global TTM_GETCURRENTTOOLW := 0x043B ; (WM_USER + 59)
Global TTM_GETDELAYTIME    := 0x0415 ; (WM_USER + 21)
Global TTM_GETMARGIN       := 0x041B ; (WM_USER + 27) lParam = lprc
Global TTM_GETMAXTIPWIDTH  := 0x0419 ; (WM_USER + 25)
Global TTM_GETTEXTA        := 0x040B ; (WM_USER + 11)
Global TTM_GETTEXTW        := 0x0438 ; (WM_USER + 56)
Global TTM_GETTIPBKCOLOR   := 0x0416 ; (WM_USER + 22)
Global TTM_GETTIPTEXTCOLOR := 0x0417 ; (WM_USER + 23)
Global TTM_GETTITLE        := 0x0423 ; (WM_USER + 35) wParam = 0, lParam = TTGETTITLE*
Global TTM_GETTOOLCOUNT    := 0x040D ; (WM_USER + 13)
Global TTM_GETTOOLINFOA    := 0x0408 ; (WM_USER + 8)
Global TTM_GETTOOLINFOW    := 0x0435 ; (WM_USER + 53)
Global TTM_HITTESTA        := 0x040A ; (WM_USER + 10)
Global TTM_HITTESTW        := 0x0437 ; (WM_USER + 55)
Global TTM_NEWTOOLRECTA    := 0x0406 ; (WM_USER + 6)
Global TTM_NEWTOOLRECTW    := 0x0434 ; (WM_USER + 52)
Global TTM_POP             := 0x041C ; (WM_USER + 28)
Global TTM_POPUP           := 0x0422 ; (WM_USER + 34)
Global TTM_RELAYEVENT      := 0x0407 ; (WM_USER + 7)  Win7: wParam = GetMessageExtraInfo() when relaying WM_MOUSEMOVE
Global TTM_SETDELAYTIME    := 0x0403 ; (WM_USER + 3)
Global TTM_SETMARGIN       := 0x041A ; (WM_USER + 26) lParam = lprc
Global TTM_SETMAXTIPWIDTH  := 0x0418 ; (WM_USER + 24)
Global TTM_SETTIPBKCOLOR   := 0x0413 ; (WM_USER + 19)
Global TTM_SETTIPTEXTCOLOR := 0x0414 ; (WM_USER + 20)
Global TTM_SETTITLEA       := 0x0420 ; (WM_USER + 32) wParam = TTI_*, lParam = char* szTitle
Global TTM_SETTITLEW       := 0x0421 ; (WM_USER + 33) wParam = TTI_*, lParam = wchar* szTitle
Global TTM_SETTOOLINFOA    := 0x0409 ; (WM_USER + 9)
Global TTM_SETTOOLINFOW    := 0x0636 ; (WM_USER + 54)
Global TTM_SETWINDOWTHEME  := 0x200B ; (CCM_FIRST + 0xB) CCM_SETWINDOWTHEME
Global TTM_TRACKACTIVATE   := 0x0411 ; (WM_USER + 17) wParam = TRUE/FALSE start end  lparam = LPTOOLINFO
Global TTM_TRACKPOSITION   := 0x0412 ; (WM_USER + 18) lParam = dwPos
Global TTM_UPDATE          := 0x041D ; (WM_USER + 29)
Global TTM_UPDATETIPTEXTA  := 0x040C ; (WM_USER + 12)
Global TTM_UPDATETIPTEXTW  := 0x0439 ; (WM_USER + 57)
Global TTM_WINDOWFROMPOINT := 0x0410 ; (WM_USER + 16)
; Notifications ========================================================================================================
Global TTN_GETDISPINFOA    := -520   ; (TTN_FIRST - 0)
Global TTN_GETDISPINFOW    := -530   ; (TTN_FIRST - 10)
Global TTN_LINKCLICK       := -523   ; (TTN_FIRST - 3)
Global TTN_NEEDTEXTA       := -520   ; TTN_GETDISPINFOA
Global TTN_NEEDTEXTW       := -530   ; TTN_GETDISPINFOW
Global TTN_POP             := -522   ; (TTN_FIRST - 2)
Global TTN_SHOW            := -521   ; (TTN_FIRST - 1)
; Styles ===============================================================================================================
Global TTS_ALWAYSTIP       := 0x0001
Global TTS_BALLOON         := 0x0040
Global TTS_CLOSE           := 0x0080
Global TTS_NOANIMATE       := 0x0010
Global TTS_NOFADE          := 0x0020
Global TTS_NOPREFIX        := 0x0002
Global TTS_USEVISUALSTYLE  := 0x0100   ; >= Vista: use themed hyperlinks
; Others ===============================================================================================================
; TOOLINFO uFlags
; Use TTF_CENTERTIP to center around trackpoint in trackmode -OR- to center around tool in normal mode.
; Use TTF_ABSOLUTE to place the tip exactly at the track coords when in tracking mode.
; TTF_ABSOLUTE can be used in conjunction with TTF_CENTERTIP to center the tip absolutely about the track point.
Global TTF_ABSOLUTE        := 0x0080
Global TTF_CENTERTIP       := 0x0002
Global TTF_DI_SETITEM      := 0x8000 ; valid only on the TTN_NEEDTEXT callback
Global TTF_IDISHWND        := 0x0001
Global TTF_PARSELINKS      := 0x1000
Global TTF_RTLREADING      := 0x0004
Global TTF_SUBCLASS        := 0x0010
Global TTF_TRACK           := 0x0020
Global TTF_TRANSPARENT     := 0x0100
; TTMSETDELAYTIME
Global TTDT_AUTOMATIC      := 0
Global TTDT_AUTOPOP        := 2
Global TTDT_INITIAL        := 3
Global TTDT_RESHOW         := 1
; TTM_SETTITLE Tooltip icons
Global TTI_ERROR           := 3
Global TTI_ERROR_LARGE     := 6      ; >= Vista
Global TTI_INFO            := 1
Global TTI_INFO_LARGE      := 4      ; >= Vista
Global TTI_NONE            := 0
Global TTI_WARNING         := 2
Global TTI_WARNING_LARGE   := 5      ; >= Vista
; ======================================================================================================================