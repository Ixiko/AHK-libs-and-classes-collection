; ======================================================================================================================
; Function:         Constants for Toolbar controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-05-05/just me
; Remarks:          Although not a built-in AHK GUI control it might be useful anyway.
; ======================================================================================================================
; TBN_FIRST = -700
; WM_USER   = 0x0400
; ======================================================================================================================
; Class ================================================================================================================
Global WC_TOOLBAR               := "ToolbarWindow32"
; Messages =============================================================================================================
Global TB_ADDBITMAP             := 0x0413 ; (WM_USER + 19)
Global TB_ADDBUTTONSA           := 0x0414 ; (WM_USER + 20)
Global TB_ADDBUTTONSW           := 0x0444 ; (WM_USER + 68)
Global TB_ADDSTRINGA            := 0x041C ; (WM_USER + 28)
Global TB_ADDSTRINGW            := 0x044D ; (WM_USER + 77)
Global TB_AUTOSIZE              := 0x0421 ; (WM_USER + 33)
Global TB_BUTTONCOUNT           := 0x0418 ; (WM_USER + 24)
Global TB_BUTTONSTRUCTSIZE      := 0x041E ; (WM_USER + 30)
Global TB_CHANGEBITMAP          := 0x042B ; (WM_USER + 43)
Global TB_CHECKBUTTON           := 0x0402 ; (WM_USER + 2)
Global TB_COMMANDTOINDEX        := 0x0419 ; (WM_USER + 25)
Global TB_CUSTOMIZE             := 0x041B ; (WM_USER + 27)
Global TB_DELETEBUTTON          := 0x0416 ; (WM_USER + 22)
Global TB_ENABLEBUTTON          := 0x0401 ; (WM_USER + 1)
Global TB_GETANCHORHIGHLIGHT    := 0x044A ; (WM_USER + 74)
Global TB_GETBITMAP             := 0x042C ; (WM_USER + 44)
Global TB_GETBUTTON             := 0x0417 ; (WM_USER + 23)
Global TB_GETBUTTONINFOA        := 0x0441 ; (WM_USER + 65)
Global TB_GETBUTTONINFOW        := 0x043F ; (WM_USER + 63)
Global TB_GETBUTTONSIZE         := 0x043A ; (WM_USER + 58)
Global TB_GETBUTTONTEXTA        := 0x042D ; (WM_USER + 45)
Global TB_GETBUTTONTEXTW        := 0x044B ; (WM_USER + 75)
Global TB_GETCOLORSCHEME        := 0x2003 ; CCM_GETCOLORSCHEME   // fills in COLORSCHEME pointed to by lParam
Global TB_GETDISABLEDIMAGELIST  := 0x0437 ; (WM_USER + 55)
Global TB_GETEXTENDEDSTYLE      := 0x0455 ; (WM_USER + 85)       // For TBSTYLE_EX_*
Global TB_GETHOTIMAGELIST       := 0x0435 ; (WM_USER + 53)
Global TB_GETHOTITEM            := 0x0447 ; (WM_USER + 71)
Global TB_GETIDEALSIZE          := 0x0463 ; (WM_USER + 99)       // wParam == fHeight, lParam = psize
Global TB_GETIMAGELIST          := 0x0431 ; (WM_USER + 49)
Global TB_GETIMAGELISTCOUNT     := 0x0462 ; (WM_USER + 98)
Global TB_GETINSERTMARK         := 0x044F ; (WM_USER + 79)       // lParam == LPTBINSERTMARK
Global TB_GETINSERTMARKCOLOR    := 0x0459 ; (WM_USER + 89)
Global TB_GETITEMDROPDOWNRECT   := 0x0467 ; (WM_USER + 103)      >= Vista // Rect of item's drop down button
Global TB_GETITEMRECT           := 0x041D ; (WM_USER + 29)
Global TB_GETMAXSIZE            := 0x0453 ; (WM_USER + 83)       // lParam == LPSIZE
Global TB_GETMETRICS            := 0x0465 ; (WM_USER + 101)
Global TB_GETOBJECT             := 0x043E ; (WM_USER + 62)       // wParam == IID, lParam void **ppv
Global TB_GETPADDING            := 0x0456 ; (WM_USER + 86)
Global TB_GETPRESSEDIMAGELIST   := 0x0469 ; (WM_USER + 105)      >= Vista
Global TB_GETRECT               := 0x0433 ; (WM_USER + 51)       // wParam is the Cmd instead of index
Global TB_GETROWS               := 0x0428 ; (WM_USER + 40)
Global TB_GETSTATE              := 0x0412 ; (WM_USER + 18)
Global TB_GETSTRINGA            := 0x045C ; (WM_USER + 92)
Global TB_GETSTRINGW            := 0x045B ; (WM_USER + 91)
Global TB_GETSTYLE              := 0x0439 ; (WM_USER + 57)
Global TB_GETTEXTROWS           := 0x043D ; (WM_USER + 61)
Global TB_GETTOOLTIPS           := 0x0423 ; (WM_USER + 35)
Global TB_GETUNICODEFORMAT      := 0x2005 ; CCM_GETUNICODEFORMAT
Global TB_HIDEBUTTON            := 0x0404 ; (WM_USER + 4)
Global TB_HITTEST               := 0x0445 ; (WM_USER + 69)
Global TB_INDETERMINATE         := 0x0405 ; (WM_USER + 5)
Global TB_INSERTBUTTONA         := 0x0415 ; (WM_USER + 21)
Global TB_INSERTBUTTONW         := 0x0443 ; (WM_USER + 67)
Global TB_INSERTMARKHITTEST     := 0x0451 ; (WM_USER + 81)       // wParam == LPPOINT lParam == LPTBINSERTMARK
Global TB_ISBUTTONCHECKED       := 0x040A ; (WM_USER + 10)
Global TB_ISBUTTONENABLED       := 0x0409 ; (WM_USER + 9)
Global TB_ISBUTTONHIDDEN        := 0x040C ; (WM_USER + 12)
Global TB_ISBUTTONHIGHLIGHTED   := 0x040E ; (WM_USER + 14)
Global TB_ISBUTTONINDETERMINATE := 0x040D ; (WM_USER + 13)
Global TB_ISBUTTONPRESSED       := 0x040B ; (WM_USER + 11)
Global TB_LOADIMAGES            := 0x0432 ; (WM_USER + 50)
Global TB_MAPACCELERATORA       := 0x044E ; (WM_USER + 78)       // wParam == ch, lParam int * pidBtn
Global TB_MAPACCELERATORW       := 0x045A ; (WM_USER + 90)       // wParam == ch, lParam int * pidBtn
Global TB_MARKBUTTON            := 0x0406 ; (WM_USER + 6)
Global TB_MOVEBUTTON            := 0x0452 ; (WM_USER + 82)
Global TB_PRESSBUTTON           := 0x0403 ; (WM_USER + 3)
Global TB_REPLACEBITMAP         := 0x042E ; (WM_USER + 46)
Global TB_SAVERESTOREA          := 0x041A ; (WM_USER + 26)
Global TB_SAVERESTOREW          := 0x044C ; (WM_USER + 76)
Global TB_SETANCHORHIGHLIGHT    := 0x0449 ; (WM_USER + 73)       // wParam == TRUE/FALSE
Global TB_SETBITMAPSIZE         := 0x0420 ; (WM_USER + 32)
Global TB_SETBUTTONINFOA        := 0x0442 ; (WM_USER + 66)
Global TB_SETBUTTONINFOW        := 0x0440 ; (WM_USER + 64)
Global TB_SETBUTTONSIZE         := 0x041F ; (WM_USER + 31)
Global TB_SETBUTTONWIDTH        := 0x043B ; (WM_USER + 59)
Global TB_SETCMDID              := 0x042A ; (WM_USER + 42)
Global TB_SETCOLORSCHEME        := 0x2002 ; CCM_SETCOLORSCHEME   // lParam is color scheme
Global TB_SETDISABLEDIMAGELIST  := 0x0436 ; (WM_USER + 54)
Global TB_SETDRAWTEXTFLAGS      := 0x0446 ; (WM_USER + 70)       // wParam == mask lParam == bit values
Global TB_SETEXTENDEDSTYLE      := 0x0454 ; (WM_USER + 84)       // For TBSTYLE_EX_*
Global TB_SETHOTIMAGELIST       := 0x0434 ; (WM_USER + 52)
Global TB_SETHOTITEM            := 0x0448 ; (WM_USER + 72)       // wParam == iHotItem
Global TB_SETHOTITEM2           := 0x045E ; (WM_USER + 94)       // wParam == iHotItem,  lParam = dwFlags
Global TB_SETIMAGELIST          := 0x0430 ; (WM_USER + 48)
Global TB_SETINDENT             := 0x042F ; (WM_USER + 47)
Global TB_SETINSERTMARK         := 0x0450 ; (WM_USER + 80)       // lParam == LPTBINSERTMARK
Global TB_SETINSERTMARKCOLOR    := 0x0458 ; (WM_USER + 88)
Global TB_SETLISTGAP            := 0x0460 ; (WM_USER + 96)
Global TB_SETMAXTEXTROWS        := 0x043C ; (WM_USER + 60)
Global TB_SETMETRICS            := 0x0466 ; (WM_USER + 102)
Global TB_SETPADDING            := 0x0457 ; (WM_USER + 87)
Global TB_SETPARENT             := 0x0425 ; (WM_USER + 37)
Global TB_SETPRESSEDIMAGELIST   := 0x0468 ; (WM_USER + 104)      >= Vista
Global TB_SETROWS               := 0x0427 ; (WM_USER + 39)
Global TB_SETSTATE              := 0x0411 ; (WM_USER + 17)
Global TB_SETSTYLE              := 0x0438 ; (WM_USER + 56)
Global TB_SETTOOLTIPS           := 0x0424 ; (WM_USER + 36)
Global TB_SETUNICODEFORMAT      := 0x2004 ; CCM_SETUNICODEFORMAT
Global TB_SETWINDOWTHEME        := 0x200B ; CCM_SETWINDOWTHEME
Global TB_TRANSLATEACCELERATOR  := 0x200A ; ??? -> CCM_TRANSLATEACCELERATOR (not defined !!!)
; Notifications ========================================================================================================
Global TBN_BEGINADJUST     := -703 ; (TBN_FIRST - 3)
Global TBN_BEGINDRAG       := -701 ; (TBN_FIRST - 1)
Global TBN_CUSTHELP        := -709 ; (TBN_FIRST - 9)
Global TBN_DELETINGBUTTON  := -715 ; (TBN_FIRST - 15) // uses TBNOTIFY
Global TBN_DRAGOUT         := -714 ; (TBN_FIRST - 14) // this is sent when the user clicks down on a button then drags off the button
Global TBN_DRAGOVER        := -727 ; (TBN_FIRST - 27)
Global TBN_DROPDOWN        := -710 ; (TBN_FIRST - 10)
Global TBN_DUPACCELERATOR  := -725 ; (TBN_FIRST - 25)
Global TBN_ENDADJUST       := -704 ; (TBN_FIRST - 4)
Global TBN_ENDDRAG         := -702 ; (TBN_FIRST - 2)
Global TBN_GETBUTTONINFOA  := -700 ; (TBN_FIRST - 0)
Global TBN_GETBUTTONINFOW  := -720 ; (TBN_FIRST - 20)
Global TBN_GETDISPINFOA    := -716 ; (TBN_FIRST - 16) // This is sent when the toolbar needs some display information
Global TBN_GETDISPINFOW    := -717 ; (TBN_FIRST - 17) // This is sent when the toolbar needs some display information
Global TBN_GETINFOTIPA     := -718 ; (TBN_FIRST - 18)
Global TBN_GETINFOTIPW     := -719 ; (TBN_FIRST - 19)
Global TBN_GETOBJECT       := -712 ; (TBN_FIRST - 12)
Global TBN_HOTITEMCHANGE   := -713 ; (TBN_FIRST - 13)
Global TBN_INITCUSTOMIZE   := -723 ; (TBN_FIRST - 23)
Global TBN_MAPACCELERATOR  := -728 ; (TBN_FIRST - 28)
Global TBN_QUERYDELETE     := -707 ; (TBN_FIRST - 7)
Global TBN_QUERYINSERT     := -706 ; (TBN_FIRST - 6)
Global TBN_RESET           := -705 ; (TBN_FIRST - 5)
Global TBN_RESTORE         := -721 ; (TBN_FIRST - 21)
Global TBN_SAVE            := -722 ; (TBN_FIRST - 22)
Global TBN_TOOLBARCHANGE   := -708 ; (TBN_FIRST - 8)
Global TBN_WRAPACCELERATOR := -726 ; (TBN_FIRST - 26)
Global TBN_WRAPHOTITEM     := -724 ; (TBN_FIRST - 24)
; Styles ===============================================================================================================
Global TBSTYLE_ALTDRAG      := 0x0400
Global TBSTYLE_CUSTOMERASE  := 0x2000
Global TBSTYLE_FLAT         := 0x0800
Global TBSTYLE_LIST         := 0x1000
Global TBSTYLE_REGISTERDROP := 0x4000
Global TBSTYLE_TOOLTIPS     := 0x0100
Global TBSTYLE_TRANSPARENT  := 0x8000
Global TBSTYLE_WRAPABLE     := 0x0200
; ExStyles =============================================================================================================
Global TBSTYLE_EX_DOUBLEBUFFER       := 0x80 ; // Double Buffer the toolbar
Global TBSTYLE_EX_DRAWDDARROWS       := 0x01
Global TBSTYLE_EX_HIDECLIPPEDBUTTONS := 0x10 ; // don't show partially obscured buttons
Global TBSTYLE_EX_MIXEDBUTTONS       := 0x08
Global TBSTYLE_EX_MULTICOLUMN        := 0x02 ; // Intended for internal use; not recommended for use in applications.
Global TBSTYLE_EX_VERTICAL           := 0x04 ; // Intended for internal use; not recommended for use in applications.
; Button styles ========================================================================================================
Global BTNS_BUTTON        := 0x00 ; TBSTYLE_BUTTON
Global BTNS_SEP           := 0x01 ; TBSTYLE_SEP
Global BTNS_CHECK         := 0x02 ; TBSTYLE_CHECK
Global BTNS_GROUP         := 0x04 ; TBSTYLE_GROUP
Global BTNS_CHECKGROUP    := 0x06 ; TBSTYLE_CHECKGROUP  // (TBSTYLE_GROUP | TBSTYLE_CHECK)
Global BTNS_DROPDOWN      := 0x08 ; TBSTYLE_DROPDOWN
Global BTNS_AUTOSIZE      := 0x10 ; TBSTYLE_AUTOSIZE    // automatically calculate the cx of the button
Global BTNS_NOPREFIX      := 0x20 ; TBSTYLE_NOPREFIX    // this button should not have accel prefix
Global BTNS_SHOWTEXT      := 0x40 ; // ignored unless TBSTYLE_EX_MIXEDBUTTONS is set
Global BTNS_WHOLEDROPDOWN := 0x80 ; // draw drop-down arrow, but without split arrow section
; Button states ========================================================================================================
Global TBSTATE_CHECKED       := 0x01
Global TBSTATE_ELLIPSES      := 0x40
Global TBSTATE_ENABLED       := 0x04
Global TBSTATE_HIDDEN        := 0x08
Global TBSTATE_INDETERMINATE := 0x10
Global TBSTATE_MARKED        := 0x80
Global TBSTATE_PRESSED       := 0x02
Global TBSTATE_WRAP          := 0x20
; Button standard image index values ===================================================================================
; HIST
Global IDB_HIST_SMALL_COLOR := 8
Global IDB_HIST_LARGE_COLOR := 9
Global IDB_HIST_NORMAL      := 12 ; >= Vista
Global IDB_HIST_HOT         := 13 ; >= Vista
Global IDB_HIST_DISABLED    := 14 ; >= Vista
Global IDB_HIST_PRESSED     := 15 ; >= Vista
Global HIST_ADDTOFAVORITES := 3
Global HIST_BACK           := 0
Global HIST_FAVORITES      := 2
Global HIST_FORWARD        := 1
Global HIST_VIEWTREE       := 4
; STD
Global IDB_STD_SMALL_COLOR := 0
Global IDB_STD_LARGE_COLOR := 1
Global STD_COPY            := 1
Global STD_CUT             := 0
Global STD_DELETE          := 5
Global STD_FILENEW         := 6
Global STD_FILEOPEN        := 7
Global STD_FILESAVE        := 8
Global STD_FIND            := 12
Global STD_HELP            := 11
Global STD_PASTE           := 2
Global STD_PRINT           := 14
Global STD_PRINTPRE        := 9
Global STD_PROPERTIES      := 10
Global STD_REDOW           := 4
Global STD_REPLACE         := 13
Global STD_UNDO            := 3
; VIEW
Global IDB_VIEW_SMALL_COLOR := 4
Global IDB_VIEW_LARGE_COLOR := 5
Global VIEW_DETAILS         := 3
Global VIEW_LARGEICONS      := 0
Global VIEW_LIST            := 2
Global VIEW_NETCONNECT      := 9
Global VIEW_NETDISCONNECT   := 10
Global VIEW_NEWFOLDER       := 11
Global VIEW_PARENTFOLDER    := 8
Global VIEW_SMALLICONS      := 1
Global VIEW_SORTDATE        := 6
Global VIEW_SORTNAME        := 4
Global VIEW_SORTSIZE        := 5
Global VIEW_SORTTYPE        := 7
Global VIEW_VIEWMENU        := 12
; Others ===============================================================================================================
; Toolbar custom draw return flags
Global TBCDRF_BLENDICON      := 0x200000 ; // Use ILD_BLEND50 on the icon image
Global TBCDRF_HILITEHOTTRACK := 0x020000 ; // Use color of the button bk when hottracked
Global TBCDRF_NOBACKGROUND   := 0x400000 ; // Use ILD_BLEND50 on the icon image
Global TBCDRF_NOEDGES        := 0x010000 ; // Don't draw button edges
Global TBCDRF_NOETCHEDEFFECT := 0x100000 ; // Don't draw etched effect for disabled items
Global TBCDRF_NOMARK         := 0x080000 ; // Don't draw default highlight of image/text for TBSTATE_MARKED
Global TBCDRF_NOOFFSET       := 0x040000 ; // Don't offset button if pressed
Global TBCDRF_USECDCOLORS    := 0x800000 ; >= Vista // Use CustomDrawColors to RenderText regardless of VisualStyle
; TB_GETINSERTMARK
Global TBIMHT_AFTER      := 0x01 ; // TRUE = insert After iButton, otherwise before
Global TBIMHT_BACKGROUND := 0x02 ; // TRUE iff missed buttons completely
; TB_GETBITMAPFLAGS
Global TBBF_LARGE   := 0x00000001
Global TBIF_BYINDEX := 0x80000000 ; // this specifies that the wparam in Get/SetButtonInfo is an index, not id
Global TBIF_COMMAND := 0x00000020
Global TBIF_IMAGE   := 0x00000001
Global TBIF_LPARAM  := 0x00000010
Global TBIF_SIZE    := 0x00000040
Global TBIF_STATE   := 0x00000004
Global TBIF_STYLE   := 0x00000008
Global TBIF_TEXT    := 0x00000002
; TB_GETMETRICS
Global TBMF_BARPAD        := 0x02
Global TBMF_BUTTONSPACING := 0x04
Global TBMF_PAD           := 0x01
; Hot item change flags
Global HICF_ACCELERATOR    := 0x0004 ; // Triggered by accelerator
Global HICF_ARROWKEYS      := 0x0002 ; // Triggered by arrow keys
Global HICF_DUPACCEL       := 0x0008 ; // This accelerator is not unique
Global HICF_ENTERING       := 0x0010 ; // idOld is invalid
Global HICF_LEAVING        := 0x0020 ; // idNew is invalid
Global HICF_LMOUSE         := 0x0080 ; // left mouse button selected
Global HICF_MOUSE          := 0x0001 ; // Triggered by mouse
Global HICF_OTHER          := 0x0000
Global HICF_RESELECT       := 0x0040 ; // hot item reselected
Global HICF_TOGGLEDROPDOWN := 0x0100 ; // Toggle button's dropdown state
; TBN_INITCUSTOMIZE
Global TBNRF_ENDCUSTOMIZE := 0x02
Global TBNRF_HIDEHELP     := 0x01
; TBN_GET/SETDISPINFO
Global TBNF_DI_SETITEM := 0x10000000
Global TBNF_IMAGE      := 0x00000001
Global TBNF_TEXT       := 0x00000002
; Return codes for TBN_DROPDOWN
Global TBDDRET_DEFAULT      := 0
Global TBDDRET_NODEFAULT    := 1
Global TBDDRET_TREATPRESSED := 2 ; // Treat as a standard press button
; ======================================================================================================================