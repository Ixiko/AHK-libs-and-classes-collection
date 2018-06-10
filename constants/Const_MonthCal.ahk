; ======================================================================================================================
; Function:         Constants for MonthCal controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; CCM_FIRST = 0x2000
; MCM_FIRST = 0x1000
; MCN_FIRST = -746
; ======================================================================================================================
; Class ================================================================================================================
Global WC_MONTHCAL             := "SysMonthCal32"
; Messages =============================================================================================================
Global MCM_GETCALENDARBORDER   := 0x101F ; (MCM_FIRST + 31) >= Vista
Global MCM_GETCALENDARCOUNT    := 0x1017 ; (MCM_FIRST + 23) >= Vista
Global MCM_GETCALENDARGRIDINFO := 0x1018 ; (MCM_FIRST + 24) >= Vista
Global MCM_GETCALID            := 0x101B ; (MCM_FIRST + 27) >= Vista
Global MCM_GETCOLOR            := 0x100B ; (MCM_FIRST + 11)
Global MCM_GETCURRENTVIEW      := 0x1016 ; (MCM_FIRST + 22) >= Vista
Global MCM_GETCURSEL           := 0x1001 ; (MCM_FIRST + 1)
Global MCM_GETFIRSTDAYOFWEEK   := 0x1010 ; (MCM_FIRST + 16)
Global MCM_GETMAXSELCOUNT      := 0x1003 ; (MCM_FIRST + 3)
Global MCM_GETMINREQRECT       := 0x1009 ; (MCM_FIRST + 9)
Global MCM_GETMONTHDELTA       := 0x1013 ; (MCM_FIRST + 19)
Global MCM_GETMONTHRANGE       := 0x1007 ; (MCM_FIRST + 7)
Global MCM_GETRANGE            := 0x1011 ; (MCM_FIRST + 17)
Global MCM_GETSELRANGE         := 0x1005 ; (MCM_FIRST + 5)
Global MCM_GETTODAY            := 0x100D ; (MCM_FIRST + 13)
Global MCM_GETUNICODEFORMAT    := 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
Global MCM_HITTEST             := 0x100E ; (MCM_FIRST + 14)
Global MCM_SETCALENDARBORDER   := 0x101E ; (MCM_FIRST + 30) >= Vista
Global MCM_SETCALID            := 0x101C ; (MCM_FIRST + 28) >= Vista
Global MCM_SETCOLOR            := 0x100A ; (MCM_FIRST + 10)
Global MCM_SETCURRENTVIEW      := 0x1020 ; (MCM_FIRST + 32) >= Vista
Global MCM_SETCURSEL           := 0x1002 ; (MCM_FIRST + 2)
Global MCM_SETDAYSTATE         := 0x1008 ; (MCM_FIRST + 8)
Global MCM_SETFIRSTDAYOFWEEK   := 0x100F ; (MCM_FIRST + 15)
Global MCM_SETMAXSELCOUNT      := 0x1004 ; (MCM_FIRST + 4)
Global MCM_SETMONTHDELTA       := 0x1014 ; (MCM_FIRST + 20)
Global MCM_SETRANGE            := 0x1012 ; (MCM_FIRST + 18)
Global MCM_SETSELRANGE         := 0x1006 ; (MCM_FIRST + 6)
Global MCM_SETTODAY            := 0x100C ; (MCM_FIRST + 12)
Global MCM_SETUNICODEFORMAT    := 0x2005 ; (CCM_FIRST + 5) CCM_SETUNICODEFORMAT
Global MCM_SIZERECTTOMIN       := 0x101D ; (MCM_FIRST + 29) >= Vista
; Notifications ========================================================================================================
Global MCN_SELECT              := -746 ; (MCN_FIRST)
Global MCN_GETDAYSTATE         := -747 ; (MCN_FIRST - 1)
Global MCN_SELCHANGE           := -749 ; (MCN_FIRST - 3)
Global MCN_VIEWCHANGE          := -750 ; (MCN_FIRST - 4)
; Styles ===============================================================================================================
Global MCS_DAYSTATE            := 0x0001
Global MCS_MULTISELECT         := 0x0002
Global MCS_WEEKNUMBERS         := 0x0004
Global MCS_NOTODAYCIRCLE       := 0x0008
Global MCS_NOTODAY             := 0x0010
Global MCS_NOTRAILINGDATES     := 0x0040 ; >= Vista
Global MCS_SHORTDAYSOFWEEK     := 0x0080 ; >= Vista
Global MCS_NOSELCHANGEONNAV    := 0x0100 ; >= Vista
; Errors and Other =====================================================================================================
; MCM_GET/SETCOLOROR
Global MCSC_BACKGROUND         := 0 ; the background color := (between months)
Global MCSC_MONTHBK            := 4 ; background within the month cal
Global MCSC_TEXT               := 1 ; the dates
Global MCSC_TITLEBK            := 2 ; background of the title
Global MCSC_TITLETEXT          := 3
Global MCSC_TRAILINGTEXT       := 5 ; the text color of header & trailing days
; MCM_HITTET
Global MCHT_CALENDAR           := 0x00020000
Global MCHT_CALENDARBK         := 0x00020000 ; (MCHT_CALENDAR)
Global MCHT_CALENDARCONTROL    := 0x00100000 ; >= Vista
Global MCHT_CALENDARDATE       := 0x00020001 ; (MCHT_CALENDAR | 0x0001)
Global MCHT_CALENDARDATEMAX    := 0x00020005 ; (MCHT_CALENDAR | 0x0005)
Global MCHT_CALENDARDATEMIN    := 0x00020004 ; (MCHT_CALENDAR | 0x0004)
Global MCHT_CALENDARDATENEXT   := 0x01020000 ; (MCHT_CALENDARDATE | MCHT_NEXT)
Global MCHT_CALENDARDATEPREV   := 0x02020000 ; (MCHT_CALENDARDATE | MCHT_PREV)
Global MCHT_CALENDARDAY        := 0x00020002 ; (MCHT_CALENDAR | 0x0002)
Global MCHT_CALENDARWEEKNUM    := 0x00020003 ; (MCHT_CALENDAR | 0x0003)
Global MCHT_NEXT               := 0x01000000 ; these indicate that hitting
Global MCHT_NOWHERE            := 0x00000000
Global MCHT_PREV               := 0x02000000 ; here will go to the next/prev month
Global MCHT_TITLE              := 0x00010000
Global MCHT_TITLEBK            := 0x00010000 ; (MCHT_TITLE)
Global MCHT_TITLEBTNNEXT       := 0x01010003 ; (MCHT_TITLE | MCHT_NEXT | 0x0003)
Global MCHT_TITLEBTNPREV       := 0x02010003 ; (MCHT_TITLE | MCHT_PREV | 0x0003)
Global MCHT_TITLEMONTH         := 0x00010001 ; (MCHT_TITLE | 0x0001)
Global MCHT_TITLEYEAR          := 0x00010002 ; (MCHT_TITLE | 0x0002)
Global MCHT_TODAYLINK          := 0x00030000
; MCM_GET/SETCURRENTVIEW >= Vista
Global MCMV_CENTURY            := 3
Global MCMV_DECADE             := 2
Global MCMV_MAX                := 3 ; MCMV_CENTURY
Global MCMV_MONTH              := 0
Global MCMV_YEAR               := 1
; MCM_GET/SETCALENDARGRIDINFO >= Vista
Global MCGIF_DATE              := 0x00000001
Global MCGIF_NAME              := 0x00000004
Global MCGIF_RECT              := 0x00000002
Global MCGIP_CALENDAR          := 4
Global MCGIP_CALENDARBODY      := 6
Global MCGIP_CALENDARCELL      := 8
Global MCGIP_CALENDARCONTROL   := 0
Global MCGIP_CALENDARHEADER    := 5
Global MCGIP_CALENDARROW       := 7
Global MCGIP_FOOTER            := 3
Global MCGIP_NEXT              := 1
Global MCGIP_PREV              := 2
; ======================================================================================================================