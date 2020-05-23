; ======================================================================================================================
; Function:          Constants for ListView controls
; AHK version:       1.1.05+
; Language:          English
; Version:           1.0.00.00/2012-04-01/just me
;                    1.0.01.00/2012-05-20/just me - fixed some typos
; ======================================================================================================================
; CCM_FIRST = 8192 (0x2000)
; LVM_FIRST = 4096 (0x1000) ; ListView messages
; LVN_FIRST = -100          ; ListView notifications
; ======================================================================================================================
; Class ================================================================================================================
Global WC_LISTVIEW             := "SysListView32"
; Messages =============================================================================================================
Global LVM_APPROXIMATEVIEWRECT := 0x1040 ; (LVM_FIRST + 64)
Global LVM_ARRANGE             := 0x1016 ; (LVM_FIRST + 22)
Global LVM_CANCELEDITLABEL     := 0x10B3 ; (LVM_FIRST + 179)
Global LVM_CREATEDRAGIMAGE     := 0x1021 ; (LVM_FIRST + 33)
Global LVM_DELETEALLITEMS      := 0x1009 ; (LVM_FIRST + 9)
Global LVM_DELETECOLUMN        := 0x101C ; (LVM_FIRST + 28)
Global LVM_DELETEITEM          := 0x1008 ; (LVM_FIRST + 8)
Global LVM_EDITLABELA          := 0x1017 ; (LVM_FIRST + 23)
Global LVM_EDITLABELW          := 0x1076 ; (LVM_FIRST + 118)
Global LVM_ENABLEGROUPVIEW     := 0x109D ; (LVM_FIRST + 157)
Global LVM_ENSUREVISIBLE       := 0x1013 ; (LVM_FIRST + 19)
Global LVM_FINDITEMA           := 0x100D ; (LVM_FIRST + 13)
Global LVM_FINDITEMW           := 0x1053 ; (LVM_FIRST + 83)
Global LVM_GETBKCOLOR          := 0x1000 ; (LVM_FIRST + 0)
Global LVM_GETBKIMAGEA         := 0x1045 ; (LVM_FIRST + 69)
Global LVM_GETBKIMAGEW         := 0x108B ; (LVM_FIRST + 139)
Global LVM_GETCALLBACKMASK     := 0x100A ; (LVM_FIRST + 10)
Global LVM_GETCOLUMNA          := 0x1019 ; (LVM_FIRST + 25)
Global LVM_GETCOLUMNW          := 0x105F ; (LVM_FIRST + 95)
Global LVM_GETCOLUMNORDERARRAY := 0x103B ; (LVM_FIRST + 59)
Global LVM_GETCOLUMNWIDTH      := 0x101D ; (LVM_FIRST + 29)
Global LVM_GETCOUNTPERPAGE     := 0x1028 ; (LVM_FIRST + 40)
Global LVM_GETEDITCONTROL      := 0x1018 ; (LVM_FIRST + 24)
Global LVM_GETEMPTYTEXT        := 0x10CC ; (LVM_FIRST + 204) >= Vista
Global LVM_GETEXTENDEDLISTVIEWSTYLE := 0x1037 ; (LVM_FIRST + 55)
Global LVM_GETFOCUSEDGROUP     := 0x105D ; (LVM_FIRST + 93)
Global LVM_GETFOOTERINFO       := 0x10CE ; (LVM_FIRST + 206) >= Vista
Global LVM_GETFOOTERITEM       := 0x10D0 ; (LVM_FIRST + 208) >= Vista
Global LVM_GETFOOTERITEMRECT   := 0x10CF ; (LVM_FIRST + 207) >= Vista
Global LVM_GETFOOTERRECT       := 0x10CD ; (LVM_FIRST + 205) >= Vista
Global LVM_GETGROUPCOUNT       := 0x1098 ; (LVM_FIRST + 152)
Global LVM_GETGROUPINFO        := 0x1095 ; (LVM_FIRST + 149)
Global LVM_GETGROUPINFOBYINDEX := 0x1099 ; (LVM_FIRST + 153)
Global LVM_GETGROUPMETRICS     := 0x109C ; (LVM_FIRST + 156)
Global LVM_GETGROUPRECT        := 0x1062 ; (LVM_FIRST + 98)  >= Vista ?
Global LVM_GETGROUPSTATE       := 0x105C ; (LVM_FIRST + 92)
Global LVM_GETHEADER           := 0x101F ; (LVM_FIRST + 31)
Global LVM_GETHOTCURSOR        := 0x103F ; (LVM_FIRST + 63)
Global LVM_GETHOTITEM          := 0x103D ; (LVM_FIRST + 61)
Global LVM_GETHOVERTIME        := 0x1048 ; (LVM_FIRST + 72)
Global LVM_GETIMAGELIST        := 0x1002 ; (LVM_FIRST + 2)
Global LVM_GETINSERTMARK       := 0x10A7 ; (LVM_FIRST + 167)
Global LVM_GETINSERTMARKCOLOR  := 0x10AB ; (LVM_FIRST + 171)
Global LVM_GETINSERTMARKRECT   := 0x10A9 ; (LVM_FIRST + 169)
Global LVM_GETISEARCHSTRINGA   := 0x1034 ; (LVM_FIRST + 52)
Global LVM_GETISEARCHSTRINGW   := 0x1075 ; (LVM_FIRST + 117)
Global LVM_GETITEMA            := 0x1005 ; (LVM_FIRST + 5)
Global LVM_GETITEMW            := 0x104B ; (LVM_FIRST + 75)
Global LVM_GETITEMCOUNT        := 0x1004 ; (LVM_FIRST + 4)
Global LVM_GETITEMINDEXRECT    := 0x10D1 ; (LVM_FIRST + 209) >= Vista
Global LVM_GETITEMPOSITION     := 0x1010 ; (LVM_FIRST + 16)
Global LVM_GETITEMRECT         := 0x100E ; (LVM_FIRST + 14)
Global LVM_GETITEMSPACING      := 0x1033 ; (LVM_FIRST + 51)
Global LVM_GETITEMSTATE        := 0x102C ; (LVM_FIRST + 44)
Global LVM_GETITEMTEXTA        := 0x102D ; (LVM_FIRST + 45)
Global LVM_GETITEMTEXTW        := 0x1073 ; (LVM_FIRST + 115)
Global LVM_GETNEXTITEM         := 0x100C ; (LVM_FIRST + 12)
Global LVM_GETNEXTITEMINDEX    := 0x10D3 ; (LVM_FIRST + 211) >= Vista
Global LVM_GETNUMBEROFWORKAREAS := 0x1049 ; (LVM_FIRST + 73)
Global LVM_GETORIGIN           := 0x1029 ; (LVM_FIRST + 41)
Global LVM_GETOUTLINECOLOR     := 0x10B0 ; (LVM_FIRST + 176)
Global LVM_GETSELECTEDCOLUMN   := 0x10AE ; (LVM_FIRST + 174)
Global LVM_GETSELECTEDCOUNT    := 0x1032 ; (LVM_FIRST + 50)
Global LVM_GETSELECTIONMARK    := 0x1042 ; (LVM_FIRST + 66)
Global LVM_GETSTRINGWIDTHA     := 0x1011 ; (LVM_FIRST + 17)
Global LVM_GETSTRINGWIDTHW     := 0x1057 ; (LVM_FIRST + 87)
Global LVM_GETSUBITEMRECT      := 0x1038 ; (LVM_FIRST + 56)
Global LVM_GETTEXTBKCOLOR      := 0x1025 ; (LVM_FIRST + 37)
Global LVM_GETTEXTCOLOR        := 0x1023 ; (LVM_FIRST + 35)
Global LVM_GETTILEINFO         := 0x10A5 ; (LVM_FIRST + 165)
Global LVM_GETTILEVIEWINFO     := 0x10A3 ; (LVM_FIRST + 163)
Global LVM_GETTOOLTIPS         := 0x104E ; (LVM_FIRST + 78)
Global LVM_GETTOPINDEX         := 0x1027 ; (LVM_FIRST + 39)
Global LVM_GETUNICODEFORMAT    := 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
Global LVM_GETVIEW             := 0x108F ; (LVM_FIRST + 143)
Global LVM_GETVIEWRECT         := 0x1022 ; (LVM_FIRST + 34)
Global LVM_GETWORKAREAS        := 0x1046 ; (LVM_FIRST + 70)
Global LVM_HASGROUP            := 0x10A1 ; (LVM_FIRST + 161)
Global LVM_HITTEST             := 0x1012 ; (LVM_FIRST + 18)
Global LVM_INSERTCOLUMNA       := 0x1019 ; (LVM_FIRST + 27)
Global LVM_INSERTCOLUMNW       := 0x1061 ; (LVM_FIRST + 97)
Global LVM_INSERTGROUP         := 0x1091 ; (LVM_FIRST + 145)
Global LVM_INSERTGROUPSORTED   := 0x109F ; (LVM_FIRST + 159)
Global LVM_INSERTITEMA         := 0x1007 ; (LVM_FIRST + 7)
Global LVM_INSERTITEMW         := 0x104D ; (LVM_FIRST + 77)
Global LVM_INSERTMARKHITTEST   := 0x10A8 ; (LVM_FIRST + 168)
Global LVM_ISGROUPVIEWENABLED  := 0x10AF ; (LVM_FIRST + 175)
Global LVM_ISITEMVISIBLE       := 0x10B6 ; (LVM_FIRST + 182)
Global LVM_MAPIDTOINDEX        := 0x10B5 ; (LVM_FIRST + 181)
Global LVM_MAPINDEXTOID        := 0x10B4 ; (LVM_FIRST + 180)
Global LVM_MOVEGROUP           := 0x1097 ; (LVM_FIRST + 151)
Global LVM_MOVEITEMTOGROUP     := 0x109A ; (LVM_FIRST + 154)
Global LVM_REDRAWITEMS         := 0x1015 ; (LVM_FIRST + 21)
Global LVM_REMOVEALLGROUPS     := 0x10A0 ; (LVM_FIRST + 160)
Global LVM_REMOVEGROUP         := 0x1096 ; (LVM_FIRST + 150)
Global LVM_SCROLL              := 0x1014 ; (LVM_FIRST + 20)
Global LVM_SETBKCOLOR          := 0x1001 ; (LVM_FIRST + 1)
Global LVM_SETBKIMAGEA         := 0x1044 ; (LVM_FIRST + 68)
Global LVM_SETBKIMAGEW         := 0x108A ; (LVM_FIRST + 138)
Global LVM_SETCALLBACKMASK     := 0x100B ; (LVM_FIRST + 11)
Global LVM_SETCOLUMNA          := 0x101A ; (LVM_FIRST + 26)
Global LVM_SETCOLUMNW          := 0x1060 ; (LVM_FIRST + 96)
Global LVM_SETCOLUMNORDERARRAY := 0x103A ; (LVM_FIRST + 58)
Global LVM_SETCOLUMNWIDTH      := 0x101E ; (LVM_FIRST + 30)
Global LVM_SETEXTENDEDLISTVIEWSTYLE := 0x1036 ; (LVM_FIRST + 54) optional wParam == mask
Global LVM_SETGROUPINFO        := 0x1093 ; (LVM_FIRST + 147)
Global LVM_SETGROUPMETRICS     := 0x109B ; (LVM_FIRST + 155)
Global LVM_SETHOTCURSOR        := 0x103E ; (LVM_FIRST + 62)
Global LVM_SETHOTITEM          := 0x103C ; (LVM_FIRST + 60)
Global LVM_SETHOVERTIME        := 0x1047 ; (LVM_FIRST + 71)
Global LVM_SETICONSPACING      := 0x1035 ; (LVM_FIRST + 53)
Global LVM_SETIMAGELIST        := 0x1003 ; (LVM_FIRST + 3)
Global LVM_SETINFOTIP          := 0x10AD ; (LVM_FIRST + 173)
Global LVM_SETINSERTMARK       := 0x10A6 ; (LVM_FIRST + 166)
Global LVM_SETINSERTMARKCOLOR  := 0x10AA ; (LVM_FIRST + 170)
Global LVM_SETITEMA            := 0x1006 ; (LVM_FIRST + 6)
Global LVM_SETITEMW            := 0x104C ; (LVM_FIRST + 76)
Global LVM_SETITEMCOUNT        := 0x102F ; (LVM_FIRST + 47)
Global LVM_SETITEMINDEXSTATE   := 0x10D2 ; (LVM_FIRST + 210) >= Vista
Global LVM_SETITEMPOSITION     := 0x100F ; (LVM_FIRST + 15)
Global LVM_SETITEMPOSITION32   := 0x1031 ; (LVM_FIRST + 49)
Global LVM_SETITEMSTATE        := 0x102B ; (LVM_FIRST + 43)
Global LVM_SETITEMTEXTA        := 0x102E ; (LVM_FIRST + 46)
Global LVM_SETITEMTEXTW        := 0x1074 ; (LVM_FIRST + 116)
Global LVM_SETOUTLINECOLOR     := 0x10B1 ; (LVM_FIRST + 177)
Global LVM_SETSELECTIONMARK    := 0x1043 ; (LVM_FIRST + 67)
Global LVM_SETTEXTBKCOLOR      := 0x1026 ; (LVM_FIRST + 38)
Global LVM_SETTEXTCOLOR        := 0x1024 ; (LVM_FIRST + 36)
Global LVM_SETTILEINFO         := 0x10A4 ; (LVM_FIRST + 164)
Global LVM_SETTILEVIEWINFO     := 0x10A2 ; (LVM_FIRST + 162)
Global LVM_SETTOOLTIPS         := 0x104A ; (LVM_FIRST + 74)
Global LVM_SETUNICODEFORMAT    := 0x2005 ; (CCM_FIRST + 5) CCM_SETUNICODEFORMAT
Global LVM_SETVIEW             := 0x108E ; (LVM_FIRST + 142)
Global LVM_SETWORKAREAS        := 0x1041 ; (LVM_FIRST + 65)
Global LVM_SORTGROUPS          := 0x109E ; (LVM_FIRST + 158)
Global LVM_SORTITEMS           := 0x1030 ; (LVM_FIRST + 48)
Global LVM_SORTITEMSEX         := 0x1051 ; (LVM_FIRST + 81)
Global LVM_SUBITEMHITTEST      := 0x1039 ; (LVM_FIRST + 57)
Global LVM_UPDATE              := 0x102A ; (LVM_FIRST + 42)
; Notifications ========================================================================================================
Global LVN_BEGINDRAG           := -109 ; (LVN_FIRST - 9)
Global LVN_BEGINLABELEDITA     := -105 ; (LVN_FIRST - 5)
Global LVN_BEGINLABELEDITW     := -175 ; (LVN_FIRST - 75)
Global LVN_BEGINRDRAG          := -111 ; (LVN_FIRST - 11)
Global LVN_BEGINSCROLL         := -180 ; (LVN_FIRST - 80)
Global LVN_COLUMNCLICK         := -108 ; (LVN_FIRST - 8)
Global LVN_COLUMNDROPDOWN      := -164 ; (LVN_FIRST - 64) >= Vista
Global LVN_COLUMNOVERFLOWCLICK := -166 ; (LVN_FIRST - 66) >= Vista
Global LVN_DELETEALLITEMS      := -104 ; (LVN_FIRST - 4)
Global LVN_DELETEITEM          := -103 ; (LVN_FIRST - 3)
Global LVN_ENDLABELEDITA       := -106 ; (LVN_FIRST - 6)
Global LVN_ENDLABELEDITW       := -176 ; (LVN_FIRST - 76)
Global LVN_ENDSCROLL           := -181 ; (LVN_FIRST - 81)
Global LVN_GETDISPINFOA        := -150 ; (LVN_FIRST - 50)
Global LVN_GETDISPINFOW        := -177 ; (LVN_FIRST - 77)
Global LVN_GETEMPTYMARKUP      := -187 ; (LVN_FIRST - 87) >= Vista
Global LVN_GETINFOTIPA         := -157 ; (LVN_FIRST - 57)
Global LVN_GETINFOTIPW         := -158 ; (LVN_FIRST - 58)
Global LVN_HOTTRACK            := -121 ; (LVN_FIRST - 21)
Global LVN_INCREMENTALSEARCHA  := -162 ; (LVN_FIRST - 62)
Global LVN_INCREMENTALSEARCHW  := -163 ; (LVN_FIRST - 63)
Global LVN_INSERTITEM          := -102 ; (LVN_FIRST - 2)
Global LVN_ITEMACTIVATE        := -114 ; (LVN_FIRST - 14)
Global LVN_ITEMCHANGED         := -101 ; (LVN_FIRST - 1)
Global LVN_ITEMCHANGING        := -100 ; (LVN_FIRST - 0)
Global LVN_KEYDOWN             := -155 ; (LVN_FIRST - 55)
Global LVN_LINKCLICK           := -184 ; (LVN_FIRST - 84) >= Vista
Global LVN_MARQUEEBEGIN        := -156 ; (LVN_FIRST - 56)
Global LVN_ODCACHEHINT         := -113 ; (LVN_FIRST - 13)
Global LVN_ODFINDITEMA         := -152 ; (LVN_FIRST - 52)
Global LVN_ODFINDITEMW         := -179 ; (LVN_FIRST - 79)
Global LVN_ODSTATECHANGED      := -115 ; (LVN_FIRST - 15)
Global LVN_SETDISPINFOA        := -151 ; (LVN_FIRST - 51)
Global LVN_SETDISPINFOW        := -178 ; (LVN_FIRST - 78)
; Styles ===============================================================================================================
GLOBAL LVS_ALIGNLEFT           := 0x0800
GLOBAL LVS_ALIGNMASK           := 0x0C00
GLOBAL LVS_ALIGNTOP            := 0x0000
GLOBAL LVS_AUTOARRANGE         := 0x0100
GLOBAL LVS_EDITLABELS          := 0x0200
GLOBAL LVS_ICON                := 0x0000
GLOBAL LVS_LIST                := 0x0003
GLOBAL LVS_NOCOLUMNHEADER      := 0x4000
GLOBAL LVS_NOLABELWRAP         := 0x0080
GLOBAL LVS_NOSCROLL            := 0x2000
GLOBAL LVS_NOSORTHEADER        := 0x8000
GLOBAL LVS_OWNERDATA           := 0x1000
GLOBAL LVS_OWNERDRAWFIXED      := 0x0400
GLOBAL LVS_REPORT              := 0x0001
GLOBAL LVS_SHAREIMAGELISTS     := 0x0040
GLOBAL LVS_SHOWSELALWAYS       := 0x0008
GLOBAL LVS_SINGLESEL           := 0x0004
GLOBAL LVS_SMALLICON           := 0x0002
GLOBAL LVS_SORTASCENDING       := 0x0010
GLOBAL LVS_SORTDESCENDING      := 0x0020
GLOBAL LVS_TYPEMASK            := 0x0003
GLOBAL LVS_TYPESTYLEMASK       := 0xFC00
; ExStyles =============================================================================================================
Global LVS_EX_AUTOAUTOARRANGE  := 0x01000000  ; >= Vista: icons automatically arrange if no icon positions have been set
Global LVS_EX_AUTOCHECKSELECT  := 0x08000000  ; >= Vista
Global LVS_EX_AUTOSIZECOLUMNS  := 0x10000000  ; >= Vista
Global LVS_EX_BORDERSELECT     := 0x00008000  ; border selection style instead of highlight
Global LVS_EX_CHECKBOXES       := 0x00000004
Global LVS_EX_COLUMNOVERFLOW   := 0x80000000  ; >= Vista
Global LVS_EX_COLUMNSNAPPOINTS := 0x40000000  ; >= Vista
Global LVS_EX_DOUBLEBUFFER     := 0x00010000
Global LVS_EX_FLATSB           := 0x00000100
Global LVS_EX_FULLROWSELECT    := 0x00000020  ; applies to report mode only
Global LVS_EX_GRIDLINES        := 0x00000001
Global LVS_EX_HEADERDRAGDROP   := 0x00000010
Global LVS_EX_HEADERINALLVIEWS := 0x02000000  ; >= Vista: display column header in all view modes
Global LVS_EX_HIDELABELS       := 0x00020000
Global LVS_EX_INFOTIP          := 0x00000400  ; listview does InfoTips for you
Global LVS_EX_JUSTIFYCOLUMNS   := 0x00200000  ; >= Vista: icons are lined up in columns that use up the whole view area
Global LVS_EX_LABELTIP         := 0x00004000  ; listview unfolds partly hidden labels if it does not have infotip text
Global LVS_EX_MULTIWORKAREAS   := 0x00002000
Global LVS_EX_ONECLICKACTIVATE := 0x00000040
Global LVS_EX_REGIONAL         := 0x00000200
Global LVS_EX_SIMPLESELECT     := 0x00100000  ; also changes overlay rendering to top right for icon mode
Global LVS_EX_SINGLEROW        := 0x00040000
Global LVS_EX_SNAPTOGRID       := 0x00080000  ; icons automatically snap to grid
Global LVS_EX_SUBITEMIMAGES    := 0x00000002
Global LVS_EX_TRACKSELECT      := 0x00000008
Global LVS_EX_TRANSPARENTBKGND := 0x00400000  ; >= Vista: background is painted by the parent via WM_PRINTCLIENT
Global LVS_EX_TRANSPARENTSHADOWTEXT := 0x00800000  ; >=Vista: enable shadow text on transparent backgrounds only (useful with bitmaps)
Global LVS_EX_TWOCLICKACTIVATE := 0x00000080
Global LVS_EX_UNDERLINECOLD    := 0x00001000
Global LVS_EX_UNDERLINEHOT     := 0x00000800
; Others ===============================================================================================================
; LVM_GET/SETIMAGELIST
Global LVSIL_GROUPHEADER       := 3
Global LVSIL_NORMAL            := 0
Global LVSIL_SMALL             := 1
Global LVSIL_STATE             := 2
; LVITEM mask
Global LVIF_COLFMT             := 0x00010000  ; >= Vista - the piColFmt member is valid in addition to puColumns
Global LVIF_COLUMNS            := 0x00000200
Global LVIF_DI_SETITEM         := 0x00001000
Global LVIF_GROUPID            := 0x00000100
Global LVIF_IMAGE              := 0x00000002
Global LVIF_INDENT             := 0x00000010
Global LVIF_NORECOMPUTE        := 0x00000800
Global LVIF_PARAM              := 0x00000004
Global LVIF_STATE              := 0x00000008
Global LVIF_TEXT               := 0x00000001
; LVITEM state
Global LVIS_ACTIVATING         := 0x0020
Global LVIS_CUT                := 0x0004
Global LVIS_DROPHILITED        := 0x0008
Global LVIS_FOCUSED            := 0x0001
Global LVIS_GLOW               := 0x0010      ; not documented in MSDN
Global LVIS_OVERLAYMASK        := 0x0F00
Global LVIS_SELECTED           := 0x0002
Global LVIS_STATEIMAGEMASK     := 0xF000
; LVN_GETNEXTITEM
Global LVNI_ABOVE              := 0x0100
Global LVNI_ALL                := 0x0000
Global LVNI_BELOW              := 0x0200
Global LVNI_CUT                := 0x0004
Global LVNI_DIRECTIONMASK      := 0x0F00      ; (LVNI_ABOVE | LVNI_BELOW | LVNI_TOLEFT | LVNI_TORIGHT) >= Vista
Global LVNI_DROPHILITED        := 0x0008
Global LVNI_FOCUSED            := 0x0001
Global LVNI_PREVIOUS           := 0x0020      ; >= Vista
Global LVNI_SAMEGROUPONLY      := 0x0080      ; >= Vista
Global LVNI_SELECTED           := 0x0002
Global LVNI_STATEMASK          := 0x000F      ; (LVNI_FOCUSED | LVNI_SELECTED | LVNI_CUT | LVNI_DROPHILITED) >= Vista
Global LVNI_TOLEFT             := 0x0400
Global LVNI_TORIGHT            := 0x0800
Global LVNI_VISIBLEONLY        := 0x0040      ; >= Vista
Global LVNI_VISIBLEORDER       := 0x0010      ; >= Vista
; LVFINDINFO flags
Global LVFI_NEARESTXY          := 0x0040
Global LVFI_PARAM              := 0x0001
Global LVFI_PARTIAL            := 0x0008
Global LVFI_STRING             := 0x0002
Global LVFI_SUBSTRING          := 0x0004      ; >= Vista - same as LVFI_PARTIAL
Global LVFI_WRAP               := 0x0020
; LVM_GETITEMRECT
Global LVIR_BOUNDS             := 0
Global LVIR_ICON               := 1
Global LVIR_LABEL              := 2
Global LVIR_SELECTBOUNDS       := 3
; LVHITTESTINFO flags
Global LVHT_NOWHERE            := 0x00000001
Global LVHT_ABOVE              := 0x00000008
Global LVHT_BELOW              := 0x00000010
Global LVHT_ONITEM             := 0x0000000E ; (LVHT_ONITEMICON | LVHT_ONITEMLABEL | LVHT_ONITEMSTATEICON)
Global LVHT_ONITEMICON         := 0x00000002
Global LVHT_ONITEMLABEL        := 0x00000004
Global LVHT_ONITEMSTATEICON    := 0x00000008
Global LVHT_TOLEFT             := 0x00000040
Global LVHT_TORIGHT            := 0x00000020
Global LVHT_EX_FOOTER           := 0x08000000 ; >= Vista
Global LVHT_EX_GROUP            := 0xF3000000 ; >= Vista (LVHT_EX_GROUP_BACKGROUND | _COLLAPSE | _FOOTER | _HEADER | _STATEICON | _SUBSETLINK)
Global LVHT_EX_GROUP_BACKGROUND := 0x80000000 ; >= Vista
Global LVHT_EX_GROUP_COLLAPSE   := 0x40000000 ; >= Vista
Global LVHT_EX_GROUP_FOOTER     := 0x20000000 ; >= Vista
Global LVHT_EX_GROUP_HEADER     := 0x10000000 ; >= Vista
Global LVHT_EX_GROUP_STATEICON  := 0x01000000 ; >= Vista
Global LVHT_EX_GROUP_SUBSETLINK := 0x02000000 ; >= Vista
Global LVHT_EX_ONCONTENTS       := 0x04000000 ; >= Vista - on item AND not on the background
; LVM_ARRANGE
Global LVA_ALIGNLEFT           := 0x0001
Global LVA_ALIGNTOP            := 0x0002
Global LVA_DEFAULT             := 0x0000
Global LVA_SNAPTOGRID          := 0x0005
; LVCOLUMN mask
Global LVCF_DEFAULTWIDTH       := 0x0080        ; >= Vista
Global LVCF_FMT                := 0x0001
Global LVCF_IDEALWIDTH         := 0x0100        ; >= Vista
Global LVCF_IMAGE              := 0x0010
Global LVCF_MINWIDTH           := 0x0040        ; >= Vista
Global LVCF_ORDER              := 0x0020
Global LVCF_SUBITEM            := 0x0008
Global LVCF_TEXT               := 0x0004
Global LVCF_WIDTH              := 0x0002
; LVCOLUMN fmt, LVITEM piColFmt
Global LVCFMT_BITMAP_ON_RIGHT    := 0x1000        ; Same as HDF_BITMAP_ON_RIGHT
Global LVCFMT_CENTER             := 0x0002        ; Same as HDF_CENTER
Global LVCFMT_COL_HAS_IMAGES     := 0x8000        ; Same as HDF_OWNERDRAW
Global LVCFMT_FILL               := 0x200000      ; >= Win7   Fill the remainder of the tile area. Might have a title.
Global LVCFMT_FIXED_RATIO        := 0x80000       ; >= Vista  Width will augment with the row height
Global LVCFMT_FIXED_WIDTH        := 0x000100      ; >= Vista  Can't resize the column; same as HDF_FIXEDWIDTH
Global LVCFMT_IMAGE              := 0x0800        ; Same as HDF_IMAGE
Global LVCFMT_JUSTIFYMASK        := 0x0003        ; Same as HDF_JUSTIFYMASK
Global LVCFMT_LEFT               := 0x0000        ; Same as HDF_LEFT
Global LVCFMT_LINE_BREAK         := 0x100000      ; >= Win7   Move to the top of the next list of columns
Global LVCFMT_NO_DPI_SCALE       := 0x40000       ; >= Vista  If not set, CCM_DPISCALE will govern scaling up fixed width
Global LVCFMT_NO_TITLE           := 0x800000      ; >= Win7   This sub-item doesn't have an title.
Global LVCFMT_RIGHT              := 0x0001        ; Same as HDF_RIGHT
Global LVCFMT_SPLITBUTTON        := 0x01000000    ; >= Vista  Column is a split button; same as HDF_SPLITBUTTON
Global LVCFMT_TILE_PLACEMENTMASK := 0x300000      ; (LVCFMT_LINE_BREAK | LVCFMT_FILL) >= Win7
Global LVCFMT_WRAP               := 0x400000      ; >= Win7   This sub-item can be wrapped.
; LVM_SETCOLOMNWIDTH
Global LVSCW_AUTOSIZE           := -1
Global LVSCW_AUTOSIZE_USEHEADER := -2
; LVM_SETITEMCOUNT
Global LVSICF_NOINVALIDATEALL  := 0x00000001
Global LVSICF_NOSCROLL         := 0x00000002
; LVM_SETWORKAREAS
Global LV_MAX_WORKAREAS        := 16
; LVBKIMAGE ulFlags
Global LVBKIF_FLAG_ALPHABLEND  := 0x20000000
Global LVBKIF_FLAG_TILEOFFSET  := 0x00000100
Global LVBKIF_SOURCE_HBITMAP   := 0x00000001
Global LVBKIF_SOURCE_MASK      := 0x00000003
Global LVBKIF_SOURCE_NONE      := 0x00000000
Global LVBKIF_SOURCE_URL       := 0x00000002
Global LVBKIF_STYLE_MASK       := 0x00000010
Global LVBKIF_STYLE_NORMAL     := 0x00000000
Global LVBKIF_STYLE_TILE       := 0x00000010
Global LVBKIF_TYPE_WATERMARK   := 0x10000000
; LVM_GET/SETVIEW
Global LV_VIEW_DETAILS         := 0x0001
Global LV_VIEW_ICON            := 0x0000
Global LV_VIEW_LIST            := 0x0003
Global LV_VIEW_MAX             := 0x0004
Global LV_VIEW_SMALLICON       := 0x0002
Global LV_VIEW_TILE            := 0x0004
; LVGROUP mask
Global LVGF_ALIGN              := 0x00000008
Global LVGF_DESCRIPTIONBOTTOM  := 0x00000800    ; >= Vista  pszDescriptionBottom is valid
Global LVGF_DESCRIPTIONTOP     := 0x00000400    ; >= Vista  pszDescriptionTop is valid
Global LVGF_EXTENDEDIMAGE      := 0x00002000    ; >= Vista  iExtendedImage is valid
Global LVGF_FOOTER             := 0x00000002
Global LVGF_GROUPID            := 0x00000010
Global LVGF_HEADER             := 0x00000001
Global LVGF_ITEMS              := 0x00004000    ; >= Vista  iFirstItem and cItems are valid
Global LVGF_NONE               := 0x00000000
Global LVGF_STATE              := 0x00000004
Global LVGF_SUBSET             := 0x00008000    ; >= Vista  pszSubsetTitle is valid
Global LVGF_SUBSETITEMS        := 0x00010000    ; >= Vista  readonly, cItems holds count of items in visible subset, iFirstItem is valid
Global LVGF_SUBTITLE           := 0x00000100    ; >= Vista  pszSubtitle is valid
Global LVGF_TASK               := 0x00000200    ; >= Vista  pszTask is valid
Global LVGF_TITLEIMAGE         := 0x00001000    ; >= Vista  iTitleImage is valid
; LVGROUP state
Global LVGS_COLLAPSED          := 0x00000001
Global LVGS_COLLAPSIBLE        := 0x00000008    ; >= Vista ?
Global LVGS_FOCUSED            := 0x00000010    ; >= Vista ?
Global LVGS_HIDDEN             := 0x00000002
Global LVGS_NOHEADER           := 0x00000004    ; >= Vista ?
Global LVGS_NORMAL             := 0x00000000
Global LVGS_SELECTED           := 0x00000020    ; >= Vista ?
Global LVGS_SUBSETED           := 0x00000040    ; >= Vista ?
Global LVGS_SUBSETLINKFOCUSED  := 0x00000080    ; >= Vista ?
; LVGROUP uAlign
Global LVGA_FOOTER_CENTER      := 0x00000010
Global LVGA_FOOTER_LEFT        := 0x00000008
Global LVGA_FOOTER_RIGHT       := 0x00000020    ; Don't forget to validate exclusivity
Global LVGA_HEADER_CENTER      := 0x00000002
Global LVGA_HEADER_LEFT        := 0x00000001
Global LVGA_HEADER_RIGHT       := 0x00000004    ; Don't forget to validate exclusivity
; LVM_GETGROUPRECT
Global LVGGR_GROUP             := 0             ; Entire expanded group
Global LVGGR_HEADER            := 1             ; Header only (collapsed group)
Global LVGGR_LABEL             := 2             ; Label only
Global LVGGR_SUBSETLINK        := 3             ; subset link only
; LVGROUPMETRICS mask
Global LVGMF_BORDERCOLOR       := 0x00000002
Global LVGMF_BORDERSIZE        := 0x00000001
Global LVGMF_NONE              := 0x00000000
Global LVGMF_TEXTCOLOR         := 0x00000004
; LVTILEVIEWINFO dwMask
Global LVTVIM_COLUMNS          := 0x00000002
Global LVTVIM_LABELMARGIN      := 0x00000004
Global LVTVIM_TILESIZE         := 0x00000001
; LVTILEVIEWINFO dwFlags
Global LVTVIF_AUTOSIZE         := 0x00000000
Global LVTVIF_EXTENDED         := 0x00000004    ; >= Vista
Global LVTVIF_FIXEDHEIGHT      := 0x00000002
Global LVTVIF_FIXEDSIZE        := 0x00000003
Global LVTVIF_FIXEDWIDTH       := 0x00000001
; LVINSERTMARK dwFlags
Global LVIM_AFTER              := 0x00000001    ; TRUE = insert After iItem, otherwise before
; LVFOOTERINFO mask (>= Vista)
Global LVFF_ITEMCOUNT          := 0x00000001
; LVFOOTERITEM (>= Vista)
Global LVFIF_STATE             := 0x00000002
Global LVFIF_TEXT              := 0x00000001
; footer item state
Global LVFIS_FOCUSED           := 0x0001
; NMITEMACTIVATE uKeyFlags
Global LVKF_ALT                := 0x0001
Global LVKF_CONTROL            := 0x0002
Global LVKF_SHIFT              := 0x0004
; NMLVCUSTOMDRAW
; dwItemType
Global LVCDI_GROUP             := 0x00000001
Global LVCDI_ITEM              := 0x00000000
Global LVCDI_ITEMSLIST         := 0x00000002
; ListView custom draw return values
Global LVCDRF_NOGROUPFRAME     := 0x00020000
Global LVCDRF_NOSELECT         := 0x00010000
; NMLVGETINFOTIP dwFlag
Global LVGIT_UNFOLDED          := 0x0001
; LVN_INCREMENTALSEARCH LVFINDINFO lParam
Global LVNSCH_DEFAULT          := -1
Global LVNSCH_ERROR            := -2
Global LVNSCH_IGNORE           := -3
; NMLVEMPTYMARKUP dwFlags ( >= Vista)
Global EMF_CENTERED            := 0x00000001    ; render markup centered in the listview area
Global L_MAX_URL_LENGTH        := 2083          ; (2048 + 32 + sizeof("://"))
; ======================================================================================================================