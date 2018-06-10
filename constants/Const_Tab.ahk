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
Global WC_TAB                := "SysTabControl32"
; Messages =============================================================================================================
Global TCM_ADJUSTRECT        := 0x1328 ; (TCM_FIRST + 40)
Global TCM_DELETEALLITEMS    := 0x1309 ; (TCM_FIRST + 9)
Global TCM_DELETEITEM        := 0x1308 ; (TCM_FIRST + 8)
Global TCM_DESELECTALL       := 0x1332 ; (TCM_FIRST + 50)
Global TCM_GETCURFOCUS       := 0x132F ; (TCM_FIRST + 47)
Global TCM_GETCURSEL         := 0x130B ; (TCM_FIRST + 11)
Global TCM_GETEXTENDEDSTYLE  := 0x1335 ; (TCM_FIRST + 53)
Global TCM_GETIMAGELIST      := 0x1302 ; (TCM_FIRST + 2)
Global TCM_GETITEMA          := 0x1305 ; (TCM_FIRST + 5)
Global TCM_GETITEMCOUNT      := 0x1304 ; (TCM_FIRST + 4)
Global TCM_GETITEMRECT       := 0x130A ; (TCM_FIRST + 10)
Global TCM_GETITEMW          := 0x133C ; (TCM_FIRST + 60)
Global TCM_GETROWCOUNT       := 0x132C ; (TCM_FIRST + 44)
Global TCM_GETTOOLTIPS       := 0x132D ; (TCM_FIRST + 45)
Global TCM_GETUNICODEFORMAT  := 0x2006 ; (CCM_FIRST + 6)  CCM_GETUNICODEFORMAT
Global TCM_HIGHLIGHTITEM     := 0x1333 ; (TCM_FIRST + 51)
Global TCM_HITTEST           := 0x130D ; (TCM_FIRST + 13)
Global TCM_INSERTITEMA       := 0x1307 ; (TCM_FIRST + 7)
Global TCM_INSERTITEMW       := 0x133E ; (TCM_FIRST + 62)
Global TCM_REMOVEIMAGE       := 0x132A ; (TCM_FIRST + 42)
Global TCM_SETCURFOCUS       := 0x1330 ; (TCM_FIRST + 48)
Global TCM_SETCURSEL         := 0x130C ; (TCM_FIRST + 12)
Global TCM_SETEXTENDEDSTYLE  := 0x1334 ; (TCM_FIRST + 52) optional wParam == mask
Global TCM_SETIMAGELIST      := 0x1303 ; (TCM_FIRST + 3)
Global TCM_SETITEMA          := 0x1306 ; (TCM_FIRST + 6)
Global TCM_SETITEMEXTRA      := 0x130E ; (TCM_FIRST + 14)
Global TCM_SETITEMSIZE       := 0x1329 ; (TCM_FIRST + 41)
Global TCM_SETITEMW          := 0x133D ; (TCM_FIRST + 61)
Global TCM_SETMINTABWIDTH    := 0x1331 ; (TCM_FIRST + 49)
Global TCM_SETPADDING        := 0x132B ; (TCM_FIRST + 43)
Global TCM_SETTOOLTIPS       := 0x132E ; (TCM_FIRST + 46)
Global TCM_SETUNICODEFORMAT  := 0x2005 ; (CCM_FIRST + 5)  CCM_SETUNICODEFORMAT
; Notifications ========================================================================================================
Global TCN_FOCUSCHANGE       := -554   ; (TCN_FIRST - 4)
Global TCN_GETOBJECT         := -553   ; (TCN_FIRST - 3)
Global TCN_KEYDOWN           := -550   ; (TCN_FIRST - 0)
Global TCN_SELCHANGE         := -551   ; (TCN_FIRST - 1)
Global TCN_SELCHANGING       := -552   ; (TCN_FIRST - 2)
; Styles ===============================================================================================================
Global TCS_BOTTOM            := 0x0002
Global TCS_BUTTONS           := 0x0100
Global TCS_FIXEDWIDTH        := 0x0400
Global TCS_FLATBUTTONS       := 0x0008
Global TCS_FOCUSNEVER        := 0x8000
Global TCS_FOCUSONBUTTONDOWN := 0x1000
Global TCS_FORCEICONLEFT     := 0x0010
Global TCS_FORCELABELLEFT    := 0x0020
Global TCS_HOTTRACK          := 0x0040
Global TCS_MULTILINE         := 0x0200
Global TCS_MULTISELECT       := 0x0004 ; allow multi-select in button mode
Global TCS_OWNERDRAWFIXED    := 0x2000
Global TCS_RAGGEDRIGHT       := 0x0800
Global TCS_RIGHT             := 0x0002
Global TCS_RIGHTJUSTIFY      := 0x0000
Global TCS_SCROLLOPPOSITE    := 0x0001 ; assumes multiline tab
Global TCS_SINGLELINE        := 0x0000
Global TCS_TABS              := 0x0000
Global TCS_TOOLTIPS          := 0x4000
Global TCS_VERTICAL          := 0x0080
; ExStyles =============================================================================================================
Global TCS_EX_FLATSEPARATORS := 0x00000001
Global TCS_EX_REGISTERDROP   := 0x00000002
; Errors and Other =====================================================================================================
; TCITEM mask
Global TCIF_IMAGE            := 0x0002
Global TCIF_PARAM            := 0x0008
Global TCIF_RTLREADING       := 0x0004
Global TCIF_STATE            := 0x0010
Global TCIF_TEXT             := 0x0001
; TCITEM dwState
Global TCIS_BUTTONPRESSED    := 0x0001
Global TCIS_HIGHLIGHTED      := 0x0002
; TCHITTESTINFO flags
Global TCHT_NOWHERE          := 0x0001
Global TCHT_ONITEMICON       := 0x0002
Global TCHT_ONITEMLABEL      := 0x0004
Global TCHT_ONITEM           := 0x0006 ; (TCHT_ONITEMICON | TCHT_ONITEMLABEL)
; ======================================================================================================================