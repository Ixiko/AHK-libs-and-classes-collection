;{ GuiButtonIcon
; Fanatic Guru
; 2014 05 31
; Version 2.0
;
; FUNCTION to Assign an Icon to a Gui Button
;
;------------------------------------------------
;
; Method:
;   GuiButtonIcon(Handle, File, Options)
;
;   Parameters:
;   1) {Handle}     HWND handle of Gui button
;   2) {File}       File containing icon image
;   3) {Index}      Index of icon in file
;                       Optional: Default = 1
;   4) {Options}    Single letter flag followed by a number with multiple options delimited by a space
;                       W = Width of Icon (default = 16)
;                       H = Height of Icon (default = 16)
;                       S = Size of Icon, Makes Width and Height both equal to Size
;                       L = Left Margin
;                       T = Top Margin
;                       R = Right Margin
;                       B = Botton Margin
;                       A = Alignment (0 = left, 1 = right, 2 = top, 3 = bottom, 4 = center; default = 4)
;
; Return:
;   1 = icon found, 0 = icon not found
;
; Example:
; Gui, Add, Button, w70 h38 hwndIcon, Save
; GuiButtonIcon(Icon, "shell32.dll", 259, "s30 a1 r2")
; Gui, Show
;
GuiButtonIcon(Handle, File, Index := 1, Options := "") {
    Local W, H, S, L, T, R, B, A, Psz, DW, Ptr
    RegExMatch(Options, "i)w\K\d+", W), (W="") ? W := 16 :
    RegExMatch(Options, "i)h\K\d+", H), (H="") ? H := 16 :
    RegExMatch(Options, "i)s\K\d+", S), S ? W := H := S :
    RegExMatch(Options, "i)l\K\d+", L), (L="") ? L := 0 :
    RegExMatch(Options, "i)t\K\d+", T), (T="") ? T := 0 :
    RegExMatch(Options, "i)r\K\d+", R), (R="") ? R := 0 :
    RegExMatch(Options, "i)b\K\d+", B), (B="") ? B := 0 :
    RegExMatch(Options, "i)a\K\d+", A), (A="") ? A := 4 :
    Psz := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"
    VarSetCapacity( button_il, 20 + Psz, 0 )
    NumPut( normal_il := DllCall( "ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1 ), button_il, 0, Ptr )   ; Width & Height
    NumPut( L, button_il, 0 + Psz, DW )     ; Left Margin
    NumPut( T, button_il, 4 + Psz, DW )     ; Top Margin
    NumPut( R, button_il, 8 + Psz, DW )     ; Right Margin
    NumPut( B, button_il, 12 + Psz, DW )    ; Bottom Margin
    NumPut( A, button_il, 16 + Psz, DW )    ; Alignment
    SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %Handle%
    return IL_Add( normal_il, File, Index )
}
