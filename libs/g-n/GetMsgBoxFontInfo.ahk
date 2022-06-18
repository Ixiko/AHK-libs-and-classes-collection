GetMsgBoxFontInfo(ByRef Name:="", ByRef Size:=0, ByRef Weight:=0, ByRef IsItalic:=0) {
	; Reference: http://ahkscript.org/boards/viewtopic.php?f=6&t=9122
	; https://autohotkey.com/boards/viewtopic.php?f=6&t=9043
   ; SystemParametersInfo constant for retrieving the metrics associated with the nonclient area of nonminimized windows
   static SPI_GETNONCLIENTMETRICS := 0x0029

   static NCM_Size        := 40 + 5*(A_IsUnicode ? 92 : 60)   ; Size of NONCLIENTMETRICS structure (not including iPaddedBorderWidth)
   static MsgFont_Offset  := 40 + 4*(A_IsUnicode ? 92 : 60)   ; Offset for lfMessageFont in NONCLIENTMETRICS structure
   static Size_Offset     := 0    ; Offset for cbSize in NONCLIENTMETRICS structure

   static Height_Offset   := 0    ; Offset for lfHeight in LOGFONT structure
   static Weight_Offset   := 16   ; Offset for lfWeight in LOGFONT structure
   static Italic_Offset   := 20   ; Offset for lfItalic in LOGFONT structure
   static FaceName_Offset := 28   ; Offset for lfFaceName in LOGFONT structure
   static FACESIZE        := 32   ; Size of lfFaceName array in LOGFONT structure
                                  ; Maximum number of characters in font name string

   VarSetCapacity(NCM, NCM_Size, 0)              ; Set the size of the NCM structure and initialize it
   NumPut(NCM_Size, &NCM, Size_Offset, "UInt")   ; Set the cbSize element of the NCM structure
   ; Get the system parameters and store them in the NONCLIENTMETRICS structure (NCM)
   if !DllCall("SystemParametersInfo"            ; If the SystemParametersInfo function returns a NULL value ...
             , "UInt", SPI_GETNONCLIENTMETRICS
             , "UInt", NCM_Size
             , "Ptr", &NCM
             , "UInt", 0)                        ; Don't update the user profile
      Return false                               ; Return false
   Name   := StrGet(&NCM + MsgFont_Offset + FaceName_Offset, FACESIZE)          ; Get the font name
   Height := NumGet(&NCM + MsgFont_Offset + Height_Offset, "Int")               ; Get the font height
   Size   := DllCall("MulDiv", "Int", -Height, "Int", 72, "Int", A_ScreenDPI)   ; Convert the font height to the font size in points
   ; Reference: http://stackoverflow.com/questions/2944149/converting-logfont-height-to-font-size-in-points
   Weight   := NumGet(&NCM + MsgFont_Offset + Weight_Offset, "Int")             ; Get the font weight (400 is normal and 700 is bold)
   IsItalic := NumGet(&NCM + MsgFont_Offset + Italic_Offset, "UChar")           ; Get the italic state of the font
   Return true
}