; Source: http://www.autohotkey.com/community/viewtopic.php?f=13&t=85383
; Just packed all super global gui constants into a single function.
; 23.4.2012

MsgBox % GuiConstants("BM_Click")
MsgBox % GuiConstants("MCM_SETCALID")

GuiConstants(constant)
{
static init := false

if (init == false)
{
init := true

; ======================================================================================================================
; Function:         Constants for Button controls (Button, Checkbox, Radio, GroupBox)
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; BCM_FIRST := 0x1600
; BCN_FIRST := -1250
; ======================================================================================================================
; Class ================================================================================================================
Static WC_BUTTON            := "Button"
; Messages =============================================================================================================
Static BCM_GETIDEALSIZE     := 0x1601 ; (BCM_FIRST + 0x0001)
Static BCM_GETIMAGELIST     := 0x1603 ; (BCM_FIRST + 0x0003)
Static BCM_GETNOTE          := 0x160A ; (BCM_FIRST + 0x000A) >= Vista
Static BCM_GETNOTELENGTH    := 0x160B ; (BCM_FIRST + 0x000B) >= Vista
Static BCM_GETSPLITINFO     := 0x1608 ; (BCM_FIRST + 0x0008) >= Vista
Static BCM_GETTEXTMARGIN    := 0x1605 ; (BCM_FIRST + 0x0005)
Static BCM_SETDROPDOWNSTATE := 0x1606 ; (BCM_FIRST + 0x0006) >= Vista
Static BCM_SETIMAGELIST     := 0x1602 ; (BCM_FIRST + 0x0002)
Static BCM_SETNOTE          := 0x1609 ; (BCM_FIRST + 0x0009) >= Vista
Static BCM_SETSHIELD        := 0x160C ; (BCM_FIRST + 0x000C) >= Vista
Static BCM_SETSPLITINFO     := 0x1607 ; (BCM_FIRST + 0x0007) >= Vista
Static BCM_SETTEXTMARGIN    := 0x1604 ; (BCM_FIRST + 0x0004)
Static BM_CLICK             := 0x00F5
Static BM_GETCHECK          := 0x00F0
Static BM_GETIMAGE          := 0x00F6
Static BM_GETSTATE          := 0x00F2
Static BM_SETCHECK          := 0x00F1
Static BM_SETDONTCLICK      := 0x00F8 ; >= Vista
Static BM_SETIMAGE          := 0x00F7
Static BM_SETSTATE          := 0x00F3
Static BM_SETSTYLE          := 0x00F4
; Notifications ========================================================================================================
Static BCN_DROPDOWN         := -1248  ; (BCN_FIRST + 0x0002) >= Vista
Static BCN_HOTITEMCHANGE    := -1249  ; (BCN_FIRST + 0x0001)
Static BN_CLICKED           := 0x0000
Static BN_DBLCLK            := 0x0005 ; BN_DOUBLECLICKED
Static BN_DISABLE           := 0x0004
Static BN_DOUBLECLICKED     := 0x0005
Static BN_HILITE            := 0x0002
Static BN_KILLFOCUS         := 0x0007
Static BN_PAINT             := 0x0001
Static BN_PUSHED            := 0x0002 ; BN_HILITE
Static BN_SETFOCUS          := 0x0006
Static BN_UNHILITE          := 0x0003
Static BN_UNPUSHED          := 0x0003 ; BN_UNHILITE
; Styles ===============================================================================================================
Static BS_3STATE            := 0x0005
Static BS_AUTO3STATE        := 0x0006
Static BS_AUTOCHECKBOX      := 0x0003
Static BS_AUTORADIOBUTTON   := 0x0009
Static BS_BITMAP            := 0x0080
Static BS_BOTTOM            := 0x0800
Static BS_CENTER            := 0x0300
Static BS_CHECKBOX          := 0x0002
Static BS_COMMANDLINK       := 0x000E ; >= Vista
Static BS_DEFCOMMANDLINK    := 0x000F ; >= Vista
Static BS_DEFPUSHBUTTON     := 0x0001
Static BS_DEFSPLITBUTTON    := 0x000D ; >= Vista
Static BS_FLAT              := 0x8000
Static BS_GROUPBOX          := 0x0007
Static BS_ICON              := 0x0040
Static BS_LEFT              := 0x0100
Static BS_LEFTTEXT          := 0x0020
Static BS_MULTILINE         := 0x2000
Static BS_NOTIFY            := 0x4000
Static BS_OWNERDRAW         := 0x000B
Static BS_PUSHBOX           := 0x000A
Static BS_PUSHBUTTON        := 0x0000
Static BS_PUSHLIKE          := 0x1000
Static BS_RADIOBUTTON       := 0x0004
Static BS_RIGHT             := 0x0200
Static BS_RIGHTBUTTON       := 0x0020 ; BS_LEFTTEXT
Static BS_SPLITBUTTON       := 0x000C ; >= Vista
Static BS_TEXT              := 0x0000
Static BS_TOP               := 0x0400
Static BS_TYPEMASK          := 0x000F
Static BS_USERBUTTON        := 0x0008
Static BS_VCENTER           := 0x0C00
; Buton states =========================================================================================================
Static BST_CHECKED          := 0x0001
Static BST_DROPDOWNPUSHED   := 0x0400 ; >= Vista
Static BST_FOCUS            := 0x0008
Static BST_HOT              := 0x0200
Static BST_INDETERMINATE    := 0x0002
Static BST_PUSHED           := 0x0004
Static BST_UNCHECKED        := 0x0000
; Vista SPLIT BUTTON INFO mask flags ===================================================================================
Static BCSIF_GLYPH          := 0x0001
Static BCSIF_IMAGE          := 0x0002
Static BCSIF_SIZE           := 0x0008
Static BCSIF_STYLE          := 0x0004
; Vista SPLIT BUTTON STYLE flags =======================================================================================
Static BCSS_NOSPLIT         := 0x0001
Static BCSS_ALIGNLEFT       := 0x0004
Static BCSS_IMAGE           := 0x0008
Static BCSS_STRETCH         := 0x0002
; Button ImageList Constants ===========================================================================================
Static BUTTON_IMAGELIST_ALIGN_BOTTOM := 0x0003
Static BUTTON_IMAGELIST_ALIGN_CENTER := 0x0004 ; Doesn't draw text
Static BUTTON_IMAGELIST_ALIGN_RIGHT  := 0x0001
Static BUTTON_IMAGELIST_ALIGN_TOP    := 0x0002
; ==================================================

; ======================================================================================================================
; Function:         Constants for ComboBox controls (ComboBox, DropDownList)
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; CBM_FIRST = 0x1700
; ======================================================================================================================
; Class ================================================================================================================
Static WC_COMBOBOX              := "ComboBox"
; Messages =============================================================================================================
Static CB_ADDSTRING             := 0x0143
Static CB_DELETESTRING          := 0x0144
Static CB_DIR                   := 0x0145
Static CB_FINDSTRING            := 0x014C
Static CB_FINDSTRINGEXACT       := 0x0158
Static CB_GETCOMBOBOXINFO       := 0x0164
Static CB_GETCOUNT              := 0x0146
Static CB_GETCUEBANNER          := 0x1704 ; (CBM_FIRST + 4)
Static CB_GETCURSEL             := 0x0147
Static CB_GETDROPPEDCONTROLRECT := 0x0152
Static CB_GETDROPPEDSTATE       := 0x0157
Static CB_GETDROPPEDWIDTH       := 0x015F
Static CB_GETEDITSEL            := 0x0140
Static CB_GETEXTENDEDUI         := 0x0156
Static CB_GETHORIZONTALEXTENT   := 0x015D
Static CB_GETITEMDATA           := 0x0150
Static CB_GETITEMHEIGHT         := 0x0154
Static CB_GETLBTEXT             := 0x0148
Static CB_GETLBTEXTLEN          := 0x0149
Static CB_GETLOCALE             := 0x015A
Static CB_GETMINVISIBLE         := 0x1702 ; (CBM_FIRST + 2)
Static CB_GETTOPINDEX           := 0x015B
Static CB_INITSTORAGE           := 0x0161
Static CB_INSERTSTRING          := 0x014A
Static CB_LIMITTEXT             := 0x0141
Static CB_MULTIPLEADDSTRING     := 0x0163
Static CB_RESETCONTENT          := 0x014B
Static CB_SELECTSTRING          := 0x014D
Static CB_SETCUEBANNER          := 0x1703 ; (CBM_FIRST + 3)
Static CB_SETCURSEL             := 0x014E
Static CB_SETDROPPEDWIDTH       := 0x0160
Static CB_SETEDITSEL            := 0x0142
Static CB_SETEXTENDEDUI         := 0x0155
Static CB_SETHORIZONTALEXTENT   := 0x015E
Static CB_SETITEMDATA           := 0x0151
Static CB_SETITEMHEIGHT         := 0x0153
Static CB_SETLOCALE             := 0x0159
Static CB_SETMINVISIBLE         := 0x1701 ; (CBM_FIRST + 1)
Static CB_SETTOPINDEX           := 0x015C
Static CB_SHOWDROPDOWN          := 0x014F
; Notifications ========================================================================================================
Static CBN_CLOSEUP              := 8
Static CBN_DBLCLK               := 2
Static CBN_DROPDOWN             := 7
Static CBN_EDITCHANGE           := 5
Static CBN_EDITUPDATE           := 6
Static CBN_ERRSPACE             := -1
Static CBN_KILLFOCUS            := 4
Static CBN_SELCHANGE            := 1
Static CBN_SELENDCANCEL         := 10
Static CBN_SELENDOK             := 9
Static CBN_SETFOCUS             := 3
; Styles ===============================================================================================================
Static CBS_AUTOHSCROLL          := 0x0040
Static CBS_DISABLENOSCROLL      := 0x0800
Static CBS_DROPDOWN             := 0x0002
Static CBS_DROPDOWNLIST         := 0x0003
Static CBS_HASSTRINGS           := 0x0200
Static CBS_LOWERCASE            := 0x4000
Static CBS_NOINTEGRALHEIGHT     := 0x0400
Static CBS_OEMCONVERT           := 0x0080
Static CBS_OWNERDRAWFIXED       := 0x0010
Static CBS_OWNERDRAWVARIABLE    := 0x0020
Static CBS_SIMPLE               := 0x0001
Static CBS_SORT                 := 0x0100
Static CBS_UPPERCASE            := 0x2000
; Others ===============================================================================================================
; ComboBox return values
Static CB_OKAY                  := 0
Static CB_ERR                   := -1
Static CB_ERRSPACE              := -2
; ======================================================================================================================

; ======================================================================================================================
; Function:         Generic constants for common controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; CCM_FIRST = 0x2000    Common control shared messages
; NM_FIRST  = 0         Generic to all controls
; ======================================================================================================================
; Common control shared messages =======================================================================================
Static CCM_DPISCALE            := 0x200C ; (CCM_FIRST + 0xC) wParam == Awareness
Static CCM_GETCOLORSCHEME      := 0x2003 ; (CCM_FIRST + 3) fills in COLORSCHEME pointed to by lParam
Static CCM_GETDROPTARGET       := 0x2004 ; (CCM_FIRST + 4)
Static CCM_GETUNICODEFORMAT    := 0x2006 ; (CCM_FIRST + 6)
Static CCM_GETVERSION          := 0x2008 ; (CCM_FIRST + 0x8)
Static CCM_SETBKCOLOR          := 0x2001 ; (CCM_FIRST + 1) lParam is bkColor
Static CCM_SETCOLORSCHEME      := 0x2002 ; (CCM_FIRST + 2) lParam is color scheme
Static CCM_SETNOTIFYWINDOW     := 0x2009 ; (CCM_FIRST + 0x9) wParam == hwndParent.
Static CCM_SETUNICODEFORMAT    := 0x2005 ; (CCM_FIRST + 5)
Static CCM_SETVERSION          := 0x2007 ; (CCM_FIRST + 0x7)
Static CCM_SETWINDOWTHEME      := 0x200B ; (CCM_FIRST + 0xB)
; Common control styles ================================================================================================
Static CCS_ADJUSTABLE          := 0x0020
Static CCS_BOTTOM              := 0x0003
Static CCS_LEFT                := 0x0081 ; (CCS_VERT | CCS_TOP)
Static CCS_NODIVIDER           := 0x0040
Static CCS_NOMOVEX             := 0x0082 ; (CCS_VERT | CCS_NOMOVEY)
Static CCS_NOMOVEY             := 0x0002
Static CCS_NOPARENTALIGN       := 0x0008
Static CCS_NORESIZE            := 0x0004
Static CCS_RIGHT               := 0x0083 ; (CCS_VERT | CCS_BOTTOM)
Static CCS_TOP                 := 0x0001
Static CCS_VERT                := 0x0080
; Generic WM_NOTIFY notification codes =================================================================================
Static NM_CHAR                 := -18 ; (NM_FIRST-18) uses NMCHAR struct
Static NM_CLICK                := -2  ; (NM_FIRST-2)  uses NMCLICK struct
Static NM_CUSTOMDRAW           := -12 ; (NM_FIRST-12)
Static NM_CUSTOMTEXT           := -24 ; (NM_FIRST-24) >= Vista uses NMCUSTOMTEXT struct
Static NM_DBLCLK               := -3  ; (NM_FIRST-3)
Static NM_FONTCHANGED          := -23 ; (NM_FIRST-23) >= Vista
Static NM_HOVER                := -13 ; (NM_FIRST-13)
Static NM_KEYDOWN              := -15 ; (NM_FIRST-15) uses NMKEY struct
Static NM_KILLFOCUS            := -8  ; (NM_FIRST-8)
Static NM_LDOWN                := -20 ; (NM_FIRST-20)
Static NM_NCHITTEST            := -14 ; (NM_FIRST-14) uses NMMOUSE struct
Static NM_OUTOFMEMORY          := -1  ; (NM_FIRST-1)
Static NM_RCLICK               := -5  ; (NM_FIRST-5)  uses NMCLICK struct
Static NM_RDBLCLK              := -6  ; (NM_FIRST-6)
Static NM_RDOWN                := -21 ; (NM_FIRST-21)
Static NM_RELEASEDCAPTURE      := -16 ; (NM_FIRST-16)
Static NM_RETURN               := -4  ; (NM_FIRST-4)
Static NM_SETCURSOR            := -17 ; (NM_FIRST-17) uses NMMOUSE struct
Static NM_SETFOCUS             := -7  ; (NM_FIRST-7)
Static NM_THEMECHANGED         := -22 ; (NM_FIRST-22)
Static NM_TOOLTIPSCREATED      := -19 ; (NM_FIRST-19) notify of when the tooltips window is create
Static NM_TVSTATEIMAGECHANGING := -24 ; (NM_FIRST-24) >= Vista uses NMTVSTATEIMAGECHANGING struct
; ======================================================================================================================

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
Static WC_DATETIME                := "SysDateTimePick32"
; Messages =============================================================================================================
Static DTM_GETSYSTEMTIME          := 0x1001  ; (DTM_FIRST + 1)
Static DTM_CLOSEMONTHCAL          := 0x100D  ; (DTM_FIRST + 13) >= Vista
Static DTM_GETDATETIMEPICKERINFO  := 0x100E  ; (DTM_FIRST + 14) >= Vista
Static DTM_GETIDEALSIZE           := 0x100F  ; (DTM_FIRST + 15) >= Vista
Static DTM_GETMCCOLOR             := 0x1007  ; (DTM_FIRST + 7)
Static DTM_GETMCFONT              := 0x100A  ; (DTM_FIRST + 10)
Static DTM_GETMCSTYLE             := 0x100C  ; (DTM_FIRST + 12) >= Vista
Static DTM_GETMONTHCAL            := 0x1008  ; (DTM_FIRST + 8)
Static DTM_GETRANGE               := 0x1003  ; (DTM_FIRST + 3)
Static DTM_SETFORMATA             := 0x1005  ; (DTM_FIRST + 5)
Static DTM_SETFORMATW             := 0x1032  ; (DTM_FIRST + 50)
Static DTM_SETMCCOLOR             := 0x1006  ; (DTM_FIRST + 6)
Static DTM_SETMCFONT              := 0x1009  ; (DTM_FIRST + 9)
Static DTM_SETMCSTYLE             := 0x100B  ; (DTM_FIRST + 11) >= Vista
Static DTM_SETRANGE               := 0x1004  ; (DTM_FIRST + 4)
Static DTM_SETSYSTEMTIME          := 0x1002  ; (DTM_FIRST + 2)
; Notifications ========================================================================================================
Static DTN_CLOSEUP                := -753    ; (DTN_FIRST2)     MonthCal is popping up
Static DTN_DATETIMECHANGE         := -759    ; (DTN_FIRST2 - 6) the systemtime has changed
Static DTN_DROPDOWN               := -754    ; (DTN_FIRST2 - 1) MonthCal has dropped down
Static DTN_FORMATA                := -756    ; (DTN_FIRST2 - 3) query display for app format field := (X)
Static DTN_FORMATQUERYA           := -755    ; (DTN_FIRST2 - 2) query formatting info for app format field := (X)
Static DTN_FORMATQUERYW           := -742    ; (DTN_FIRST - 2)
Static DTN_FORMATW                := -743    ; (DTN_FIRST - 3)
Static DTN_USERSTRINGA            := -758    ; (DTN_FIRST2 - 5) the user has entered a string
Static DTN_USERSTRINGW            := -745    ; (DTN_FIRST - 5)
Static DTN_WMKEYDOWNA             := -757    ; (DTN_FIRST2 - 4) modify keydown on app format field := (X)
Static DTN_WMKEYDOWNW             := -744    ; (DTN_FIRST - 4)
; Styles ===============================================================================================================
Static DTS_APPCANPARSE            := 0x0010  ; allow user entered strings (app MUST respond to DTN_USERSTRING)
Static DTS_LONGDATEFORMAT         := 0x0004  ; use the long date format (app must forward WM_WININICHANGE messages)
Static DTS_RIGHTALIGN             := 0x0020  ; right-align popup instead of left-align it
Static DTS_SHORTDATECENTURYFORMAT := 0x000C  ; short date format with century (app must forward WM_WININICHANGE messages)
Static DTS_SHORTDATEFORMAT        := 0x0000  ; use the short date format (app must forward WM_WININICHANGE messages)
Static DTS_SHOWNONE               := 0x0002  ; allow a NONE selection
Static DTS_TIMEFORMAT             := 0x0009  ; use the time format (app must forward WM_WININICHANGE messages)
Static DTS_UPDOWN                 := 0x0001  ; use UPDOWN instead of MONTHCAL
; Errors and Other =====================================================================================================
Static GDT_ERROR := -1
Static GDT_NONE  := 1
Static GDT_VALID := 0
Static GDTR_MAX  := 2
Static GDTR_MIN  := 1
; ======================================================================================================================

; ======================================================================================================================
; Function:         Constants for Edit controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; ECM_FIRST = 0x1500, all messages based on ECM_FIRST need Unicode strings
; ======================================================================================================================
; Class ================================================================================================================
Static WC_EDIT                := "Edit"
; Messages =============================================================================================================
Static EM_CANUNDO             := 0x00C6
Static EM_CHARFROMPOS         := 0x00D7
Static EM_EMPTYUNDOBUFFER     := 0x00CD
Static EM_FMTLINES            := 0x00C8
Static EM_GETCUEBANNER        := 0x1502 ; (ECM_FIRST + 2) Unicode
Static EM_GETFIRSTVISIBLELINE := 0x00CE
Static EM_GETHANDLE           := 0x00BD
Static EM_GETHILITE           := 0x1506 ; (ECM_FIRST + 6) Unicode >= Vista, not documented
Static EM_GETIMESTATUS        := 0x00D9
Static EM_GETLIMITTEXT        := 0x00D5
Static EM_GETLINE             := 0x00C4
Static EM_GETLINECOUNT        := 0x00BA
Static EM_GETMARGINS          := 0x00D4
Static EM_GETMODIFY           := 0x00B8
Static EM_GETPASSWORDCHAR     := 0x00D2
Static EM_GETRECT             := 0x00B2
Static EM_GETSEL              := 0x00B0
Static EM_GETTHUMB            := 0x00BE
Static EM_GETWORDBREAKPROC    := 0x00D1
Static EM_HIDEBALLOONTIP      := 0x1504 ; (ECM_FIRST + 4) Unicode
Static EM_LIMITTEXT           := 0x00C5
Static EM_LINEFROMCHAR        := 0x00C9
Static EM_LINEINDEX           := 0x00BB
Static EM_LINELENGTH          := 0x00C1
Static EM_LINESCROLL          := 0x00B6
Static EM_POSFROMCHAR         := 0x00D6
Static EM_REPLACESEL          := 0x00C2
Static EM_SCROLL              := 0x00B5
Static EM_SCROLLCARET         := 0x00B7
Static EM_SETCUEBANNER        := 0x1501 ; (ECM_FIRST + 1) Unicode
Static EM_SETHANDLE           := 0x00BC
Static EM_SETHILITE           := 0x1505 ; (ECM_FIRST + 5) Unicode >= Vista, not documented
Static EM_SETIMESTATUS        := 0x00D8
Static EM_SETLIMITTEXT        := 0x00C5 ; EM_LIMITTEXT
Static EM_SETMARGINS          := 0x00D3
Static EM_SETMODIFY           := 0x00B9
Static EM_SETPASSWORDCHAR     := 0x00CC
Static EM_SETREADONLY         := 0x00CF
Static EM_SETRECT             := 0x00B3
Static EM_SETRECTNP           := 0x00B4
Static EM_SETSEL              := 0x00B1
Static EM_SETTABSTOPS         := 0x00CB
Static EM_SETWORDBREAKPROC    := 0x00D0
Static EM_SHOWBALLOONTIP      := 0x1503 ; (ECM_FIRST + 2) Unicode
Static EM_UNDO                := 0x00C7
; Notifications ========================================================================================================
Static EN_ALIGN_LTR_EC        := 0x0700
Static EN_ALIGN_RTL_EC        := 0x0701
Static EN_CHANGE              := 0x0300
Static EN_ERRSPACE            := 0x0500
Static EN_HSCROLL             := 0x0601
Static EN_KILLFOCUS           := 0x0200
Static EN_MAXTEXT             := 0x0501
Static EN_SETFOCUS            := 0x0100
Static EN_UPDATE              := 0x0400
Static EN_VSCROLL             := 0x0602
; Styles ===============================================================================================================
Static ES_AUTOHSCROLL         := 0x0080
Static ES_AUTOVSCROLL         := 0x0040
Static ES_CENTER              := 0x0001
Static ES_LEFT                := 0x0000
Static ES_LOWERCASE           := 0x0010
Static ES_MULTILINE           := 0x0004
Static ES_NOHIDESEL           := 0x0100
Static ES_NUMBER              := 0x2000
Static ES_OEMCONVERT          := 0x0400
Static ES_PASSWORD            := 0x0020
Static ES_READONLY            := 0x0800
Static ES_RIGHT               := 0x0002
Static ES_UPPERCASE           := 0x0008
Static ES_WANTRETURN          := 0x1000
; Parameters for EM_SETMARGINS =========================================================================================
Static EC_LEFTMARGIN          := 0x0001
Static EC_RIGHTMARGIN         := 0x0002
Static EC_USEFONTINFO         := 0xFFFF
; Parameters for EM_SETIMESTATUS =======================================================================================
Static EMSIS_COMPOSITIONSTRING        := 0x0001
Static EIMES_GETCOMPSTRATONCE         := 0x0001
Static EIMES_CANCELCOMPSTRINFOCUS     := 0x0002
Static EIMES_COMPLETECOMPSTRKILLFOCUS := 0x0004
; Icons for EM_SHOWBALLOONTIP ==========================================================================================
; TTI_NONE                := 0
; TTI_INFO                := 1
; TTI_WARNING             := 2
; TTI_ERROR               := 3
; TTI_INFO_LARGE          := 4  ; >= Vista
; TTI_WARNING_LARGE       := 5  ; >= Vista
; TTI_ERROR_LARGE         := 6  ; >= Vista
; ======================================================================================================================

; ======================================================================================================================
; Function:          Constants for Hotkey controls
; AHK version:       1.1.05+
; Language:          English
; Version:           1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; WM_USER = 0x0400
; ======================================================================================================================
; Class ================================================================================================================
Static WC_HOTKEY       := "msctls_hotkey32"
; Messages =============================================================================================================
Static HKM_SETHOTKEY   := 0x0401 ; (WM_USER + 1)
Static HKM_GETHOTKEY   := 0x0402 ; (WM_USER + 2)
Static HKM_SETRULES    := 0x0403 ; (WM_USER + 3)
; Others ===============================================================================================================
; HKM_GET/SETHOTKEY: Modifiers
Static HOTKEYF_SHIFT   := 0x01
Static HOTKEYF_CONTROL := 0x02
Static HOTKEYF_ALT     := 0x04
Static HOTKEYF_EXT     := 0x08
; HKM_SETRULES: Invalid key combinations
Static HKCOMB_NONE     := 0x0001 ; unmodified
Static HKCOMB_S        := 0x0002 ; Shift
Static HKCOMB_C        := 0x0004 ; Ctrl
Static HKCOMB_A        := 0x0008 ; Alt
Static HKCOMB_SC       := 0x0010 ; Shift+Ctrl
Static HKCOMB_SA       := 0x0020 ; Shift+Alt
Static HKCOMB_CA       := 0x0040 ; Ctrl+Alt
Static HKCOMB_SCA      := 0x0080 ; Chift+Ctrl+Alt
; ======================================================================================================================

; ======================================================================================================================
; Function:         Constants for ListBox controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; Class ================================================================================================================
Static WC_LISTBOX             := "ListBox"
; Messages =============================================================================================================
Static LB_ADDSTRING           := 0x0180
Static LB_INSERTSTRING        := 0x0181
Static LB_DELETESTRING        := 0x0182
Static LB_SELITEMRANGEEX      := 0x0183
Static LB_RESETCONTENT        := 0x0184
Static LB_SETSEL              := 0x0185
Static LB_SETCURSEL           := 0x0186
Static LB_GETSEL              := 0x0187
Static LB_GETCURSEL           := 0x0188
Static LB_GETTEXT             := 0x0189
Static LB_GETTEXTLEN          := 0x018A
Static LB_GETCOUNT            := 0x018B
Static LB_SELECTSTRING        := 0x018C
Static LB_DIR                 := 0x018D
Static LB_GETTOPINDEX         := 0x018E
Static LB_FINDSTRING          := 0x018F
Static LB_GETSELCOUNT         := 0x0190
Static LB_GETSELITEMS         := 0x0191
Static LB_SETTABSTOPS         := 0x0192
Static LB_GETHORIZONTALEXTENT := 0x0193
Static LB_SETHORIZONTALEXTENT := 0x0194
Static LB_SETCOLUMNWIDTH      := 0x0195
Static LB_ADDFILE             := 0x0196
Static LB_SETTOPINDEX         := 0x0197
Static LB_GETITEMRECT         := 0x0198
Static LB_GETITEMDATA         := 0x0199
Static LB_SETITEMDATA         := 0x019A
Static LB_SELITEMRANGE        := 0x019B
Static LB_SETANCHORINDEX      := 0x019C
Static LB_GETANCHORINDEX      := 0x019D
Static LB_SETCARETINDEX       := 0x019E
Static LB_GETCARETINDEX       := 0x019F
Static LB_SETITEMHEIGHT       := 0x01A0
Static LB_GETITEMHEIGHT       := 0x01A1
Static LB_FINDSTRINGEXACT     := 0x01A2
Static LB_SETLOCALE           := 0x01A5
Static LB_GETLOCALE           := 0x01A6
Static LB_SETCOUNT            := 0x01A7
Static LB_INITSTORAGE         := 0x01A8
Static LB_ITEMFROMPOINT       := 0x01A9
Static LB_MULTIPLEADDSTRING   := 0x01B1
Static LB_GETLISTBOXINFO      := 0x01B2
; Notifications ========================================================================================================
Static LBN_ERRSPACE           := -2
Static LBN_SELCHANGE          := 1
Static LBN_DBLCLK             := 2
Static LBN_SELCANCEL          := 3
Static LBN_SETFOCUS           := 4
Static LBN_KILLFOCUS          := 5
; Styles ===============================================================================================================
Static LBS_NOTIFY             := 0x0001
Static LBS_SORT               := 0x0002
Static LBS_NOREDRAW           := 0x0004
Static LBS_MULTIPLESEL        := 0x0008
Static LBS_OWNERDRAWFIXED     := 0x0010
Static LBS_OWNERDRAWVARIABLE  := 0x0020
Static LBS_HASSTRINGS         := 0x0040
Static LBS_USETABSTOPS        := 0x0080
Static LBS_NOINTEGRALHEIGHT   := 0x0100
Static LBS_MULTICOLUMN        := 0x0200
Static LBS_WANTKEYBOARDINPUT  := 0x0400
Static LBS_EXTENDEDSEL        := 0x0800
Static LBS_DISABLENOSCROLL    := 0x1000
Static LBS_NODATA             := 0x2000
Static LBS_NOSEL              := 0x4000
Static LBS_COMBOBOX           := 0x8000
Static LBS_STANDARD           := 0xA00003 ; (LBS_NOTIFY | LBS_SORT | WS_VSCROLL = 0x200000 | WS_BORDER = 0x800000)
; Errors ===============================================================================================================
Static LB_OKAY                := 0
Static LB_ERR                 := -1
Static LB_ERRSPACE            := -2
; ======================================================================================================================

; ======================================================================================================================
; Function:          Constants for ListView controls
; AHK version:       1.1.05+
; Language:          English
; Version:           1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; CCM_FIRST := 8192 (0x2000)
; LVM_FIRST := 4096 (0x1000) ; ListView messages
; LVN_FIRST := -100          ; ListView notifications
; ======================================================================================================================
; Class ================================================================================================================
Static WC_LISTVIEW             := "SysListView32"
; Messages =============================================================================================================
Static LVM_APPROXIMATEVIEWRECT := 0x1040 ; (LVM_FIRST + 64)
Static LVM_ARRANGE             := 0x1016 ; (LVM_FIRST + 22)
Static LVM_CANCELEDITLABEL     := 0x10B3 ; (LVM_FIRST + 179)
Static LVM_CREATEDRAGIMAGE     := 0x1021 ; (LVM_FIRST + 33)
Static LVM_DELETEALLITEMS      := 0x1009 ; (LVM_FIRST + 9)
Static LVM_DELETECOLUMN        := 0x101C ; (LVM_FIRST + 28)
Static LVM_DELETEITEM          := 0x1008 ; (LVM_FIRST + 8)
Static LVM_EDITLABELA          := 0x1017 ; (LVM_FIRST + 23)
Static LVM_EDITLABELW          := 0x1076 ; (LVM_FIRST + 118)
Static LVM_ENABLEGROUPVIEW     := 0x109D ; (LVM_FIRST + 157)
Static LVM_ENSUREVISIBLE       := 0x1013 ; (LVM_FIRST + 19)
Static LVM_FINDITEMA           := 0x100D ; (LVM_FIRST + 13)
Static LVM_FINDITEMW           := 0x1053 ; (LVM_FIRST + 83)
Static LVM_GETBKCOLOR          := 0x1000 ; (LVM_FIRST + 0)
Static LVM_GETBKIMAGEA         := 0x1045 ; (LVM_FIRST + 69)
Static LVM_GETBKIMAGEW         := 0x108B ; (LVM_FIRST + 139)
Static LVM_GETCALLBACKMASK     := 0x100A ; (LVM_FIRST + 10)
Static LVM_GETCOLUMNA          := 0x1019 ; (LVM_FIRST + 25)
Static LVM_GETCOLUMNW          := 0x105F ; (LVM_FIRST + 95)
Static LVM_GETCOLUMNORDERARRAY := 0x103B ; (LVM_FIRST + 59)
Static LVM_GETCOLUMNWIDTH      := 0x101D ; (LVM_FIRST + 29)
Static LVM_GETCOUNTPERPAGE     := 0x1028 ; (LVM_FIRST + 40)
Static LVM_GETEDITCONTROL      := 0x1018 ; (LVM_FIRST + 24)
Static LVM_GETEMPTYTEXT        := 0x10CC ; (LVM_FIRST + 204) >= Vista
Static LVM_GETEXTENDEDLISTVIEWSTYLE := 0x1037 ; (LVM_FIRST + 55)
Static LVM_GETFOCUSEDGROUP     := 0x105D ; (LVM_FIRST + 93)
Static LVM_GETFOOTERINFO       := 0x10CE ; (LVM_FIRST + 206) >= Vista
Static LVM_GETFOOTERITEM       := 0x10D0 ; (LVM_FIRST + 208) >= Vista
Static LVM_GETFOOTERITEMRECT   := 0x10CF ; (LVM_FIRST + 207) >= Vista
Static LVM_GETFOOTERRECT       := 0x10CD ; (LVM_FIRST + 205) >= Vista
Static LVM_GETGROUPCOUNT       := 0x1098 ; (LVM_FIRST + 152)
Static LVM_GETGROUPINFO        := 0x1095 ; (LVM_FIRST + 149)
Static LVM_GETGROUPINFOBYINDEX := 0x1099 ; (LVM_FIRST + 153)
Static LVM_GETGROUPMETRICS     := 0x109C ; (LVM_FIRST + 156)
Static LVM_GETGROUPRECT        := 0x1062 ; (LVM_FIRST + 98)  >= Vista ?
Static LVM_GETGROUPSTATE       := 0x105C ; (LVM_FIRST + 92)
Static LVM_GETHEADER           := 0x101F ; (LVM_FIRST + 31)
Static LVM_GETHOTCURSOR        := 0x103F ; (LVM_FIRST + 63)
Static LVM_GETHOTITEM          := 0x103D ; (LVM_FIRST + 61)
Static LVM_GETHOVERTIME        := 0x1048 ; (LVM_FIRST + 72)
Static LVM_GETIMAGELIST        := 0x1002 ; (LVM_FIRST + 2)
Static LVM_GETINSERTMARK       := 0x10A7 ; (LVM_FIRST + 167)
Static LVM_GETINSERTMARKCOLOR  := 0x10AB ; (LVM_FIRST + 171)
Static LVM_GETINSERTMARKRECT   := 0x10A9 ; (LVM_FIRST + 169)
Static LVM_GETISEARCHSTRINGA   := 0x1034 ; (LVM_FIRST + 52)
Static LVM_GETISEARCHSTRINGW   := 0x1075 ; (LVM_FIRST + 117)
Static LVM_GETITEMA            := 0x1005 ; (LVM_FIRST + 5)
Static LVM_GETITEMW            := 0x104B ; (LVM_FIRST + 75)
Static LVM_GETITEMCOUNT        := 0x1004 ; (LVM_FIRST + 4)
Static LVM_GETITEMINDEXRECT    := 0x10D1 ; (LVM_FIRST + 209) >= Vista
Static LVM_GETITEMPOSITION     := 0x1010 ; (LVM_FIRST + 16)
Static LVM_GETITEMRECT         := 0x100E ; (LVM_FIRST + 14)
Static LVM_GETITEMSPACING      := 0x1033 ; (LVM_FIRST + 51)
Static LVM_GETITEMSTATE        := 0x102C ; (LVM_FIRST + 44)
Static LVM_GETITEMTEXTA        := 0x102D ; (LVM_FIRST + 45)
Static LVM_GETITEMTEXTW        := 0x1073 ; (LVM_FIRST + 115)
Static LVM_GETNEXTITEM         := 0x100C ; (LVM_FIRST + 12)
Static LVM_GETNEXTITEMINDEX    := 0x10D3 ; (LVM_FIRST + 211) >= Vista
Static LVM_GETNUMBEROFWORKAREAS := 0x1049 ; (LVM_FIRST + 73)
Static LVM_GETORIGIN           := 0x1029 ; (LVM_FIRST + 41)
Static LVM_GETOUTLINECOLOR     := 0x10B0 ; (LVM_FIRST + 176)
Static LVM_GETSELECTEDCOLUMN   := 0x10AE ; (LVM_FIRST + 174)
Static LVM_GETSELECTEDCOUNT    := 0x1032 ; (LVM_FIRST + 50)
Static LVM_GETSELECTIONMARK    := 0x1042 ; (LVM_FIRST + 66)
Static LVM_GETSTRINGWIDTHA     := 0x1011 ; (LVM_FIRST + 17)
Static LVM_GETSTRINGWIDTHW     := 0x1057 ; (LVM_FIRST + 87)
Static LVM_GETSUBITEMRECT      := 0x1038 ; (LVM_FIRST + 56)
Static LVM_GETTEXTBKCOLOR      := 0x1025 ; (LVM_FIRST + 37)
Static LVM_GETTEXTCOLOR        := 0x1023 ; (LVM_FIRST + 35)
Static LVM_GETTILEINFO         := 0x10A5 ; (LVM_FIRST + 165)
Static LVM_GETTILEVIEWINFO     := 0x10A3 ; (LVM_FIRST + 163)
Static LVM_GETTOOLTIPS         := 0x104E ; (LVM_FIRST + 78)
Static LVM_GETTOPINDEX         := 0x1027 ; (LVM_FIRST + 39)
Static LVM_GETUNICODEFORMAT    := 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
Static LVM_GETVIEW             := 0x108F ; (LVM_FIRST + 143)
Static LVM_GETVIEWRECT         := 0x1022 ; (LVM_FIRST + 34)
Static LVM_GETWORKAREAS        := 0x1046 ; (LVM_FIRST + 70)
Static LVM_HASGROUP            := 0x10A1 ; (LVM_FIRST + 161)
Static LVM_HITTEST             := 0x1012 ; (LVM_FIRST + 18)
Static LVM_INSERTCOLUMNA       := 0x1019 ; (LVM_FIRST + 27)
Static LVM_INSERTCOLUMNW       := 0x1061 ; (LVM_FIRST + 97)
Static LVM_INSERTGROUP         := 0x1091 ; (LVM_FIRST + 145)
Static LVM_INSERTGROUPSORTED   := 0x109F ; (LVM_FIRST + 159)
Static LVM_INSERTITEMA         := 0x1007 ; (LVM_FIRST + 7)
Static LVM_INSERTITEMW         := 0x104D ; (LVM_FIRST + 77)
Static LVM_INSERTMARKHITTEST   := 0x10A8 ; (LVM_FIRST + 168)
Static LVM_ISGROUPVIEWENABLED  := 0x10AF ; (LVM_FIRST + 175)
Static LVM_ISITEMVISIBLE       := 0x10B6 ; (LVM_FIRST + 182)
Static LVM_MAPIDTOINDEX        := 0x10B5 ; (LVM_FIRST + 181)
Static LVM_MAPINDEXTOID        := 0x10B4 ; (LVM_FIRST + 180)
Static LVM_MOVEGROUP           := 0x1097 ; (LVM_FIRST + 151)
Static LVM_MOVEITEMTOGROUP     := 0x109A ; (LVM_FIRST + 154)
Static LVM_REDRAWITEMS         := 0x1015 ; (LVM_FIRST + 21)
Static LVM_REMOVEALLGROUPS     := 0x10A0 ; (LVM_FIRST + 160)
Static LVM_REMOVEGROUP         := 0x1096 ; (LVM_FIRST + 150)
Static LVM_SCROLL              := 0x1014 ; (LVM_FIRST + 20)
Static LVM_SETBKCOLOR          := 0x1001 ; (LVM_FIRST + 1)
Static LVM_SETBKIMAGEA         := 0x1044 ; (LVM_FIRST + 68)
Static LVM_SETBKIMAGEW         := 0x10A8 ; (LVM_FIRST + 138)
Static LVM_SETCALLBACKMASK     := 0x100B ; (LVM_FIRST + 11)
Static LVM_SETCOLUMNA          := 0x101A ; (LVM_FIRST + 26)
Static LVM_SETCOLUMNW          := 0x1060 ; (LVM_FIRST + 96)
Static LVM_SETCOLUMNORDERARRAY := 0x103A ; (LVM_FIRST + 58)
Static LVM_SETCOLUMNWIDTH      := 0x101E ; (LVM_FIRST + 30)
Static LVM_SETEXTENDEDLISTVIEWSTYLE := 0x1036 ; (LVM_FIRST + 54) optional wParam == mask
Static LVM_SETGROUPINFO        := 0x1093 ; (LVM_FIRST + 147)
Static LVM_SETGROUPMETRICS     := 0x109B ; (LVM_FIRST + 155)
Static LVM_SETHOTCURSOR        := 0x103E ; (LVM_FIRST + 62)
Static LVM_SETHOTITEM          := 0x103C ; (LVM_FIRST + 60)
Static LVM_SETHOVERTIME        := 0x1047 ; (LVM_FIRST + 71)
Static LVM_SETICONSPACING      := 0x1035 ; (LVM_FIRST + 53)
Static LVM_SETIMAGELIST        := 0x1003 ; (LVM_FIRST + 3)
Static LVM_SETINFOTIP          := 0x10AD ; (LVM_FIRST + 173)
Static LVM_SETINSERTMARK       := 0x10A6 ; (LVM_FIRST + 166)
Static LVM_SETINSERTMARKCOLOR  := 0x10AA ; (LVM_FIRST + 170)
Static LVM_SETITEMA            := 0x1006 ; (LVM_FIRST + 6)
Static LVM_SETITEMW            := 0x104C ; (LVM_FIRST + 76)
Static LVM_SETITEMCOUNT        := 0x102F ; (LVM_FIRST + 47)
Static LVM_SETITEMINDEXSTATE   := 0x10D2 ; (LVM_FIRST + 210) >= Vista
Static LVM_SETITEMPOSITION     := 0x100F ; (LVM_FIRST + 15)
Static LVM_SETITEMPOSITION32   := 0x1031 ; (LVM_FIRST + 49)
Static LVM_SETITEMSTATE        := 0x102B ; (LVM_FIRST + 43)
Static LVM_SETITEMTEXTA        := 0x102E ; (LVM_FIRST + 46)
Static LVM_SETITEMTEXTW        := 0x1074 ; (LVM_FIRST + 116)
Static LVM_SETOUTLINECOLOR     := 0x10B1 ; (LVM_FIRST + 177)
Static LVM_SETSELECTIONMARK    := 0x1043 ; (LVM_FIRST + 67)
Static LVM_SETTEXTBKCOLOR      := 0x1026 ; (LVM_FIRST + 38)
Static LVM_SETTEXTCOLOR        := 0x1024 ; (LVM_FIRST + 36)
Static LVM_SETTILEINFO         := 0x10A4 ; (LVM_FIRST + 164)
Static LVM_SETTILEVIEWINFO     := 0x10A2 ; (LVM_FIRST + 162)
Static LVM_SETTOOLTIPS         := 0x104A ; (LVM_FIRST + 74)
Static LVM_SETUNICODEFORMAT    := 0x2005 ; (CCM_FIRST + 5) CCM_SETUNICODEFORMAT
Static LVM_SETVIEW             := 0x108E ; (LVM_FIRST + 142)
Static LVM_SETWORKAREAS        := 0x1041 ; (LVM_FIRST + 65)
Static LVM_SORTGROUPS          := 0x109E ; (LVM_FIRST + 158)
Static LVM_SORTITEMS           := 0x1030 ; (LVM_FIRST + 48)
Static LVM_SORTITEMSEX         := 0x1051 ; (LVM_FIRST + 81)
Static LVM_SUBITEMHITTEST      := 0x1039 ; (LVM_FIRST + 57)
Static LVM_UPDATE              := 0x102A ; (LVM_FIRST + 42)
; Notifications ========================================================================================================
Static LVN_BEGINDRAG           := -109 ; (LVN_FIRST - 9)
Static LVN_BEGINLABELEDITA     := -105 ; (LVN_FIRST - 5)
Static LVN_BEGINLABELEDITW     := -175 ; (LVN_FIRST - 75)
Static LVN_BEGINRDRAG          := -111 ; (LVN_FIRST - 11)
Static LVN_BEGINSCROLL         := -180 ; (LVN_FIRST - 80)
Static LVN_COLUMNCLICK         := -108 ; (LVN_FIRST - 8)
Static LVN_COLUMNDROPDOWN      := -164 ; (LVN_FIRST - 64) >= Vista
Static LVN_COLUMNOVERFLOWCLICK := -166 ; (LVN_FIRST - 66) >= Vista
Static LVN_DELETEALLITEMS      := -104 ; (LVN_FIRST - 4)
Static LVN_DELETEITEM          := -103 ; (LVN_FIRST - 3)
Static LVN_ENDLABELEDITA       := -106 ; (LVN_FIRST - 6)
Static LVN_ENDLABELEDITW       := -176 ; (LVN_FIRST - 76)
Static LVN_ENDSCROLL           := -181 ; (LVN_FIRST - 81)
Static LVN_GETDISPINFOA        := -150 ; (LVN_FIRST - 50)
Static LVN_GETDISPINFOW        := -177 ; (LVN_FIRST - 77)
Static LVN_GETEMPTYMARKUP      := -187 ; (LVN_FIRST - 87) >= Vista
Static LVN_GETINFOTIPA         := -157 ; (LVN_FIRST - 57)
Static LVN_GETINFOTIPW         := -158 ; (LVN_FIRST - 58)
Static LVN_HOTTRACK            := -121 ; (LVN_FIRST - 21)
Static LVN_INCREMENTALSEARCHA  := -162 ; (LVN_FIRST - 62)
Static LVN_INCREMENTALSEARCHW  := -163 ; (LVN_FIRST - 63)
Static LVN_INSERTITEM          := -102 ; (LVN_FIRST - 2)
Static LVN_ITEMACTIVATE        := -114 ; (LVN_FIRST - 14)
Static LVN_ITEMCHANGED         := -101 ; (LVN_FIRST - 1)
Static LVN_ITEMCHANGING        := -100 ; (LVN_FIRST - 0)
Static LVN_KEYDOWN             := -155 ; (LVN_FIRST - 55)
Static LVN_LINKCLICK           := -184 ; (LVN_FIRST - 84) >= Vista
Static LVN_MARQUEEBEGIN        := -156 ; (LVN_FIRST - 56)
Static LVN_ODCACHEHINT         := -113 ; (LVN_FIRST - 13)
Static LVN_ODFINDITEMA         := -152 ; (LVN_FIRST - 52)
Static LVN_ODFINDITEMW         := -179 ; (LVN_FIRST - 79)
Static LVN_ODSTATECHANGED      := -115 ; (LVN_FIRST - 15)
Static LVN_SETDISPINFOA        := -151 ; (LVN_FIRST - 51)
Static LVN_SETDISPINFOW        := -178 ; (LVN_FIRST - 78)
; Styles ===============================================================================================================
Static LVS_ALIGNLEFT           := 0x0800
Static LVS_ALIGNMASK           := 0x0c00
Static LVS_ALIGNTOP            := 0x0000
Static LVS_AUTOARRANGE         := 0x0100
Static LVS_EDITLABELS          := 0x0200
Static LVS_ICON                := 0x0000
Static LVS_LIST                := 0x0003
Static LVS_NOCOLUMNHEADER      := 0x4000
Static LVS_NOLABELWRAP         := 0x0080
Static LVS_NOSCROLL            := 0x2000
Static LVS_NOSORTHEADER        := 0x8000
Static LVS_OWNERDATA           := 0x1000
Static LVS_OWNERDRAWFIXED      := 0x0400
Static LVS_REPORT              := 0x0001
Static LVS_SHAREIMAGELISTS     := 0x0040
Static LVS_SHOWSELALWAYS       := 0x0008
Static LVS_SINGLESEL           := 0x0004
Static LVS_SMALLICON           := 0x0002
Static LVS_SORTASCENDING       := 0x0010
Static LVS_SORTDESCENDING      := 0x0020
Static LVS_TYPEMASK            := 0x0003
Static LVS_TYPESTYLEMASK       := 0xfc00
; ExStyles =============================================================================================================
Static LVS_EX_AUTOAUTOARRANGE  := 0x01000000  ; >= Vista: icons automatically arrange if no icon positions have been set
Static LVS_EX_AUTOCHECKSELECT  := 0x08000000  ; >= Vista
Static LVS_EX_AUTOSIZECOLUMNS  := 0x10000000  ; >= Vista
Static LVS_EX_BORDERSELECT     := 0x00008000  ; border selection style instead of highlight
Static LVS_EX_CHECKBOXES       := 0x00000004
Static LVS_EX_COLUMNOVERFLOW   := 0x80000000  ; >= Vista
Static LVS_EX_COLUMNSNAPPOINTS := 0x40000000  ; >= Vista
Static LVS_EX_DOUBLEBUFFER     := 0x00010000
Static LVS_EX_FLATSB           := 0x00000100
Static LVS_EX_FULLROWSELECT    := 0x00000020  ; applies to report mode only
Static LVS_EX_GRIDLINES        := 0x00000001
Static LVS_EX_HEADERDRAGDROP   := 0x00000010
Static LVS_EX_HEADERINALLVIEWS := 0x02000000  ; >= Vista: display column header in all view modes
Static LVS_EX_HIDELABELS       := 0x00020000
Static LVS_EX_INFOTIP          := 0x00000400  ; listview does InfoTips for you
Static LVS_EX_JUSTIFYCOLUMNS   := 0x00200000  ; >= Vista: icons are lined up in columns that use up the whole view area
Static LVS_EX_LABELTIP         := 0x00004000  ; listview unfolds partly hidden labels if it does not have infotip text
Static LVS_EX_MULTIWORKAREAS   := 0x00002000
Static LVS_EX_ONECLICKACTIVATE := 0x00000040
Static LVS_EX_REGIONAL         := 0x00000200
Static LVS_EX_SIMPLESELECT     := 0x00100000  ; also changes overlay rendering to top right for icon mode
Static LVS_EX_SINGLEROW        := 0x00040000
Static LVS_EX_SNAPTOGRID       := 0x00080000  ; icons automatically snap to grid
Static LVS_EX_SUBITEMIMAGES    := 0x00000002
Static LVS_EX_TRACKSELECT      := 0x00000008
Static LVS_EX_TRANSPARENTBKGND := 0x00400000  ; >= Vista: background is painted by the parent via WM_PRINTCLIENT
Static LVS_EX_TRANSPARENTSHADOWTEXT := 0x00800000  ; >=Vista: enable shadow text on transparent backgrounds only (useful with bitmaps)
Static LVS_EX_TWOCLICKACTIVATE := 0x00000080
Static LVS_EX_UNDERLINECOLD    := 0x00001000
Static LVS_EX_UNDERLINEHOT     := 0x00000800
; Others ===============================================================================================================
; LVM_GET/SETIMAGELIST
Static LVSIL_GROUPHEADER       := 3
Static LVSIL_NORMAL            := 0
Static LVSIL_SMALL             := 1
Static LVSIL_STATE             := 2
; LVITEM mask
Static LVIF_COLFMT             := 0x00010000  ; >= Vista - the piColFmt member is valid in addition to puColumns
Static LVIF_COLUMNS            := 0x00000200
Static LVIF_DI_SETITEM         := 0x00001000
Static LVIF_GROUPID            := 0x00000100
Static LVIF_IMAGE              := 0x00000002
Static LVIF_INDENT             := 0x00000010
Static LVIF_NORECOMPUTE        := 0x00000800
Static LVIF_PARAM              := 0x00000004
Static LVIF_STATE              := 0x00000008
Static LVIF_TEXT               := 0x00000001
; LVITEM state
Static LVIS_ACTIVATING         := 0x0020
Static LVIS_CUT                := 0x0004
Static LVIS_DROPHILITED        := 0x0008
Static LVIS_FOCUSED            := 0x0001
Static LVIS_GLOW               := 0x0010      ; not documented in MSDN
Static LVIS_OVERLAYMASK        := 0x0F00
Static LVIS_SELECTED           := 0x0002
Static LVIS_STATEIMAGEMASK     := 0xF000
; LVN_GETNEXTITEM
Static LVNI_ABOVE              := 0x0100
Static LVNI_ALL                := 0x0000
Static LVNI_BELOW              := 0x0200
Static LVNI_CUT                := 0x0004
Static LVNI_DIRECTIONMASK      := 0x0F00      ; (LVNI_ABOVE | LVNI_BELOW | LVNI_TOLEFT | LVNI_TORIGHT) >= Vista
Static LVNI_DROPHILITED        := 0x0008
Static LVNI_FOCUSED            := 0x0001
Static LVNI_PREVIOUS           := 0x0020      ; >= Vista
Static LVNI_SAMEGROUPONLY      := 0x0080      ; >= Vista
Static LVNI_SELECTED           := 0x0002
Static LVNI_STATEMASK          := 0x000F      ; (LVNI_FOCUSED | LVNI_SELECTED | LVNI_CUT | LVNI_DROPHILITED) >= Vista
Static LVNI_TOLEFT             := 0x0400
Static LVNI_TORIGHT            := 0x0800
Static LVNI_VISIBLEONLY        := 0x0040      ; >= Vista
Static LVNI_VISIBLEORDER       := 0x0010      ; >= Vista
; LVFINDINFO flags
Static LVFI_NEARESTXY          := 0x0040
Static LVFI_PARAM              := 0x0001
Static LVFI_PARTIAL            := 0x0008
Static LVFI_STRING             := 0x0002
Static LVFI_SUBSTRING          := 0x0004      ; >= Vista - same as LVFI_PARTIAL
Static LVFI_WRAP               := 0x0020
; LVM_GETITEMRECT
Static LVIR_BOUNDS             := 0
Static LVIR_ICON               := 1
Static LVIR_LABEL              := 2
Static LVIR_SELECTBOUNDS       := 3
; LVHITTESTINFO flags
Static LVHT_NOWHERE            := 0x00000001
Static LVHT_ABOVE              := 0x00000008
Static LVHT_BELOW              := 0x00000010
Static LVHT_ONITEM             := 0x0000000E ; (LVHT_ONITEMICON | LVHT_ONITEMLABEL | LVHT_ONITEMSTATEICON)
Static LVHT_ONITEMICON         := 0x00000002
Static LVHT_ONITEMLABEL        := 0x00000004
Static LVHT_ONITEMSTATEICON    := 0x00000008
Static LVHT_TOLEFT             := 0x00000040
Static LVHT_TORIGHT            := 0x00000020
Static LVHT_EX_FOOTER           := 0x08000000 ; >= Vista
Static LVHT_EX_GROUP            := 0xF3000000 ; >= Vista (LVHT_EX_GROUP_BACKGROUND | _COLLAPSE | _FOOTER | _HEADER | _STATEICON | _SUBSETLINK)
Static LVHT_EX_GROUP_BACKGROUND := 0x80000000 ; >= Vista
Static LVHT_EX_GROUP_COLLAPSE   := 0x40000000 ; >= Vista
Static LVHT_EX_GROUP_FOOTER     := 0x20000000 ; >= Vista
Static LVHT_EX_GROUP_HEADER     := 0x10000000 ; >= Vista
Static LVHT_EX_GROUP_STATEICON  := 0x01000000 ; >= Vista
Static LVHT_EX_GROUP_SUBSETLINK := 0x02000000 ; >= Vista
Static LVHT_EX_ONCONTENTS       := 0x04000000 ; >= Vista - on item AND not on the background
; LVM_ARRANGE
Static LVA_ALIGNLEFT           := 0x0001
Static LVA_ALIGNTOP            := 0x0002
Static LVA_DEFAULT             := 0x0000
Static LVA_SNAPTOGRID          := 0x0005
; LVCOLUMN mask
Static LVCF_DEFAULTWIDTH       := 0x0080        ; >= Vista
Static LVCF_FMT                := 0x0001
Static LVCF_IDEALWIDTH         := 0x0100        ; >= Vista
Static LVCF_IMAGE              := 0x0010
Static LVCF_MINWIDTH           := 0x0040        ; >= Vista
Static LVCF_ORDER              := 0x0020
Static LVCF_SUBITEM            := 0x0008
Static LVCF_TEXT               := 0x0004
Static LVCF_WIDTH              := 0x0002
; LVCOLUMN fmt, LVITEM piColFmt
Static LVCFMT_BITMAP_ON_RIGHT    := 0x1000        ; Same as HDF_BITMAP_ON_RIGHT
Static LVCFMT_CENTER             := 0x0002        ; Same as HDF_CENTER
Static LVCFMT_COL_HAS_IMAGES     := 0x8000        ; Same as HDF_OWNERDRAW
Static LVCFMT_FILL               := 0x200000      ; >= Win7   Fill the remainder of the tile area. Might have a title.
Static LVCFMT_FIXED_RATIO        := 0x80000       ; >= Vista  Width will augment with the row height
Static LVCFMT_FIXED_WIDTH        := 0x000100      ; >= Vista  Can't resize the column; same as HDF_FIXEDWIDTH
Static LVCFMT_IMAGE              := 0x0800        ; Same as HDF_IMAGE
Static LVCFMT_JUSTIFYMASK        := 0x0003        ; Same as HDF_JUSTIFYMASK
Static LVCFMT_LEFT               := 0x0000        ; Same as HDF_LEFT
Static LVCFMT_LINE_BREAK         := 0x100000      ; >= Win7   Move to the top of the next list of columns
Static LVCFMT_NO_DPI_SCALE       := 0x40000       ; >= Vista  If not set, CCM_DPISCALE will govern scaling up fixed width
Static LVCFMT_NO_TITLE           := 0x800000      ; >= Win7   This sub-item doesn't have an title.
Static LVCFMT_RIGHT              := 0x0001        ; Same as HDF_RIGHT
Static LVCFMT_SPLITBUTTON        := 0x01000000    ; >= Vista  Column is a split button; same as HDF_SPLITBUTTON
Static LVCFMT_TILE_PLACEMENTMASK := 0x300000      ; (LVCFMT_LINE_BREAK | LVCFMT_FILL) >= Win7
Static LVCFMT_WRAP               := 0x400000      ; >= Win7   This sub-item can be wrapped.
; LVM_SETCOLOMNWIDTH
Static LVSCW_AUTOSIZE           := -1
Static LVSCW_AUTOSIZE_USEHEADER := -2
; LVM_SETITEMCOUNT
Static LVSICF_NOINVALIDATEALL  := 0x00000001
Static LVSICF_NOSCROLL         := 0x00000002
; LVM_SETWORKAREAS
Static LV_MAX_WORKAREAS        := 16
; LVBKIMAGE ulFlags
Static LVBKIF_FLAG_ALPHABLEND  := 0x20000000
Static LVBKIF_FLAG_TILEOFFSET  := 0x00000100
Static LVBKIF_SOURCE_HBITMAP   := 0x00000001
Static LVBKIF_SOURCE_MASK      := 0x00000003
Static LVBKIF_SOURCE_NONE      := 0x00000000
Static LVBKIF_SOURCE_URL       := 0x00000002
Static LVBKIF_STYLE_MASK       := 0x00000010
Static LVBKIF_STYLE_NORMAL     := 0x00000000
Static LVBKIF_STYLE_TILE       := 0x00000010
Static LVBKIF_TYPE_WATERMARK   := 0x10000000
; LVM_GET/SETVIEW
Static LV_VIEW_DETAILS         := 0x0001
Static LV_VIEW_ICON            := 0x0000
Static LV_VIEW_LIST            := 0x0003
Static LV_VIEW_MAX             := 0x0004
Static LV_VIEW_SMALLICON       := 0x0002
Static LV_VIEW_TILE            := 0x0004
; LVGROUP mask
Static LVGF_ALIGN              := 0x00000008
Static LVGF_DESCRIPTIONBOTTOM  := 0x00000800    ; >= Vista  pszDescriptionBottom is valid
Static LVGF_DESCRIPTIONTOP     := 0x00000400    ; >= Vista  pszDescriptionTop is valid
Static LVGF_EXTENDEDIMAGE      := 0x00002000    ; >= Vista  iExtendedImage is valid
Static LVGF_FOOTER             := 0x00000002
Static LVGF_GROUPID            := 0x00000010
Static LVGF_HEADER             := 0x00000001
Static LVGF_ITEMS              := 0x00004000    ; >= Vista  iFirstItem and cItems are valid
Static LVGF_NONE               := 0x00000000
Static LVGF_STATE              := 0x00000004
Static LVGF_SUBSET             := 0x00008000    ; >= Vista  pszSubsetTitle is valid
Static LVGF_SUBSETITEMS        := 0x00010000    ; >= Vista  readonly, cItems holds count of items in visible subset, iFirstItem is valid
Static LVGF_SUBTITLE           := 0x00000100    ; >= Vista  pszSubtitle is valid
Static LVGF_TASK               := 0x00000200    ; >= Vista  pszTask is valid
Static LVGF_TITLEIMAGE         := 0x00001000    ; >= Vista  iTitleImage is valid
; LVGROUP state
Static LVGS_COLLAPSED          := 0x00000001
Static LVGS_COLLAPSIBLE        := 0x00000008    ; >= Vista ?
Static LVGS_FOCUSED            := 0x00000010    ; >= Vista ?
Static LVGS_HIDDEN             := 0x00000002
Static LVGS_NOHEADER           := 0x00000004    ; >= Vista ?
Static LVGS_NORMAL             := 0x00000000
Static LVGS_SELECTED           := 0x00000020    ; >= Vista ?
Static LVGS_SUBSETED           := 0x00000040    ; >= Vista ?
Static LVGS_SUBSETLINKFOCUSED  := 0x00000080    ; >= Vista ?
; LVGROUP uAlign
Static LVGA_FOOTER_CENTER      := 0x00000010
Static LVGA_FOOTER_LEFT        := 0x00000008
Static LVGA_FOOTER_RIGHT       := 0x00000020    ; Don't forget to validate exclusivity
Static LVGA_HEADER_CENTER      := 0x00000002
Static LVGA_HEADER_LEFT        := 0x00000001
Static LVGA_HEADER_RIGHT       := 0x00000004    ; Don't forget to validate exclusivity
; LVM_GETGROUPRECT
Static LVGGR_GROUP             := 0             ; Entire expanded group
Static LVGGR_HEADER            := 1             ; Header only (collapsed group)
Static LVGGR_LABEL             := 2             ; Label only
Static LVGGR_SUBSETLINK        := 3             ; subset link only
; LVGROUPMETRICS mask
Static LVGMF_BORDERCOLOR       := 0x00000002
Static LVGMF_BORDERSIZE        := 0x00000001
Static LVGMF_NONE              := 0x00000000
Static LVGMF_TEXTCOLOR         := 0x00000004
; LVTILEVIEWINFO dwMask
Static LVTVIM_COLUMNS          := 0x00000002
Static LVTVIM_LABELMARGIN      := 0x00000004
Static LVTVIM_TILESIZE         := 0x00000001
; LVTILEVIEWINFO dwFlags
Static LVTVIF_AUTOSIZE         := 0x00000000
Static LVTVIF_EXTENDED         := 0x00000004    ; >= Vista
Static LVTVIF_FIXEDHEIGHT      := 0x00000002
Static LVTVIF_FIXEDSIZE        := 0x00000003
Static LVTVIF_FIXEDWIDTH       := 0x00000001
; LVINSERTMARK dwFlags
Static LVIM_AFTER              := 0x00000001    ; TRUE = insert After iItem, otherwise before
; LVFOOTERINFO mask (>= Vista)
Static LVFF_ITEMCOUNT          := 0x00000001
; LVFOOTERITEM (>= Vista)
Static LVFIF_STATE             := 0x00000002
Static LVFIF_TEXT              := 0x00000001
; footer item state
Static LVFIS_FOCUSED           := 0x0001
; NMITEMACTIVATE uKeyFlags
Static LVKF_ALT                := 0x0001
Static LVKF_CONTROL            := 0x0002
Static LVKF_SHIFT              := 0x0004
; NMLVCUSTOMDRAW
; dwItemType
Static LVCDI_GROUP             := 0x00000001
Static LVCDI_ITEM              := 0x00000000
Static LVCDI_ITEMSLIST         := 0x00000002
; ListView custom draw return values
Static LVCDRF_NOGROUPFRAME     := 0x00020000
Static LVCDRF_NOSELECT         := 0x00010000
; NMLVGETINFOTIP dwFlag
Static LVGIT_UNFOLDED          := 0x0001
; LVN_INCREMENTALSEARCH LVFINDINFO lParam
Static LVNSCH_DEFAULT          := -1
Static LVNSCH_ERROR            := -2
Static LVNSCH_IGNORE           := -3
; NMLVEMPTYMARKUP dwFlags ( >= Vista)
Static EMF_CENTERED            := 0x00000001    ; render markup centered in the listview area
Static L_MAX_URL_LENGTH        := 2083          ; (2048 + 32 + sizeof("://"))
; ======================================================================================================================

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
Static WC_MONTHCAL             := "SysMonthCal32"
; Messages =============================================================================================================
Static MCM_GETCALENDARBORDER   := 0x101F ; (MCM_FIRST + 31) >= Vista
Static MCM_GETCALENDARCOUNT    := 0x1017 ; (MCM_FIRST + 23) >= Vista
Static MCM_GETCALENDARGRIDINFO := 0x1018 ; (MCM_FIRST + 24) >= Vista
Static MCM_GETCALID            := 0x101B ; (MCM_FIRST + 27) >= Vista
Static MCM_GETCOLOR            := 0x100B ; (MCM_FIRST + 11)
Static MCM_GETCURRENTVIEW      := 0x1016 ; (MCM_FIRST + 22) >= Vista
Static MCM_GETCURSEL           := 0x1001 ; (MCM_FIRST + 1)
Static MCM_GETFIRSTDAYOFWEEK   := 0x1010 ; (MCM_FIRST + 16)
Static MCM_GETMAXSELCOUNT      := 0x1003 ; (MCM_FIRST + 3)
Static MCM_GETMINREQRECT       := 0x1009 ; (MCM_FIRST + 9)
Static MCM_GETMONTHDELTA       := 0x1013 ; (MCM_FIRST + 19)
Static MCM_GETMONTHRANGE       := 0x1007 ; (MCM_FIRST + 7)
Static MCM_GETRANGE            := 0x1011 ; (MCM_FIRST + 17)
Static MCM_GETSELRANGE         := 0x1005 ; (MCM_FIRST + 5)
Static MCM_GETTODAY            := 0x100D ; (MCM_FIRST + 13)
Static MCM_GETUNICODEFORMAT    := 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
Static MCM_HITTEST             := 0x100E ; (MCM_FIRST + 14)
Static MCM_SETCALENDARBORDER   := 0x101E ; (MCM_FIRST + 30) >= Vista
Static MCM_SETCALID            := 0x101C ; (MCM_FIRST + 28) >= Vista
Static MCM_SETCOLOR            := 0x100A ; (MCM_FIRST + 10)
Static MCM_SETCURRENTVIEW      := 0x1020 ; (MCM_FIRST + 32) >= Vista
Static MCM_SETCURSEL           := 0x1002 ; (MCM_FIRST + 2)
Static MCM_SETDAYSTATE         := 0x1008 ; (MCM_FIRST + 8)
Static MCM_SETFIRSTDAYOFWEEK   := 0x100F ; (MCM_FIRST + 15)
Static MCM_SETMAXSELCOUNT      := 0x1004 ; (MCM_FIRST + 4)
Static MCM_SETMONTHDELTA       := 0x1014 ; (MCM_FIRST + 20)
Static MCM_SETRANGE            := 0x1012 ; (MCM_FIRST + 18)
Static MCM_SETSELRANGE         := 0x1006 ; (MCM_FIRST + 6)
Static MCM_SETTODAY            := 0x100C ; (MCM_FIRST + 12)
Static MCM_SETUNICODEFORMAT    := 0x2005 ; (CCM_FIRST + 5) CCM_SETUNICODEFORMAT
Static MCM_SIZERECTTOMIN       := 0x101D ; (MCM_FIRST + 29) >= Vista
; Notifications ========================================================================================================
Static MCN_SELECT              := -746 ; (MCN_FIRST)
Static MCN_GETDAYSTATE         := -747 ; (MCN_FIRST - 1)
Static MCN_SELCHANGE           := -749 ; (MCN_FIRST - 3)
Static MCN_VIEWCHANGE          := -750 ; (MCN_FIRST - 4)
; Styles ===============================================================================================================
Static MCS_DAYSTATE            := 0x0001
Static MCS_MULTISELECT         := 0x0002
Static MCS_WEEKNUMBERS         := 0x0004
Static MCS_NOTODAYCIRCLE       := 0x0008
Static MCS_NOTODAY             := 0x0010
Static MCS_NOTRAILINGDATES     := 0x0040 ; >= Vista
Static MCS_SHORTDAYSOFWEEK     := 0x0080 ; >= Vista
Static MCS_NOSELCHANGEONNAV    := 0x0100 ; >= Vista
; Errors and Other =====================================================================================================
; MCM_GET/SETCOLOROR
Static MCSC_BACKGROUND         := 0 ; the background color := (between months)
Static MCSC_MONTHBK            := 4 ; background within the month cal
Static MCSC_TEXT               := 1 ; the dates
Static MCSC_TITLEBK            := 2 ; background of the title
Static MCSC_TITLETEXT          := 3
Static MCSC_TRAILINGTEXT       := 5 ; the text color of header & trailing days
; MCM_HITTET
Static MCHT_CALENDAR           := 0x00020000
Static MCHT_CALENDARBK         := 0x00020000 ; (MCHT_CALENDAR)
Static MCHT_CALENDARCONTROL    := 0x00100000 ; >= Vista
Static MCHT_CALENDARDATE       := 0x00020001 ; (MCHT_CALENDAR | 0x0001)
Static MCHT_CALENDARDATEMAX    := 0x00020005 ; (MCHT_CALENDAR | 0x0005)
Static MCHT_CALENDARDATEMIN    := 0x00020004 ; (MCHT_CALENDAR | 0x0004)
Static MCHT_CALENDARDATENEXT   := 0x01020000 ; (MCHT_CALENDARDATE | MCHT_NEXT)
Static MCHT_CALENDARDATEPREV   := 0x02020000 ; (MCHT_CALENDARDATE | MCHT_PREV)
Static MCHT_CALENDARDAY        := 0x00020002 ; (MCHT_CALENDAR | 0x0002)
Static MCHT_CALENDARWEEKNUM    := 0x00020003 ; (MCHT_CALENDAR | 0x0003)
Static MCHT_NEXT               := 0x01000000 ; these indicate that hitting
Static MCHT_NOWHERE            := 0x00000000
Static MCHT_PREV               := 0x02000000 ; here will go to the next/prev month
Static MCHT_TITLE              := 0x00010000
Static MCHT_TITLEBK            := 0x00010000 ; (MCHT_TITLE)
Static MCHT_TITLEBTNNEXT       := 0x01010003 ; (MCHT_TITLE | MCHT_NEXT | 0x0003)
Static MCHT_TITLEBTNPREV       := 0x02010003 ; (MCHT_TITLE | MCHT_PREV | 0x0003)
Static MCHT_TITLEMONTH         := 0x00010001 ; (MCHT_TITLE | 0x0001)
Static MCHT_TITLEYEAR          := 0x00010002 ; (MCHT_TITLE | 0x0002)
Static MCHT_TODAYLINK          := 0x00030000
; MCM_GET/SETCURRENTVIEW >= Vista
Static MCMV_CENTURY            := 3
Static MCMV_DECADE             := 2
Static MCMV_MAX                := 3 ; MCMV_CENTURY
Static MCMV_MONTH              := 0
Static MCMV_YEAR               := 1
; MCM_GET/SETCALENDARGRIDINFO >= Vista
Static MCGIF_DATE              := 0x00000001
Static MCGIF_NAME              := 0x00000004
Static MCGIF_RECT              := 0x00000002
Static MCGIP_CALENDAR          := 4
Static MCGIP_CALENDARBODY      := 6
Static MCGIP_CALENDARCELL      := 8
Static MCGIP_CALENDARCONTROL   := 0
Static MCGIP_CALENDARHEADER    := 5
Static MCGIP_CALENDARROW       := 7
Static MCGIP_FOOTER            := 3
Static MCGIP_NEXT              := 1
Static MCGIP_PREV              := 2
; ======================================================================================================================

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
Static WC_PROGRESSBAR    := "msctls_progress32"
; Messages =============================================================================================================
Static PBM_DELTAPOS      := 0x0403 ; (WM_USER + 3)
Static PBM_GETBARCOLOR   := 0x040F ; (WM_USER + 15)  >= Vista
Static PBM_GETBKCOLOR    := 0x040E ; (WM_USER + 14)  >= Vista
Static PBM_GETPOS        := 0x0408 ; (WM_USER + 8)
Static PBM_GETRANGE      := 0x0407 ; (WM_USER + 7)   wParam = return:= (TRUE ? low : high). lParam = PPBRANGE or NULL
Static PBM_GETSTATE      := 0x0411 ; (WM_USER + 17)  >= Vista
Static PBM_GETSTEP       := 0x040D ; (WM_USER + 13)  >= Vista
Static PBM_SETBARCOLOR   := 0x0409 ; (WM_USER + 9)   lParam = bar color
Static PBM_SETBKCOLOR    := 0x2001 ; (CCM_FIRST + 1) CCM_SETBKCOLOR lParam = bkColor
Static PBM_SETMARQUEE    := 0x040A ; (WM_USER + 10)
Static PBM_SETPOS        := 0x0402 ; (WM_USER + 2)
Static PBM_SETRANGE      := 0x0401 ; (WM_USER + 1)
Static PBM_SETRANGE32    := 0x0406 ; (WM_USER + 6)   lParam = high, wParam = low
Static PBM_SETSTATE      := 0x0410 ; (WM_USER + 16)  >= Vista, wParam = PBST_[State]:= (NORMAL, ERROR, PAUSED)
Static PBM_SETSTEP       := 0x0404 ; (WM_USER + 4)
Static PBM_STEPIT        := 0x0405 ; (WM_USER + 5)
; Styles ===============================================================================================================
Static PBS_MARQUEE       := 0x08
Static PBS_SMOOTH        := 0x01
Static PBS_SMOOTHREVERSE := 0x10   ; >= Vista
Static PBS_VERTICAL      := 0x04
; Others ===============================================================================================================
; PBM_SETSTATE states >= Vista
Static PBST_NORMAL       := 1
Static PBST_ERROR        := 2
Static PBST_PAUSED       := 3
; ======================================================================================================================

; ======================================================================================================================
; Function:         Constants for Static controls (GUI: Text, Pic)
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; Class ================================================================================================================
Static WC_STATIC          := "Static"
; Messages =============================================================================================================
Static STM_GETICON        := 0x0171
Static STM_GETIMAGE       := 0x0173
Static STM_SETICON        := 0x0170
Static STM_SETIMAGE       := 0x0172
; Notifications ========================================================================================================
Static STN_CLICKED        := 0
Static STN_DBLCLK         := 1
Static STN_DISABLE        := 3
Static STN_ENABLE         := 2
; Styles ===============================================================================================================
Static SS_BITMAP          := 0x000E
Static SS_BLACKFRAME      := 0x0007
Static SS_BLACKRECT       := 0x0004
Static SS_CENTER          := 0x0001
Static SS_CENTERIMAGE     := 0x0200
Static SS_EDITCONTROL     := 0x2000
Static SS_ELLIPSISMASK    := 0xC000
Static SS_ENDELLIPSIS     := 0x4000
Static SS_ENHMETAFILE     := 0x000F
Static SS_ETCHEDFRAME     := 0x0012
Static SS_ETCHEDHORZ      := 0x0010
Static SS_ETCHEDVERT      := 0x0011
Static SS_GRAYFRAME       := 0x0008
Static SS_GRAYRECT        := 0x0005
Static SS_ICON            := 0x0003
Static SS_LEFT            := 0x0000
Static SS_LEFTNOWORDWRAP  := 0x000C
Static SS_NOPREFIX        := 0x0080
Static SS_NOTIFY          := 0x0100
Static SS_OWNERDRAW       := 0x000D
Static SS_PATHELLIPSIS    := 0x8000
Static SS_REALSIZECONTROL := 0x0040
Static SS_REALSIZEIMAGE   := 0x0800
Static SS_RIGHT           := 0x0002
Static SS_RIGHTJUST       := 0x0400
Static SS_SIMPLE          := 0x000B
Static SS_SUNKEN          := 0x1000
Static SS_TYPEMASK        := 0x001F
Static SS_USERITEM        := 0x000A
Static SS_WHITEFRAME      := 0x0009
Static SS_WHITERECT       := 0x0006
Static SS_WORDELLIPSIS    := 0xC000
; ======================================================================================================================

; ======================================================================================================================
; Function:          Constants for StatusBar controls
; AHK version:       1.1.05+
; Language:          English
; Version:           1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; CCM_FIRST = 0x2000
; SBN_FIRST = -880  ; status bar
; WM_USER   = 0x0400
; ======================================================================================================================
; Class ================================================================================================================
Static WC_STATUSBAR        := "msctls_statusbar32"
; Messages =============================================================================================================
Static SB_GETBORDERS        := 0x0407 ; (WM_USER + 7)
Static SB_GETICON           := 0x0414 ; (WM_USER + 20)
Static SB_GETPARTS          := 0x0406 ; (WM_USER + 6)
Static SB_GETRECT           := 0x040A ; (WM_USER + 10)
Static SB_GETTEXTA          := 0x0402 ; (WM_USER + 2)
Static SB_GETTEXTLENGTHA    := 0x0403 ; (WM_USER + 3)
Static SB_GETTEXTLENGTHW    := 0x040C ; (WM_USER + 12)
Static SB_GETTEXTW          := 0x040D ; (WM_USER + 13)
Static SB_GETTIPTEXTA       := 0x0412 ; (WM_USER + 18)
Static SB_GETTIPTEXTW       := 0x0413 ; (WM_USER + 19)
Static SB_GETUNICODEFORMAT  := 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
Static SB_ISSIMPLE          := 0x040E ; (WM_USER + 14)
Static SB_SETBKCOLOR        := 0x2001 ; (CCM_FIRST + 1) CCM_SETBKCOLOR lParam = bkColor
Static SB_SETICON           := 0x040F ; (WM_USER + 15)
Static SB_SETMINHEIGHT      := 0x0408 ; (WM_USER + 8)
Static SB_SETPARTS          := 0x0404 ; (WM_USER + 4)
Static SB_SETTEXTA          := 0x0401 ; (WM_USER + 1)
Static SB_SETTEXTW          := 0x040B ; (WM_USER + 11)
Static SB_SETTIPTEXTA       := 0x0410 ; (WM_USER + 16)
Static SB_SETTIPTEXTW       := 0x0411 ; (WM_USER + 17)
Static SB_SETUNICODEFORMAT  := 0x2005 ; (CCM_FIRST + 5) CCM_SETUNICODEFORMAT
Static SB_SIMPLE            := 0x0409 ; (WM_USER + 9)
; Notifications ========================================================================================================
Static SBN_SIMPLEMODECHANGE := -880   ; (SBN_FIRST - 0)
; Styles ===============================================================================================================
Static SBARS_SIZEGRIP       := 0x0100
Static SBARS_TOOLTIPS       := 0x0800
Static SBT_TOOLTIPS         := 0x0800 ; this is a status bar flag, preference to SBARS_TOOLTIPS
; Others ===============================================================================================================
; SB_GET/SETTEXT return codes
Static SBT_NOBORDERS        := 0x0100
Static SBT_NOTABPARSING     := 0x0800
Static SBT_OWNERDRAW        := 0x1000
Static SBT_POPOUT           := 0x0200
Static SBT_RTLREADING       := 0x0400
; ======================================================================================================================

; ======================================================================================================================
; Function:         Constants for Tab controls (Tab2)
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; CCM_FIRST = 0x2000
; TCM_FIRST = 0x1300 Tab control messages
; TCN_FIRST = -550   Tab control notifications
; ======================================================================================================================
; Class ================================================================================================================
Static WC_TAB                := "SysTabControl32"
; Messages =============================================================================================================
Static TCM_ADJUSTRECT        := 0x1328 ; (TCM_FIRST + 40)
Static TCM_DELETEALLITEMS    := 0x1309 ; (TCM_FIRST + 9)
Static TCM_DELETEITEM        := 0x1308 ; (TCM_FIRST + 8)
Static TCM_DESELECTALL       := 0x1332 ; (TCM_FIRST + 50)
Static TCM_GETCURFOCUS       := 0x132F ; (TCM_FIRST + 47)
Static TCM_GETCURSEL         := 0x130B ; (TCM_FIRST + 11)
Static TCM_GETEXTENDEDSTYLE  := 0x1335 ; (TCM_FIRST + 53)
Static TCM_GETIMAGELIST      := 0x1302 ; (TCM_FIRST + 2)
Static TCM_GETITEMA          := 0x1305 ; (TCM_FIRST + 5)
Static TCM_GETITEMCOUNT      := 0x1304 ; (TCM_FIRST + 4)
Static TCM_GETITEMRECT       := 0x130A ; (TCM_FIRST + 10)
Static TCM_GETITEMW          := 0x133C ; (TCM_FIRST + 60)
Static TCM_GETROWCOUNT       := 0x132C ; (TCM_FIRST + 44)
Static TCM_GETTOOLTIPS       := 0x132D ; (TCM_FIRST + 45)
Static TCM_GETUNICODEFORMAT  := 0x2006 ; (CCM_FIRST + 6)  CCM_GETUNICODEFORMAT
Static TCM_HIGHLIGHTITEM     := 0x1333 ; (TCM_FIRST + 51)
Static TCM_HITTEST           := 0x130D ; (TCM_FIRST + 13)
Static TCM_INSERTITEMA       := 0x1307 ; (TCM_FIRST + 7)
Static TCM_INSERTITEMW       := 0x133E ; (TCM_FIRST + 62)
;Static TCM_INSERTITEMW       := 0x133E ; (TCM_FIRST + 62)
Static TCM_REMOVEIMAGE       := 0x132A ; (TCM_FIRST + 42)
Static TCM_SETCURFOCUS       := 0x1330 ; (TCM_FIRST + 48)
Static TCM_SETCURSEL         := 0x130C ; (TCM_FIRST + 12)
Static TCM_SETEXTENDEDSTYLE  := 0x1334 ; (TCM_FIRST + 52) optional wParam == mask
Static TCM_SETIMAGELIST      := 0x1303 ; (TCM_FIRST + 3)
Static TCM_SETITEMA          := 0x1306 ; (TCM_FIRST + 6)
Static TCM_SETITEMEXTRA      := 0x130E ; (TCM_FIRST + 14)
Static TCM_SETITEMSIZE       := 0x1329 ; (TCM_FIRST + 41)
Static TCM_SETITEMW          := 0x133D ; (TCM_FIRST + 61)
Static TCM_SETMINTABWIDTH    := 0x1331 ; (TCM_FIRST + 49)
Static TCM_SETPADDING        := 0x130B ; (TCM_FIRST + 43)
Static TCM_SETTOOLTIPS       := 0x132E ; (TCM_FIRST + 46)
Static TCM_SETUNICODEFORMAT  := 0x2005 ; (CCM_FIRST + 5)  CCM_SETUNICODEFORMAT
; Notifications ========================================================================================================
Static TCN_FOCUSCHANGE       := -554   ; (TCN_FIRST - 4)
Static TCN_GETOBJECT         := -553   ; (TCN_FIRST - 3)
Static TCN_KEYDOWN           := -550   ; (TCN_FIRST - 0)
Static TCN_SELCHANGE         := -551   ; (TCN_FIRST - 1)
Static TCN_SELCHANGING       := -552   ; (TCN_FIRST - 2)
; Styles ===============================================================================================================
Static TCS_BOTTOM            := 0x0002
Static TCS_BUTTONS           := 0x0100
Static TCS_FIXEDWIDTH        := 0x0400
Static TCS_FLATBUTTONS       := 0x0008
Static TCS_FOCUSNEVER        := 0x8000
Static TCS_FOCUSONBUTTONDOWN := 0x1000
Static TCS_FORCEICONLEFT     := 0x0010
Static TCS_FORCELABELLEFT    := 0x0020
Static TCS_HOTTRACK          := 0x0040
Static TCS_MULTILINE         := 0x0200
Static TCS_MULTISELECT       := 0x0004 ; allow multi-select in button mode
Static TCS_OWNERDRAWFIXED    := 0x2000
Static TCS_RAGGEDRIGHT       := 0x0800
Static TCS_RIGHT             := 0x0002
Static TCS_RIGHTJUSTIFY      := 0x0000
Static TCS_SCROLLOPPOSITE    := 0x0001 ; assumes multiline tab
Static TCS_SINGLELINE        := 0x0000
Static TCS_TABS              := 0x0000
Static TCS_TOOLTIPS          := 0x4000
Static TCS_VERTICAL          := 0x0080
; ExStyles =============================================================================================================
Static TCS_EX_FLATSEPARATORS := 0x00000001
Static TCS_EX_REGISTERDROP   := 0x00000002
; Errors and Other =====================================================================================================
; TCITEM mask
Static TCIF_IMAGE            := 0x0002
Static TCIF_PARAM            := 0x0008
Static TCIF_RTLREADING       := 0x0004
Static TCIF_STATE            := 0x0010
Static TCIF_TEXT             := 0x0001
; TCITEM dwState
Static TCIS_BUTTONPRESSED    := 0x0001
Static TCIS_HIGHLIGHTED      := 0x0002
; TCHITTESTINFO flags
Static TCHT_NOWHERE          := 0x0001
Static TCHT_ONITEMICON       := 0x0002
Static TCHT_ONITEMLABEL      := 0x0004
Static TCHT_ONITEM           := 0x0006 ; (TCHT_ONITEMICON | TCHT_ONITEMLABEL)
; ======================================================================================================================

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
Static WC_TOOLTIP          := "tooltips_class32"
; Messages =============================================================================================================
Static TTM_ACTIVATE        := 0x0401 ; (WM_USER + 1)
Static TTM_ADDTOOLA        := 0x0404 ; (WM_USER + 4)
Static TTM_ADDTOOLW        := 0x0432 ; (WM_USER + 50)
Static TTM_ADJUSTRECT      := 0x041F ; (WM_USER + 31)
Static TTM_DELTOOLA        := 0x0405 ; (WM_USER + 5)
Static TTM_DELTOOLW        := 0x0433 ; (WM_USER + 51)
Static TTM_ENUMTOOLSA      := 0x040E ; (WM_USER + 14)
Static TTM_ENUMTOOLSW      := 0x043A ; (WM_USER + 58)
Static TTM_GETBUBBLESIZE   := 0x041E ; (WM_USER + 30)
Static TTM_GETCURRENTTOOLA := 0x040F ; (WM_USER + 15)
Static TTM_GETCURRENTTOOLW := 0x043B ; (WM_USER + 59)
Static TTM_GETDELAYTIME    := 0x0415 ; (WM_USER + 21)
Static TTM_GETMARGIN       := 0x041B ; (WM_USER + 27) lParam = lprc
Static TTM_GETMAXTIPWIDTH  := 0x0419 ; (WM_USER + 25)
Static TTM_GETTEXTA        := 0x040B ; (WM_USER + 11)
Static TTM_GETTEXTW        := 0x0438 ; (WM_USER + 56)
Static TTM_GETTIPBKCOLOR   := 0x0416 ; (WM_USER + 22)
Static TTM_GETTIPTEXTCOLOR := 0x0417 ; (WM_USER + 23)
Static TTM_GETTITLE        := 0x0423 ; (WM_USER + 35) wParam = 0, lParam = TTGETTITLE*
Static TTM_GETTOOLCOUNT    := 0x040D ; (WM_USER + 13)
Static TTM_GETTOOLINFOA    := 0x0408 ; (WM_USER + 8)
Static TTM_GETTOOLINFOW    := 0x0435 ; (WM_USER + 53)
Static TTM_HITTESTA        := 0x040A ; (WM_USER + 10)
Static TTM_HITTESTW        := 0x0437 ; (WM_USER + 55)
Static TTM_NEWTOOLRECTA    := 0x0406 ; (WM_USER + 6)
Static TTM_NEWTOOLRECTW    := 0x0434 ; (WM_USER + 52)
Static TTM_POP             := 0x041C ; (WM_USER + 28)
Static TTM_POPUP           := 0x0422 ; (WM_USER + 34)
Static TTM_RELAYEVENT      := 0x0407 ; (WM_USER + 7)  Win7: wParam = GetMessageExtraInfo() when relaying WM_MOUSEMOVE
Static TTM_SETDELAYTIME    := 0x0403 ; (WM_USER + 3)
Static TTM_SETMARGIN       := 0x041A ; (WM_USER + 26) lParam = lprc
Static TTM_SETMAXTIPWIDTH  := 0x0418 ; (WM_USER + 24)
Static TTM_SETTIPBKCOLOR   := 0x0413 ; (WM_USER + 19)
Static TTM_SETTIPTEXTCOLOR := 0x0414 ; (WM_USER + 20)
Static TTM_SETTITLEA       := 0x0420 ; (WM_USER + 32) wParam = TTI_*, lParam = char* szTitle
Static TTM_SETTITLEW       := 0x0421 ; (WM_USER + 33) wParam = TTI_*, lParam = wchar* szTitle
Static TTM_SETTOOLINFOA    := 0x0409 ; (WM_USER + 9)
Static TTM_SETTOOLINFOW    := 0x0636 ; (WM_USER + 54)
Static TTM_SETWINDOWTHEME  := 0x200B ; (CCM_FIRST + 0xB) CCM_SETWINDOWTHEME
Static TTM_TRACKACTIVATE   := 0x0411 ; (WM_USER + 17) wParam = TRUE/FALSE start end  lparam = LPTOOLINFO
Static TTM_TRACKPOSITION   := 0x0412 ; (WM_USER + 18) lParam = dwPos
Static TTM_UPDATE          := 0x041D ; (WM_USER + 29)
Static TTM_UPDATETIPTEXTA  := 0x040C ; (WM_USER + 12)
Static TTM_UPDATETIPTEXTW  := 0x0439 ; (WM_USER + 57)
Static TTM_WINDOWFROMPOINT := 0x0410 ; (WM_USER + 16)
; Notifications ========================================================================================================
Static TTN_GETDISPINFOA    := -520   ; (TTN_FIRST - 0)
Static TTN_GETDISPINFOW    := -530   ; (TTN_FIRST - 10)
Static TTN_LINKCLICK       := -523   ; (TTN_FIRST - 3)
Static TTN_NEEDTEXTA       := -520   ; TTN_GETDISPINFOA
Static TTN_NEEDTEXTW       := -530   ; TTN_GETDISPINFOW
Static TTN_POP             := -522   ; (TTN_FIRST - 2)
Static TTN_SHOW            := -521   ; (TTN_FIRST - 1)
; Styles ===============================================================================================================
Static TTS_ALWAYSTIP       := 0x01
Static TTS_BALLOON         := 0x40
Static TTS_CLOSE           := 0x80
Static TTS_NOANIMATE       := 0x10
Static TTS_NOFADE          := 0x20
Static TTS_NOPREFIX        := 0x02
Static TTS_USEVISUALSTYLE  := 0x100   ; >= Vista: use themed hyperlinks
; Others ===============================================================================================================
; TOOLINFO uFlags
; Use TTF_CENTERTIP to center around trackpoint in trackmode -OR- to center around tool in normal mode.
; Use TTF_ABSOLUTE to place the tip exactly at the track coords when in tracking mode.
; TTF_ABSOLUTE can be used in conjunction with TTF_CENTERTIP to center the tip absolutely about the track point.
Static TTF_ABSOLUTE        := 0x0080
Static TTF_CENTERTIP       := 0x0002
Static TTF_DI_SETITEM      := 0x8000 ; valid only on the TTN_NEEDTEXT callback
Static TTF_IDISHWND        := 0x0001
Static TTF_PARSELINKS      := 0x1000
Static TTF_RTLREADING      := 0x0004
Static TTF_SUBCLASS        := 0x0010
Static TTF_TRACK           := 0x0020
Static TTF_TRANSPARENT     := 0x0100
; TTMSETDELAYTIME
Static TTDT_AUTOMATIC      := 0
Static TTDT_RESHOW         := 1
Static TTDT_AUTOPOP        := 2
Static TTDT_INITIAL        := 3
; TTM_SETTITLE Tooltip icons
Static TTI_NONE            := 0
Static TTI_INFO            := 1
Static TTI_WARNING         := 2
Static TTI_ERROR           := 3
Static TTI_INFO_LARGE      := 4      ; >= Vista
Static TTI_WARNING_LARGE   := 5      ; >= Vista
Static TTI_ERROR_LARGE     := 6      ; >= Vista
; ======================================================================================================================

; ======================================================================================================================
; Function:         Constants for TreeView controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; CCM_FIRST = 0x2000
; TV_FIRST  = 0x1100
; TVN_FIRST = -400
; ======================================================================================================================
; Class ================================================================================================================
Static WC_TREEVIEW             := "SysTreeView32"
; Messages =============================================================================================================
Static TVM_CREATEDRAGIMAGE     := 0x1112 ; (TV_FIRST + 18)
Static TVM_DELETEITEM          := 0x1101 ; (TV_FIRST + 1)
Static TVM_EDITLABELA          := 0x110E ; (TV_FIRST + 14)
Static TVM_EDITLABELW          := 0x1141 ; (TV_FIRST + 65)
Static TVM_ENDEDITLABELNOW     := 0x1116 ; (TV_FIRST + 22)
Static TVM_ENSUREVISIBLE       := 0x1114 ; (TV_FIRST + 20)
Static TVM_EXPAND              := 0x1102 ; (TV_FIRST + 2)
Static TVM_GETBKCOLOR          := 0x112F ; (TV_FIRST + 31)
Static TVM_GETCOUNT            := 0x1105 ; (TV_FIRST + 5)
Static TVM_GETEDITCONTROL      := 0x110F ; (TV_FIRST + 15)
Static TVM_GETEXTENDEDSTYLE    := 0x112D ; (TV_FIRST + 45)
Static TVM_GETIMAGELIST        := 0x1108 ; (TV_FIRST + 8)
Static TVM_GETINDENT           := 0x1106 ; (TV_FIRST + 6)
Static TVM_GETINSERTMARKCOLOR  := 0x1126 ; (TV_FIRST + 38)
Static TVM_GETISEARCHSTRINGA   := 0x1117 ; (TV_FIRST + 23)
Static TVM_GETISEARCHSTRINGW   := 0x1140 ; (TV_FIRST + 64)
Static TVM_GETITEMA            := 0x110C ; (TV_FIRST + 12)
Static TVM_GETITEMHEIGHT       := 0x111C ; (TV_FIRST + 28)
Static TVM_GETITEMPARTRECT     := 0x1148 ; (TV_FIRST + 72) ; >= Vista
Static TVM_GETITEMRECT         := 0x1104 ; (TV_FIRST + 4)
Static TVM_GETITEMSTATE        := 0x1127 ; (TV_FIRST + 39)
Static TVM_GETITEMW            := 0x113E ; (TV_FIRST + 62)
Static TVM_GETLINECOLOR        := 0x1129 ; (TV_FIRST + 41)
Static TVM_GETNEXTITEM         := 0x110A ; (TV_FIRST + 10)
Static TVM_GETSCROLLTIME       := 0x1122 ; (TV_FIRST + 34)
Static TVM_GETSELECTEDCOUNT    := 0x1146 ; (TV_FIRST + 70) ; >= Vista
Static TVM_GETTEXTCOLOR        := 0x1120 ; (TV_FIRST + 32)
Static TVM_GETTOOLTIPS         := 0x1119 ; (TV_FIRST + 25)
Static TVM_GETUNICODEFORMAT    := 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
Static TVM_GETVISIBLECOUNT     := 0x1110 ; (TV_FIRST + 16)
Static TVM_HITTEST             := 0x1111 ; (TV_FIRST + 17)
Static TVM_INSERTITEMA         := 0x1100 ; (TV_FIRST + 0)
Static TVM_INSERTITEMW         := 0x1142 ; (TV_FIRST + 50)
Static TVM_MAPACCIDTOHTREEITEM := 0x112A ; (TV_FIRST + 42)
Static TVM_MAPHTREEITEMTOACCID := 0x112B ; (TV_FIRST + 43)
Static TVM_SELECTITEM          := 0x110B ; (TV_FIRST + 11)
Static TVM_SETAUTOSCROLLINFO   := 0x113B ; (TV_FIRST + 59)
Static TVM_SETBKCOLOR          := 0x111D ; (TV_FIRST + 29)
Static TVM_SETEXTENDEDSTYLE    := 0x112C ; (TV_FIRST + 44)
Static TVM_SETIMAGELIST        := 0x1109 ; (TV_FIRST + 9)
Static TVM_SETINDENT           := 0x1107 ; (TV_FIRST + 7)
Static TVM_SETINSERTMARK       := 0x111A ; (TV_FIRST + 26)
Static TVM_SETINSERTMARKCOLOR  := 0x1125 ; (TV_FIRST + 37)
Static TVM_SETITEMA            := 0x110D ; (TV_FIRST + 13)
Static TVM_SETITEMHEIGHT       := 0x111B ; (TV_FIRST + 27)
Static TVM_SETITEMW            := 0x113F ; (TV_FIRST + 63)
Static TVM_SETLINECOLOR        := 0x1128 ; (TV_FIRST + 40)
Static TVM_SETSCROLLTIME       := 0x1121 ; (TV_FIRST + 33)
Static TVM_SETTEXTCOLOR        := 0x111E ; (TV_FIRST + 30)
Static TVM_SETTOOLTIPS         := 0x1118 ; (TV_FIRST + 24)
Static TVM_SETUNICODEFORMAT    := 0x2005 ; (CCM_FIRST + 5) ; CCM_SETUNICODEFORMAT
Static TVM_SHOWINFOTIP         := 0x1147 ; (TV_FIRST + 71) ; >= Vista
Static TVM_SORTCHILDREN        := 0x1113 ; (TV_FIRST + 19)
Static TVM_SORTCHILDRENCB      := 0x1115 ; (TV_FIRST + 21)
; Notifications ========================================================================================================
Static TVN_ASYNCDRAW           := -420 ; (TVN_FIRST - 20) >= Vista
Static TVN_BEGINDRAGA          := -427 ; (TVN_FIRST - 7)
Static TVN_BEGINDRAGW          := -456 ; (TVN_FIRST - 56)
Static TVN_BEGINLABELEDITA     := -410 ; (TVN_FIRST - 10)
Static TVN_BEGINLABELEDITW     := -456 ; (TVN_FIRST - 59)
Static TVN_BEGINRDRAGA         := -408 ; (TVN_FIRST - 8)
Static TVN_BEGINRDRAGW         := -457 ; (TVN_FIRST - 57)
Static TVN_DELETEITEMA         := -409 ; (TVN_FIRST - 9)
Static TVN_DELETEITEMW         := -458 ; (TVN_FIRST - 58)
Static TVN_ENDLABELEDITA       := -411 ; (TVN_FIRST - 11)
Static TVN_ENDLABELEDITW       := -460 ; (TVN_FIRST - 60)
Static TVN_GETDISPINFOA        := -403 ; (TVN_FIRST - 3)
Static TVN_GETDISPINFOW        := -452 ; (TVN_FIRST - 52)
Static TVN_GETINFOTIPA         := -412 ; (TVN_FIRST - 13)
Static TVN_GETINFOTIPW         := -414 ; (TVN_FIRST - 14)
Static TVN_ITEMCHANGEDA        := -418 ; (TVN_FIRST - 18) ; >= Vista
Static TVN_ITEMCHANGEDW        := -419 ; (TVN_FIRST - 19) ; >= Vista
Static TVN_ITEMCHANGINGA       := -416 ; (TVN_FIRST - 16) ; >= Vista
Static TVN_ITEMCHANGINGW       := -417 ; (TVN_FIRST - 17) ; >= Vista
Static TVN_ITEMEXPANDEDA       := -406 ; (TVN_FIRST - 6)
Static TVN_ITEMEXPANDEDW       := -455 ; (TVN_FIRST - 55)
Static TVN_ITEMEXPANDINGA      := -405 ; (TVN_FIRST - 5)
Static TVN_ITEMEXPANDINGW      := -454 ; (TVN_FIRST - 54)
Static TVN_KEYDOWN             := -412 ; (TVN_FIRST - 12)
Static TVN_SELCHANGEDA         := -402 ; (TVN_FIRST - 2)
Static TVN_SELCHANGEDW         := -451 ; (TVN_FIRST - 51)
Static TVN_SELCHANGINGA        := -401 ; (TVN_FIRST - 1)
Static TVN_SELCHANGINGW        := -450 ; (TVN_FIRST - 50)
Static TVN_SETDISPINFOA        := -404 ; (TVN_FIRST - 4)
Static TVN_SETDISPINFOW        := -453 ; (TVN_FIRST - 53)
Static TVN_SINGLEEXPAND        := -415 ; (TVN_FIRST - 15)
; Styles ===============================================================================================================
Static TVS_CHECKBOXES          := 0x0100
Static TVS_DISABLEDRAGDROP     := 0x0010
Static TVS_EDITLABELS          := 0x0008
Static TVS_FULLROWSELECT       := 0x1000
Static TVS_HASBUTTONS          := 0x0001
Static TVS_HASLINES            := 0x0002
Static TVS_INFOTIP             := 0x0800
Static TVS_LINESATROOT         := 0x0004
Static TVS_NOHSCROLL           := 0x8000 ; TVS_NOSCROLL overrides this
Static TVS_NONEVENHEIGHT       := 0x4000
Static TVS_NOSCROLL            := 0x2000
Static TVS_NOTOOLTIPS          := 0x0080
Static TVS_RTLREADING          := 0x0040
Static TVS_SHOWSELALWAYS       := 0x0020
Static TVS_SINGLEEXPAND        := 0x0400
Static TVS_TRACKSELECT         := 0x0200
; Exstyles =============================================================================================================
Static TVS_EX_AUTOHSCROLL         := 0x0020 ; >= Vista
Static TVS_EX_DIMMEDCHECKBOXES    := 0x0200 ; >= Vista
Static TVS_EX_DOUBLEBUFFER        := 0x0004 ; >= Vista
Static TVS_EX_DRAWIMAGEASYNC      := 0x0400 ; >= Vista
Static TVS_EX_EXCLUSIONCHECKBOXES := 0x0100 ; >= Vista
Static TVS_EX_FADEINOUTEXPANDOS   := 0x0040 ; >= Vista
Static TVS_EX_MULTISELECT         := 0x0002 ; >= Vista - Not supported. Do not use.
Static TVS_EX_NOINDENTSTATE       := 0x0008 ; >= Vista
Static TVS_EX_NOSINGLECOLLAPSE    := 0x0001 ; >= Vista - Intended for internal use; not recommended for use in applications.
Static TVS_EX_PARTIALCHECKBOXES   := 0x0080 ; >= Vista
Static TVS_EX_RICHTOOLTIP         := 0x0010 ; >= Vista
; Others ===============================================================================================================
; Item flags
Static TVIF_CHILDREN           := 0x0040
Static TVIF_DI_SETITEM         := 0x1000
Static TVIF_EXPANDEDIMAGE      := 0x0200 ; >= Vista
Static TVIF_HANDLE             := 0x0010
Static TVIF_IMAGE              := 0x0002
Static TVIF_INTEGRAL           := 0x0080
Static TVIF_PARAM              := 0x0004
Static TVIF_SELECTEDIMAGE      := 0x0020
Static TVIF_STATE              := 0x0008
Static TVIF_STATEEX            := 0x0100 ; >= Vista
Static TVIF_TEXT               := 0x0001
; Item states
Static TVIS_BOLD               := 0x0010
Static TVIS_CUT                := 0x0004
Static TVIS_DROPHILITED        := 0x0008
Static TVIS_EXPANDED           := 0x0020
Static TVIS_EXPANDEDONCE       := 0x0040
Static TVIS_EXPANDPARTIAL      := 0x0080
Static TVIS_OVERLAYMASK        := 0x0F00
Static TVIS_SELECTED           := 0x0002
Static TVIS_STATEIMAGEMASK     := 0xF000
Static TVIS_USERMASK           := 0xF000
; TVITEMEX uStateEx
Static TVIS_EX_ALL             := 0x0002 ; not documented
Static TVIS_EX_DISABLED        := 0x0002 ; >= Vista
Static TVIS_EX_FLAT            := 0x0001
; TVINSERTSTRUCT hInsertAfter
Static TVI_FIRST               := -65535 ; (-0x0FFFF)
Static TVI_LAST                := -65534 ; (-0x0FFFE)
Static TVI_ROOT                := -65536 ; (-0x10000)
Static TVI_SORT                := -65533 ; (-0x0FFFD)
; TVM_EXPAND wParam
Static TVE_COLLAPSE            := 0x0001
Static TVE_COLLAPSERESET       := 0x8000
Static TVE_EXPAND              := 0x0002
Static TVE_EXPANDPARTIAL       := 0x4000
Static TVE_TOGGLE              := 0x0003
; TVM_GETIMAGELIST wParam
Static TVSIL_NORMAL            := 0
Static TVSIL_STATE             := 2
; TVM_GETNEXTITEM wParam
Static TVGN_CARET              := 0x0009
Static TVGN_CHILD              := 0x0004
Static TVGN_DROPHILITE         := 0x0008
Static TVGN_FIRSTVISIBLE       := 0x0005
Static TVGN_LASTVISIBLE        := 0x000A
Static TVGN_NEXT               := 0x0001
Static TVGN_NEXTSELECTED       := 0x000B ; >= Vista (MSDN)
Static TVGN_NEXTVISIBLE        := 0x0006
Static TVGN_PARENT             := 0x0003
Static TVGN_PREVIOUS           := 0x0002
Static TVGN_PREVIOUSVISIBLE    := 0x0007
Static TVGN_ROOT               := 0x0000
; TVM_SELECTITEM wParam
Static TVSI_NOSINGLEEXPAND     := 0x8000 ; Should not conflict with TVGN flags.
; TVHITTESTINFO flags
Static TVHT_ABOVE              := 0x0100
Static TVHT_BELOW              := 0x0200
Static TVHT_NOWHERE            := 0x0001
Static TVHT_ONITEMBUTTON       := 0x0010
Static TVHT_ONITEMICON         := 0x0002
Static TVHT_ONITEMINDENT       := 0x0008
Static TVHT_ONITEMLABEL        := 0x0004
Static TVHT_ONITEMRIGHT        := 0x0020
Static TVHT_ONITEMSTATEICON    := 0x0040
Static TVHT_TOLEFT             := 0x0800
Static TVHT_TORIGHT            := 0x0400
Static TVHT_ONITEM             := 0x0046 ; (TVHT_ONITEMICON | TVHT_ONITEMLABEL | TVHT_ONITEMSTATEICON)
; TVGETITEMPARTRECTINFO partID (>= Vista)
Static TVGIPR_BUTTON           := 0x0001
; NMTREEVIEW action
Static TVC_BYKEYBOARD          := 0x0002
Static TVC_BYMOUSE             := 0x0001
Static TVC_UNKNOWN             := 0x0000
; TVN_SINGLEEXPAND return codes
Static TVNRET_DEFAULT          := 0
Static TVNRET_SKIPOLD          := 1
Static TVNRET_SKIPNEW          := 2
; ======================================================================================================================

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
Static WC_UPDOWN            := "msctls_updown32"
; Messages =============================================================================================================
Static UDM_SETRANGE         				:= 0x0465 ; (WM_USER + 101)
Static UDM_GETRANGE         			:= 0x0466 ; (WM_USER + 102)
Static UDM_SETPOS           				:= 0x0467 ; (WM_USER + 103)
Static UDM_GETPOS           				:= 0x0468 ; (WM_USER + 104)
Static UDM_SETBUDDY         				:= 0x0469 ; (WM_USER + 105)
Static UDM_GETBUDDY         			:= 0x046A ; (WM_USER + 106)
Static UDM_SETACCEL         				:= 0x046B ; (WM_USER + 107)
Static UDM_GETACCEL         			:= 0x046C ; (WM_USER + 108)
Static UDM_SETBASE          				:= 0x046D ; (WM_USER + 109)
Static UDM_GETBASE          				:= 0x046E ; (WM_USER + 110)
Static UDM_SETRANGE32       			:= 0x046F ; (WM_USER + 111)
Static UDM_GETRANGE32       			:= 0x0470 ; (WM_USER + 112) wParam & lParam are LPINT
Static UDM_SETUNICODEFORMAT 	:= 0x2005 ; (CCM_FIRST + 5) CCM_SETUNICODEFORMAT
Static UDM_GETUNICODEFORMAT 	:= 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
Static UDM_SETPOS32         				:= 0x0471 ; (WM_USER + 113)
Static UDM_GETPOS32         			:= 0x0472 ; (WM_USER + 114)
; Notifications ========================================================================================================
Static UDN_DELTAPOS         				:= -722   ; (UDN_FIRST - 1)
; Styles ===============================================================================================================
Static UDS_WRAP             					:= 0x0001
Static UDS_SETBUDDYINT      			:= 0x0002
Static UDS_ALIGNRIGHT       				:= 0x0004
Static UDS_ALIGNLEFT        				:= 0x0008
Static UDS_AUTOBUDDY        			:= 0x0010
Static UDS_ARROWKEYS        			:= 0x0020
Static UDS_HORZ             					:= 0x0040
Static UDS_NOTHOUSANDS      		:= 0x0080
Static UDS_HOTTRACK         				:= 0x0100
; ======================================================================================================================

; ======================================================================================================================
; Function:         Constants for Windows
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; Remarks:          Only messages, styles and exstyles are included here, otherwise I wouldn't know, where to stop.
; ======================================================================================================================
; Messages / notifications =============================================================================================
Static MN_GETHMENU                := 0x01E1
Static WM_ACTIVATE                := 0x0006
Static WM_ACTIVATEAPP             := 0x001C
Static WM_AFXFIRST                := 0x0360
Static WM_AFXLAST                 := 0x037F
Static WM_APP                     := 0x8000
Static WM_APPCOMMAND              := 0x0319
Static WM_ASKCBFORMATNAME         := 0x030C
Static WM_CANCELMODE              := 0x001F
Static WM_CAPTURECHANGED          := 0x0215
Static WM_CHANGECBCHAIN           := 0x030D
Static WM_CHANGEUISTATE           := 0x0127
Static WM_CHAR                    := 0x0102
Static WM_CHARTOITEM              := 0x002F
Static WM_CHILDACTIVATE           := 0x0022
Static WM_CLEAR                   := 0x0303
Static WM_CLIPBOARDUPDATE         := 0x031D
Static WM_CLOSE                   := 0x0010
Static WM_COMMAND                 := 0x0111
Static WM_COMMNOTIFY              := 0x0044 ; no longer suported
Static WM_COMPACTING              := 0x0041
Static WM_COMPAREITEM             := 0x0039
Static WM_CONTEXTMENU             := 0x007B
Static WM_COPY                    := 0x0301
Static WM_CREATE                  := 0x0001
Static WM_CTLCOLORBTN             := 0x0135
Static WM_CTLCOLORDLG             := 0x0136
Static WM_CTLCOLOREDIT            := 0x0133
Static WM_CTLCOLORLISTBOX         := 0x0134
Static WM_CTLCOLORMSGBOX          := 0x0132
Static WM_CTLCOLORSCROLLBAR       := 0x0137
Static WM_CTLCOLORSTATIC          := 0x0138
Static WM_CUT                     := 0x0300
Static WM_DEADCHAR                := 0x0103
Static WM_DELETEITEM              := 0x002D
Static WM_DESTROY                 := 0x0002
Static WM_DESTROYCLIPBOARD        := 0x0307
Static WM_DEVICECHANGE            := 0x0219
Static WM_DEVMODECHANGE           := 0x001B
Static WM_DISPLAYCHANGE           := 0x007E
Static WM_DRAWCLIPBOARD           := 0x0308
Static WM_DRAWITEM                := 0x002B
Static WM_DROPFILES               := 0x0233
Static WM_DWMCOLORIZATIONCOLORCHANGED    := 0x0320 ; >= Vista
Static WM_DWMCOMPOSITIONCHANGED          := 0x031E ; >= Vista
Static WM_DWMNCRENDERINGCHANGED          := 0x031F ; >= Vista
Static WM_DWMSENDICONICLIVEPREVIEWBITMAP := 0x0326 ; >= Win 7
Static WM_DWMSENDICONICTHUMBNAIL         := 0x0323 ; >= Win 7
Static WM_DWMWINDOWMAXIMIZEDCHANGE       := 0x0321 ; >= Vista
Static WM_ENABLE                  := 0x000A
Static WM_ENDSESSION              := 0x0016
Static WM_ENTERIDLE               := 0x0121
Static WM_ENTERMENULOOP           := 0x0211
Static WM_ENTERSIZEMOVE           := 0x0231
Static WM_ERASEBKGND              := 0x0014
Static WM_EXITMENULOOP            := 0x0212
Static WM_EXITSIZEMOVE            := 0x0232
Static WM_FONTCHANGE              := 0x001D
Static WM_GESTURE                 := 0x0119 ; >= Win 7
Static WM_GESTURENOTIFY           := 0x011A ; >= Win 7
Static WM_GETDLGCODE              := 0x0087
Static WM_GETFONT                 := 0x0031
Static WM_GETHOTKEY               := 0x0033
Static WM_GETICON                 := 0x007F
Static WM_GETMINMAXINFO           := 0x0024
Static WM_GETOBJECT               := 0x003D
Static WM_GETTEXT                 := 0x000D
Static WM_GETTEXTLENGTH           := 0x000E
Static WM_GETTITLEBARINFOEX       := 0x033F ; >= Vista
Static WM_HANDHELDFIRST           := 0x0358
Static WM_HANDHELDLAST            := 0x035F
Static WM_HELP                    := 0x0053
Static WM_HOTKEY                  := 0x0312
Static WM_HSCROLL                 := 0x0114
Static WM_HSCROLLCLIPBOARD        := 0x030E
Static WM_ICONERASEBKGND          := 0x0027
Static WM_IME_CHAR                := 0x0286
Static WM_IME_COMPOSITION         := 0x010F
Static WM_IME_COMPOSITIONFULL     := 0x0284
Static WM_IME_CONTROL             := 0x0283
Static WM_IME_ENDCOMPOSITION      := 0x010E
Static WM_IME_KEYDOWN             := 0x0290
Static WM_IME_KEYLAST             := 0x010F
Static WM_IME_KEYUP               := 0x0291
Static WM_IME_NOTIFY              := 0x0282
Static WM_IME_REQUEST             := 0x0288
Static WM_IME_SELECT              := 0x0285
Static WM_IME_SETCONTEXT          := 0x0281
Static WM_IME_STARTCOMPOSITION    := 0x010D
Static WM_INITDIALOG              := 0x0110
Static WM_INITMENU                := 0x0116
Static WM_INITMENUPOPUP           := 0x0117
Static WM_INPUT                   := 0x00FF
Static WM_INPUT_DEVICE_CHANGE     := 0x00FE
Static WM_INPUTLANGCHANGE         := 0x0051
Static WM_INPUTLANGCHANGEREQUEST  := 0x0050
Static WM_KEYDOWN                 := 0x0100
Static WM_KEYLAST                 := 0x0109
Static WM_KEYUP                   := 0x0101
Static WM_KILLFOCUS               := 0x0008
Static WM_LBUTTONDBLCLK           := 0x0203
Static WM_LBUTTONDOWN             := 0x0201
Static WM_LBUTTONUP               := 0x0202
Static WM_MBUTTONDBLCLK           := 0x0209
Static WM_MBUTTONDOWN             := 0x0207
Static WM_MBUTTONUP               := 0x0208
Static WM_MDIACTIVATE             := 0x0222
Static WM_MDICASCADE              := 0x0227
Static WM_MDICREATE               := 0x0220
Static WM_MDIDESTROY              := 0x0221
Static WM_MDIGETACTIVE            := 0x0229
Static WM_MDIICONARRANGE          := 0x0228
Static WM_MDIMAXIMIZE             := 0x0225
Static WM_MDINEXT                 := 0x0224
Static WM_MDIREFRESHMENU          := 0x0234
Static WM_MDIRESTORE              := 0x0223
Static WM_MDISETMENU              := 0x0230
Static WM_MDITILE                 := 0x0226
Static WM_MEASUREITEM             := 0x002C
Static WM_MENUCHAR                := 0x0120
Static WM_MENUCOMMAND             := 0x0126
Static WM_MENUDRAG                := 0x0123
Static WM_MENUGETOBJECT           := 0x0124
Static WM_MENURBUTTONUP           := 0x0122
Static WM_MENUSELECT              := 0x011F
Static WM_MOUSEACTIVATE           := 0x0021
Static WM_MOUSEHOVER              := 0x02A1
Static WM_MOUSEHWHEEL             := 0x020E ; >= Vista
Static WM_MOUSELEAVE              := 0x02A3
Static WM_MOUSEMOVE               := 0x0200
Static WM_MOUSEWHEEL              := 0x020A
Static WM_MOVE                    := 0x0003
Static WM_MOVING                  := 0x0216
Static WM_NCACTIVATE              := 0x0086
Static WM_NCCALCSIZE              := 0x0083
Static WM_NCCREATE                := 0x0081
Static WM_NCDESTROY               := 0x0082
Static WM_NCHITTEST               := 0x0084
Static WM_NCLBUTTONDBLCLK         := 0x00A3
Static WM_NCLBUTTONDOWN           := 0x00A1
Static WM_NCLBUTTONUP             := 0x00A2
Static WM_NCMBUTTONDBLCLK         := 0x00A9
Static WM_NCMBUTTONDOWN           := 0x00A7
Static WM_NCMBUTTONUP             := 0x00A8
Static WM_NCMOUSEHOVER            := 0x02A0
Static WM_NCMOUSELEAVE            := 0x02A2
Static WM_NCMOUSEMOVE             := 0x00A0
Static WM_NCPAINT                 := 0x0085
Static WM_NCRBUTTONDBLCLK         := 0x00A6
Static WM_NCRBUTTONDOWN           := 0x00A4
Static WM_NCRBUTTONUP             := 0x00A5
Static WM_NCXBUTTONDBLCLK         := 0x00AD
Static WM_NCXBUTTONDOWN           := 0x00AB
Static WM_NCXBUTTONUP             := 0x00AC
Static WM_NEXTDLGCTL              := 0x0028
Static WM_NEXTMENU                := 0x0213
Static WM_NOTIFY                  := 0x004E
Static WM_NOTIFYFORMAT            := 0x0055
Static WM_NULL                    := 0x0000
Static WM_PAINT                   := 0x000F
Static WM_PAINTCLIPBOARD          := 0x0309
Static WM_PAINTICON               := 0x0026
Static WM_PALETTECHANGED          := 0x0311
Static WM_PALETTEISCHANGING       := 0x0310
Static WM_PARENTNOTIFY            := 0x0210
Static WM_PASTE                   := 0x0302
Static WM_PENWINFIRST             := 0x0380
Static WM_PENWINLAST              := 0x038F
Static WM_POWER                   := 0x0048
Static WM_POWERBROADCAST          := 0x0218
Static WM_PRINT                   := 0x0317
Static WM_PRINTCLIENT             := 0x0318
Static WM_QUERYDRAGICON           := 0x0037
Static WM_QUERYENDSESSION         := 0x0011
Static WM_QUERYNEWPALETTE         := 0x030F
Static WM_QUERYOPEN               := 0x0013
Static WM_QUERYUISTATE            := 0x0129
Static WM_QUEUESYNC               := 0x0023
Static WM_QUIT                    := 0x0012
Static WM_RBUTTONDBLCLK           := 0x0206
Static WM_RBUTTONDOWN             := 0x0204
Static WM_RBUTTONUP               := 0x0205
Static WM_RENDERALLFORMATS        := 0x0306
Static WM_RENDERFORMAT            := 0x0305
Static WM_SETCURSOR               := 0x0020
Static WM_SETFOCUS                := 0x0007
Static WM_SETFONT                 := 0x0030
Static WM_SETHOTKEY               := 0x0032
Static WM_SETICON                 := 0x0080
Static WM_SETREDRAW               := 0x000B
Static WM_SETTEXT                 := 0x000C
Static WM_SETTINGCHANGE           := 0x001A ; WM_WININICHANGE
Static WM_SHOWWINDOW              := 0x0018
Static WM_SIZE                    := 0x0005
Static WM_SIZECLIPBOARD           := 0x030B
Static WM_SIZING                  := 0x0214
Static WM_SPOOLERSTATUS           := 0x002A
Static WM_STYLECHANGED            := 0x007D
Static WM_STYLECHANGING           := 0x007C
Static WM_SYNCPAINT               := 0x0088
Static WM_SYSCHAR                 := 0x0106
Static WM_SYSCOLORCHANGE          := 0x0015
Static WM_SYSCOMMAND              := 0x0112
Static WM_SYSDEADCHAR             := 0x0107
Static WM_SYSKEYDOWN              := 0x0104
Static WM_SYSKEYUP                := 0x0105
Static WM_TABLET_FIRST            := 0x02C0
Static WM_TABLET_LAST             := 0x02DF
Static WM_TCARD                   := 0x0052
Static WM_THEMECHANGED            := 0x031A
Static WM_TIMECHANGE              := 0x001E
Static WM_TIMER                   := 0x0113
Static WM_TOUCH                   := 0x0240 ; >= Win 7
Static WM_UNDO                    := 0x0304
Static WM_UNICHAR                 := 0x0109
Static WM_UNINITMENUPOPUP         := 0x0125
Static WM_UPDATEUISTATE           := 0x0128
Static WM_USER                    := 0x0400
Static WM_USERCHANGED             := 0x0054
Static WM_VKEYTOITEM              := 0x002E
Static WM_VSCROLL                 := 0x0115
Static WM_VSCROLLCLIPBOARD        := 0x030A
Static WM_WINDOWPOSCHANGED        := 0x0047
Static WM_WINDOWPOSCHANGING       := 0x0046
Static WM_WININICHANGE            := 0x001A
Static WM_WTSSESSION_CHANGE       := 0x02B1
Static WM_XBUTTONDBLCLK           := 0x020D
Static WM_XBUTTONDOWN             := 0x020B
Static WM_XBUTTONUP               := 0x020C
; Styles ===============================================================================================================
Static WS_BORDER                  := 0x00800000
Static WS_CAPTION                 := 0x00C00000 ; WS_BORDER|WS_DLGFRAME
Static WS_CHILD                   := 0x40000000
Static WS_CLIPCHILDREN            := 0x02000000
Static WS_CLIPSIBLINGS            := 0x04000000
Static WS_DISABLED                := 0x08000000
Static WS_DLGFRAME                := 0x00400000
Static WS_GROUP                   := 0x00020000
Static WS_HSCROLL                 := 0x00100000
Static WS_ICONIC                  := 0x20000000 ; WS_MINIMIZE
Static WS_MAXIMIZE                := 0x01000000
Static WS_MAXIMIZEBOX             := 0x00010000
Static WS_MINIMIZE                := 0x20000000
Static WS_MINIMIZEBOX             := 0x00020000
Static WS_OVERLAPPED              := 0x00000000
Static WS_POPUP                   := 0x80000000
Static WS_SIZEBOX                 := 0x00040000 ; WS_THICKFRAME
Static WS_SYSMENU                 := 0x00080000
Static WS_TABSTOP                 := 0x00010000
Static WS_THICKFRAME              := 0x00040000
Static WS_TILED                   := 0x00000000 ; WS_OVERLAPPED
Static WS_VISIBLE                 := 0x10000000
Static WS_VSCROLL                 := 0x00200000
; Common Window Styles
Static WS_CHILDWINDOW             := 0x40000000 ; WS_CHILD
Static WS_OVERLAPPEDWINDOW        := 0x00CF0000 ; WS_OVERLAPPED|CAPTION|SYSMENU|THICKFRAME|MINIMIZEBOX|MAXIMIZEBOX
Static WS_POPUPWINDOW             := 0x80880000 ; WS_POPUP|BORDER|SYSMENU
Static WS_TILEDWINDOW             := 0x00CF0000 ; WS_OVERLAPPEDWINDOW
; ExStyles =============================================================================================================
Static WS_EX_ACCEPTFILES          := 0x00000010
Static WS_EX_APPWINDOW            := 0x00040000
Static WS_EX_CLIENTEDGE           := 0x00000200
Static WS_EX_COMPOSITED           := 0x02000000
Static WS_EX_CONTEXTHELP          := 0x00000400
Static WS_EX_CONTROLPARENT        := 0x00010000
Static WS_EX_DLGMODALFRAME        := 0x00000001
Static WS_EX_LAYERED              := 0x00080000
Static WS_EX_LAYOUTRTL            := 0x00400000  ; Right to left mirroring
Static WS_EX_LEFT                 := 0x00000000
Static WS_EX_LEFTSCROLLBAR        := 0x00004000
Static WS_EX_LTRREADING           := 0x00000000
Static WS_EX_MDICHILD             := 0x00000040
Static WS_EX_NOACTIVATE           := 0x08000000
Static WS_EX_NOINHERITLAYOUT      := 0x00100000  ; Disable inheritence of mirroring by children
Static WS_EX_NOPARENTNOTIFY       := 0x00000004
Static WS_EX_RIGHT                := 0x00001000
Static WS_EX_RIGHTSCROLLBAR       := 0x00000000
Static WS_EX_RTLREADING           := 0x00002000
Static WS_EX_STATICEDGE           := 0x00020000
Static WS_EX_TOOLWINDOW           := 0x00000080
Static WS_EX_TOPMOST              := 0x00000008
Static WS_EX_TRANSPARENT          := 0x00000020
Static WS_EX_WINDOWEDGE           := 0x00000100
Static WS_EX_OVERLAPPEDWINDOW     := 0x00000300 ; WS_EX_WINDOWEDGE|EX_CLIENTEDGE
Static WS_EX_PALETTEWINDOW        := 0x00000188 ; WS_EX_WINDOWEDGE|EX_TOOLWINDOW|EX_TOPMOST
; ======================================================================================================================

; ======================================================================================================================
; Function:         Constants for Trackbar controls (Slider)
; AHK version:      1.1.05 +
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; CCM_FIRST              := 0x2000
; TRBN_FIRST             := -1501    ; trackbar (>= Vista)
; WM_USER                := 0x0400
; Class ================================================================================================================
Static WC_TRACKBAR             := "msctls_trackbar32"
; Messages =============================================================================================================
Static TBM_CLEARSEL            := 0x0413   ; (WM_USER + 19)
Static TBM_CLEARTICS           := 0x0409   ; (WM_USER + 9)
Static TBM_GETBUDDY            := 0x0421   ; (WM_USER + 33)    ; wparam = BOOL fLeft (or right)
Static TBM_GETCHANNELRECT      := 0x041A   ; (WM_USER + 26)
Static TBM_GETLINESIZE         := 0x0418   ; (WM_USER + 24)
Static TBM_GETNUMTICS          := 0x0410   ; (WM_USER + 16)
Static TBM_GETPAGESIZE         := 0x0416   ; (WM_USER + 22)
Static TBM_GETPOS              := 0x0400   ;( WM_USER)
Static TBM_GETPTICS            := 0x040E   ; (WM_USER + 14)
Static TBM_GETRANGEMAX         := 0x0402   ; (WM_USER + 2)
Static TBM_GETRANGEMIN         := 0x0401   ; (WM_USER + 1)
Static TBM_GETSELEND           := 0x0412   ; (WM_USER + 18)
Static TBM_GETSELSTART         := 0x0411   ; (WM_USER + 17)
Static TBM_GETTHUMBLENGTH      := 0x041C   ; (WM_USER + 28)
Static TBM_GETTHUMBRECT        := 0x0419   ; (WM_USER + 25)
Static TBM_GETTIC              := 0x0403   ; (WM_USER + 3)
Static TBM_GETTICPOS           := 0x040F   ; (WM_USER + 15)
Static TBM_GETTOOLTIPS         := 0x041E   ; (WM_USER + 30)
Static TBM_GETUNICODEFORMAT    := 0x2006   ; (CCM_FIRST + 6)   ; CCM_GETUNICODEFORMAT
Static TBM_SETBUDDY            := 0x0420   ; (WM_USER + 32)    ; wparam = BOOL fLeft (or right)
Static TBM_SETLINESIZE         := 0x0417   ; (WM_USER + 23)
Static TBM_SETPAGESIZE         := 0x0415   ; (WM_USER + 21)
Static TBM_SETPOS              := 0x0405   ; (WM_USER + 5)
Static TBM_SETPOSNOTIFY        := 0x0422   ; (WM_USER + 34)
Static TBM_SETRANGE            := 0x0406   ; (WM_USER + 6)
Static TBM_SETRANGEMAX         := 0x0408   ; (WM_USER + 8)
Static TBM_SETRANGEMIN         := 0x0407   ; (WM_USER + 7)
Static TBM_SETSEL              := 0x040A   ; (WM_USER + 10)
Static TBM_SETSELEND           := 0x040C   ; (WM_USER + 12)
Static TBM_SETSELSTART         := 0x040B   ; (WM_USER + 11)
Static TBM_SETTHUMBLENGTH      := 0x041B   ; (WM_USER + 27)
Static TBM_SETTIC              := 0x0404   ; (WM_USER + 4)
Static TBM_SETTICFREQ          := 0x0414   ; (WM_USER + 20)
Static TBM_SETTIPSIDE          := 0x041F   ; (WM_USER + 31)
Static TBM_SETTOOLTIPS         := 0x041D   ; (WM_USER + 29)
Static TBM_SETUNICODEFORMAT    := 0x2005   ; (CCM_FIRST + 5)   ; CCM_SETUNICODEFORMAT
; Notifications ========================================================================================================
Static TRBN_THUMBPOSCHANGING   := (TRBN_FIRST-1)    ; >= Vista
; Styles ===============================================================================================================
Static TBS_AUTOTICKS           := 0x0001
Static TBS_BOTH                := 0x0008
Static TBS_BOTTOM              := 0x0000
Static TBS_DOWNISLEFT          := 0x0400  ; Down=Left and Up=Right (default is Down=Right and Up=Left)
Static TBS_ENABLESELRANGE      := 0x0020
Static TBS_FIXEDLENGTH         := 0x0040
Static TBS_HORZ                := 0x0000
Static TBS_LEFT                := 0x0004
Static TBS_NOTHUMB             := 0x0080
Static TBS_NOTICKS             := 0x0010
Static TBS_NOTIFYBEFOREMOVE    := 0x0800  ; >= Vista : Trackbar should notify parent before repositioning the slider due to
;                                    user action (enables snapping)
Static TBS_REVERSED            := 0x0200  ; Accessibility hint: the smaller number (usually the min value) means "high" and
;                                    the larger number (usually the max value) means "low"
Static TBS_RIGHT               := 0x0000
Static TBS_TOOLTIPS            := 0x0100
Static TBS_TOP                 := 0x0004
Static TBS_TRANSPARENTBKGND    := 0x1000  ; >= Vista : Background is painted by the parent via WM_PRINTCLIENT
Static TBS_VERT                := 0x0002
; Others ===============================================================================================================
; Custom draw item specs
Static TBCD_CHANNEL            := 0x0003
Static TBCD_THUMB              := 0x0002
Static TBCD_TICS               := 0x0001
; Interaction notification codes
Static TB_BOTTOM               := 7
Static TB_ENDTRACK             := 8
Static TB_LINEDOWN             := 1
Static TB_LINEUP               := 0
Static TB_PAGEDOWN             := 3
Static TB_PAGEUP               := 2
Static TB_THUMBPOSITION        := 4
Static TB_THUMBTRACK           := 5
Static TB_TOP                  := 6
; ======================================================================================================================
}

constant := %constant%
return %constant%

}