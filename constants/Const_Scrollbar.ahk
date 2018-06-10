; ======================================================================================================================
; Function:         Constants for Scrollbar controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-05-20/just me
; Remarks:          Although not a built-in AHK GUI control it might be useful anyway.
; ======================================================================================================================
; Class ================================================================================================================
Global WC_SCROLLBAR                := "ScrollBar"
; Messages =============================================================================================================
Global SBM_ENABLE_ARROWS           := 0xE4
Global SBM_GETPOS                  := 0xE1
Global SBM_GETRANGE                := 0xE3
Global SBM_GETSCROLLBARINFO        := 0xEB
Global SBM_GETSCROLLINFO           := 0xEA
Global SBM_SETPOS                  := 0xE0
Global SBM_SETRANGE                := 0xE2
Global SBM_SETRANGEREDRAW          := 0xE6
Global SBM_SETSCROLLINFO           := 0xE9
; Notifications ========================================================================================================
; WM_CTLCOLORSCROLLBAR  -> Const_Windows
; WM_HSCROLL            -> Const_Windows
; WM_VSCROLL            -> Const_Windows
; Styles ===============================================================================================================
Global SBS_BOTTOMALIGN             := 0x04
Global SBS_HORZ                    := 0x00
Global SBS_LEFTALIGN               := 0x02
Global SBS_RIGHTALIGN              := 0x04
Global SBS_SIZEBOX                 := 0x08
Global SBS_SIZEBOXBOTTOMRIGHTALIGN := 0x04
Global SBS_SIZEBOXTOPLEFTALIGN     := 0x02
Global SBS_SIZEGRIP                := 0x10
Global SBS_TOPALIGN                := 0x02
Global SBS_VERT                    := 0x01
; Scrollinfo flags =====================================================================================================
Global SIF_ALL             := 0x1F ; (SIF_RANGE | SIF_PAGE | SIF_POS | SIF_TRACKPOS)
Global SIF_DISABLENOSCROLL := 0x08
Global SIF_PAGE            := 0x02
Global SIF_POS             := 0x04
Global SIF_RANGE           := 0x01
Global SIF_TRACKPOS        := 0x10
; Scrollbar constants =================================================================================================
Global SB_BOTH             := 3
Global SB_CTL              := 2
Global SB_HORZ             := 0
Global SB_VERT             := 1
; Scrollbar commands ===================================================================================================
Global SB_BOTTOM           := 7
Global SB_ENDSCROLL        := 8
Global SB_LEFT             := 6
Global SB_LINEDOWN         := 1
Global SB_LINELEFT         := 0
Global SB_LINERIGHT        := 1
Global SB_LINEUP           := 0
Global SB_PAGEDOWN         := 3
Global SB_PAGELEFT         := 2
Global SB_PAGERIGHT        := 3
Global SB_PAGEUP           := 2
Global SB_RIGHT            := 7
Global SB_THUMBPOSITION    := 4
Global SB_THUMBTRACK       := 5
Global SB_TOP              := 6
; ======================================================================================================================