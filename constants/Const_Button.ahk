; ======================================================================================================================
; Function:         Constants for Button controls (Button, Checkbox, Radio, GroupBox)
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
; ======================================================================================================================
; BCM_FIRST = 0x1600
; BCN_FIRST = -1250
; ======================================================================================================================
; Class ================================================================================================================
Global WC_BUTTON            := "Button"
; Messages =============================================================================================================
Global BCM_GETIDEALSIZE     := 0x1601 ; (BCM_FIRST + 0x0001)
Global BCM_GETIMAGELIST     := 0x1603 ; (BCM_FIRST + 0x0003)
Global BCM_GETNOTE          := 0x160A ; (BCM_FIRST + 0x000A) >= Vista
Global BCM_GETNOTELENGTH    := 0x160B ; (BCM_FIRST + 0x000B) >= Vista
Global BCM_GETSPLITINFO     := 0x1608 ; (BCM_FIRST + 0x0008) >= Vista
Global BCM_GETTEXTMARGIN    := 0x1605 ; (BCM_FIRST + 0x0005)
Global BCM_SETDROPDOWNSTATE := 0x1606 ; (BCM_FIRST + 0x0006) >= Vista
Global BCM_SETIMAGELIST     := 0x1602 ; (BCM_FIRST + 0x0002)
Global BCM_SETNOTE          := 0x1609 ; (BCM_FIRST + 0x0009) >= Vista
Global BCM_SETSHIELD        := 0x160C ; (BCM_FIRST + 0x000C) >= Vista
Global BCM_SETSPLITINFO     := 0x1607 ; (BCM_FIRST + 0x0007) >= Vista
Global BCM_SETTEXTMARGIN    := 0x1604 ; (BCM_FIRST + 0x0004)
Global BM_CLICK             := 0x00F5
Global BM_GETCHECK          := 0x00F0
Global BM_GETIMAGE          := 0x00F6
Global BM_GETSTATE          := 0x00F2
Global BM_SETCHECK          := 0x00F1
Global BM_SETDONTCLICK      := 0x00F8 ; >= Vista
Global BM_SETIMAGE          := 0x00F7
Global BM_SETSTATE          := 0x00F3
Global BM_SETSTYLE          := 0x00F4
; Notifications ========================================================================================================
Global BCN_DROPDOWN         := -1248  ; (BCN_FIRST + 0x0002) >= Vista
Global BCN_HOTITEMCHANGE    := -1249  ; (BCN_FIRST + 0x0001)
Global BN_CLICKED           := 0x0000
Global BN_DBLCLK            := 0x0005 ; BN_DOUBLECLICKED
Global BN_DISABLE           := 0x0004
Global BN_DOUBLECLICKED     := 0x0005
Global BN_HILITE            := 0x0002
Global BN_KILLFOCUS         := 0x0007
Global BN_PAINT             := 0x0001
Global BN_PUSHED            := 0x0002 ; BN_HILITE
Global BN_SETFOCUS          := 0x0006
Global BN_UNHILITE          := 0x0003
Global BN_UNPUSHED          := 0x0003 ; BN_UNHILITE
; Styles ===============================================================================================================
Global BS_3STATE            := 0x0005
Global BS_AUTO3STATE        := 0x0006
Global BS_AUTOCHECKBOX      := 0x0003
Global BS_AUTORADIOBUTTON   := 0x0009
Global BS_BITMAP            := 0x0080
Global BS_BOTTOM            := 0x0800
Global BS_CENTER            := 0x0300
Global BS_CHECKBOX          := 0x0002
Global BS_COMMANDLINK       := 0x000E ; >= Vista
Global BS_DEFCOMMANDLINK    := 0x000F ; >= Vista
Global BS_DEFPUSHBUTTON     := 0x0001
Global BS_DEFSPLITBUTTON    := 0x000D ; >= Vista
Global BS_FLAT              := 0x8000
Global BS_GROUPBOX          := 0x0007
Global BS_ICON              := 0x0040
Global BS_LEFT              := 0x0100
Global BS_LEFTTEXT          := 0x0020
Global BS_MULTILINE         := 0x2000
Global BS_NOTIFY            := 0x4000
Global BS_OWNERDRAW         := 0x000B
Global BS_PUSHBOX           := 0x000A
Global BS_PUSHBUTTON        := 0x0000
Global BS_PUSHLIKE          := 0x1000
Global BS_RADIOBUTTON       := 0x0004
Global BS_RIGHT             := 0x0200
Global BS_RIGHTBUTTON       := 0x0020 ; BS_LEFTTEXT
Global BS_SPLITBUTTON       := 0x000C ; >= Vista
Global BS_TEXT              := 0x0000
Global BS_TOP               := 0x0400
Global BS_TYPEMASK          := 0x000F
Global BS_USERBUTTON        := 0x0008
Global BS_VCENTER           := 0x0C00
; Buton states =========================================================================================================
Global BST_CHECKED          := 0x0001
Global BST_DROPDOWNPUSHED   := 0x0400 ; >= Vista
Global BST_FOCUS            := 0x0008
Global BST_HOT              := 0x0200
Global BST_INDETERMINATE    := 0x0002
Global BST_PUSHED           := 0x0004
Global BST_UNCHECKED        := 0x0000
; Vista SPLIT BUTTON INFO mask flags ===================================================================================
Global BCSIF_GLYPH          := 0x0001
Global BCSIF_IMAGE          := 0x0002
Global BCSIF_SIZE           := 0x0008
Global BCSIF_STYLE          := 0x0004
; Vista SPLIT BUTTON STYLE flags =======================================================================================
Global BCSS_ALIGNLEFT       := 0x0004
Global BCSS_IMAGE           := 0x0008
Global BCSS_NOSPLIT         := 0x0001
Global BCSS_STRETCH         := 0x0002
; Button ImageList Constants ===========================================================================================
Global BUTTON_IMAGELIST_ALIGN_BOTTOM := 0x0003
Global BUTTON_IMAGELIST_ALIGN_CENTER := 0x0004 ; Doesn't draw text
Global BUTTON_IMAGELIST_ALIGN_RIGHT  := 0x0001
Global BUTTON_IMAGELIST_ALIGN_TOP    := 0x0002
; ======================================================================================================================