; =========================================
;
; This example shows usage of picture functions
;
; =========================================

#Include GPF_v1.1c.ahk

; -- Picture X position
var_PosX := 100
; -- Picture Y position
var_PosY := 150
; -- Boolean for showing picture
var_ShowPic := 0
; -- Picture to be shown (MUST BE FULL PATH)
var_PicFullPath := "C:\My Folder\This is a full path\picture.png"

Return

; ~~~~~~~~~~~~~~~~~~~~

; -- Pressing F10 will toggle library via GPF_Main()
F10::GPF_Main()

; -- Pressing F11 will set desired picture
F11::GPF_SetPicture(var_PicFullPath)

; -- Pressing F12 will toggle
; picture display once the library
; is loaded and the picture is set
F12::

var_ShowPic := !var_ShowPic

GPF_ShowPicture(var_ShowPic,var_PosX,var_PosY)

Return

; =========================================