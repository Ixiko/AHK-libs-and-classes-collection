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
Global WC_TREEVIEW             := "SysTreeView32"
; Messages =============================================================================================================
Global TVM_CREATEDRAGIMAGE     := 0x1112 ; (TV_FIRST + 18)
Global TVM_DELETEITEM          := 0x1101 ; (TV_FIRST + 1)
Global TVM_EDITLABELA          := 0x110E ; (TV_FIRST + 14)
Global TVM_EDITLABELW          := 0x1141 ; (TV_FIRST + 65)
Global TVM_ENDEDITLABELNOW     := 0x1116 ; (TV_FIRST + 22)
Global TVM_ENSUREVISIBLE       := 0x1114 ; (TV_FIRST + 20)
Global TVM_EXPAND              := 0x1102 ; (TV_FIRST + 2)
Global TVM_GETBKCOLOR          := 0x112F ; (TV_FIRST + 31)
Global TVM_GETCOUNT            := 0x1105 ; (TV_FIRST + 5)
Global TVM_GETEDITCONTROL      := 0x110F ; (TV_FIRST + 15)
Global TVM_GETEXTENDEDSTYLE    := 0x112D ; (TV_FIRST + 45)
Global TVM_GETIMAGELIST        := 0x1108 ; (TV_FIRST + 8)
Global TVM_GETINDENT           := 0x1106 ; (TV_FIRST + 6)
Global TVM_GETINSERTMARKCOLOR  := 0x1126 ; (TV_FIRST + 38)
Global TVM_GETISEARCHSTRINGA   := 0x1117 ; (TV_FIRST + 23)
Global TVM_GETISEARCHSTRINGW   := 0x1140 ; (TV_FIRST + 64)
Global TVM_GETITEMA            := 0x110C ; (TV_FIRST + 12)
Global TVM_GETITEMHEIGHT       := 0x111C ; (TV_FIRST + 28)
Global TVM_GETITEMPARTRECT     := 0x1148 ; (TV_FIRST + 72) ; >= Vista
Global TVM_GETITEMRECT         := 0x1104 ; (TV_FIRST + 4)
Global TVM_GETITEMSTATE        := 0x1127 ; (TV_FIRST + 39)
Global TVM_GETITEMW            := 0x113E ; (TV_FIRST + 62)
Global TVM_GETLINECOLOR        := 0x1129 ; (TV_FIRST + 41)
Global TVM_GETNEXTITEM         := 0x110A ; (TV_FIRST + 10)
Global TVM_GETSCROLLTIME       := 0x1122 ; (TV_FIRST + 34)
Global TVM_GETSELECTEDCOUNT    := 0x1146 ; (TV_FIRST + 70) ; >= Vista
Global TVM_GETTEXTCOLOR        := 0x1120 ; (TV_FIRST + 32)
Global TVM_GETTOOLTIPS         := 0x1119 ; (TV_FIRST + 25)
Global TVM_GETUNICODEFORMAT    := 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
Global TVM_GETVISIBLECOUNT     := 0x1110 ; (TV_FIRST + 16)
Global TVM_HITTEST             := 0x1111 ; (TV_FIRST + 17)
Global TVM_INSERTITEMA         := 0x1100 ; (TV_FIRST + 0)
Global TVM_INSERTITEMW         := 0x1142 ; (TV_FIRST + 50)
Global TVM_MAPACCIDTOHTREEITEM := 0x112A ; (TV_FIRST + 42)
Global TVM_MAPHTREEITEMTOACCID := 0x112B ; (TV_FIRST + 43)
Global TVM_SELECTITEM          := 0x110B ; (TV_FIRST + 11)
Global TVM_SETAUTOSCROLLINFO   := 0x113B ; (TV_FIRST + 59)
Global TVM_SETBKCOLOR          := 0x111D ; (TV_FIRST + 29)
Global TVM_SETEXTENDEDSTYLE    := 0x112C ; (TV_FIRST + 44)
Global TVM_SETIMAGELIST        := 0x1109 ; (TV_FIRST + 9)
Global TVM_SETINDENT           := 0x1107 ; (TV_FIRST + 7)
Global TVM_SETINSERTMARK       := 0x111A ; (TV_FIRST + 26)
Global TVM_SETINSERTMARKCOLOR  := 0x1125 ; (TV_FIRST + 37)
Global TVM_SETITEMA            := 0x110D ; (TV_FIRST + 13)
Global TVM_SETITEMHEIGHT       := 0x111B ; (TV_FIRST + 27)
Global TVM_SETITEMW            := 0x113F ; (TV_FIRST + 63)
Global TVM_SETLINECOLOR        := 0x1128 ; (TV_FIRST + 40)
Global TVM_SETSCROLLTIME       := 0x1121 ; (TV_FIRST + 33)
Global TVM_SETTEXTCOLOR        := 0x111E ; (TV_FIRST + 30)
Global TVM_SETTOOLTIPS         := 0x1118 ; (TV_FIRST + 24)
Global TVM_SETUNICODEFORMAT    := 0x2005 ; (CCM_FIRST + 5) ; CCM_SETUNICODEFORMAT
Global TVM_SHOWINFOTIP         := 0x1147 ; (TV_FIRST + 71) ; >= Vista
Global TVM_SORTCHILDREN        := 0x1113 ; (TV_FIRST + 19)
Global TVM_SORTCHILDRENCB      := 0x1115 ; (TV_FIRST + 21)
; Notifications ========================================================================================================
Global TVN_ASYNCDRAW           := -420 ; (TVN_FIRST - 20) >= Vista
Global TVN_BEGINDRAGA          := -407 ; (TVN_FIRST - 7)
Global TVN_BEGINDRAGW          := -456 ; (TVN_FIRST - 56)
Global TVN_BEGINLABELEDITA     := -410 ; (TVN_FIRST - 10)
Global TVN_BEGINLABELEDITW     := -456 ; (TVN_FIRST - 59)
Global TVN_BEGINRDRAGA         := -408 ; (TVN_FIRST - 8)
Global TVN_BEGINRDRAGW         := -457 ; (TVN_FIRST - 57)
Global TVN_DELETEITEMA         := -409 ; (TVN_FIRST - 9)
Global TVN_DELETEITEMW         := -458 ; (TVN_FIRST - 58)
Global TVN_ENDLABELEDITA       := -411 ; (TVN_FIRST - 11)
Global TVN_ENDLABELEDITW       := -460 ; (TVN_FIRST - 60)
Global TVN_GETDISPINFOA        := -403 ; (TVN_FIRST - 3)
Global TVN_GETDISPINFOW        := -452 ; (TVN_FIRST - 52)
Global TVN_GETINFOTIPA         := -412 ; (TVN_FIRST - 13)
Global TVN_GETINFOTIPW         := -414 ; (TVN_FIRST - 14)
Global TVN_ITEMCHANGEDA        := -418 ; (TVN_FIRST - 18) ; >= Vista
Global TVN_ITEMCHANGEDW        := -419 ; (TVN_FIRST - 19) ; >= Vista
Global TVN_ITEMCHANGINGA       := -416 ; (TVN_FIRST - 16) ; >= Vista
Global TVN_ITEMCHANGINGW       := -417 ; (TVN_FIRST - 17) ; >= Vista
Global TVN_ITEMEXPANDEDA       := -406 ; (TVN_FIRST - 6)
Global TVN_ITEMEXPANDEDW       := -455 ; (TVN_FIRST - 55)
Global TVN_ITEMEXPANDINGA      := -405 ; (TVN_FIRST - 5)
Global TVN_ITEMEXPANDINGW      := -454 ; (TVN_FIRST - 54)
Global TVN_KEYDOWN             := -412 ; (TVN_FIRST - 12)
Global TVN_SELCHANGEDA         := -402 ; (TVN_FIRST - 2)
Global TVN_SELCHANGEDW         := -451 ; (TVN_FIRST - 51)
Global TVN_SELCHANGINGA        := -401 ; (TVN_FIRST - 1)
Global TVN_SELCHANGINGW        := -450 ; (TVN_FIRST - 50)
Global TVN_SETDISPINFOA        := -404 ; (TVN_FIRST - 4)
Global TVN_SETDISPINFOW        := -453 ; (TVN_FIRST - 53)
Global TVN_SINGLEEXPAND        := -415 ; (TVN_FIRST - 15)
; Styles ===============================================================================================================
Global TVS_CHECKBOXES          := 0x0100
Global TVS_DISABLEDRAGDROP     := 0x0010
Global TVS_EDITLABELS          := 0x0008
Global TVS_FULLROWSELECT       := 0x1000
Global TVS_HASBUTTONS          := 0x0001
Global TVS_HASLINES            := 0x0002
Global TVS_INFOTIP             := 0x0800
Global TVS_LINESATROOT         := 0x0004
Global TVS_NOHSCROLL           := 0x8000 ; TVS_NOSCROLL overrides this
Global TVS_NONEVENHEIGHT       := 0x4000
Global TVS_NOSCROLL            := 0x2000
Global TVS_NOTOOLTIPS          := 0x0080
Global TVS_RTLREADING          := 0x0040
Global TVS_SHOWSELALWAYS       := 0x0020
Global TVS_SINGLEEXPAND        := 0x0400
Global TVS_TRACKSELECT         := 0x0200
; Exstyles =============================================================================================================
Global TVS_EX_AUTOHSCROLL         := 0x0020 ; >= Vista
Global TVS_EX_DIMMEDCHECKBOXES    := 0x0200 ; >= Vista
Global TVS_EX_DOUBLEBUFFER        := 0x0004 ; >= Vista
Global TVS_EX_DRAWIMAGEASYNC      := 0x0400 ; >= Vista
Global TVS_EX_EXCLUSIONCHECKBOXES := 0x0100 ; >= Vista
Global TVS_EX_FADEINOUTEXPANDOS   := 0x0040 ; >= Vista
Global TVS_EX_MULTISELECT         := 0x0002 ; >= Vista - Not supported. Do not use.
Global TVS_EX_NOINDENTSTATE       := 0x0008 ; >= Vista
Global TVS_EX_NOSINGLECOLLAPSE    := 0x0001 ; >= Vista - Intended for internal use; not recommended for use in applications.
Global TVS_EX_PARTIALCHECKBOXES   := 0x0080 ; >= Vista
Global TVS_EX_RICHTOOLTIP         := 0x0010 ; >= Vista
; Others ===============================================================================================================
; Item flags
Global TVIF_CHILDREN           := 0x0040
Global TVIF_DI_SETITEM         := 0x1000
Global TVIF_EXPANDEDIMAGE      := 0x0200 ; >= Vista
Global TVIF_HANDLE             := 0x0010
Global TVIF_IMAGE              := 0x0002
Global TVIF_INTEGRAL           := 0x0080
Global TVIF_PARAM              := 0x0004
Global TVIF_SELECTEDIMAGE      := 0x0020
Global TVIF_STATE              := 0x0008
Global TVIF_STATEEX            := 0x0100 ; >= Vista
Global TVIF_TEXT               := 0x0001
; Item states
Global TVIS_BOLD               := 0x0010
Global TVIS_CUT                := 0x0004
Global TVIS_DROPHILITED        := 0x0008
Global TVIS_EXPANDED           := 0x0020
Global TVIS_EXPANDEDONCE       := 0x0040
Global TVIS_EXPANDPARTIAL      := 0x0080
Global TVIS_OVERLAYMASK        := 0x0F00
Global TVIS_SELECTED           := 0x0002
Global TVIS_STATEIMAGEMASK     := 0xF000
Global TVIS_USERMASK           := 0xF000
; TVITEMEX uStateEx
Global TVIS_EX_ALL             := 0x0002 ; not documented
Global TVIS_EX_DISABLED        := 0x0002 ; >= Vista
Global TVIS_EX_FLAT            := 0x0001
; TVINSERTSTRUCT hInsertAfter
Global TVI_FIRST               := -65535 ; (-0x0FFFF)
Global TVI_LAST                := -65534 ; (-0x0FFFE)
Global TVI_ROOT                := -65536 ; (-0x10000)
Global TVI_SORT                := -65533 ; (-0x0FFFD)
; TVM_EXPAND wParam
Global TVE_COLLAPSE            := 0x0001
Global TVE_COLLAPSERESET       := 0x8000
Global TVE_EXPAND              := 0x0002
Global TVE_EXPANDPARTIAL       := 0x4000
Global TVE_TOGGLE              := 0x0003
; TVM_GETIMAGELIST wParam
Global TVSIL_NORMAL            := 0
Global TVSIL_STATE             := 2
; TVM_GETNEXTITEM wParam
Global TVGN_CARET              := 0x0009
Global TVGN_CHILD              := 0x0004
Global TVGN_DROPHILITE         := 0x0008
Global TVGN_FIRSTVISIBLE       := 0x0005
Global TVGN_LASTVISIBLE        := 0x000A
Global TVGN_NEXT               := 0x0001
Global TVGN_NEXTSELECTED       := 0x000B ; >= Vista (MSDN)     
Global TVGN_NEXTVISIBLE        := 0x0006
Global TVGN_PARENT             := 0x0003
Global TVGN_PREVIOUS           := 0x0002
Global TVGN_PREVIOUSVISIBLE    := 0x0007
Global TVGN_ROOT               := 0x0000
; TVM_SELECTITEM wParam
Global TVSI_NOSINGLEEXPAND     := 0x8000 ; Should not conflict with TVGN flags.
; TVHITTESTINFO flags
Global TVHT_ABOVE              := 0x0100
Global TVHT_BELOW              := 0x0200
Global TVHT_NOWHERE            := 0x0001
Global TVHT_ONITEMBUTTON       := 0x0010
Global TVHT_ONITEMICON         := 0x0002
Global TVHT_ONITEMINDENT       := 0x0008
Global TVHT_ONITEMLABEL        := 0x0004
Global TVHT_ONITEMRIGHT        := 0x0020
Global TVHT_ONITEMSTATEICON    := 0x0040
Global TVHT_TOLEFT             := 0x0800
Global TVHT_TORIGHT            := 0x0400
Global TVHT_ONITEM             := 0x0046 ; (TVHT_ONITEMICON | TVHT_ONITEMLABEL | TVHT_ONITEMSTATEICON)
; TVGETITEMPARTRECTINFO partID (>= Vista)
Global TVGIPR_BUTTON           := 0x0001
; NMTREEVIEW action
Global TVC_BYKEYBOARD          := 0x0002
Global TVC_BYMOUSE             := 0x0001
Global TVC_UNKNOWN             := 0x0000
; TVN_SINGLEEXPAND return codes
Global TVNRET_DEFAULT          := 0
Global TVNRET_SKIPOLD          := 1
Global TVNRET_SKIPNEW          := 2
; ======================================================================================================================