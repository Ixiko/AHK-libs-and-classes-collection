#NoEnv
SetBatchLines, -1
#Include WIA.ahk
; ----------------------------------------------------------------------------------------------------------------------
PicW := 400          ; Pic conrol's width
PicH := 240          ; Pic control's height
NewW := PicW // 10   ; image width
NewH := PicH // 10   ; imag height
; Set the ARGB values (alpha will be ignored)
ARGB := [0xFFFFFF, 0xFF0000, 0x00FF00 , 0x0000FF, 0x000000]
; Create a new image
ImgObj := WIA_CreateImage(NewW, NewW, ARGB)
; Scale the image, might produce surprising effects
Scaled := WIA_ScaleImage(ImgObj, PicW, PicH)
; ----------------------------------------------------------------------------------------------------------------------
Gui, Margin, 20, 20
Gui, Color, Black
Gui, Add, Text, cWhite, Scaled by the control to %PicW%x%PicH%:
Gui, Add, Pic, xm y+2 w%PicW% h%PicH% hwndHPIC1 +0x4E
; Get the bitmap data of the new image, the bitmap will be scaled by the control
PicObj1 := WIA_GetImageBitmap(ImgObj)
; Get the HBITMAP handle
HBM := PicObj.Handle
; STM_SETIMAGE message: Set the control's image.
SendMessage, 0x172, 0, % PicObj1.Handle, , ahk_id %HPIC1%
Gui, Add, Text, ym cWhite, Scaled by WIA_ScaleImage() to %PicW%x%PicH%:
Gui, Add, Pic, xp y+2 w%PicW% h%PicH% hwndHPIC2 +0x4E
; Get the bitmap data of the scaled image
PicObj2 := WIA_GetImageBitmap(Scaled)
; STM_SETIMAGE message: Set the control's image.
SendMessage, 0x172, 0, % PicObj2.Handle, , ahk_id %HPIC2%
Gui, Show, AutoSize, WIA_CreateImage() Sample
Return
; ======================================================================================================================
GuiClose:
ExitApp