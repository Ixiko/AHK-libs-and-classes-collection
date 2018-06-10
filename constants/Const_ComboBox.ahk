; ======================================================================================================================
; Function:         Constants for ComboBox controls (ComboBox, DropDownList)
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-04-01/just me
;                   1.0.01.00/2012-05-30/just me - Added DDL_ constants for CB_DIR
; ======================================================================================================================
; CBM_FIRST = 0x1700
; ======================================================================================================================
; Class ================================================================================================================
Global WC_COMBOBOX              := "ComboBox"
; Messages =============================================================================================================
Global CB_ADDSTRING             := 0x0143
Global CB_DELETESTRING          := 0x0144
Global CB_DIR                   := 0x0145
Global CB_FINDSTRING            := 0x014C
Global CB_FINDSTRINGEXACT       := 0x0158
Global CB_GETCOMBOBOXINFO       := 0x0164
Global CB_GETCOUNT              := 0x0146
Global CB_GETCUEBANNER          := 0x1704 ; (CBM_FIRST + 4)
Global CB_GETCURSEL             := 0x0147
Global CB_GETDROPPEDCONTROLRECT := 0x0152
Global CB_GETDROPPEDSTATE       := 0x0157
Global CB_GETDROPPEDWIDTH       := 0x015F
Global CB_GETEDITSEL            := 0x0140
Global CB_GETEXTENDEDUI         := 0x0156
Global CB_GETHORIZONTALEXTENT   := 0x015D
Global CB_GETITEMDATA           := 0x0150
Global CB_GETITEMHEIGHT         := 0x0154
Global CB_GETLBTEXT             := 0x0148
Global CB_GETLBTEXTLEN          := 0x0149
Global CB_GETLOCALE             := 0x015A
Global CB_GETMINVISIBLE         := 0x1702 ; (CBM_FIRST + 2)
Global CB_GETTOPINDEX           := 0x015B
Global CB_INITSTORAGE           := 0x0161
Global CB_INSERTSTRING          := 0x014A
Global CB_LIMITTEXT             := 0x0141
Global CB_MULTIPLEADDSTRING     := 0x0163
Global CB_RESETCONTENT          := 0x014B
Global CB_SELECTSTRING          := 0x014D
Global CB_SETCUEBANNER          := 0x1703 ; (CBM_FIRST + 3)
Global CB_SETCURSEL             := 0x014E
Global CB_SETDROPPEDWIDTH       := 0x0160
Global CB_SETEDITSEL            := 0x0142
Global CB_SETEXTENDEDUI         := 0x0155
Global CB_SETHORIZONTALEXTENT   := 0x015E
Global CB_SETITEMDATA           := 0x0151
Global CB_SETITEMHEIGHT         := 0x0153
Global CB_SETLOCALE             := 0x0159
Global CB_SETMINVISIBLE         := 0x1701 ; (CBM_FIRST + 1)
Global CB_SETTOPINDEX           := 0x015C
Global CB_SHOWDROPDOWN          := 0x014F
; Notifications ========================================================================================================
Global CBN_CLOSEUP              := 8
Global CBN_DBLCLK               := 2
Global CBN_DROPDOWN             := 7
Global CBN_EDITCHANGE           := 5
Global CBN_EDITUPDATE           := 6
Global CBN_ERRSPACE             := -1
Global CBN_KILLFOCUS            := 4
Global CBN_SELCHANGE            := 1
Global CBN_SELENDCANCEL         := 10
Global CBN_SELENDOK             := 9
Global CBN_SETFOCUS             := 3
; Styles ===============================================================================================================
Global CBS_AUTOHSCROLL          := 0x0040
Global CBS_DISABLENOSCROLL      := 0x0800
Global CBS_DROPDOWN             := 0x0002
Global CBS_DROPDOWNLIST         := 0x0003
Global CBS_HASSTRINGS           := 0x0200
Global CBS_LOWERCASE            := 0x4000
Global CBS_NOINTEGRALHEIGHT     := 0x0400
Global CBS_OEMCONVERT           := 0x0080
Global CBS_OWNERDRAWFIXED       := 0x0010
Global CBS_OWNERDRAWVARIABLE    := 0x0020
Global CBS_SIMPLE               := 0x0001
Global CBS_SORT                 := 0x0100
Global CBS_UPPERCASE            := 0x2000
; Others ===============================================================================================================
; ComboBox return values
Global CB_OKAY                  := 0
Global CB_ERR                   := -1
Global CB_ERRSPACE              := -2
; CB_DIR, LB_DIR, DlgDirList(), DlgDirListComboBox()
Global DDL_ARCHIVE              := 0x0020 ; Includes archived files.
Global DDL_DIRECTORY            := 0x0010 ; Includes subdirectories.
                                          ; Subdirectory names are enclosed in square brackets ([ ]).
Global DDL_DRIVES               := 0x4000 ; All mapped drives are added to the list.
                                          ; Drives are listed in the form [- x-], where x is the drive letter.
Global DDL_EXCLUSIVE            := 0x8000 ; Includes only files with the specified attributes. By default,
                                          ; read/write files are listed even if DDL_READWRITE is not specified.
Global DDL_HIDDEN               := 0x0002 ; Includes hidden files.
Global DDL_POSTMSGS             := 0x2000 ; Used with DlgDirList() and DlgDirListComboBox()
Global DDL_READONLY             := 0x0001 ; Includes read-only files.
Global DDL_READWRITE            := 0x0000 ; Includes read/write files with no additional attributes.
                                          ; This is the default setting.
Global DDL_SYSTEM               := 0x0004 ; Includes system files.
; ======================================================================================================================