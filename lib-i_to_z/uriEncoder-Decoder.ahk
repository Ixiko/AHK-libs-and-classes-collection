;----------
; 2010 URI encoder/decoder gui
; http://autohotkey.net/~gahks
;
; functions by Titam
; http://www.autohotkey.com/forum/topic18876.html#119507
;----------
;VARS
;----------
edit_width = 600 ;width of edit controls
edit_height = 300 ;height of edit controls
font_size = 13 ;font size in edit controls
;----------
gui, add, radio, vradio gcode, Encode
gui, add, radio, checked1 gcode, Decode
gui, font, s%font_size%
gui, add, edit, w%edit_width% h%edit_height% gcode vedit1,
gui, add, edit, w%edit_width% h%edit_height% vedit2,
gui, show,, URI Encoder/Decoder GUI
return

code:
gui, submit, nohide
guicontrol,,edit2, % radio=2 ? uriDecode(edit1) : uriEncode(edit1)
return

guiclose:
exitapp

uriDecode(str) {
;by Titam
   Loop
      If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)
         StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
      Else Break
   Return, str
}

uriEncode(str)
{
;by Titam & ESUHSD
   ; Replace characters with uri encoded version except for letters, numbers,
   ; and the following: /.~:&=-
   f = %A_FormatInteger%
   SetFormat, Integer, Hex
   pos = 1
   Loop
      If pos := RegExMatch(str, "i)[^\/\w\.~`:%&=-]", char, pos++)
         StringReplace, str, str, %char%, % "%" . Asc(char), All
      Else Break
   SetFormat, Integer, %f%
   StringReplace, str, str, 0x, , All
   Return, str
}