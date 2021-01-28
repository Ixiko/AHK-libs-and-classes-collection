; ======================================================================================================================
; Function:         Constants for DateTime controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; DTM_FIRST  = 0x1000
; DTN_FIRST  = -740 datetimepick
; DTN_FIRST2 = -753 datetimepick2
; ======================================================================================================================
Global WC_DATETIME                := "SysDateTimePick32"
; Messages =============================================================================================================
Global DTM_CLOSEMONTHCAL          := 0x100D  ; (DTM_FIRST + 13) >= Vista
Global DTM_GETDATETIMEPICKERINFO  := 0x100E  ; (DTM_FIRST + 14) >= Vista
Global DTM_GETIDEALSIZE           := 0x100F  ; (DTM_FIRST + 15) >= Vista
Global DTM_GETMCCOLOR             := 0x1007  ; (DTM_FIRST + 7)
Global DTM_GETMCFONT              := 0x100A  ; (DTM_FIRST + 10)
Global DTM_GETMCSTYLE             := 0x100C  ; (DTM_FIRST + 12) >= Vista
Global DTM_GETMONTHCAL            := 0x1008  ; (DTM_FIRST + 8)
Global DTM_GETRANGE               := 0x1003  ; (DTM_FIRST + 3)
Global DTM_GETSYSTEMTIME          := 0x1001  ; (DTM_FIRST + 1)
Global DTM_SETFORMATA             := 0x1005  ; (DTM_FIRST + 5)
Global DTM_SETFORMATW             := 0x1032  ; (DTM_FIRST + 50)
Global DTM_SETMCCOLOR             := 0x1006  ; (DTM_FIRST + 6)
Global DTM_SETMCFONT              := 0x1009  ; (DTM_FIRST + 9)
Global DTM_SETMCSTYLE             := 0x100B  ; (DTM_FIRST + 11) >= Vista
Global DTM_SETRANGE               := 0x1004  ; (DTM_FIRST + 4)
Global DTM_SETSYSTEMTIME          := 0x1002  ; (DTM_FIRST + 2)
; Notifications ========================================================================================================
Global DTN_CLOSEUP                := -753    ; (DTN_FIRST2)     MonthCal is popping up
Global DTN_DATETIMECHANGE         := -759    ; (DTN_FIRST2 - 6) the systemtime has changed
Global DTN_DROPDOWN               := -754    ; (DTN_FIRST2 - 1) MonthCal has dropped down
Global DTN_FORMATA                := -756    ; (DTN_FIRST2 - 3) query display for app format field := (X)
Global DTN_FORMATQUERYA           := -755    ; (DTN_FIRST2 - 2) query formatting info for app format field := (X)
Global DTN_FORMATQUERYW           := -742    ; (DTN_FIRST - 2)
Global DTN_FORMATW                := -743    ; (DTN_FIRST - 3)
Global DTN_USERSTRINGA            := -758    ; (DTN_FIRST2 - 5) the user has entered a string
Global DTN_USERSTRINGW            := -745    ; (DTN_FIRST - 5)
Global DTN_WMKEYDOWNA             := -757    ; (DTN_FIRST2 - 4) modify keydown on app format field := (X)
Global DTN_WMKEYDOWNW             := -744    ; (DTN_FIRST - 4)
; Styles ===============================================================================================================
Global DTS_APPCANPARSE            := 0x0010  ; allow user entered strings (app MUST respond to DTN_USERSTRING)
Global DTS_LONGDATEFORMAT         := 0x0004  ; use the long date format (app must forward WM_WININICHANGE messages)
Global DTS_RIGHTALIGN             := 0x0020  ; right-align popup instead of left-align it
Global DTS_SHORTDATECENTURYFORMAT := 0x000C  ; short date format with century (app must forward WM_WININICHANGE messages)
Global DTS_SHORTDATEFORMAT        := 0x0000  ; use the short date format (app must forward WM_WININICHANGE messages)
Global DTS_SHOWNONE               := 0x0002  ; allow a NONE selection
Global DTS_TIMEFORMAT             := 0x0009  ; use the time format (app must forward WM_WININICHANGE messages)
Global DTS_UPDOWN                 := 0x0001  ; use UPDOWN instead of MONTHCAL
; Errors and Other =====================================================================================================
Global GDT_ERROR := -1
Global GDT_NONE  := 1
Global GDT_VALID := 0
Global GDTR_MAX  := 2
Global GDTR_MIN  := 1
; ======================================================================================================================