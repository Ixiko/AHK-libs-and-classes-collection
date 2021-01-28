#SingleInstance ignore
Unidecode("init")

; mark a text with unicode chars and use CTRL+C and CTRL+SHIFT+V (Deutsch: STRG+SHIFT+V) to get an ascii representation of the string.
^+v:: 
Clipboard:= Unidecode(Clipboard,"Ä ä Ö ö Ü ü ß ¥Yen €Eur")
send, ^v
return

#include unidecode.ahk


