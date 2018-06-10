; ======================================================================================================================
; Function:          Constants for ComboBoxEx controls.
;                    ComboBoxEx controls are combo box controls that provide native support for item images.
; AHK version:       1.1.05+
; Language:          English
; Version:           1.0.00.00/2012-05-20/just me
; MSDN:              http://msdn.microsoft.com/en-us/library/bb775740(VS.85).aspx
;                    Look at this documents to see which ComboBox constants can be used also with ComboBoxEx controls.
; ======================================================================================================================
; CBEN_FIRST = -800
; WM_USER    = 0x0400
; ======================================================================================================================
; Class ================================================================================================================
Global WC_COMBOBOXEX            := "ComboBoxEx32"
; Messages =============================================================================================================
Global CBEM_DELETEITEM         := 0x0144 ; CB_DELETESTRING
Global CBEM_GETCOMBOCONTROL    := 0x0406 ; (WM_USER + 6)
Global CBEM_GETEDITCONTROL     := 0x0407 ; (WM_USER + 7)
Global CBEM_GETEXSTYLE         := 0x0409 ; (WM_USER + 9)  // use GETEXTENDEDSTYLE instead
Global CBEM_GETEXTENDEDSTYLE   := 0x0409 ; (WM_USER + 9)
Global CBEM_GETIMAGELIST       := 0x0403 ; (WM_USER + 3)
Global CBEM_GETITEMA           := 0x0404 ; (WM_USER + 4)
Global CBEM_GETITEMW           := 0x040D ; (WM_USER + 13)
Global CBEM_GETUNICODEFORMAT   := 0x2005 ; CCM_GETUNICODEFORMAT
Global CBEM_HASEDITCHANGED     := 0x040A ; (WM_USER + 10)
Global CBEM_INSERTITEMA        := 0x0401 ; (WM_USER + 1)
Global CBEM_INSERTITEMW        := 0x040B ; (WM_USER + 11)
Global CBEM_SETEXSTYLE         := 0x0408 ; (WM_USER + 8)  // use  SETEXTENDEDSTYLE instead
Global CBEM_SETEXTENDEDSTYLE   := 0x040E ; (WM_USER + 14) // lparam == new style, wParam (optional) == mask
Global CBEM_SETIMAGELIST       := 0x0402 ; (WM_USER + 2)
Global CBEM_SETITEMA           := 0x0405 ; (WM_USER + 5)
Global CBEM_SETITEMW           := 0x040C ; (WM_USER + 12)
Global CBEM_SETUNICODEFORMAT   := 0x2004 ; CCM_SETUNICODEFORMAT
Global CBEM_SETWINDOWTHEME     := 0x200B ; CCM_SETWINDOWTHEME
; Notifications ========================================================================================================
Global CBEN_BEGINEDIT          := -804   ; (CBEN_FIRST - 4)
Global CBEN_DELETEITEM         := -802   ; (CBEN_FIRST - 2)
Global CBEN_DRAGBEGINA         := -808   ; (CBEN_FIRST - 8)
Global CBEN_DRAGBEGINW         := -809   ; (CBEN_FIRST - 9)
Global CBEN_ENDEDITA           := -805   ; (CBEN_FIRST - 5)
Global CBEN_ENDEDITW           := -806   ; (CBEN_FIRST - 6)
Global CBEN_GETDISPINFOA       := -800   ; (CBEN_FIRST - 0)
Global CBEN_GETDISPINFOW       := -807   ; (CBEN_FIRST - 7)
Global CBEN_INSERTITEM         := -801   ; (CBEN_FIRST - 1)
;      NM_SETURSOR             see Const_Controls.ahk
; ExStyles =============================================================================================================
Global CBES_EX_CASESENSITIVE     := 0x0010
Global CBES_EX_NOEDITIMAGE       := 0x0001
Global CBES_EX_NOEDITIMAGEINDENT := 0x0002
Global CBES_EX_NOSIZELIMIT       := 0x0008
Global CBES_EX_PATHWORDBREAKPROC := 0x0004
Global CBES_EX_TEXTENDELLIPSIS   := 0x0020 ; Vista+
; Others ===============================================================================================================
; COMBOBOXEXITEM mask
Global CBEIF_TEXT              := 0x00000001
Global CBEIF_IMAGE             := 0x00000002
Global CBEIF_SELECTEDIMAGE     := 0x00000004
Global CBEIF_OVERLAY           := 0x00000008
Global CBEIF_INDENT            := 0x00000010
Global CBEIF_LPARAM            := 0x00000020
Global CBEIF_DI_SETITEM        := 0x10000000
; NMCBEENDEDIT iWhy
Global CBENF_DROPDOWN          := 4
Global CBENF_ESCAPE            := 3
Global CBENF_KILLFOCUS         := 1
Global CBENF_RETURN            := 2
; Max string length (characters)
Global CBEMAXSTRLEN            := 260
; ======================================================================================================================