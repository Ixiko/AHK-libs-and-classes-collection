; ======================================================================================================================
; Function:         Constants for Edit controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; ECM_FIRST = 0x1500, all messages based on ECM_FIRST need Unicode strings
; ======================================================================================================================
; Class ================================================================================================================
Global WC_EDIT                := "Edit"
; Messages =============================================================================================================
Global EM_CANUNDO             := 0x00C6
Global EM_CHARFROMPOS         := 0x00D7
Global EM_EMPTYUNDOBUFFER     := 0x00CD
Global EM_FMTLINES            := 0x00C8
Global EM_GETCUEBANNER        := 0x1502 ; (ECM_FIRST + 2) Unicode
Global EM_GETFIRSTVISIBLELINE := 0x00CE
Global EM_GETHANDLE           := 0x00BD
Global EM_GETHILITE           := 0x1506 ; (ECM_FIRST + 6) Unicode >= Vista, not documented
Global EM_GETIMESTATUS        := 0x00D9
Global EM_GETLIMITTEXT        := 0x00D5
Global EM_GETLINE             := 0x00C4
Global EM_GETLINECOUNT        := 0x00BA
Global EM_GETMARGINS          := 0x00D4
Global EM_GETMODIFY           := 0x00B8
Global EM_GETPASSWORDCHAR     := 0x00D2
Global EM_GETRECT             := 0x00B2
Global EM_GETSEL              := 0x00B0
Global EM_GETTHUMB            := 0x00BE
Global EM_GETWORDBREAKPROC    := 0x00D1
Global EM_HIDEBALLOONTIP      := 0x1504 ; (ECM_FIRST + 4) Unicode
Global EM_LIMITTEXT           := 0x00C5
Global EM_LINEFROMCHAR        := 0x00C9
Global EM_LINEINDEX           := 0x00BB
Global EM_LINELENGTH          := 0x00C1
Global EM_LINESCROLL          := 0x00B6
Global EM_POSFROMCHAR         := 0x00D6
Global EM_REPLACESEL          := 0x00C2
Global EM_SCROLL              := 0x00B5
Global EM_SCROLLCARET         := 0x00B7
Global EM_SETCUEBANNER        := 0x1501 ; (ECM_FIRST + 1) Unicode
Global EM_SETHANDLE           := 0x00BC
Global EM_SETHILITE           := 0x1505 ; (ECM_FIRST + 5) Unicode >= Vista, not documented
Global EM_SETIMESTATUS        := 0x00D8
Global EM_SETLIMITTEXT        := 0x00C5 ; EM_LIMITTEXT
Global EM_SETMARGINS          := 0x00D3
Global EM_SETMODIFY           := 0x00B9
Global EM_SETPASSWORDCHAR     := 0x00CC
Global EM_SETREADONLY         := 0x00CF
Global EM_SETRECT             := 0x00B3
Global EM_SETRECTNP           := 0x00B4
Global EM_SETSEL              := 0x00B1
Global EM_SETTABSTOPS         := 0x00CB
Global EM_SETWORDBREAKPROC    := 0x00D0
Global EM_SHOWBALLOONTIP      := 0x1503 ; (ECM_FIRST + 2) Unicode
Global EM_UNDO                := 0x00C7
; Notifications ========================================================================================================
Global EN_ALIGN_LTR_EC        := 0x0700
Global EN_ALIGN_RTL_EC        := 0x0701
Global EN_CHANGE              := 0x0300
Global EN_ERRSPACE            := 0x0500
Global EN_HSCROLL             := 0x0601
Global EN_KILLFOCUS           := 0x0200
Global EN_MAXTEXT             := 0x0501
Global EN_SETFOCUS            := 0x0100
Global EN_UPDATE              := 0x0400
Global EN_VSCROLL             := 0x0602
; Styles ===============================================================================================================
Global ES_AUTOHSCROLL         := 0x0080
Global ES_AUTOVSCROLL         := 0x0040
Global ES_CENTER              := 0x0001
Global ES_LEFT                := 0x0000
Global ES_LOWERCASE           := 0x0010
Global ES_MULTILINE           := 0x0004
Global ES_NOHIDESEL           := 0x0100
Global ES_NUMBER              := 0x2000
Global ES_OEMCONVERT          := 0x0400
Global ES_PASSWORD            := 0x0020
Global ES_READONLY            := 0x0800
Global ES_RIGHT               := 0x0002
Global ES_UPPERCASE           := 0x0008
Global ES_WANTRETURN          := 0x1000
; Parameters for EM_SETMARGINS =========================================================================================
Global EC_LEFTMARGIN          := 0x0001
Global EC_RIGHTMARGIN         := 0x0002
Global EC_USEFONTINFO         := 0xFFFF
; Parameters for EM_SETIMESTATUS =======================================================================================
Global EMSIS_COMPOSITIONSTRING        := 0x0001
Global EIMES_GETCOMPSTRATONCE         := 0x0001 
Global EIMES_CANCELCOMPSTRINFOCUS     := 0x0002 
Global EIMES_COMPLETECOMPSTRKILLFOCUS := 0x0004 
; Icons for EM_SHOWBALLOONTIP ==========================================================================================
; TTI_NONE                := 0
; TTI_INFO                := 1
; TTI_WARNING             := 2
; TTI_ERROR               := 3
; TTI_INFO_LARGE          := 4  ; >= Vista
; TTI_WARNING_LARGE       := 5  ; >= Vista
; TTI_ERROR_LARGE         := 6  ; >= Vista
; ======================================================================================================================