; =========================================

;
; Example function - f_Change_SL_Text_0
;
; Function to change only the text parameter
; of SingleLine Text Field number 0.
; All other parameters are fixed.
; A static variable checks if text really changed.
; Must have GPF_v1.1c.ahk included, of course.
;

f_Change_SL_Text_0(newText)
{
  static oldText
  if ( oldText = newText )
    return "NoChange"  ;  indicates I'm performing an unecessary attempt to change text
  oldText := newText
  return GPF_SetSingleLine(0,100,100,oldText,0xFFFFFFFF,0,20,1,0)
}

; =========================================