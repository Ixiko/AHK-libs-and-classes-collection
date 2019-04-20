; =========================================

#Include GPF_v1.1c.ahk

var_ObjNumber := 0 ; ------------ from 0 to 4
var_PosX := 420 ; --------------- text X position
var_PosY := 230 ; --------------- text Y position
;   var_SizeX := 500 ; ---------- X multiline field size
;   var_SizeY := 500 ; ---------- Y multiline field size
var_TextLine := "LineTest1!" ;--- text
var_ARGB := 0xFF000000 ; -------- Alpha,Red,Green,Blue
var_UseBlackBG := 0 ; ----------- boolean, use black background
var_UseBold := 1 ; -------------- boolean, use bold text
var_FontSize := 20 ; ------------ font size (in units)
var_FontFamily := 0 ; ----------- 0 = SWISS (proportional) --- 1 = MODERN (monospace)
var_ShowText := 0 ; ------------- boolean, show text or not

Return

; =========================================

; F12 toggles the overlayed text by toggling
; library loaded or not via GPF_Main()
F12::

; If not loaded, open/load library, otherwise close/free library
;
; Return values for GPF_Main():
;  1 = Success (load library)
; -1 = Fail (load library)
;  2 = Sucess (free library)
; -2 = Fail (free library)

GPF_Main()

; If library isn't loaded at this point, other
; functions will return ErrorLevel different
; than 0 and will simply not work (as expected).

; Boolean for showing text TRUE
var_ShowText := 1

; Current var_ObjNumer is 0, so it sets the data of the first SingLine Text Field
GPF_SetSingleLine(var_ObjNumber,var_PosX,var_PosY,var_TextLine,var_ARGB,var_UseBlackBG,var_FontSize,var_UseBold,var_FontFamily)

; Shows the SingleLine Text Field number 0 (the first one)
GPF_ShowSingleLine(var_ObjNumber,var_ShowText)

Sleep, 1000

; Now previous text will be replaced by a new one
GPF_SetSingleLine(var_ObjNumber,var_PosX,var_PosY,"Test number 2!",var_ARGB,var_UseBlackBG,var_FontSize,var_UseBold,var_FontFamily)

Return

; =========================================