; ======================================================================================================================
; Function:         Constants for Header controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-05-20/just me
; Remarks:          Although not a built-in AHK GUI control it might be useful anyway.
; ======================================================================================================================
; HDM_FIRST = 0x1200
; HDN_FIRST = -300
; Class ================================================================================================================
Global WC_HEADER                   := "SysHeader32"
; Messages =============================================================================================================
Global HDM_CLEARFILTER             := 0x1218 ; (HDM_FIRST + 24)
Global HDM_CREATEDRAGIMAGE         := 0x1210 ; (HDM_FIRST + 16) // wparam = which item (by index)
Global HDM_DELETEITEM              := 0x1202 ; (HDM_FIRST + 2)
Global HDM_EDITFILTER              := 0x1217 ; (HDM_FIRST + 23)
Global HDM_GETBITMAPMARGIN         := 0x1215 ; (HDM_FIRST + 21)
Global HDM_GETFOCUSEDITEM          := 0x121B ; (HDM_FIRST + 27) >= Vista
Global HDM_GETIMAGELIST            := 0x1209 ; (HDM_FIRST + 9)
Global HDM_GETITEMA                := 0x1203 ; (HDM_FIRST + 3)
Global HDM_GETITEMCOUNT            := 0x1200 ; (HDM_FIRST + 0)
Global HDM_GETITEMDROPDOWNRECT     := 0x1219 ; (HDM_FIRST + 25) >= Vista  // rect of item's drop down button
Global HDM_GETITEMRECT             := 0x1207 ; (HDM_FIRST + 7)
Global HDM_GETITEMW                := 0x120B ; (HDM_FIRST + 11)
Global HDM_GETORDERARRAY           := 0x1211 ; (HDM_FIRST + 17)
Global HDM_GETOVERFLOWRECT         := 0x121A ; (HDM_FIRST + 26) >= Vista  // rect of overflow button
Global HDM_GETUNICODEFORMAT        := 0x2005 ; CCM_GETUNICODEFORMAT
Global HDM_HITTEST                 := 0x1206 ; (HDM_FIRST + 6)
Global HDM_INSERTITEMA             := 0x1201 ; (HDM_FIRST + 1)
Global HDM_INSERTITEMW             := 0x120A ; (HDM_FIRST + 10)
Global HDM_LAYOUT                  := 0x1205 ; (HDM_FIRST + 5)
Global HDM_ORDERTOINDEX            := 0x120F ; (HDM_FIRST + 15)
Global HDM_SETBITMAPMARGIN         := 0x1214 ; (HDM_FIRST + 20)
Global HDM_SETFILTERCHANGETIMEOUT  := 0x1216 ; (HDM_FIRST + 22)
Global HDM_SETFOCUSEDITEM          := 0x121C ; (HDM_FIRST + 28) >= Vista
Global HDM_SETHOTDIVIDER           := 0x1213 ; (HDM_FIRST + 19)
Global HDM_SETIMAGELIST            := 0x1208 ; (HDM_FIRST + 8)
Global HDM_SETITEMA                := 0x1204 ; (HDM_FIRST + 4)
Global HDM_SETITEMW                := 0x120C ; (HDM_FIRST + 12)
Global HDM_SETORDERARRAY           := 0x1212 ; (HDM_FIRST + 18)
Global HDM_SETUNICODEFORMAT        := 0x2004 ; CCM_SETUNICODEFORMAT
Global HDM_TRANSLATEACCELERATOR    := 0x200A ; ??? -> CCM_TRANSLATEACCELERATOR (not defined !!!)
; Notifications ========================================================================================================
Global HDN_BEGINDRAG           := -310 ; (HDN_FIRST - 10)
Global HDN_BEGINFILTEREDIT     := -314 ; (HDN_FIRST - 14)
Global HDN_BEGINTRACKA         := -306 ; (HDN_FIRST - 6)
Global HDN_BEGINTRACKW         := -326 ; (HDN_FIRST - 26)
Global HDN_DIVIDERDBLCLICKA    := -305 ; (HDN_FIRST - 5)
Global HDN_DIVIDERDBLCLICKW    := -325 ; (HDN_FIRST - 25)
Global HDN_DROPDOWN            := -318 ; (HDN_FIRST - 18) >= Vista
Global HDN_ENDDRAG             := -311 ; (HDN_FIRST - 11)
Global HDN_ENDFILTEREDIT       := -315 ; (HDN_FIRST - 15)
Global HDN_ENDTRACKA           := -307 ; (HDN_FIRST - 7)
Global HDN_ENDTRACKW           := -327 ; (HDN_FIRST - 27)
Global HDN_FILTERBTNCLICK      := -313 ; (HDN_FIRST - 13)
Global HDN_FILTERCHANGE        := -312 ; (HDN_FIRST - 12)
Global HDN_GETDISPINFOA        := -309 ; (HDN_FIRST - 9)
Global HDN_GETDISPINFOW        := -329 ; (HDN_FIRST - 29)
Global HDN_ITEMCHANGEDA        := -301 ; (HDN_FIRST - 1)
Global HDN_ITEMCHANGEDW        := -321 ; (HDN_FIRST - 21)
Global HDN_ITEMCHANGINGA       := -300 ; (HDN_FIRST - 0)
Global HDN_ITEMCHANGINGW       := -320 ; (HDN_FIRST - 20)
Global HDN_ITEMCLICKA          := -302 ; (HDN_FIRST - 2)
Global HDN_ITEMCLICKW          := -322 ; (HDN_FIRST - 22)
Global HDN_ITEMDBLCLICKA       := -303 ; (HDN_FIRST - 3)
Global HDN_ITEMDBLCLICKW       := -323 ; (HDN_FIRST - 23)
Global HDN_ITEMKEYDOWN         := -317 ; (HDN_FIRST - 17) >= Vista
Global HDN_ITEMSTATEICONCLICK  := -316 ; (HDN_FIRST - 16) >= Vista
Global HDN_OVERFLOWCLICK       := -319 ; (HDN_FIRST - 19) >= Vista
Global HDN_TRACKA              := -308 ; (HDN_FIRST - 8)
Global HDN_TRACKW              := -328 ; (HDN_FIRST - 28)
; Styles ===============================================================================================================
Global HDS_BUTTONS             := 0x0002
Global HDS_CHECKBOXES          := 0x0400 ; >= Vista
Global HDS_DRAGDROP            := 0x0040
Global HDS_FILTERBAR           := 0x0100
Global HDS_FLAT                := 0x0200
Global HDS_FULLDRAG            := 0x0080
Global HDS_HIDDEN              := 0x0008
Global HDS_HORZ                := 0x0000
Global HDS_HOTTRACK            := 0x0004
Global HDS_NOSIZING            := 0x0800 ; >= Vista
Global HDS_OVERFLOW            := 0x1000 ; >= Vista
; Others ===============================================================================================================
; HDITEM type
Global HDFT_ISSTRING           := 0x0000 ; // HD_ITEM.pvFilter points to a HD_TEXTFILTER
Global HDFT_ISNUMBER           := 0x0001 ; // HD_ITEM.pvFilter points to a INT
Global HDFT_ISDATE             := 0x0002 ; // HD_ITEM.pvFilter points to a DWORD (dos date)
Global HDFT_HASNOVALUE         := 0x8000 ; // clear the filter, by setting this bit
; HDITEM mask
Global HDI_BITMAP              := 0x0010
Global HDI_DI_SETITEM          := 0x0040
Global HDI_FILTER              := 0x0100
Global HDI_FORMAT              := 0x0004
Global HDI_HEIGHT              := 0x0001 ; HDI_WIDTH
Global HDI_IMAGE               := 0x0020
Global HDI_LPARAM              := 0x0008
Global HDI_ORDER               := 0x0080
Global HDI_STATE               := 0x0200 ; >= Vista
Global HDI_TEXT                := 0x0002
Global HDI_WIDTH               := 0x0001
; HDITEM fmt
Global HDF_BITMAP              := 0x2000
Global HDF_BITMAP_ON_RIGHT     := 0x1000 ; // Same as LVCFMT_BITMAP_ON_RIGHT
Global HDF_CENTER              := 0x0002 ; // Same as LVCFMT_CENTER
Global HDF_CHECKBOX            := 0x00000040 ; >= Vista
Global HDF_CHECKED             := 0x00000080 ; >= Vista
Global HDF_FIXEDWIDTH          := 0x00000100 ; >= Vista // Can't resize the column; same as LVCFMT_FIXED_WIDTH
Global HDF_IMAGE               := 0x0800 ; // Same as LVCFMT_IMAGE
Global HDF_JUSTIFYMASK         := 0x0003 ; // Same as LVCFMT_JUSTIFYMASK
Global HDF_LEFT                := 0x0000 ; // Same as LVCFMT_LEFT
Global HDF_OWNERDRAW           := 0x8000 ; // Same as LVCFMT_COL_HAS_IMAGES
Global HDF_RIGHT               := 0x0001 ; // Same as LVCFMT_RIGHT
Global HDF_RTLREADING          := 0x0004 ; // Same as LVCFMT_LEFT
Global HDF_SORTDOWN            := 0x0200
Global HDF_SORTUP              := 0x0400
Global HDF_SPLITBUTTON         := 0x01000000 ; >= Vista // Column is a split button; same as LVCFMT_SPLITBUTTON
Global HDF_STRING              := 0x4000
; HDITEM state
Global HDIS_FOCUSED            := 0x00000001 ; >= Vista
; HDHITTESTINFO flags
Global HHT_ABOVE               := 0x0100
Global HHT_BELOW               := 0x0200
Global HHT_NOWHERE             := 0x0001
Global HHT_ONDIVIDER           := 0x0004
Global HHT_ONDIVOPEN           := 0x0008
Global HHT_ONDROPDOWN          := 0x2000 ; >= Vista
Global HHT_ONFILTER            := 0x0010
Global HHT_ONFILTERBUTTON      := 0x0020
Global HHT_ONHEADER            := 0x0002
Global HHT_ONITEMSTATEICON     := 0x1000 ; >= Vista
Global HHT_ONOVERFLOW          := 0x4000 ; >= Vista
Global HHT_TOLEFT              := 0x0800
Global HHT_TORIGHT             := 0x0400
; HDM_GETIMAGELIST wParam
Global HDSIL_NORMAL            := 0
Global HDSIL_STATE             := 1
; ======================================================================================================================