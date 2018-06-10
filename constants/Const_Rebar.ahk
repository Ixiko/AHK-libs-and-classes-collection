; ======================================================================================================================
; Function:          Constants for Rebar controls.
; AHK version:       1.1.05+
; Language:          English
; Version:           1.0.00.00/2012-05-23/just me
; MSDN:              http://msdn.microsoft.com/en-us/library/bb774375(VS.85).aspx
; ======================================================================================================================
; RBN_FIRST = -831
; WM_USER   = 0x0400
; Class ================================================================================================================
Global WC_REBAR               := "ReBarWindow32"
; Messages =============================================================================================================
Global RB_INSERTBANDA         := 0x0401 ; (WM_USER +  1)
Global RB_DELETEBAND          := 0x0402 ; (WM_USER +  2)
Global RB_GETBARINFO          := 0x0403 ; (WM_USER +  3)
Global RB_SETBARINFO          := 0x0404 ; (WM_USER +  4)
Global RB_GETBANDINFO         := 0x0405 ; (WM_USER +  5)
Global RB_SETBANDINFOA        := 0x0406 ; (WM_USER +  6)
Global RB_SETPARENT           := 0x0407 ; (WM_USER +  7)
Global RB_HITTEST             := 0x0408 ; (WM_USER +  8)
Global RB_GETRECT             := 0x0409 ; (WM_USER +  9)
Global RB_INSERTBANDW         := 0x040A ; (WM_USER +  10)
Global RB_SETBANDINFOW        := 0x040B ; (WM_USER +  11)
Global RB_GETBANDCOUNT        := 0x040C ; (WM_USER +  12)
Global RB_GETROWCOUNT         := 0x040D ; (WM_USER +  13)
Global RB_GETROWHEIGHT        := 0x040E ; (WM_USER +  14)
Global RB_IDTOINDEX           := 0x0410 ; (WM_USER +  16) // wParam == id
Global RB_GETTOOLTIPS         := 0x0411 ; (WM_USER +  17)
Global RB_SETTOOLTIPS         := 0x0412 ; (WM_USER +  18)
Global RB_SETBKCOLOR          := 0x0413 ; (WM_USER +  19) // sets the default BK color
Global RB_GETBKCOLOR          := 0x0414 ; (WM_USER +  20) // defaults to CLR_NONE
Global RB_SETTEXTCOLOR        := 0x0415 ; (WM_USER +  21)
Global RB_GETTEXTCOLOR        := 0x0416 ; (WM_USER +  22) // defaults to 0x00000000
Global RB_SIZETORECT          := 0x0417 ; (WM_USER +  23) // resize the rebar/break bands and such to this rect (lparam)
Global RB_SETCOLORSCHEME      := 0x2002 ; CCM_SETCOLORSCHEME  // lParam is color scheme
Global RB_GETCOLORSCHEME      := 0x2003 ; CCM_GETCOLORSCHEME  // fills in COLORSCHEME pointed to by lParam
Global RB_BEGINDRAG           := 0x0418 ; (WM_USER + 24)
Global RB_ENDDRAG             := 0x0419 ; (WM_USER + 25)
Global RB_DRAGMOVE            := 0x041A ; (WM_USER + 26)
Global RB_GETBARHEIGHT        := 0x041B ; (WM_USER + 27)
Global RB_GETBANDINFOW        := 0x041C ; (WM_USER + 28)
Global RB_GETBANDINFOA        := 0x041D ; (WM_USER + 29)
Global RB_MINIMIZEBAND        := 0x041E ; (WM_USER + 30)
Global RB_MAXIMIZEBAND        := 0x041F ; (WM_USER + 31)
Global RB_GETDROPTARGET       := 0x2004 ; CCM_GETDROPTARGET
Global RB_GETBANDBORDERS      := 0x0422 ; (WM_USER + 34) // returns in lparam = lprc the amount of edges added to band wparam
Global RB_SHOWBAND            := 0x0423 ; (WM_USER + 35) // show/hide band
Global RB_SETPALETTE          := 0x0425 ; (WM_USER + 37)
Global RB_GETPALETTE          := 0x0426 ; (WM_USER + 38)
Global RB_MOVEBAND            := 0x0427 ; (WM_USER + 39)
Global RB_SETUNICODEFORMAT    := 0x2004 ; CCM_SETUNICODEFORMAT
Global RB_GETUNICODEFORMAT    := 0x2005 ; CCM_GETUNICODEFORMAT
Global RB_GETBANDMARGINS      := 0x0428 ; (WM_USER + 40)
Global RB_SETWINDOWTHEME      := 0x200B ; CCM_SETWINDOWTHEME
Global RB_SETEXTENDEDSTYLE    := 0x0429 ; (WM_USER + 41) >= Vista
Global RB_GETEXTENDEDSTYLE    := 0x042A ; (WM_USER + 42) >= Vista
Global RB_PUSHCHEVRON         := 0x042B ; (WM_USER + 43)
Global RB_SETBANDWIDTH        := 0x042C ; (WM_USER + 44) >= Vista // set width for docked band
; Notifications ========================================================================================================
Global RBN_AUTOBREAK          := -853 ; (RBN_FIRST - 22)
Global RBN_AUTOSIZE           := -834 ; (RBN_FIRST - 3)
Global RBN_BEGINDRAG          := -835 ; (RBN_FIRST - 4)
Global RBN_CHEVRONPUSHED      := -841 ; (RBN_FIRST - 10)
Global RBN_CHILDSIZE          := -839 ; (RBN_FIRST - 8)
Global RBN_DELETEDBAND        := -838 ; (RBN_FIRST - 7)  // Uses NMREBAR
Global RBN_DELETINGBAND       := -837 ; (RBN_FIRST - 6)  // Uses NMREBAR
Global RBN_ENDDRAG            := -836 ; (RBN_FIRST - 5)
Global RBN_GETOBJECT          := -832 ; (RBN_FIRST - 1)
Global RBN_HEIGHTCHANGE       := -831 ; (RBN_FIRST - 0)
Global RBN_LAYOUTCHANGED      := -833 ; (RBN_FIRST - 2)
Global RBN_MINMAX             := -852 ; (RBN_FIRST - 21)
Global RBN_SPLITTERDRAG       := -842 ; (RBN_FIRST - 11)
; Styles ===============================================================================================================
Global RBS_AUTOSIZE           := 0x2000
Global RBS_BANDBORDERS        := 0x0400
Global RBS_DBLCLKTOGGLE       := 0x8000
Global RBS_FIXEDORDER         := 0x0800
Global RBS_REGISTERDROP       := 0x1000
Global RBS_TOOLTIPS           := 0x0100
Global RBS_VARHEIGHT          := 0x0200
Global RBS_VERTICALGRIPPER    := 0x4000 ; // this always has the vertical gripper (default for horizontal mode)
; Others ===============================================================================================================
; NMREBAR dwMask
Global RBNM_ID                := 0x01
Global RBNM_LPARAM            := 0x04
Global RBNM_STYLE             := 0x02
; NMREBARAUTOBREAK fStyleCurrent ?
Global RBAB_ADDBAND           := 0x02
Global RBAB_AUTOSIZE          := 0x01 ; // These are not flags and are all mutually exclusive
; RBHITTESTINFO flags
Global RBHT_CAPTION           := 0x02
Global RBHT_CHEVRON           := 0x08
Global RBHT_CLIENT            := 0x03
Global RBHT_GRABBER           := 0x04
Global RBHT_NOWHERE           := 0x01
Global RBHT_SPLITTER          := 0x10 ; >= Vista
; REBARBANDINFO fMask
Global RBBIM_BACKGROUND       := 0x0080
Global RBBIM_CHEVRONLOCATION  := 0x1000 ; >= Vista
Global RBBIM_CHEVRONSTATE     := 0x2000 ; >= Vista
Global RBBIM_CHILD            := 0x0010
Global RBBIM_CHILDSIZE        := 0x0020
Global RBBIM_COLORS           := 0x0002
Global RBBIM_HEADERSIZE       := 0x0800 ; // control the size of the header
Global RBBIM_ID               := 0x0100
Global RBBIM_IDEALSIZE        := 0x0200
Global RBBIM_IMAGE            := 0x0008
Global RBBIM_LPARAM           := 0x0400
Global RBBIM_SIZE             := 0x0040
Global RBBIM_STYLE            := 0x0001
Global RBBIM_TEXT             := 0x0004
; REBARBANDINFO fStyle
Global RBBS_BREAK             := 0x0001 ; // break to new line
Global RBBS_CHILDEDGE         := 0x0004 ; // edge around top & bottom of child window
Global RBBS_FIXEDBMP          := 0x0020 ; // bitmap doesn't move during band resize
Global RBBS_FIXEDSIZE         := 0x0002 ; // band can't be sized
Global RBBS_GRIPPERALWAYS     := 0x0080 ; // always show the gripper
Global RBBS_HIDDEN            := 0x0008 ; // don't show
Global RBBS_HIDETITLE         := 0x0400 ; // keep band title hidden
Global RBBS_NOGRIPPER         := 0x0100 ; // never show the gripper
Global RBBS_NOVERT            := 0x0010 ; // don't show when vertical
Global RBBS_TOPALIGN          := 0x0800 ; // keep band in top row
Global RBBS_USECHEVRON        := 0x0200 ; // display drop-down button for this band if it's sized smaller than ideal width
Global RBBS_VARIABLEHEIGHT    := 0x0040 ; // allow autosizing of this child vertically
; RB_SIZETORECT flags
Global RBSTR_CHANGERECT       := 0x01
; ======================================================================================================================