; ======================================================================================================================
; Function:         Constants for ImageList controls
; AHK version:      1.1.05+
; Language:         English
; Version:          1.0.00.00/2012-07-11/just me
; ======================================================================================================================
; Image List Creation Flags ============================================================================================
Global ILC_COLOR              := 0x00000000
Global ILC_COLOR16            := 0x00000010
Global ILC_COLOR24            := 0x00000018
Global ILC_COLOR32            := 0x00000020
Global ILC_COLOR4             := 0x00000004
Global ILC_COLOR8             := 0x00000008
Global ILC_COLORDDB           := 0x000000FE
Global ILC_HIGHQUALITYSCALE   := 0x00020000  ; Vista+ - Imagelist should enable use of the high quality scaler.
Global ILC_MASK               := 0x00000001
Global ILC_MIRROR             := 0x00002000  ; Mirror the icons contained, if the process is mirrored
Global ILC_ORIGINALSIZE       := 0x00010000  ; Vista+ - Imagelist should accept smaller than set images and
                                             ; apply OriginalSize based on image added
Global ILC_PALETTE            := 0x00000800  ; not implemented
Global ILC_PERITEMMIRROR      := 0x00008000  ; Causes the mirroring code to mirror each item when inserting a set
                                             ; of images, verses the whole strip
; Image List Draw Flags ================================================================================================
Global ILD_ASYNC              := 0x00008000  ; Vista+
Global ILD_BLEND              := 0x00000004  ; ILD_BLEND50
Global ILD_BLEND25            := 0x00000002
Global ILD_BLEND50            := 0x00000004
Global ILD_DPISCALE           := 0x00004000
Global ILD_FOCUS              := 0x00000002  ; ILD_BLEND25
Global ILD_IMAGE              := 0x00000020
Global ILD_MASK               := 0x00000010
Global ILD_NORMAL             := 0x00000000
Global ILD_OVERLAYMASK        := 0x00000F00
Global ILD_PRESERVEALPHA      := 0x00001000  ; This preserves the alpha channel in dest
Global ILD_ROP                := 0x00000040
Global ILD_SCALE              := 0x00002000  ; Causes the image to be scaled to cx, cy instead of clipped
Global ILD_SELECTED           := 0x00000004  ; ILD_BLEND50
Global ILD_TRANSPARENT        := 0x00000001
; Image List State Flags ===============================================================================================
Global ILS_ALPHA              := 0x00000008
Global ILS_GLOW               := 0x00000001
Global ILS_NORMAL             := 0x00000000
Global ILS_SATURATE           := 0x00000004
Global ILS_SHADOW             := 0x00000002
; ImageList_Copy uFlags ================================================================================================
Global ILCF_MOVE              := 0x00000000
Global ILCF_SWAP              := 0x00000001
; ImageList_ReadEx/WriteEx dwFlags =====================================================================================
Global ILP_DOWNLEVEL          := 1           ; Write or reads the stream using downlevel sematics.
Global ILP_NORMAL             := 0           ; Writes or reads the stream using new sematics for this version of comctl32
; Not documented =======================================================================================================
Global ILGT_ASYNC             := 0x00000001  ; Vista+
Global ILGT_NORMAL            := 0x00000000  ; Vista+
; ======================================================================================================================